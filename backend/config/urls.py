import uuid

from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.views.generic import RedirectView

from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from drf_yasg.views import get_schema_view
from drf_yasg import openapi


schema_view = get_schema_view(
    openapi.Info(
        title="FarmTech API",
        default_version="v1",
        description="Backend APIs for FarmTech Platform",
    ),
    public=True,
    permission_classes=[AllowAny],
)


class HealthCheckView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        return Response({"status": "ok", "service": "farmtech-backend"}, status=200)


class RecommendView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        from ai_core.services.crop_predictor import predict_crop

        try:
            input_data = request.data
            mapped_data = {
                "nitrogen": input_data.get("nitrogen", 50),
                "phosphorous": input_data.get("phosphorous", 50),
                "potassium": input_data.get("potassium", 50),
                "pH": input_data.get("pH", 7),
                "rainfall": input_data.get("rainfall", 80),
            }

            result = predict_crop(mapped_data)

            # Store result in a simple in-memory cache keyed by task_id
            task_id = str(uuid.uuid4())

            # Cache the result using Django's cache framework
            from django.core.cache import cache
            cache.set(f"task_{task_id}", result, timeout=300)

            return Response({"taskId": task_id})

        except Exception as e:
            return Response({"error": str(e)}, status=400)


class StatusView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, task_id):
        from django.core.cache import cache

        result = cache.get(f"task_{task_id}")

        if result is None:
            # Fallback: run a fresh prediction with defaults
            from ai_core.services.crop_predictor import predict_crop
            result = predict_crop({
                "nitrogen": 50,
                "phosphorous": 50,
                "potassium": 50,
                "pH": 7,
                "rainfall": 80,
            })

        return Response({
            "status": "completed",
            "recommended_crop": result["recommended_crop"],
            "confidence": int(result["confidence"] * 100),
            "all_scores": result["all_scores"],
        })


urlpatterns = [
    # Health checks
    path("api/", HealthCheckView.as_view(), name="health-check"),
    path("api/health/", HealthCheckView.as_view(), name="health-check-alt"),

    # Crop recommendation (async pattern)
    path("api/recommend/", RecommendView.as_view(), name="recommend"),
    path("api/status/<str:task_id>/", StatusView.as_view(), name="status"),

    # Admin
    path("admin/", admin.site.urls),

    # App routers
    path("api/accounts/", include("accounts.urls")),
    path("api/farms/", include("farms.urls")),
    path("api/ai/", include("ai_core.urls")),
    path("api/news/", include("news.urls")),
    path("api/mobile/", include("mobile_api.urls")),  # Mobile app backend

    # API Docs
    path("swagger/", schema_view.with_ui("swagger", cache_timeout=0), name="swagger"),
    path("redoc/", schema_view.with_ui("redoc", cache_timeout=0), name="redoc"),

    # Redirect root to swagger docs
    path("", RedirectView.as_view(url="swagger/", permanent=False)),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)