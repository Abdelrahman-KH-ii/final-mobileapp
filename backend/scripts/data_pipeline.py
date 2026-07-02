"""
Egypt Crop Data Pipeline
========================
End-to-end pipeline for building a multi-year, multi-feature dataset of Egypt's top-10 crops.

Steps:
  1  Extract top-10 crops from CROPGRIDSv1.08 NetCDF maps
  2  Attach SoilGrids (0–5 cm) properties via Google Earth Engine
  3  Attach annual TerraClimate variables (2010–2022)
  4  Add monthly Sentinel-2 indices + SAR backscatter (2017–2024)
  5  Stack per-year backup CSVs (if step 4 was interrupted)
  6a Generate booster dataset (SAR + NDRE per year)
  6b Merge booster into main indices dataset

Usage:
  python backend/scripts/data_pipeline.py --step all
  python backend/scripts/data_pipeline.py --step 1
  python backend/scripts/data_pipeline.py --step 4 --step 6a
  python manage.py run_crop_pipeline --step 3

Required:
  - CROPGRIDSv1.08_NC_maps/ with Countries_2018.nc and crop NetCDF files
  - GEE_PROJECT env var (or .env) with a valid Earth Engine project ID
  - earthengine authenticate (earthengine authenticate)
"""

from __future__ import annotations

import argparse
import glob
import logging
import os
import sys
from pathlib import Path
from typing import Optional

import ee
import numpy as np
import pandas as pd
import xarray as xr
from dotenv import load_dotenv

# Load .env from project root (farmtech_full/.env) and backend/.env
_BACKEND_DIR = Path(__file__).resolve().parent.parent
_PROJECT_ROOT = _BACKEND_DIR.parent
load_dotenv(_PROJECT_ROOT / ".env")
load_dotenv(_BACKEND_DIR / ".env")

# =============================================================================
# CONFIG
# =============================================================================

GEE_PROJECT = os.getenv("GEE_PROJECT", "ee-yasseralsaed777")
EGYPT_COUNTRY_CODE = 57
SENTINEL_YEARS = list(range(2017, 2025))
TERRACLIMATE_YEARS = list(range(2010, 2023))
MONTHS = list(range(1, 13))

CROPGRIDS_FOLDER = os.getenv(
    "CROPGRIDS_FOLDER",
    str(_PROJECT_ROOT / "data" / "CROPGRIDSv1.08_NC_maps"),
)
OUTPUT_DIR = os.getenv(
    "PIPELINE_OUTPUT_DIR",
    str(_PROJECT_ROOT / "data" / "pipeline_outputs"),
)
COUNTRIES_FILE = "Countries_2018.nc"

OUTPUT_V1 = "Egypt_TOP10_CROPGRIDS_1.0.csv"
OUTPUT_V2 = "Egypt_TOP10_CROPGRIDS_2.0.csv"
OUTPUT_V3 = "Egypt_TOP10_CROPGRIDS_3.0.csv"
OUTPUT_MULTIYEAR = "Egypt_TOP10_CROPGRIDS_MultiYear.csv"
OUTPUT_INDICES = "Egypt_TOP10_CROPGRIDS_Indices.csv"
OUTPUT_ENHANCED = "Egypt_TOP10_CROPGRIDS_Enhanced.csv"
OUTPUT_BOOSTER = "FarmTech_Booster.csv"

SOIL_SCALING = {
    "phh2o_0-5cm_mean": 10,
    "soc_0-5cm_mean": 100,
    "clay_0-5cm_mean": 10,
    "sand_0-5cm_mean": 10,
    "nitrogen_0-5cm_mean": 100,
    "cec_0-5cm_mean": 10,
    "bdod_0-5cm_mean": 100,
    "silt_0-5cm_mean": 10,
    "cfvo_0-5cm_mean": 100,
    "ocd_0-5cm_mean": 100,
}

SOIL_RENAME = {
    "phh2o_0-5cm_mean": "soil_ph",
    "soc_0-5cm_mean": "soil_soc",
    "clay_0-5cm_mean": "soil_clay",
    "sand_0-5cm_mean": "soil_sand",
    "nitrogen_0-5cm_mean": "soil_nitrogen",
    "cec_0-5cm_mean": "soil_cec",
    "bdod_0-5cm_mean": "soil_bd",
    "silt_0-5cm_mean": "soil_silt",
    "cfvo_0-5cm_mean": "soil_cfvo",
    "ocd_0-5cm_mean": "soil_ocd",
}

