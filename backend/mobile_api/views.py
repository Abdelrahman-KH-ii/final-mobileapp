"""
Mobile API Views
================
All endpoints for the FarmTech Flutter mobile application.
Base URL: /api/mobile/

Auth:       JWT Bearer token (same tokens as web)
Versioning: v1 (prefix all future breaking changes with /v2/)
"""

import json
import os
import tempfile
import time

from django.contrib.auth import authenticate
from django.db.models import Avg, Count, Q
from django.shortcuts import get_object_or_404
from rest_framework import status, permissions
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

from accounts.models import User
from ai_core.models import AICoreResult
from ai_core.services.hf_crop_recommender import HFCropRecommender
from ai_core.services.hf_forecast_service import HFForecastService
from ai_core.services.hf_irrigation_recommender import HFIrrigationRecommender
from ai_core.services.hf_yield_predictor import HFYieldPredictor
from ai_core.services.model_loader import cv_model
from farms.models import (
    CropField, Farm, FarmData, IrrigationSchedule, Plot, SoilRecord,
)
from news.models import Category, Comment, News

from .serializers import (
    MobileAIResultSerializer,
    MobileChangePasswordSerializer,
    MobileCategorySerializer,
    MobileCommentSerializer,
    MobileCropFieldSerializer,
    MobileFarmDataSerializer,
    MobileFarmDetailSerializer,
    MobileFarmSerializer,
    MobileIrrigationSerializer,
    MobileLoginSerializer,
    MobileNewsDetailSerializer,
    MobileNewsListSerializer,
    MobilePlotSerializer,
    MobileRegisterSerializer,
    MobileSoilRecordSerializer,
    MobileUserSerializer,
)


# ─── Helpers ─────────────────────────────────────────────────────────────────

def _tokens(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }


def _ok(data=None, **extra):
    payload = {'success': True}
    if data is not None:
        payload['data'] = data
    payload.update(extra)
    return Response(payload)


def _err(message, code=status.HTTP_400_BAD_REQUEST):
    return Response({'success': False, 'error': message}, status=code)


# ═══════════════════════════════════════════════════════════════════════════════
# AUTH
# ═══════════════════════════════════════════════════════════════════════════════

class MobileRegisterView(APIView):
    """
    POST /api/mobile/auth/register/
    Body: { email, username, password, phone_number? }
    Returns: tokens + user profile
    """
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = MobileRegisterSerializer(data=request.data)
        if not serializer.is_valid():
            return _err(serializer.errors)
        user = serializer.save()
        tokens = _tokens(user)
        return Response({
            'success': True,
            'message': 'Account created successfully.',
            'access': tokens['access'],
            'refresh': tokens['refresh'],
            'user': MobileUserSerializer(user).data,
        }, status=status.HTTP_201_CREATED)


class MobileLoginView(APIView):
    """
    POST /api/mobile/auth/login/
    Body: { email, password }
    Returns: tokens + user profile
    """
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = MobileLoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = authenticate(
            request,
            email=serializer.validated_data['email'],
            password=serializer.validated_data['password'],
        )
        if user is None:
            return _err('Invalid email or password.', status.HTTP_401_UNAUTHORIZED)
        if not user.is_active:
            return _err('Account is disabled.', status.HTTP_403_FORBIDDEN)
        tokens = _tokens(user)
        return Response({
            'success': True,
            'message': 'Login successful.',
            'access': tokens['access'],
            'refresh': tokens['refresh'],
            'user': MobileUserSerializer(user).data,
        })


class MobileLogoutView(APIView):
    """
    POST /api/mobile/auth/logout/
    Body: { refresh }
    Blacklists refresh token.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        refresh_token = request.data.get('refresh')
        if not refresh_token:
            return _err('Refresh token required.')
        try:
            token = RefreshToken(refresh_token)
            token.blacklist()
            return _ok(message='Logged out successfully.')
        except Exception:
            return _err('Invalid or expired token.')


class MobileProfileView(APIView):
    """
    GET  /api/mobile/auth/profile/   → get profile
    PUT  /api/mobile/auth/profile/   → update username / phone_number
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        return _ok(MobileUserSerializer(request.user).data)

    def put(self, request):
        user = request.user
        serializer = MobileUserSerializer(user, data=request.data, partial=True)
        if not serializer.is_valid():
            return _err(serializer.errors)
        serializer.save()
        return _ok(serializer.data)


