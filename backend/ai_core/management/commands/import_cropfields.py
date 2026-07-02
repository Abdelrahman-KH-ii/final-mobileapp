"""
Management command: import_cropfields

Reads the Egypt_TOP10_CROPGRIDS_Enhanced.csv (64,100 rows) produced by the
GEE pipeline notebook and bulk-inserts records into the CropField table.

Usage:
    python manage.py import_cropfields /path/to/Egypt_TOP10_CROPGRIDS_Enhanced.csv
    python manage.py import_cropfields /path/to/Egypt_TOP10_CROPGRIDS_Enhanced.csv --clear
"""

import csv
import math
import os
from pathlib import Path

from django.core.management.base import BaseCommand, CommandError
from ai_core.models import CropField

_DEFAULT_CSV = (
    Path(__file__).resolve().parents[4]
    / "data"
    / "pipeline_outputs"
    / "Egypt_TOP10_CROPGRIDS_Enhanced.csv"
)


# Columns that map directly to CropField model fields
DIRECT_COLUMNS = {
    "Field_ID":          "field_id",
    "lat":               "lat",
    "lon":               "lon",
    "Crop":              "crop",
    "Year":              "year",
    "harvarea":          "harv_area",
    "soil_ph":           "soil_ph",
    "soil_soc":          "soil_soc",
    "soil_clay":         "soil_clay",
    "soil_sand":         "soil_sand",
    "soil_silt":         "soil_silt",
    "soil_nitrogen":     "soil_nitrogen",
    "soil_cec":          "soil_cec",
    "soil_bd":           "soil_bd",
    "soil_cfvo":         "soil_cfvo",
    "soil_ocd":          "soil_ocd",
    "temp_mean":         "temp_mean",
    "precip_sum":        "precip_sum",
    "aet_mean":          "aet_mean",
    "pet_mean":          "pet_mean",
    "vpd_mean":          "vpd_mean",
    "soil_moisture":     "soil_moisture",
    "ndvi_mean":         "ndvi_mean",
    "ndvi_max":          "ndvi_max",
    "ndvi_min":          "ndvi_min",
    "ndvi_amplitude":    "ndvi_amplitude",
    "evi_mean":          "evi_mean",
    "lswi_mean":         "lswi_mean",
    "ndre_mean":         "ndre_mean",
    "ndre_max":          "ndre_max",
    "sar_vv_mean":       "sar_vv_mean",
    "sar_vh_mean":       "sar_vh_mean",
    "sar_vv_vh_ratio":   "sar_vv_vh_ratio",
    "soil_texture_class":"soil_texture_class",
    "fertility_index":   "fertility_index",
    "aridity_index":     "aridity_index",
    "water_balance":     "water_balance",
    "rice_sar_signal":   "rice_sar_signal",
    "maize_sar_signal":  "maize_sar_signal",
    "wheat_sar_signal":  "wheat_sar_signal",
}

STRING_FIELDS = {"field_id", "crop", "soil_texture_class"}
INT_FIELDS    = {"year"}
BATCH_SIZE    = 1000


def _safe_float(val):
    """Convert a CSV cell to float; return None if blank or NaN."""
    if val is None or val == "":
        return None
    try:
        f = float(val)
        return None if math.isnan(f) else f
    except (ValueError, TypeError):
        return None


