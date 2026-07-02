from rest_framework import viewsets, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.decorators import action
from django.db.models import Q
from .models import Farm, Plot, SoilRecord, IrrigationSchedule, CropField
from .serializers import FarmSerializer, CropFieldSerializer, CropFieldGeoJSONSerializer


class FarmViewSet(viewsets.ModelViewSet):
    serializer_class = FarmSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Farm.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class DashboardView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user

        farms_count = Farm.objects.filter(user=user).count()
        plots_count = Plot.objects.filter(farm__user=user).count()

        latest_irrigation = (
            IrrigationSchedule.objects
            .filter(plot__farm__user=user)
            .order_by("-scheduled_time")
            .first()
        )

        latest_soil = (
            SoilRecord.objects
            .filter(plot__farm__user=user)
            .order_by("-created_at")
            .first()
        )

        return Response({
            "farms_count": farms_count,
            "plots_count": plots_count,
            "latest_irrigation": {
                "id": latest_irrigation.id,
                "status": latest_irrigation.status,
                "scheduled_time": latest_irrigation.scheduled_time,
            } if latest_irrigation else None,
            "latest_soil_record": {
                "id": latest_soil.id,
                "ph": latest_soil.ph,
                "moisture": latest_soil.moisture,
            } if latest_soil else None,
        })


class CropFieldViewSet(viewsets.ModelViewSet):
    """ViewSet for CropField with filtering and map capabilities."""
    
    serializer_class = CropFieldSerializer
    permission_classes = [permissions.IsAuthenticated]
    filterset_fields = ['crop_type', 'farm', 'soil_type']
    search_fields = ['crop_type', 'soil_type']

    def get_queryset(self):
        """Return crop fields for user's farms only."""
        user = self.request.user
        return CropField.objects.filter(farm__user=user).select_related('farm')

    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def geojson(self, request):
        """Return crop fields as GeoJSON for map visualization."""
        user = request.user
        crop_type = request.query_params.get('crop_type', None)
        
        queryset = CropField.objects.filter(farm__user=user)
        if crop_type:
            queryset = queryset.filter(crop_type=crop_type)

        features = []
        for field in queryset:
            features.append({
                'type': 'Feature',
                'geometry': {
                    'type': 'Point',
                    'coordinates': [float(field.longitude), float(field.latitude)]
                },
                'properties': {
                    'id': field.id,
                    'crop_type': field.crop_type,
                    'color': field.color,
                    'area': field.area,
                    'soil_type': field.soil_type,
                    'ndvi': field.ndvi,
                    'soil_moisture': field.soil_moisture,
                    'temperature': field.temperature,
                    'humidity': field.humidity,
                    'farm_id': field.farm_id,
                    'farm_name': field.farm.name if field.farm else None,
                }
            })

        return Response({
            'type': 'FeatureCollection',
            'features': features
        })

    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def statistics(self, request):
        """Return crop field statistics for the user."""
        user = self.request.user
        fields = CropField.objects.filter(farm__user=user)

        stats = {
            'total_fields': fields.count(),
            'total_area': sum(f.area for f in fields) if fields.exists() else 0,
            'crop_distribution': {},
            'average_ndvi': None,
            'average_moisture': None,
        }

        # Crop distribution
        for crop_type, _ in CropField._meta.get_field('crop_type').choices:
            count = fields.filter(crop_type=crop_type).count()
            if count > 0:
                stats['crop_distribution'][crop_type] = count

        # Average metrics
        fields_with_ndvi = fields.filter(ndvi__isnull=False)
        if fields_with_ndvi.exists():
            avg_ndvi = sum(f.ndvi for f in fields_with_ndvi) / fields_with_ndvi.count()
            stats['average_ndvi'] = round(avg_ndvi, 3)

        fields_with_moisture = fields.filter(soil_moisture__isnull=False)
        if fields_with_moisture.exists():
            avg_moisture = sum(f.soil_moisture for f in fields_with_moisture) / fields_with_moisture.count()
            stats['average_moisture'] = round(avg_moisture, 2)

        return Response(stats)