class MobileChangePasswordView(APIView):
    """
    POST /api/mobile/auth/change-password/
    Body: { old_password, new_password }
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = MobileChangePasswordSerializer(
            data=request.data, context={'request': request}
        )
        if not serializer.is_valid():
            return _err(serializer.errors)
        serializer.save()
        return _ok(message='Password changed. Please login again.')


# ═══════════════════════════════════════════════════════════════════════════════
# DASHBOARD
# ═══════════════════════════════════════════════════════════════════════════════

class MobileDashboardView(APIView):
    """
    GET /api/mobile/dashboard/
    Single-call home screen data: counts, latest records, recent AI history.
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user

        farms = Farm.objects.filter(user=user)
        plots = Plot.objects.filter(farm__user=user)
        alerts = plots.filter(status='alert').count()

        latest_irr = (
            IrrigationSchedule.objects
            .filter(plot__farm__user=user)
            .order_by('-scheduled_time')
            .first()
        )
        latest_soil = (
            SoilRecord.objects
            .filter(plot__farm__user=user)
            .order_by('-created_at')
            .first()
        )
        recent_ai = (
            AICoreResult.objects
            .filter(user=user)
            .order_by('-created_at')[:5]
        )

        return _ok({
            'farms_count': farms.count(),
            'plots_count': plots.count(),
            'crop_fields_count': CropField.objects.filter(farm__user=user).count(),
            'alerts_count': alerts,
            'latest_irrigation': {
                'id': latest_irr.id,
                'status': latest_irr.status,
                'scheduled_time': latest_irr.scheduled_time,
                'duration_minutes': latest_irr.duration_minutes,
            } if latest_irr else None,
            'latest_soil': {
                'id': latest_soil.id,
                'ph': latest_soil.ph,
                'moisture': latest_soil.moisture,
                'nitrogen': latest_soil.nitrogen,
            } if latest_soil else None,
            'recent_ai_results': MobileAIResultSerializer(recent_ai, many=True).data,
        })


# ═══════════════════════════════════════════════════════════════════════════════
# FARMS
# ═══════════════════════════════════════════════════════════════════════════════

