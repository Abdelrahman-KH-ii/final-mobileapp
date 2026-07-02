"""
URL Configuration for AI Core

Maps URL patterns to AI model prediction views.
"""

from django.urls import path
from .views import (
    CVView,
    CropRotationView,
    CropRecommendationView,
    PriceForecastingView,
    ScenarioSimulatorView,
    SoilHealthPredictionView,
    FertilizerOptimizerView,
    IrrigationOptimizerView,
    YieldPredictionView,
    CropFieldView,
    CropFieldMapView,
    ForecastView,
)

app_name = 'ai_core'

urlpatterns = [
    # Computer Vision
    path("cv/", CVView.as_view(), name="cv"),
    
    # Crop Management
    path("crop-rotation/", CropRotationView.as_view(), name="crop_rotation"),
    path("crop-recommendation/", CropRecommendationView.as_view(), name="crop_recommendation"),
    
    # Market & Economics
    path("price-forecasting/", PriceForecastingView.as_view(), name="price_forecasting"),
    
    # Simulation
    path("scenario-simulator/", ScenarioSimulatorView.as_view(), name="scenario_simulator"),
    
    # Soil Management
    path("soil-health/", SoilHealthPredictionView.as_view(), name="soil_health"),
    
    # Fertilizer Management
    path("fertilizer/", FertilizerOptimizerView.as_view(), name="fertilizer_optimizer"),
    
    # Irrigation Management
    path("irrigation/", IrrigationOptimizerView.as_view(), name="irrigation_optimizer"),
    
    # Yield Prediction
    path("yield/", YieldPredictionView.as_view(), name="yield_prediction"),
    
    # Crop Fields API
    path("fields/", CropFieldView.as_view(), name="fields_list"),
    path("fields/map/", CropFieldMapView.as_view(), name="fields_map"),

    # Commodity Price Forecast (HF Space)
    path("forecast/", ForecastView.as_view(), name="forecast"),
]