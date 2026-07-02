"""
AI Core models for storing AI model results and predictions
"""

from django.db import models
from django.conf import settings
from farms.models import Farm


class AICoreResult(models.Model):
    """
    Model to store results from AI model predictions.
    
    Tracks all AI model predictions including input data, output results,
    and execution metrics for auditing and analysis purposes.
    """

    MODEL_TYPES = (
        ('cv', 'Computer Vision'),
        ('crop_rotation', 'Crop Rotation'),
        ('crop_recommendation', 'Crop Recommendation'),
        ('chatbot', 'Chatbot'),
        ('price_forecasting', 'Price Forecasting'),
        ('scenario_simulator', 'Scenario Simulator'),
        ('soil_health_prediction', 'Soil Health Prediction'),
        ('fertilizer_optimizer', 'Fertilizer Optimizer'),
        ('irrigation_optimizer', 'Irrigation Optimizer'),
        ('yield_prediction', 'Yield Prediction'),
    )

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="ai_results",
        db_index=True,
        help_text="User who requested the prediction"
    )

    farm = models.ForeignKey(
        Farm,
        on_delete=models.CASCADE,
        related_name="ai_results",
        null=True,
        blank=True,
        help_text="Farm associated with this prediction (optional)"
    )

    model_type = models.CharField(
        max_length=50,
        choices=MODEL_TYPES,
        db_index=True,
        help_text="Type of AI model used"
    )

    input_data = models.JSONField(
        help_text="Input parameters sent to the model"
    )
    
    result_data = models.JSONField(
        help_text="Output predictions from the model"
    )

    execution_time = models.FloatField(
        null=True,
        blank=True,
        help_text="Time taken to run prediction in seconds"
    )

    created_at = models.DateTimeField(
        auto_now_add=True,
        db_index=True,
        help_text="Timestamp when prediction was made"
    )

    class Meta:
        ordering = ["-created_at"]
        verbose_name = "AI Core Result"
        verbose_name_plural = "AI Core Results"
        indexes = [
            models.Index(fields=["user", "-created_at"]),
            models.Index(fields=["model_type", "-created_at"]),
            models.Index(fields=["farm", "-created_at"]),
        ]

    def __str__(self):
        return f"{self.get_model_type_display()} - {self.user.email} ({self.created_at.strftime('%Y-%m-%d %H:%M')})"


class CropField(models.Model):
    """
    Egypt crop field record from the CROPGRIDSv1.08 + GEE pipeline.

    Stores 64,100 field-year combinations (2,435 unique locations × 8–13 years)
    with soil, climate, and satellite-derived features.
    Core agronomic columns are explicit fields for fast filtering/querying.
    All monthly Sentinel-2/SAR index columns are stored in extra_data.
    """

    # ── Identity ────────────────────────────────────────────────────────────
    field_id  = models.CharField(max_length=80, db_index=True)
    lat       = models.FloatField()
    lon       = models.FloatField()
    crop      = models.CharField(max_length=50, db_index=True)
    year      = models.IntegerField(db_index=True)
    harv_area = models.FloatField(null=True, blank=True)

    # ── Soil properties (SoilGrids 0–5 cm) ──────────────────────────────────
    soil_ph       = models.FloatField(null=True, blank=True)
    soil_soc      = models.FloatField(null=True, blank=True)
    soil_clay     = models.FloatField(null=True, blank=True)
    soil_sand     = models.FloatField(null=True, blank=True)
    soil_silt     = models.FloatField(null=True, blank=True)
    soil_nitrogen = models.FloatField(null=True, blank=True)
    soil_cec      = models.FloatField(null=True, blank=True)
    soil_bd       = models.FloatField(null=True, blank=True)
    soil_cfvo     = models.FloatField(null=True, blank=True)
    soil_ocd      = models.FloatField(null=True, blank=True)

    # ── Annual climate (TerraClimate) ────────────────────────────────────────
    temp_mean     = models.FloatField(null=True, blank=True)
    precip_sum    = models.FloatField(null=True, blank=True)
    aet_mean      = models.FloatField(null=True, blank=True)
    pet_mean      = models.FloatField(null=True, blank=True)
    vpd_mean      = models.FloatField(null=True, blank=True)
    soil_moisture = models.FloatField(null=True, blank=True)

    # ── Satellite indices (annual summaries from Sentinel-2 / SAR) ───────────
    ndvi_mean      = models.FloatField(null=True, blank=True)
    ndvi_max       = models.FloatField(null=True, blank=True)
    ndvi_min       = models.FloatField(null=True, blank=True)
    ndvi_amplitude = models.FloatField(null=True, blank=True)
    evi_mean       = models.FloatField(null=True, blank=True)
    lswi_mean      = models.FloatField(null=True, blank=True)
    ndre_mean      = models.FloatField(null=True, blank=True)
    ndre_max       = models.FloatField(null=True, blank=True)
    sar_vv_mean    = models.FloatField(null=True, blank=True)
    sar_vh_mean    = models.FloatField(null=True, blank=True)
    sar_vv_vh_ratio = models.FloatField(null=True, blank=True)

    # ── Derived agronomic features ───────────────────────────────────────────
    soil_texture_class = models.CharField(max_length=20, null=True, blank=True)
    fertility_index    = models.FloatField(null=True, blank=True)
    aridity_index      = models.FloatField(null=True, blank=True)
    water_balance      = models.FloatField(null=True, blank=True)

    # ── Crop-specific SAR phenology signals ──────────────────────────────────
    rice_sar_signal  = models.FloatField(null=True, blank=True)
    maize_sar_signal = models.FloatField(null=True, blank=True)
    wheat_sar_signal = models.FloatField(null=True, blank=True)

    # ── Monthly index columns (150+ columns → stored as JSON) ────────────────
    extra_data = models.JSONField(
        default=dict,
        blank=True,
        help_text="Monthly Sentinel-2 and SAR index columns (ndvi_m01…sar_vh_m12 etc.)"
    )

    class Meta:
        ordering = ["field_id", "year"]
        verbose_name = "Crop Field"
        verbose_name_plural = "Crop Fields"
        indexes = [
            models.Index(fields=["crop", "year"]),
            models.Index(fields=["lat", "lon"]),
            models.Index(fields=["field_id", "year"]),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=["field_id", "year", "crop"],
                name="unique_field_year_crop"
            )
        ]

    def __str__(self):
        return f"{self.crop} @ ({self.lat:.3f},{self.lon:.3f}) [{self.year}]"

    def to_geojson_feature(self):
        """Return a GeoJSON Feature dict for map rendering."""
        return {
            "type": "Feature",
            "geometry": {"type": "Point", "coordinates": [self.lon, self.lat]},
            "properties": {
                "id":          self.pk,
                "field_id":    self.field_id,
                "crop":        self.crop,
                "year":        self.year,
                "ndvi_mean":   self.ndvi_mean,
                "soil_ph":     self.soil_ph,
                "soil_clay":   self.soil_clay,
                "temp_mean":   self.temp_mean,
                "precip_sum":  self.precip_sum,
                "fertility":   self.fertility_index,
                "aridity":     self.aridity_index,
            },
        }