class MobileFarmListCreateView(APIView):
    """
    GET  /api/mobile/farms/         → list user farms (with counts)
    POST /api/mobile/farms/         → create farm
    Body (POST): { name, location, soil_type?, climate_zone?, latitude?, longitude? }
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        farms = Farm.objects.filter(user=request.user).order_by('-created_at')
        return _ok(MobileFarmSerializer(farms, many=True).data)

    def post(self, request):
        serializer = MobileFarmSerializer(data=request.data)
        if not serializer.is_valid():
            return _err(serializer.errors)
        farm = serializer.save(user=request.user)
        return Response(
            {'success': True, 'data': MobileFarmSerializer(farm).data},
            status=status.HTTP_201_CREATED,
        )


class MobileFarmDetailView(APIView):
    """
    GET    /api/mobile/farms/<id>/  → farm detail + plots
    PUT    /api/mobile/farms/<id>/  → update farm
    DELETE /api/mobile/farms/<id>/  → delete farm
    """
    permission_classes = [permissions.IsAuthenticated]

    def _get_farm(self, request, pk):
        return get_object_or_404(Farm, pk=pk, user=request.user)

    def get(self, request, pk):
        farm = self._get_farm(request, pk)
        return _ok(MobileFarmDetailSerializer(farm).data)

    def put(self, request, pk):
        farm = self._get_farm(request, pk)
        serializer = MobileFarmSerializer(farm, data=request.data, partial=True)
        if not serializer.is_valid():
            return _err(serializer.errors)
        serializer.save()
        return _ok(serializer.data)

    def delete(self, request, pk):
        farm = self._get_farm(request, pk)
        farm.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


# ─── Plots ────────────────────────────────────────────────────────────────────

class MobilePlotListCreateView(APIView):
    """
    GET  /api/mobile/farms/<farm_id>/plots/
    POST /api/mobile/farms/<farm_id>/plots/
    """
    permission_classes = [permissions.IsAuthenticated]

    def _get_farm(self, request, farm_id):
        return get_object_or_404(Farm, pk=farm_id, user=request.user)

    def get(self, request, farm_id):
        self._get_farm(request, farm_id)
        plots = Plot.objects.filter(farm_id=farm_id).order_by('name')
        return _ok(MobilePlotSerializer(plots, many=True).data)

    def post(self, request, farm_id):
        farm = self._get_farm(request, farm_id)
        data = request.data.copy()
        data['farm'] = farm.id
        serializer = MobilePlotSerializer(data=data)
        if not serializer.is_valid():
            return _err(serializer.errors)
        plot = serializer.save()
        return Response(
            {'success': True, 'data': MobilePlotSerializer(plot).data},
            status=status.HTTP_201_CREATED,
        )


class MobilePlotDetailView(APIView):
    """
    GET    /api/mobile/plots/<id>/
    PUT    /api/mobile/plots/<id>/
    DELETE /api/mobile/plots/<id>/
    """
    permission_classes = [permissions.IsAuthenticated]

    def _get_plot(self, request, pk):
        return get_object_or_404(Plot, pk=pk, farm__user=request.user)

    def get(self, request, pk):
        plot = self._get_plot(request, pk)
        return _ok(MobilePlotSerializer(plot).data)

    def put(self, request, pk):
        plot = self._get_plot(request, pk)
        serializer = MobilePlotSerializer(plot, data=request.data, partial=True)
        if not serializer.is_valid():
            return _err(serializer.errors)
        serializer.save()
        return _ok(serializer.data)

    def delete(self, request, pk):
        plot = self._get_plot(request, pk)
        plot.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


# ─── Soil Records ─────────────────────────────────────────────────────────────

class MobileSoilRecordView(APIView):
    """
    GET  /api/mobile/plots/<plot_id>/soil/   → list soil records (latest 20)
    POST /api/mobile/plots/<plot_id>/soil/   → add soil record
    """
    permission_classes = [permissions.IsAuthenticated]

    def _get_plot(self, request, plot_id):
        return get_object_or_404(Plot, pk=plot_id, farm__user=request.user)

    def get(self, request, plot_id):
        self._get_plot(request, plot_id)
        records = SoilRecord.objects.filter(plot_id=plot_id).order_by('-created_at')[:20]
        return _ok(MobileSoilRecordSerializer(records, many=True).data)

    def post(self, request, plot_id):
        plot = self._get_plot(request, plot_id)
        data = request.data.copy()
        data['plot'] = plot.id
        serializer = MobileSoilRecordSerializer(data=data)
        if not serializer.is_valid():
            return _err(serializer.errors)
        record = serializer.save()
        return Response(
            {'success': True, 'data': MobileSoilRecordSerializer(record).data},
            status=status.HTTP_201_CREATED,
        )


# ─── Irrigation ───────────────────────────────────────────────────────────────

class MobileIrrigationListCreateView(APIView):
    """
    GET  /api/mobile/plots/<plot_id>/irrigation/
    POST /api/mobile/plots/<plot_id>/irrigation/
    Body (POST): { scheduled_time, duration_minutes, water_volume, status? }
    """
    permission_classes = [permissions.IsAuthenticated]

    def _get_plot(self, request, plot_id):
        return get_object_or_404(Plot, pk=plot_id, farm__user=request.user)

    def get(self, request, plot_id):
        self._get_plot(request, plot_id)
        irrigations = IrrigationSchedule.objects.filter(plot_id=plot_id).order_by('scheduled_time')
        return _ok(MobileIrrigationSerializer(irrigations, many=True).data)

    def post(self, request, plot_id):
        plot = self._get_plot(request, plot_id)
        data = request.data.copy()
        data['plot'] = plot.id
        serializer = MobileIrrigationSerializer(data=data)
        if not serializer.is_valid():
            return _err(serializer.errors)
        irrigation = serializer.save()
        return Response(
            {'success': True, 'data': MobileIrrigationSerializer(irrigation).data},
            status=status.HTTP_201_CREATED,
        )


class MobileIrrigationDetailView(APIView):
    """
    PUT    /api/mobile/irrigation/<id>/   → update status or schedule
    DELETE /api/mobile/irrigation/<id>/
    """
    permission_classes = [permissions.IsAuthenticated]

    def _get_irr(self, request, pk):
        return get_object_or_404(IrrigationSchedule, pk=pk, plot__farm__user=request.user)

    def put(self, request, pk):
        irr = self._get_irr(request, pk)
        serializer = MobileIrrigationSerializer(irr, data=request.data, partial=True)
        if not serializer.is_valid():
            return _err(serializer.errors)
        serializer.save()
        return _ok(serializer.data)

    def delete(self, request, pk):
        irr = self._get_irr(request, pk)
        irr.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


# ─── Crop Fields ──────────────────────────────────────────────────────────────

class MobileCropFieldListCreateView(APIView):
    """
    GET  /api/mobile/crop-fields/?farm=<id>&crop_type=<type>
    POST /api/mobile/crop-fields/
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        qs = CropField.objects.filter(farm__user=request.user).select_related('farm')
        farm_id = request.query_params.get('farm')
        crop_type = request.query_params.get('crop_type')
        if farm_id:
            qs = qs.filter(farm_id=farm_id)
        if crop_type:
            qs = qs.filter(crop_type=crop_type)
        return _ok(MobileCropFieldSerializer(qs, many=True).data)

    def post(self, request):
        serializer = MobileCropFieldSerializer(data=request.data)
        if not serializer.is_valid():
            return _err(serializer.errors)
        # Validate the farm belongs to the user
        farm_id = request.data.get('farm')
        if farm_id:
            get_object_or_404(Farm, pk=farm_id, user=request.user)
        field = serializer.save()
        return Response(
            {'success': True, 'data': MobileCropFieldSerializer(field).data},
            status=status.HTTP_201_CREATED,
        )