TERRACLIMATE_SCALING = {
    "temp_mean": 10,
    "vpd_mean": 10,
    "srad_mean": 10,
    "wind_mean": 10,
}

FERTILITY_WEIGHTS = {
    "soil_soc": 0.4,
    "soil_nitrogen": 0.3,
    "soil_cec": 0.3,
}

CLAY_THRESHOLD = 35
SAND_THRESHOLD = 60

SOILGRIDS_LAYERS = {
    "projects/soilgrids-isric/phh2o_mean": "phh2o_0-5cm_mean",
    "projects/soilgrids-isric/soc_mean": "soc_0-5cm_mean",
    "projects/soilgrids-isric/clay_mean": "clay_0-5cm_mean",
    "projects/soilgrids-isric/sand_mean": "sand_0-5cm_mean",
    "projects/soilgrids-isric/nitrogen_mean": "nitrogen_0-5cm_mean",
    "projects/soilgrids-isric/cec_mean": "cec_0-5cm_mean",
    "projects/soilgrids-isric/bdod_mean": "bdod_0-5cm_mean",
    "projects/soilgrids-isric/silt_mean": "silt_0-5cm_mean",
    "projects/soilgrids-isric/cfvo_mean": "cfvo_0-5cm_mean",
    "projects/soilgrids-isric/ocd_mean": "ocd_0-5cm_mean",
}

logging.basicConfig(level=logging.INFO, format="%(message)s")
logger = logging.getLogger(__name__)


def _out(name: str) -> str:
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    return os.path.join(OUTPUT_DIR, name)


def init_gee() -> None:
    ee.Initialize(project=GEE_PROJECT)


# =============================================================================
# SHARED UTILITIES
# =============================================================================

def build_feature_collection(fields: pd.DataFrame) -> ee.FeatureCollection:
    features = [
        ee.Feature(
            ee.Geometry.Point([row["lon"], row["lat"]]),
            {"Field_ID": row["Field_ID"]},
        )
        for _, row in fields.iterrows()
    ]
    return ee.FeatureCollection(features)


def sample_image(image: ee.Image, fc: ee.FeatureCollection, scale: int) -> pd.DataFrame:
    samples = image.sampleRegions(collection=fc, scale=scale, geometries=False)
    features = samples.getInfo()["features"]
    return pd.DataFrame([f["properties"] for f in features])


def _month_date_range(year: int, month: int) -> tuple[str, str]:
    start = f"{year}-{month:02d}-01"
    end = f"{year + 1}-01-01" if month == 12 else f"{year}-{month + 1:02d}-01"
    return start, end


def classify_soil_texture(row: pd.Series) -> str:
    if row["soil_clay"] > CLAY_THRESHOLD:
        return "Clay"
    if row["soil_sand"] > SAND_THRESHOLD:
        return "Sandy"
    return "Loam"


