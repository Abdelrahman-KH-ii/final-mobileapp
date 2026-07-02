from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()


class Farm(models.Model):

    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="farms",
        db_index=True
    )

    name         = models.CharField(max_length=150)
    location     = models.CharField(max_length=255, blank=True, default="", help_text="Human-readable address or region name")
    soil_type    = models.CharField(max_length=100, blank=True, default="")
    climate_zone = models.CharField(max_length=100, blank=True, default="")

    # Geographic coordinates for map rendering
    latitude  = models.DecimalField(
        max_digits=9, decimal_places=6,
        null=True, blank=True,
        help_text="Farm centroid latitude (decimal degrees, WGS-84)"
    )
    longitude = models.DecimalField(
        max_digits=9, decimal_places=6,
        null=True, blank=True,
        help_text="Farm centroid longitude (decimal degrees, WGS-84)"
    )

    crop         = models.CharField(max_length=100, default="Wheat")
    area         = models.CharField(max_length=50, default="0 ha")
    health       = models.CharField(max_length=50, default="healthy")
    last_scan    = models.CharField(max_length=100, blank=True, default="")
    planted_at   = models.DateTimeField(null=True, blank=True)

    # Soil / land attributes for AI models
    nitrogen      = models.FloatField(null=True, blank=True)
    phosphorus    = models.FloatField(null=True, blank=True)
    potassium     = models.FloatField(null=True, blank=True)
    ph            = models.FloatField(null=True, blank=True)
    temperature   = models.FloatField(null=True, blank=True)
    humidity      = models.FloatField(null=True, blank=True)
    soil_moisture = models.FloatField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name


class FarmData(models.Model):

    farm = models.ForeignKey(
        Farm,
        on_delete=models.CASCADE,
        related_name="farm_data"
    )

    temperature = models.FloatField(null=True, blank=True)
    humidity = models.FloatField(null=True, blank=True)

    nitrogen = models.FloatField(null=True, blank=True)
    phosphorus = models.FloatField(null=True, blank=True)
    potassium = models.FloatField(null=True, blank=True)

    soil_ph = models.FloatField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)


class Plot(models.Model):

    STATUS_CHOICES = (
        ("healthy", "Healthy"),
        ("alert", "Alert"),
    )

    farm = models.ForeignKey(
        Farm,
        on_delete=models.CASCADE,
        related_name="plots"
    )

    name      = models.CharField(max_length=100)
    crop_type = models.CharField(max_length=100)

    area     = models.FloatField()
    moisture = models.FloatField()

    harvest_date = models.DateField()

    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default="healthy"
    )

    # Plot-level precise coordinates (can differ from farm centroid)
    latitude  = models.DecimalField(
        max_digits=9, decimal_places=6,
        null=True, blank=True,
        help_text="Plot centre latitude (decimal degrees, WGS-84)"
    )
    longitude = models.DecimalField(
        max_digits=9, decimal_places=6,
        null=True, blank=True,
        help_text="Plot centre longitude (decimal degrees, WGS-84)"
    )

    def __str__(self):
        return f"{self.farm.name} - {self.name}"


class SoilRecord(models.Model):

    plot = models.ForeignKey(
        Plot,
        on_delete=models.CASCADE,
        related_name="soil_records"
    )

    nitrogen = models.FloatField()
    phosphorus = models.FloatField()
    potassium = models.FloatField()

    ph = models.FloatField()
    moisture = models.FloatField()

    created_at = models.DateTimeField(auto_now_add=True)


class IrrigationSchedule(models.Model):

    STATUS_CHOICES = (
        ("scheduled", "Scheduled"),
        ("in_progress", "In Progress"),
        ("completed", "Completed"),
    )

    plot = models.ForeignKey(
        Plot,
        on_delete=models.CASCADE,
        related_name="irrigations"
    )

    scheduled_time = models.DateTimeField()
    duration_minutes = models.IntegerField()

    water_volume = models.FloatField()

    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default="scheduled"
    )


class CropField(models.Model):
    """Individual crop field with geolocation, color, and ML-ready data."""

    CROP_CHOICES = (
        ("wheat", "Wheat"),
        ("corn", "Corn"),
        ("rice", "Rice"),
        ("barley", "Barley"),
        ("soybeans", "Soybeans"),
        ("cotton", "Cotton"),
        ("sugarcane", "Sugarcane"),
        ("other", "Other"),
    )

    farm = models.ForeignKey(
        Farm,
        on_delete=models.CASCADE,
        related_name="crop_fields",
        null=True,
        blank=True
    )

    crop_type = models.CharField(
        max_length=50,
        choices=CROP_CHOICES,
        default="wheat",
        db_index=True
    )

    # Color for map display (hex format: #RRGGBB)
    color = models.CharField(
        max_length=7,
        default="#00AA00",
        help_text="Hex color code for map visualization (e.g., #FF5733)"
    )

    # Precise geolocation
    latitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        help_text="Field center latitude (decimal degrees, WGS-84)"
    )
    longitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        help_text="Field center longitude (decimal degrees, WGS-84)"
    )

    # Field characteristics
    area = models.FloatField(
        help_text="Field area in hectares"
    )
    soil_type = models.CharField(
        max_length=100,
        blank=True,
        default="",
        help_text="Type of soil (loamy, sandy, clay, etc.)"
    )

    # Remote sensing data for ML models
    ndvi = models.FloatField(
        null=True,
        blank=True,
        help_text="Normalized Difference Vegetation Index (-1 to 1)"
    )
    soil_moisture = models.FloatField(
        null=True,
        blank=True,
        help_text="Soil moisture percentage (0-100)"
    )
    temperature = models.FloatField(
        null=True,
        blank=True,
        help_text="Average temperature in Celsius"
    )
    humidity = models.FloatField(
        null=True,
        blank=True,
        help_text="Relative humidity percentage (0-100)"
    )

    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        indexes = [
            models.Index(fields=['crop_type', 'farm']),
            models.Index(fields=['latitude', 'longitude']),
        ]

    def __str__(self):
        farm_name = self.farm.name if self.farm else "Unknown"
        return f"{farm_name} - {self.crop_type} ({self.latitude}, {self.longitude})"