class MobileCropFieldDetailView(APIView):
    """
    GET    /api/mobile/crop-fields/<id>/
    PUT    /api/mobile/crop-fields/<id>/
    DELETE /api/mobile/crop-fields/<id>/
    """
    permission_classes = [permissions.IsAuthenticated]

    def _get_field(self, request, pk):
        return get_object_or_404(CropField, pk=pk, farm__user=request.user)

    def get(self, request, pk):
        return _ok(MobileCropFieldSerializer(self._get_field(request, pk)).data)

    def put(self, request, pk):
        field = self._get_field(request, pk)
        serializer = MobileCropFieldSerializer(field, data=request.data, partial=True)
        if not serializer.is_valid():
            return _err(serializer.errors)
        serializer.save()
        return _ok(serializer.data)

    def delete(self, request, pk):
        self._get_field(request, pk).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


# ─── Farm Sensor Data ─────────────────────────────────────────────────────────

class MobileFarmDataView(APIView):
    """
    GET  /api/mobile/farms/<farm_id>/sensor-data/   → latest 30 readings
    POST /api/mobile/farms/<farm_id>/sensor-data/   → push new sensor reading
    Body: { temperature?, humidity?, nitrogen?, phosphorus?, potassium?, soil_ph? }
    """
    permission_classes = [permissions.IsAuthenticated]

    def _get_farm(self, request, farm_id):
        return get_object_or_404(Farm, pk=farm_id, user=request.user)

    def get(self, request, farm_id):
        self._get_farm(request, farm_id)
        readings = FarmData.objects.filter(farm_id=farm_id).order_by('-created_at')[:30]
        return _ok(MobileFarmDataSerializer(readings, many=True).data)

    def post(self, request, farm_id):
        farm = self._get_farm(request, farm_id)
        data = request.data.copy()
        data['farm'] = farm.id
        serializer = MobileFarmDataSerializer(data=data)
        if not serializer.is_valid():
            return _err(serializer.errors)
        reading = serializer.save()
        return Response(
            {'success': True, 'data': MobileFarmDataSerializer(reading).data},
            status=status.HTTP_201_CREATED,
        )