def add_agronomic_features(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df["precip_sum"] = df["precip_sum"].clip(lower=0.1)
    df["aet_mean"] = df["aet_mean"].clip(lower=0.1)
    if "soil_moisture" in df.columns:
        df["soil_moisture"] = df["soil_moisture"].clip(lower=0.1)

    df["soil_texture_class"] = df.apply(classify_soil_texture, axis=1)
    df["fertility_index"] = sum(
        df[col] * weight for col, weight in FERTILITY_WEIGHTS.items()
    )

    if "pet_mean" in df.columns:
        df["aridity_index"] = df["precip_sum"] / df["pet_mean"].replace(0, 0.1)

    df["water_balance"] = df["precip_sum"] - df["aet_mean"]
    return df


def apply_soil_scaling(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    for raw_col, divisor in SOIL_SCALING.items():
        if raw_col in df.columns:
            df[raw_col] = df[raw_col] / divisor
    return df.rename(columns=SOIL_RENAME)


def apply_terraclimate_scaling(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    for col, divisor in TERRACLIMATE_SCALING.items():
        if col in df.columns:
            df[col] = df[col] / divisor
    return df


# =============================================================================
# STEP 1 — CROPGRIDS
# =============================================================================

def load_egypt_mask(folder: str) -> xr.DataArray:
    countries_ds = xr.open_dataset(os.path.join(folder, COUNTRIES_FILE))
    return countries_ds["country"] == EGYPT_COUNTRY_CODE


def summarise_egypt_harvested_area(folder: str, egypt_mask: xr.DataArray) -> pd.DataFrame:
    records = []
    for file_path in glob.glob(os.path.join(folder, "*.nc")):
        filename = os.path.basename(file_path)
        if filename == COUNTRIES_FILE:
            continue
        ds = xr.open_dataset(file_path)
        total_area = float(ds["harvarea"].where(egypt_mask).sum().values)
        crop_name = filename.replace("CROPGRIDSv1.08_", "").replace(".nc", "")
        records.append({"Crop": crop_name, "Egypt_HarvestedArea": total_area})
    return (
        pd.DataFrame(records)
        .sort_values("Egypt_HarvestedArea", ascending=False)
        .reset_index(drop=True)
    )


def extract_top_crops_pixelwise(
    folder: str, egypt_mask: xr.DataArray, top_crop_names: list
) -> pd.DataFrame:
    dfs = []
    for crop in top_crop_names:
        file_path = os.path.join(folder, f"CROPGRIDSv1.08_{crop}.nc")
        ds = xr.open_dataset(file_path)
        df_crop = (
            ds["harvarea"]
            .where(egypt_mask)
            .to_dataframe()
            .reset_index()
            .dropna(subset=["harvarea"])
        )
        df_crop["Crop"] = crop
        dfs.append(df_crop)
    return pd.concat(dfs, ignore_index=True)


def build_field_ids(df: pd.DataFrame) -> pd.DataFrame:
    df = df[df["harvarea"] > 0].copy()
    df["Field_ID"] = (
        "F_"
        + df["lat"].round(3).astype(str)
        + "_"
        + df["lon"].round(3).astype(str)
    )
    df["Year"] = 2015
    return (
        df[["Field_ID", "lat", "lon", "Crop", "harvarea", "Year"]]
        .sort_values(["Field_ID", "Crop"])
        .reset_index(drop=True)
    )


def step1_extract_crops() -> None:
    logger.info("=== Step 1: Extract top-10 crops from CROPGRIDS ===")
    if not os.path.exists(os.path.join(CROPGRIDS_FOLDER, COUNTRIES_FILE)):
        raise FileNotFoundError(
            f"Missing {COUNTRIES_FILE} in {CROPGRIDS_FOLDER}. "
            "Place CROPGRIDSv1.08 NetCDF maps there."
        )

    egypt_mask = load_egypt_mask(CROPGRIDS_FOLDER)
    summary_df = summarise_egypt_harvested_area(CROPGRIDS_FOLDER, egypt_mask)
    top10 = summary_df.head(10)
    logger.info("Top 10 crops:\n%s", top10.to_string(index=False))

    raw_df = extract_top_crops_pixelwise(CROPGRIDS_FOLDER, egypt_mask, top10["Crop"].tolist())
    raw_df.to_csv(_out(OUTPUT_V1), index=False)
    logger.info("Saved %s rows → %s", f"{len(raw_df):,}", _out(OUTPUT_V1))

    field_df = build_field_ids(raw_df)
    field_df.to_csv(_out(OUTPUT_V2), index=False)
    logger.info("Saved %s rows → %s", f"{len(field_df):,}", _out(OUTPUT_V2))


# =============================================================================
# STEP 2 — SOILGRIDS
# =============================================================================

def build_soil_stack() -> ee.Image:
    bands = [ee.Image(asset_id).select(band_name) for asset_id, band_name in SOILGRIDS_LAYERS.items()]
    stack = bands[0]
    for band in bands[1:]:
        stack = stack.addBands(band)
    return stack


def step2_soilgrids() -> None:
    logger.info("=== Step 2: SoilGrids via GEE ===")
    init_gee()

    df_v2 = pd.read_csv(_out(OUTPUT_V2))
    fields = df_v2[["Field_ID", "lat", "lon"]].drop_duplicates().reset_index(drop=True)
    fc = build_feature_collection(fields)
    soil_stack = build_soil_stack()

    logger.info("Sampling SoilGrids at %s field locations…", f"{len(fields):,}")
    soil_df = apply_soil_scaling(sample_image(soil_stack, fc, scale=250))
    df_v3 = df_v2.merge(soil_df, on="Field_ID", how="left")
    df_v3.to_csv(_out(OUTPUT_V3), index=False)
    logger.info("Saved %s rows → %s", f"{len(df_v3):,}", _out(OUTPUT_V3))


# =============================================================================
# STEP 3 — TERRACLIMATE
# =============================================================================

def build_annual_climate_image(year: int) -> ee.Image:
    tc = ee.ImageCollection("IDAHO_EPSCOR/TERRACLIMATE").filterDate(
        f"{year}-01-01", f"{year}-12-31"
    )
    return ee.Image.cat([
        tc.select("tmmx").mean().rename("temp_mean"),
        tc.select("pr").sum().rename("precip_sum"),
        tc.select("aet").mean().rename("aet_mean"),
        tc.select("pet").mean().rename("pet_mean"),
        tc.select("def").mean().rename("def_mean"),
        tc.select("soil").mean().rename("soil_moisture"),
        tc.select("vpd").mean().rename("vpd_mean"),
        tc.select("srad").mean().rename("srad_mean"),
        tc.select("vs").mean().rename("wind_mean"),
    ])


def step3_terraclimate() -> None:
    logger.info("=== Step 3: TerraClimate (annual) ===")
    init_gee()

    df_base = pd.read_csv(_out(OUTPUT_V3)).dropna()
    fields = df_base[["Field_ID", "lat", "lon"]].drop_duplicates().reset_index(drop=True)
    fc = build_feature_collection(fields)

    all_years = []
    for year in TERRACLIMATE_YEARS:
        logger.info("  Processing %s…", year)
        climate_df = apply_terraclimate_scaling(
            sample_image(build_annual_climate_image(year), fc, scale=4000)
        )
        df_year = add_agronomic_features(
            df_base.merge(climate_df, on="Field_ID", how="left").assign(Year=year)
        )
        all_years.append(df_year)

    final_multiyear = pd.concat(all_years, ignore_index=True).dropna()
    final_multiyear.to_csv(_out(OUTPUT_MULTIYEAR), index=False)
    logger.info("Saved %s rows → %s", f"{len(final_multiyear):,}", _out(OUTPUT_MULTIYEAR))


# =============================================================================
# STEP 4 — SENTINEL-2 + SAR (monthly)
# =============================================================================

def mask_s2_clouds(image: ee.Image) -> ee.Image:
    qa = image.select("QA60")
    cloud_free = qa.bitwiseAnd(1 << 10).eq(0).And(qa.bitwiseAnd(1 << 11).eq(0))
    return image.updateMask(cloud_free)


def apply_sar_speckle_filter(image: ee.Image) -> ee.Image:
    return image.focal_mean(radius=50, kernelType="circle", units="meters")


def add_vegetation_indices(image: ee.Image) -> ee.Image:
    ndvi = image.normalizedDifference(["B8", "B4"]).rename("ndvi")
    evi = image.expression(
        "2.5 * ((NIR - RED) / (NIR + 6 * RED - 7.5 * BLUE + 1))",
        {"NIR": image.select("B8"), "RED": image.select("B4"), "BLUE": image.select("B2")},
    ).rename("evi")
    lswi = image.normalizedDifference(["B8", "B11"]).rename("lswi")
    ndwi = image.normalizedDifference(["B3", "B8"]).rename("ndwi")
    savi = image.expression(
        "1.5 * ((NIR - RED) / (NIR + RED + 0.5))",
        {"NIR": image.select("B8"), "RED": image.select("B4")},
    ).rename("savi")
    ndre = image.normalizedDifference(["B8", "B5"]).rename("ndre")
    return image.addBands([ndvi, evi, lswi, ndwi, savi, ndre])


def build_s2_monthly(year: int, month: int) -> Optional[ee.Image]:
    start, end = _month_date_range(year, month)
    suffix = f"_m{month:02d}"
    try:
        s2 = (
            ee.ImageCollection("COPERNICUS/S2_SR_HARMONIZED")
            .filterDate(start, end)
            .filter(ee.Filter.lt("CLOUDY_PIXEL_PERCENTAGE", 20))
            .map(mask_s2_clouds)
            .map(add_vegetation_indices)
        )
        median = s2.select(["ndvi", "evi", "lswi", "ndwi", "savi", "ndre"]).median()
        return (
            median.select("ndvi").rename(f"ndvi{suffix}")
            .addBands(median.select("evi").rename(f"evi{suffix}"))
            .addBands(median.select("lswi").rename(f"lswi{suffix}"))
            .addBands(median.select("ndwi").rename(f"ndwi{suffix}"))
            .addBands(median.select("savi").rename(f"savi{suffix}"))
            .addBands(median.select("ndre").rename(f"ndre{suffix}"))
        )
    except Exception as exc:
        logger.warning("S2 error m%02d: %s", month, exc)
        return None


def build_sar_monthly(year: int, month: int) -> Optional[ee.Image]:
    start, end = _month_date_range(year, month)
    suffix = f"_m{month:02d}"
    try:
        s1 = (
            ee.ImageCollection("COPERNICUS/S1_GRD")
            .filterDate(start, end)
            .filter(ee.Filter.eq("instrumentMode", "IW"))
            .filter(ee.Filter.listContains("transmitterReceiverPolarisation", "VV"))
            .filter(ee.Filter.listContains("transmitterReceiverPolarisation", "VH"))
            .filter(ee.Filter.eq("orbitProperties_pass", "DESCENDING"))
            .map(apply_sar_speckle_filter)
        )
        return (
            s1.select("VV").median().rename(f"sar_vv{suffix}")
            .addBands(s1.select("VH").median().rename(f"sar_vh{suffix}"))
        )
    except Exception as exc:
        logger.warning("SAR error m%02d: %s", month, exc)
        return None


def build_tc_monthly(year: int, month: int) -> Optional[ee.Image]:
    start, end = _month_date_range(year, month)
    suffix = f"_m{month:02d}"
    try:
        tc = ee.ImageCollection("IDAHO_EPSCOR/TERRACLIMATE").filterDate(start, end).first()
        return (
            tc.select("tmmx").rename(f"temp{suffix}")
            .addBands(tc.select("pr").rename(f"pr{suffix}"))
            .addBands(tc.select("vpd").rename(f"vpd{suffix}"))
        )
    except Exception as exc:
        logger.warning("TC error m%02d: %s", month, exc)
        return None


def build_annual_tc_extras(year: int) -> Optional[ee.Image]:
    try:
        tc = ee.ImageCollection("IDAHO_EPSCOR/TERRACLIMATE").filterDate(
            f"{year}-01-01", f"{year}-12-31"
        )
        return ee.Image.cat([
            tc.select("aet").mean().rename("aet_mean"),
            tc.select("soil").mean().rename("soil_moisture"),
            tc.select("srad").mean().rename("srad_mean"),
            tc.select("vs").mean().rename("wind_mean"),
        ])
    except Exception as exc:
        logger.warning("Annual TC error: %s", exc)
        return None


def scale_monthly_climate(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    for m in MONTHS:
        for col, divisor in [(f"temp_m{m:02d}", 10), (f"vpd_m{m:02d}", 10)]:
            if col in df.columns:
                df[col] = df[col] / divisor
        pr_col = f"pr_m{m:02d}"
        if pr_col in df.columns:
            df[pr_col] = df[pr_col].clip(lower=0.1)
    return df


def add_annual_summaries(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()

    def _cols(prefix: str) -> list[str]:
        return [f"{prefix}_m{m:02d}" for m in MONTHS if f"{prefix}_m{m:02d}" in df.columns]

    def _seasonal(prefix: str, month_subset: list[int]) -> list[str]:
        return [f"{prefix}_m{m:02d}" for m in month_subset if f"{prefix}_m{m:02d}" in df.columns]

    if _cols("temp"):
        df["temp_mean"] = df[_cols("temp")].mean(axis=1)
    if _cols("pr"):
        df["precip_sum"] = df[_cols("pr")].sum(axis=1)
    if _cols("vpd"):
        df["vpd_mean"] = df[_cols("vpd")].mean(axis=1)

    for prefix in ["ndvi", "evi", "lswi", "ndre"]:
        cols = _cols(prefix)
        if cols:
            df[f"{prefix}_mean"] = df[cols].mean(axis=1)
            df[f"{prefix}_max"] = df[cols].max(axis=1)
            if prefix == "ndvi":
                df["ndvi_min"] = df[cols].min(axis=1)
                df["ndvi_amplitude"] = df["ndvi_max"] - df["ndvi_min"]

    summer_ndre = _seasonal("ndre", [7, 8, 9])
    winter_ndre = _seasonal("ndre", [2, 3, 4])
    if summer_ndre:
        df["summer_ndre_peak"] = df[summer_ndre].max(axis=1)
    if winter_ndre:
        df["winter_ndre_peak"] = df[winter_ndre].max(axis=1)

    vv_cols = _cols("sar_vv")
    vh_cols = _cols("sar_vh")
    if vv_cols:
        df["sar_vv_mean"] = df[vv_cols].mean(axis=1)
    if vh_cols:
        df["sar_vh_mean"] = df[vh_cols].mean(axis=1)
    if vv_cols and vh_cols:
        df["sar_vv_vh_ratio"] = df["sar_vv_mean"] / (df["sar_vh_mean"] + 1e-6)

    summer_vv = _seasonal("sar_vv", [6, 7, 8])
    summer_vh = _seasonal("sar_vh", [7, 8, 9])
    winter_vv = _seasonal("sar_vv", [1, 2, 3, 4])
    winter_vh = _seasonal("sar_vh", [1, 2, 3, 4])
    if summer_vv:
        df["rice_sar_signal"] = -df[summer_vv].mean(axis=1)
    if summer_vh:
        df["maize_sar_signal"] = df[summer_vh].mean(axis=1)
    if winter_vv and winter_vh:
        df["wheat_sar_signal"] = (
            df[winter_vv].mean(axis=1) / (df[winter_vh].mean(axis=1) + 1e-6)
        )
    return df


def process_year_indices(
    year: int,
    df_base: pd.DataFrame,
    fc: ee.FeatureCollection,
) -> Optional[pd.DataFrame]:
    logger.info("--- Processing indices year %s ---", year)
    monthly_dfs: dict[int, pd.DataFrame] = {}

    for month in MONTHS:
        logger.info("  Month %02d…", month)
        available = [
            img
            for img in [
                build_s2_monthly(year, month),
                build_sar_monthly(year, month),
                build_tc_monthly(year, month),
            ]
            if img is not None
        ]
        if not available:
            logger.info("    skipped (no data)")
            continue

        month_stack = available[0]
        for extra in available[1:]:
            month_stack = month_stack.addBands(extra)

        try:
            month_df = sample_image(month_stack, fc, scale=10)
            for prefix in ["ndvi", "evi", "lswi", "ndwi", "savi", "ndre"]:
                col = f"{prefix}_m{month:02d}"
                if col in month_df.columns:
                    month_df[col] = month_df[col].clip(-1, 1)
            monthly_dfs[month] = month_df
        except Exception as exc:
            logger.warning("    sampling error: %s", exc)

    if not monthly_dfs:
        return None

    first = min(monthly_dfs)
    year_df = monthly_dfs[first]
    for month in sorted(monthly_dfs):
        if month == first:
            continue
        year_df = year_df.merge(monthly_dfs[month], on="Field_ID", how="outer")

    year_df = scale_monthly_climate(year_df)
    year_df = df_base.merge(year_df, on="Field_ID", how="left")
    year_df["Year"] = year
    year_df = add_annual_summaries(year_df)

    annual_tc = build_annual_tc_extras(year)
    if annual_tc is not None:
        annual_df = sample_image(annual_tc, fc, scale=4000)
        for col, divisor in [("srad_mean", 10), ("wind_mean", 10)]:
            if col in annual_df.columns:
                annual_df[col] = annual_df[col] / divisor
        for col in ["aet_mean", "soil_moisture"]:
            if col in annual_df.columns:
                annual_df[col] = annual_df[col].clip(lower=0.1)
        year_df = year_df.merge(annual_df, on="Field_ID", how="left")

    year_df = add_agronomic_features(year_df)

    if {"temp_mean", "precip_sum"}.issubset(year_df.columns):
        year_df["temp_precip_ratio"] = year_df["temp_mean"] / (year_df["precip_sum"] + 1)
    if {"soil_clay", "soil_sand"}.issubset(year_df.columns):
        year_df["soil_texture_index"] = year_df["soil_clay"] - year_df["soil_sand"]
    if {"temp_mean", "vpd_mean"}.issubset(year_df.columns):
        year_df["heat_stress"] = year_df["temp_mean"] * year_df["vpd_mean"]
    if {"precip_sum", "soil_moisture"}.issubset(year_df.columns):
        year_df["water_availability"] = year_df["precip_sum"] + year_df["soil_moisture"]

    backup = _out(f"Egypt_Indices_{year}.csv")
    year_df.to_csv(backup, index=False)
    logger.info("  Saved %s rows → %s", f"{len(year_df):,}", backup)
    return year_df


def step4_sentinel_indices() -> None:
    logger.info("=== Step 4: Sentinel-2 + SAR monthly indices ===")
    init_gee()

    df_base = pd.read_csv(_out(OUTPUT_V3)).dropna()
    fields = df_base[["Field_ID", "lat", "lon"]].drop_duplicates().reset_index(drop=True)
    fc = build_feature_collection(fields)

    all_index_years = []
    for year in SENTINEL_YEARS:
        year_df = process_year_indices(year, df_base, fc)
        if year_df is not None:
            all_index_years.append(year_df)

    if not all_index_years:
        raise RuntimeError("No index data collected in step 4.")

    final_indices = pd.concat(all_index_years, ignore_index=True).dropna()
    final_indices.to_csv(_out(OUTPUT_INDICES), index=False)
    logger.info("Saved %s rows → %s", f"{len(final_indices):,}", _out(OUTPUT_INDICES))


# =============================================================================
# STEP 5 — STACK YEAR BACKUPS
# =============================================================================

def stack_year_backups(years: list[int] | None = None) -> pd.DataFrame:
    years = years or SENTINEL_YEARS
    dfs = []
    for year in years:
        path = _out(f"Egypt_Indices_{year}.csv")
        if os.path.exists(path):
            df = pd.read_csv(path)
            logger.info("Loaded %s: %s", year, df.shape)
            dfs.append(df)
        else:
            logger.warning("Missing backup for %s — skipping", year)

    if not dfs:
        raise FileNotFoundError("No per-year backup files found.")

    combined = pd.concat(dfs, ignore_index=True).dropna()
    combined.to_csv(_out(OUTPUT_INDICES), index=False)
    logger.info("Stacked %s rows → %s", f"{len(combined):,}", _out(OUTPUT_INDICES))
    return combined


def step5_stack_backups() -> None:
    logger.info("=== Step 5: Stack per-year backups ===")
    stack_year_backups()


# =============================================================================
# STEP 6a — BOOSTER DATASET
# =============================================================================

def build_ndre_sar_monthly(year: int, month: int) -> Optional[ee.Image]:
    start, end = _month_date_range(year, month)
    suffix = f"_m{month:02d}"
    layers = []

    try:
        s2 = (
            ee.ImageCollection("COPERNICUS/S2_SR_HARMONIZED")
            .filterDate(start, end)
            .filter(ee.Filter.lt("CLOUDY_PIXEL_PERCENTAGE", 20))
            .map(mask_s2_clouds)
            .map(lambda img: img.addBands(
                img.normalizedDifference(["B8", "B5"]).rename("ndre")
            ))
        )
        layers.append(s2.select("ndre").median().rename(f"ndre{suffix}"))
    except Exception as exc:
        logger.warning("NDRE error m%02d: %s", month, exc)

    try:
        s1 = (
            ee.ImageCollection("COPERNICUS/S1_GRD")
            .filterDate(start, end)
            .filter(ee.Filter.eq("instrumentMode", "IW"))
            .filter(ee.Filter.listContains("transmitterReceiverPolarisation", "VV"))
            .filter(ee.Filter.listContains("transmitterReceiverPolarisation", "VH"))
            .filter(ee.Filter.eq("orbitProperties_pass", "DESCENDING"))
            .map(apply_sar_speckle_filter)
        )
        layers.append(s1.select("VV").median().rename(f"sar_vv{suffix}"))
        layers.append(s1.select("VH").median().rename(f"sar_vh{suffix}"))
    except Exception as exc:
        logger.warning("SAR error m%02d: %s", month, exc)

    if not layers:
        return None

    stack = layers[0]
    for layer in layers[1:]:
        stack = stack.addBands(layer)
    return stack


def build_booster_year(
    year: int,
    df_base: pd.DataFrame,
    fc: ee.FeatureCollection,
) -> Optional[pd.DataFrame]:
    logger.info("--- Booster year %s ---", year)
    monthly_dfs: dict[int, pd.DataFrame] = {}

    for month in MONTHS:
        month_stack = build_ndre_sar_monthly(year, month)
        if month_stack is None:
            continue
        try:
            month_df = sample_image(month_stack, fc, scale=100)
            ndre_col = f"ndre_m{month:02d}"
            if ndre_col in month_df.columns:
                month_df[ndre_col] = month_df[ndre_col].clip(-1, 1)
            monthly_dfs[month] = month_df
        except Exception as exc:
            logger.warning("  Month %02d error: %s", month, exc)

    if not monthly_dfs:
        return None

    first = min(monthly_dfs)
    year_df = monthly_dfs[first]
    for month in sorted(monthly_dfs):
        if month == first:
            continue
        year_df = year_df.merge(monthly_dfs[month], on="Field_ID", how="outer")

    year_df["Year"] = year
    year_df = add_annual_summaries(year_df)
    year_df["wapor_landcover"] = None

    backup = _out(f"FarmTech_Boost_{year}.csv")
    year_df.to_csv(backup, index=False)
    logger.info("  Saved %s rows → %s", f"{len(year_df):,}", backup)
    return year_df


def step6a_booster() -> None:
    logger.info("=== Step 6a: Booster dataset (SAR + NDRE) ===")
    booster_path = _out(OUTPUT_BOOSTER)
    if os.path.exists(booster_path):
        logger.info("Booster already exists: %s (delete to regenerate)", booster_path)
        return

    init_gee()
    df_base = pd.read_csv(_out(OUTPUT_V3)).dropna()
    fields = df_base[["Field_ID", "lat", "lon"]].drop_duplicates().reset_index(drop=True)
    fc = build_feature_collection(fields)

    boost_years = []
    for year in SENTINEL_YEARS:
        year_df = build_booster_year(year, df_base, fc)
        if year_df is not None:
            boost_years.append(year_df)

    if not boost_years:
        raise RuntimeError("No booster data collected.")

    booster_df = pd.concat(boost_years, ignore_index=True)
    booster_df.to_csv(booster_path, index=False)
    logger.info("Saved %s rows → %s", f"{len(booster_df):,}", booster_path)


# =============================================================================
# STEP 6b — MERGE BOOSTER
# =============================================================================

def merge_booster() -> pd.DataFrame:
    indices_path = _out(OUTPUT_INDICES)
    booster_path = _out(OUTPUT_BOOSTER)
    output_path = _out(OUTPUT_ENHANCED)

    for label, path in [("Indices", indices_path), ("Booster", booster_path)]:
        if not os.path.exists(path):
            raise FileNotFoundError(f"{label} file not found: {path}")

    df_main = pd.read_csv(indices_path)
    df_boost = pd.read_csv(booster_path)

    overlap = [
        c for c in df_boost.columns
        if c in df_main.columns and c not in ("Field_ID", "Year")
    ]
    if overlap:
        logger.info("Dropping %s overlapping booster columns", len(overlap))
        df_boost = df_boost.drop(columns=overlap)

    df_merged = df_main.merge(df_boost, on=["Field_ID", "Year"], how="left")
    df_merged.to_csv(output_path, index=False)
    logger.info("Merged %s rows → %s", f"{len(df_merged):,}", output_path)
    return df_merged


def step6b_merge_booster() -> None:
    logger.info("=== Step 6b: Merge booster into indices ===")
    merge_booster()


# =============================================================================
# CLI
# =============================================================================

STEP_MAP = {
    "1": step1_extract_crops,
    "2": step2_soilgrids,
    "3": step3_terraclimate,
    "4": step4_sentinel_indices,
    "5": step5_stack_backups,
    "6a": step6a_booster,
    "6b": step6b_merge_booster,
}

ALL_STEPS = ["1", "2", "3", "4", "6a", "6b"]


def run_steps(steps: list[str]) -> None:
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    logger.info("Output directory: %s", OUTPUT_DIR)
    logger.info("CROPGRIDS folder: %s", CROPGRIDS_FOLDER)
    logger.info("GEE project: %s", GEE_PROJECT)

    for step in steps:
        fn = STEP_MAP.get(step)
        if fn is None:
            raise ValueError(f"Unknown step: {step}. Valid: {list(STEP_MAP)}")
        fn()


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Egypt Crop Data Pipeline — CROPGRIDS + GEE satellite features",
    )
    parser.add_argument(
        "--step",
        action="append",
        choices=list(STEP_MAP.keys()) + ["all"],
        help="Pipeline step(s) to run. Repeat for multiple steps.",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    if not args.step:
        print(__doc__)
        return 1

    steps: list[str] = []
    for s in args.step:
        if s == "all":
            steps.extend(ALL_STEPS)
        else:
            steps.append(s)

    try:
        run_steps(steps)
    except Exception as exc:
        logger.error("Pipeline failed: %s", exc)
        return 1

    logger.info("Pipeline finished successfully.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