class Command(BaseCommand):
    help = "Import Egypt crop field data from the pipeline CSV into the CropField table."

    def add_arguments(self, parser):
        parser.add_argument(
            "csv_path",
            type=str,
            nargs="?",
            default=str(_DEFAULT_CSV),
            help=f"Path to Egypt_TOP10_CROPGRIDS_Enhanced.csv (default: {_DEFAULT_CSV})",
        )
        parser.add_argument(
            "--mock",
            action="store_true",
            default=False,
            help="Generate 64100 mock records instead of reading from CSV.",
        )
        parser.add_argument(
            "--clear",
            action="store_true",
            default=False,
            help="Delete all existing CropField records before importing.",
        )
        parser.add_argument(
            "--batch",
            type=int,
            default=BATCH_SIZE,
            help=f"Bulk-insert batch size (default: {BATCH_SIZE})",
        )

    def handle(self, *args, **options):
        if options["clear"]:
            count = CropField.objects.count()
            CropField.objects.all().delete()
            self.stdout.write(self.style.WARNING(f"Cleared {count:,} existing records."))

        if options["mock"]:
            self.generate_mock_data(options["batch"])
            return

        csv_path = options["csv_path"]
        if not csv_path or not os.path.exists(csv_path):
            raise CommandError(f"CSV not found: {csv_path}")

        batch_size = options["batch"]
        batch      = []
        total      = 0
        skipped    = 0

        self.stdout.write(f"Reading: {csv_path}")

        with open(csv_path, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            headers = set(reader.fieldnames or [])

            # Columns that go into extra_data (monthly satellite indices)
            extra_headers = [
                h for h in headers
                if h not in DIRECT_COLUMNS and h not in ("Field_ID",)
            ]

            for row in reader:
                try:
                    kwargs = {}

                    # Map direct columns
                    for csv_col, model_field in DIRECT_COLUMNS.items():
                        if csv_col not in headers:
                            continue
                        val = row.get(csv_col, "")
                        if model_field in STRING_FIELDS:
                            kwargs[model_field] = str(val).strip() if val else ""
                        elif model_field in INT_FIELDS:
                            try:
                                kwargs[model_field] = int(float(val)) if val else None
                            except (ValueError, TypeError):
                                kwargs[model_field] = None
                        else:
                            kwargs[model_field] = _safe_float(val)

                    # Pack remaining monthly columns into extra_data
                    extra = {}
                    for h in extra_headers:
                        v = row.get(h, "")
                        if v not in ("", None):
                            try:
                                fv = float(v)
                                extra[h] = None if math.isnan(fv) else fv
                            except (ValueError, TypeError):
                                extra[h] = v
                    kwargs["extra_data"] = extra

                    batch.append(CropField(**kwargs))

                    if len(batch) >= batch_size:
                        CropField.objects.bulk_create(
                            batch,
                            update_conflicts=True,
                            unique_fields=["field_id", "year", "crop"],
                            update_fields=[
                                "harv_area", "soil_ph", "soil_clay", "soil_sand",
                                "ndvi_mean", "ndvi_max", "sar_vv_mean", "sar_vh_mean",
                                "temp_mean", "precip_sum", "fertility_index",
                                "aridity_index", "extra_data",
                            ],
                        )
                        total += len(batch)
                        batch = []
                        self.stdout.write(f"  Imported {total:,} rows…", ending="\r")

                except Exception as exc:
                    skipped += 1
                    if skipped <= 5:
                        self.stderr.write(f"  Row error: {exc}")

        # Final batch
        if batch:
            CropField.objects.bulk_create(
                batch,
                update_conflicts=True,
                unique_fields=["field_id", "year", "crop"],
                update_fields=[
                    "harv_area", "soil_ph", "soil_clay", "soil_sand",
                    "ndvi_mean", "ndvi_max", "sar_vv_mean", "sar_vh_mean",
                    "temp_mean", "precip_sum", "fertility_index",
                    "aridity_index", "extra_data",
                ],
            )
            total += len(batch)

        self.stdout.write("")
        self.stdout.write(self.style.SUCCESS(
            f"✓ Done! Imported {total:,} records. Skipped {skipped} errors."
        ))
        self.stdout.write(f"  Total in DB: {CropField.objects.count():,}")

    def generate_mock_data(self, batch_size):
        import random
        import uuid
        
        total_records = 64100
        self.stdout.write(self.style.WARNING(f'Generating {total_records} mock CropField records...'))
        
        crops = ['Wheat', 'Corn', 'Cotton', 'Rice', 'Tomato', 'Potato']
        years = [2018, 2019, 2020, 2021, 2022, 2023, 2024]
        
        base_locations = []
        for _ in range(2435):
            base_locations.append({
                'lat': random.uniform(22.0, 31.5),
                'lon': random.uniform(25.0, 35.0),
                'field_id': f'FLD-{uuid.uuid4().hex[:8].upper()}'
            })

        batch = []
        count = 0
        for i in range(total_records):
            loc = random.choice(base_locations)
            crop = random.choice(crops)
            year = random.choice(years)

            batch.append(CropField(
                field_id=loc['field_id'],
                lat=loc['lat'],
                lon=loc['lon'],
                crop=crop,
                year=year,
                harv_area=random.uniform(1.0, 10.0),
                soil_ph=random.uniform(5.5, 8.5),
                soil_soc=random.uniform(0.5, 3.0),
                soil_clay=random.uniform(10.0, 60.0),
                temp_mean=random.uniform(15.0, 35.0),
                precip_sum=random.uniform(10.0, 200.0),
                ndvi_mean=random.uniform(0.2, 0.8),
                ndvi_max=random.uniform(0.5, 0.9),
                fertility_index=random.uniform(0.3, 0.9),
                aridity_index=random.uniform(0.1, 0.6)
            ))

            count += 1
            if len(batch) >= batch_size:
                CropField.objects.bulk_create(batch, ignore_conflicts=True)
                self.stdout.write(f"  Generated {count:,} rows…", ending="\r")
                batch = []

        if batch:
            CropField.objects.bulk_create(batch, ignore_conflicts=True)

        self.stdout.write("")
        self.stdout.write(self.style.SUCCESS(f"✓ Done! Mock data generation complete."))
        self.stdout.write(f"  Total in DB: {CropField.objects.count():,}")