# ═══════════════════════════════════════════════════════════════════════════════
# AI ENDPOINTS
# ═══════════════════════════════════════════════════════════════════════════════

class MobileAIBaseView(APIView):
    """Base class for mobile AI views - handles timing & optional result storage."""
    permission_classes = [permissions.IsAuthenticated]
    model_type = None  # set in subclass

    def post(self, request):
        start = time.time()
        try:
            # Handle both nested {"data": {...}} and flat payload structures
            if isinstance(request.data, dict) and 'data' in request.data:
                input_data = request.data['data']
            else:
                input_data = request.data.copy() if hasattr(request.data, 'copy') else request.data
                if isinstance(input_data, dict) and 'save' in input_data:
                    input_data.pop('save')

            if isinstance(input_data, str):
                try:
                    input_data = json.loads(input_data)
                except Exception:
                    input_data = {}

            result = self.run_prediction(request, input_data)
            exec_time = round(time.time() - start, 3)

            # Optionally persist result
            if self.model_type and request.data.get('save', False):
                AICoreResult.objects.create(
                    user=request.user,
                    model_type=self.model_type,
                    input_data=input_data,
                    result_data=result,
                    execution_time=exec_time,
                )

            return _ok({'result': result, 'execution_time_s': exec_time})

        except Exception as exc:
            return _err(str(exc))

    def run_prediction(self, request, input_data):
        raise NotImplementedError


class MobileCVView(APIView):
    """
    POST /api/mobile/ai/plant-disease/
    Multipart: image=<file>
    Returns: { prediction, confidence, class_id }
    """
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request):
        image_file = request.FILES.get('image')
        if not image_file:
            return _err('No image uploaded.')

        with tempfile.NamedTemporaryFile(delete=False, suffix='.jpg') as tmp:
            for chunk in image_file.chunks():
                tmp.write(chunk)
            tmp_path = tmp.name

        try:
            result = cv_model.predict_image(tmp_path)
            return _ok({
                'prediction': result.get('prediction', 'Unknown'),
                'confidence': result.get('confidence', 0),
                'class_id': result.get('class_id', -1),
            })
        except Exception as exc:
            return _err(str(exc))
        finally:
            if os.path.exists(tmp_path):
                os.remove(tmp_path)


class MobileCropRecommendationView(MobileAIBaseView):
    """
    POST /api/mobile/ai/crop-recommendation/
    Body: { data: { N, P, K, temperature, humidity, ph, rainfall } }
    """
    model_type = 'crop_recommendation'

    def run_prediction(self, request, input_data):
        return HFCropRecommender.get_recommendation(input_data)


class MobileIrrigationRecommendationView(MobileAIBaseView):
    """
    POST /api/mobile/ai/irrigation/
    Body: { data: { crop_type, soil_moisture, temperature, ... } }
    """
    model_type = 'irrigation_optimizer'

    def run_prediction(self, request, input_data):
        return HFIrrigationRecommender.get_recommendation(input_data)


class MobileYieldPredictionView(MobileAIBaseView):
    """
    POST /api/mobile/ai/yield/
    Body: { data: { crop_type, area, ndvi, soil_ph, ... } }
    """
    model_type = 'yield_prediction'

    def run_prediction(self, request, input_data):
        return HFYieldPredictor.get_prediction(input_data)


class MobileForecastView(APIView):
    """
    GET /api/mobile/ai/forecast/?commodity=Wheat
    GET /api/mobile/ai/forecast/             → list all commodities
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        commodity = request.query_params.get('commodity', '').strip()
        if commodity:
            data = HFForecastService.get_forecast(commodity)
            if not data:
                return _err(f"No forecast for '{commodity}'", status.HTTP_502_BAD_GATEWAY)
            return _ok({'commodity': commodity, 'forecast': data})
        commodities = HFForecastService.get_commodities()
        return _ok({'commodities': commodities})


class MobileAIHistoryView(APIView):
    """
    GET /api/mobile/ai/history/?model_type=<type>&limit=20
    Returns the authenticated user's AI prediction history.
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        qs = AICoreResult.objects.filter(user=request.user).order_by('-created_at')
        model_type = request.query_params.get('model_type')
        if model_type:
            qs = qs.filter(model_type=model_type)
        limit = min(int(request.query_params.get('limit', 20)), 100)
        qs = qs[:limit]
        return _ok(MobileAIResultSerializer(qs, many=True).data)


