"""
Serializers for AI Core models

Handles serialization and deserialization of AI model results.
"""

from rest_framework import serializers
from .models import AICoreResult, CropField


class AICoreResultSerializer(serializers.ModelSerializer):
    """
    Serializer for AICoreResult model.
    
    Converts AICoreResult instances to and from JSON format.
    """
    user_email = serializers.EmailField(
        source='user.email',
        read_only=True
    )
    farm_name = serializers.CharField(
        source='farm.name',
        read_only=True
    )

    class Meta:
        model = AICoreResult
        fields = [
            "id",
            "user",
            "user_email",
            "farm",
            "farm_name",
            "model_type",
            "input_data",
            "result_data",
            "execution_time",
            "created_at"
        ]
        read_only_fields = (
            "id",
            "user",
            "created_at",
            "execution_time",
            "user_email",
            "farm_name"
        )


class CropFieldListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for list views (no extra_data to keep response small)."""
    class Meta:
        model = CropField
        fields = [
            "id", "field_id", "lat", "lon", "crop", "year",
            "ndvi_mean", "soil_ph", "soil_clay", "temp_mean",
            "precip_sum", "fertility_index", "aridity_index",
        ]


class CropFieldSerializer(serializers.ModelSerializer):
    """Full serializer for detail views — includes extra_data."""
    class Meta:
        model = CropField
        fields = "__all__"


class CropFieldGeoSerializer(serializers.ModelSerializer):
    """
    Minimal serializer for GeoJSON map endpoint.
    Returns only what the Leaflet map needs to render markers efficiently.
    """
    class Meta:
        model = CropField
        fields = [
            "id", "field_id", "lat", "lon", "crop", "year",
            "ndvi_mean", "soil_ph", "fertility_index",
        ]