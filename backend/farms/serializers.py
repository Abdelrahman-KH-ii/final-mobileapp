from rest_framework import serializers
from .models import Farm, FarmData, Plot, SoilRecord, IrrigationSchedule, CropField


class SoilSerializer(serializers.ModelSerializer):
    class Meta:
        model = SoilRecord
        fields = "__all__"


class IrrigationSerializer(serializers.ModelSerializer):
    class Meta:
        model = IrrigationSchedule
        fields = "__all__"


class PlotSerializer(serializers.ModelSerializer):
    soil_records = SoilSerializer(many=True, read_only=True)
    irrigations = IrrigationSerializer(many=True, read_only=True)

    class Meta:
        model = Plot
        fields = "__all__"


class FarmSerializer(serializers.ModelSerializer):
    plots = PlotSerializer(many=True, read_only=True)

    class Meta:
        model = Farm
        fields = "__all__"
        read_only_fields = ("user",)


class FarmDataSerializer(serializers.ModelSerializer):
    class Meta:
        model = FarmData
        fields = "__all__"


class CropFieldSerializer(serializers.ModelSerializer):
    """Serializer for CropField with all location and ML data."""
    
    farm_name = serializers.CharField(source='farm.name', read_only=True, allow_null=True)

    class Meta:
        model = CropField
        fields = [
            'id', 'farm', 'farm_name', 'crop_type', 'color',
            'latitude', 'longitude', 'area', 'soil_type',
            'ndvi', 'soil_moisture', 'temperature', 'humidity',
            'created_at', 'updated_at'
        ]
        read_only_fields = ('id', 'created_at', 'updated_at')


class CropFieldGeoJSONSerializer(serializers.ModelSerializer):
    """GeoJSON-format serializer for map visualization."""
    
    type = serializers.CharField(default='Feature', read_only=True)
    geometry = serializers.SerializerMethodField()
    properties = serializers.SerializerMethodField()

    class Meta:
        model = CropField
        fields = ['type', 'geometry', 'properties']

    def get_geometry(self, obj):
        return {
            'type': 'Point',
            'coordinates': [float(obj.longitude), float(obj.latitude)]
        }

    def get_properties(self, obj):
        return {
            'id': obj.id,
            'crop_type': obj.crop_type,
            'color': obj.color,
            'area': obj.area,
            'soil_type': obj.soil_type,
            'ndvi': obj.ndvi,
            'soil_moisture': obj.soil_moisture,
            'temperature': obj.temperature,
            'humidity': obj.humidity,
            'farm_id': obj.farm_id,
            'farm_name': obj.farm.name if obj.farm else None,
        }