# ═══════════════════════════════════════════════════════════════════════════════
# NEWS
# ═══════════════════════════════════════════════════════════════════════════════

class MobileNewsListView(APIView):
    """
    GET /api/mobile/news/?category=<id>&limit=20&offset=0
    Public endpoint - no auth required.
    """
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        qs = News.objects.filter(is_published=True).select_related('category', 'author')
        category_id = request.query_params.get('category')
        if category_id:
            qs = qs.filter(category_id=category_id)
        qs = qs.order_by('-created_at')
        limit = min(int(request.query_params.get('limit', 20)), 100)
        offset = int(request.query_params.get('offset', 0))
        total = qs.count()
        page = qs[offset: offset + limit]
        return _ok({
            'total': total,
            'limit': limit,
            'offset': offset,
            'results': MobileNewsListSerializer(page, many=True).data,
        })


class MobileNewsDetailView(APIView):
    """
    GET /api/mobile/news/<pk>/
    Public endpoint.
    """
    permission_classes = [permissions.AllowAny]

    def get(self, request, pk):
        news = get_object_or_404(News, pk=pk, is_published=True)
        return _ok(MobileNewsDetailSerializer(news).data)


class MobileNewsCategoriesView(APIView):
    """
    GET /api/mobile/news/categories/
    """
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        cats = Category.objects.all()
        return _ok(MobileCategorySerializer(cats, many=True).data)


class MobileCommentView(APIView):
    """
    GET  /api/mobile/news/<news_id>/comments/   → approved comments
    POST /api/mobile/news/<news_id>/comments/   → add comment (requires auth)
    """
    def get_permissions(self):
        if self.request.method == 'POST':
            return [permissions.IsAuthenticated()]
        return [permissions.AllowAny()]

    def get(self, request, news_id):
        get_object_or_404(News, pk=news_id, is_published=True)
        comments = Comment.objects.filter(news_id=news_id, is_approved=True).order_by('created_at')
        return _ok(MobileCommentSerializer(comments, many=True).data)

    def post(self, request, news_id):
        get_object_or_404(News, pk=news_id, is_published=True)
        serializer = MobileCommentSerializer(data=request.data)
        if not serializer.is_valid():
            return _err(serializer.errors)
        comment = serializer.save(user=request.user, news_id=news_id)
        return Response(
            {'success': True, 'data': MobileCommentSerializer(comment).data,
             'message': 'Comment submitted and awaiting approval.'},
            status=status.HTTP_201_CREATED,
        )


# ═══════════════════════════════════════════════════════════════════════════════
# HEALTH CHECK
# ═══════════════════════════════════════════════════════════════════════════════

class MobileHealthView(APIView):
    """GET /api/mobile/health/ — used by Flutter app on startup."""
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        return Response({'status': 'ok', 'service': 'farmtech-mobile-api'})


