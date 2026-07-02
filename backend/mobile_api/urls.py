"""
Mobile API URL Configuration
Base: /api/mobile/

All responses follow the format:
  Success → { "success": true, "data": {...} }
  Error   → { "success": false, "error": "..." }
"""

from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView

from .views import (
    # Auth
    MobileRegisterView,
    MobileLoginView,
    MobileLogoutView,
    MobileProfileView,
    MobileChangePasswordView,

    # Dashboard
    MobileDashboardView,

    # Farms
    MobileFarmListCreateView,
    MobileFarmDetailView,
    MobileFarmDataView,

    # Plots
    MobilePlotListCreateView,
    MobilePlotDetailView,

    # Soil
    MobileSoilRecordView,

    # Irrigation
    MobileIrrigationListCreateView,
    MobileIrrigationDetailView,

    # Crop Fields
    MobileCropFieldListCreateView,
    MobileCropFieldDetailView,

    # AI
    MobileCVView,
    MobileCropRecommendationView,
    MobileIrrigationRecommendationView,
    MobileYieldPredictionView,
    MobileForecastView,
    MobileAIHistoryView,

    # News
    MobileNewsListView,
    MobileNewsDetailView,
    MobileNewsCategoriesView,
    MobileCommentView,

    # Health
    MobileHealthView,
    MobileCropLifecycleView,
)

app_name = 'mobile_api'

urlpatterns = [

    # ── Health ────────────────────────────────────────────────────────────────
    path('health/', MobileHealthView.as_view(), name='health'),
    path('crops/lifecycle/', MobileCropLifecycleView.as_view(), name='crop-lifecycle'),

    # ── Auth ──────────────────────────────────────────────────────────────────
    path('auth/register/',        MobileRegisterView.as_view(),       name='register'),
    path('auth/login/',           MobileLoginView.as_view(),          name='login'),
    path('auth/logout/',          MobileLogoutView.as_view(),         name='logout'),
    path('auth/profile/',         MobileProfileView.as_view(),        name='profile'),
    path('auth/change-password/', MobileChangePasswordView.as_view(), name='change-password'),
    path('auth/token/refresh/',   TokenRefreshView.as_view(),         name='token-refresh'),

    # ── Dashboard ─────────────────────────────────────────────────────────────
    path('dashboard/', MobileDashboardView.as_view(), name='dashboard'),

    # ── Farms ─────────────────────────────────────────────────────────────────
    path('farms/',                             MobileFarmListCreateView.as_view(), name='farm-list'),
    path('farms/<int:pk>/',                    MobileFarmDetailView.as_view(),     name='farm-detail'),
    path('farms/<int:farm_id>/sensor-data/',   MobileFarmDataView.as_view(),       name='farm-sensor-data'),
    path('farms/<int:farm_id>/plots/',         MobilePlotListCreateView.as_view(), name='plot-list'),

    # ── Plots ─────────────────────────────────────────────────────────────────
    path('plots/<int:pk>/',                    MobilePlotDetailView.as_view(),     name='plot-detail'),
    path('plots/<int:plot_id>/soil/',          MobileSoilRecordView.as_view(),     name='soil-list'),
    path('plots/<int:plot_id>/irrigation/',    MobileIrrigationListCreateView.as_view(), name='irrigation-list'),

    # ── Irrigation ────────────────────────────────────────────────────────────
    path('irrigation/<int:pk>/', MobileIrrigationDetailView.as_view(), name='irrigation-detail'),

    # ── Crop Fields ───────────────────────────────────────────────────────────
    path('crop-fields/',         MobileCropFieldListCreateView.as_view(), name='cropfield-list'),
    path('crop-fields/<int:pk>/', MobileCropFieldDetailView.as_view(),   name='cropfield-detail'),

    # ── AI ────────────────────────────────────────────────────────────────────
    path('ai/plant-disease/',        MobileCVView.as_view(),                     name='ai-plant-disease'),
    path('ai/crop-recommendation/',  MobileCropRecommendationView.as_view(),     name='ai-crop-rec'),
    path('ai/irrigation/',           MobileIrrigationRecommendationView.as_view(), name='ai-irrigation'),
    path('ai/yield/',                MobileYieldPredictionView.as_view(),        name='ai-yield'),
    path('ai/forecast/',             MobileForecastView.as_view(),               name='ai-forecast'),
    path('ai/history/',              MobileAIHistoryView.as_view(),              name='ai-history'),

    # ── News ──────────────────────────────────────────────────────────────────
    path('news/',                         MobileNewsListView.as_view(),      name='news-list'),
    path('news/categories/',              MobileNewsCategoriesView.as_view(), name='news-categories'),
    path('news/<int:pk>/',                MobileNewsDetailView.as_view(),    name='news-detail'),
    path('news/<int:news_id>/comments/',  MobileCommentView.as_view(),       name='news-comments'),
]