class MobileCropLifecycleView(APIView):
    """GET /api/mobile/crops/lifecycle/ — return crop lifecycle constants."""
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        return _ok({
            "wheat": {
                "crop": "Wheat",
                "daysToHarvest": 120,
                "stages": [
                    {"name": "Germination", "window": "0-10 days", "action": "Keep seedbed evenly moist.", "icon": "spa"},
                    {"name": "Tillering", "window": "21-45 days", "action": "Check nitrogen and weed pressure.", "icon": "grass"},
                    {"name": "Heading", "window": "70-95 days", "action": "Watch disease and water stress.", "icon": "eco"},
                    {"name": "Maturity", "window": "100-120 days", "action": "Reduce irrigation before harvest.", "icon": "agriculture"}
                ]
            },
            "maize": {
                "crop": "Maize",
                "daysToHarvest": 110,
                "stages": [
                    {"name": "Emergence", "window": "0-12 days", "action": "Protect seedlings and confirm stand.", "icon": "spa"},
                    {"name": "Vegetative", "window": "20-55 days", "action": "Apply nitrogen and monitor moisture.", "icon": "grass"},
                    {"name": "Tasseling", "window": "60-80 days", "action": "Avoid water stress during pollination.", "icon": "eco"},
                    {"name": "Grain Fill", "window": "80-110 days", "action": "Track pests and prepare harvest.", "icon": "agriculture"}
                ]
            },
            "rice": {
                "crop": "Rice",
                "daysToHarvest": 135,
                "stages": [
                    {"name": "Seedling", "window": "0-20 days", "action": "Keep shallow water and strong nursery growth.", "icon": "water_drop"},
                    {"name": "Tillering", "window": "20-55 days", "action": "Maintain water depth and nitrogen.", "icon": "grass"},
                    {"name": "Panicle", "window": "60-95 days", "action": "Watch blast risk and nutrient balance.", "icon": "eco"},
                    {"name": "Ripening", "window": "100-135 days", "action": "Drain gradually before harvest.", "icon": "agriculture"}
                ]
            },
            "tomato": {
                "crop": "Tomato",
                "daysToHarvest": 95,
                "stages": [
                    {"name": "Transplant", "window": "0-14 days", "action": "Reduce shock with steady moisture.", "icon": "spa"},
                    {"name": "Vegetative", "window": "15-40 days", "action": "Prune, stake, and feed evenly.", "icon": "grass"},
                    {"name": "Flowering", "window": "40-65 days", "action": "Avoid heat and moisture swings.", "icon": "local_florist"},
                    {"name": "Fruiting", "window": "65-95 days", "action": "Harvest ripe clusters frequently.", "icon": "agriculture"}
                ]
            },
            "potato": {
                "crop": "Potato",
                "daysToHarvest": 100,
                "stages": [
                    {"name": "Sprouting", "window": "0-20 days", "action": "Keep beds loose and moist.", "icon": "spa"},
                    {"name": "Canopy Growth", "window": "20-45 days", "action": "Hill soil and monitor blight.", "icon": "grass"},
                    {"name": "Tuber Bulking", "window": "45-85 days", "action": "Keep moisture consistent.", "icon": "eco"},
                    {"name": "Maturation", "window": "85-100 days", "action": "Stop irrigation before lifting.", "icon": "agriculture"}
                ]
            },
            "mango": {
                "crop": "Mango",
                "daysToHarvest": 150,
                "stages": [
                    {"name": "Flush", "window": "0-35 days", "action": "Support new leaves and pest control.", "icon": "park"},
                    {"name": "Flowering", "window": "35-70 days", "action": "Protect bloom from stress.", "icon": "local_florist"},
                    {"name": "Fruit Set", "window": "70-110 days", "action": "Thin weak fruit and manage irrigation.", "icon": "eco"},
                    {"name": "Ripening", "window": "110-150 days", "action": "Harvest by color and firmness.", "icon": "agriculture"}
                ]
            },
            "jowar (sorghum)": {
                "crop": "Jowar (Sorghum)",
                "daysToHarvest": 115,
                "stages": [
                    {"name": "Emergence", "window": "0-10 days", "action": "Confirm stand and early weeds.", "icon": "spa"},
                    {"name": "Vegetative", "window": "20-50 days", "action": "Scout shoot fly and moisture stress.", "icon": "grass"},
                    {"name": "Booting", "window": "55-80 days", "action": "Protect heads and maintain nutrients.", "icon": "eco"},
                    {"name": "Grain Maturity", "window": "90-115 days", "action": "Harvest when grain hardens.", "icon": "agriculture"}
                ]
            },
            "green fodder": {
                "crop": "Green Fodder",
                "daysToHarvest": 60,
                "stages": [
                    {"name": "Establishment", "window": "0-12 days", "action": "Keep germination moisture steady.", "icon": "spa"},
                    {"name": "Leaf Growth", "window": "12-35 days", "action": "Apply nitrogen after establishment.", "icon": "grass"},
                    {"name": "Canopy", "window": "35-50 days", "action": "Irrigate for fast biomass gain.", "icon": "eco"},
                    {"name": "Cutting", "window": "50-60 days", "action": "Cut before quality declines.", "icon": "agriculture"}
                ]
            }
        })
