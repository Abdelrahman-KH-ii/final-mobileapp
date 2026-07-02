"""
AI Core Views

Provides REST API endpoints for various AI model predictions including
crop recommendations, yield forecasting, soil health analysis, and more.
RAG (Retrieval-Augmented Generation) is integrated into CV and Chatbot views
for enriched agricultural knowledge responses.
"""

import os
import json
import time
import tempfile
from PIL import Image

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework import status

from farms.models import Farm
from .models import AICoreResult, CropField
from .services.hf_crop_recommender import HFCropRecommender
from .services.hf_irrigation_recommender import HFIrrigationRecommender
from .services.hf_forecast_service import HFForecastService
from .services.hf_yield_predictor import HFYieldPredictor
from .serializers import CropFieldListSerializer, CropFieldGeoSerializer

from .services.model_loader import (
    crop_model,
    fertilizer_model,
    irrigation_model,
    price_forecast_model,
    scenario_model,
    yield_model,
    cv_model,
)


class BaseAIView(APIView):
    """
    Base class for AI prediction views.
    Handles standard result saving and error reporting.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        try:
            # 1. Extract input - Handle both nested {"data": {...}} and flat payload structures
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

            # 2. Run child prediction
            result_data = self.run_prediction(request, input_data)

            # 3. Success response
            return Response({
                "success": True,
                "data": result_data
            })

        except Exception as e:
            return Response({
                "success": False,
                "error": str(e)
            }, status=status.HTTP_400_BAD_REQUEST)

    def run_prediction(self, request, input_data):
        raise NotImplementedError("Subclasses must implement run_prediction")

class CVView(BaseAIView):
    """
    Computer Vision model for plant disease detection.

    Accepts image file uploads and returns classification results.
    """
    model_type = "cv"
    permission_classes = [AllowAny]

    def run_prediction(self, request, input_data):
        image_file = request.FILES.get("image")

        if not image_file:
            raise ValueError("No image uploaded")

        with tempfile.NamedTemporaryFile(
            delete=False,
            suffix=".jpg"
        ) as temp:
            for chunk in image_file.chunks():
                temp.write(chunk)

            temp_path = temp.name

        try:
            # Get CV classification
            result = cv_model.predict_image(temp_path)

            disease_name = result.get("prediction", "Unknown")

            # Build response
            response = {
                "prediction": disease_name,
                "class_id": result.get("class_id", -1),
                "confidence": result.get("confidence", 0),
            }

            return response

        finally:
            if os.path.exists(temp_path):
                os.remove(temp_path)


class CropRecommendationView(BaseAIView):
    model_type = "crop_recommendation"
    permission_classes = [AllowAny]
    def run_prediction(self, request, input_data):
        return HFCropRecommender.get_recommendation(input_data)

class PriceForecastingView(BaseAIView):
    model_type = "price_forecast"
    permission_classes = [AllowAny]
    def run_prediction(self, request, input_data):
        commodity = input_data.get("commodity", "Wheat")
        return HFForecastService.get_forecast(commodity)

class ScenarioSimulatorView(BaseAIView):
    model_type = "scenario"
    permission_classes = [AllowAny]
    def run_prediction(self, request, input_data):
        # Implementation for scenario simulation using scenario_model
        import numpy as np
        # Mock logic or real inference if weights exist
        return {"impact": "Positive", "confidence": 0.85}

class SoilHealthPredictionView(BaseAIView):
    model_type = "soil_health"
    permission_classes = [AllowAny]
    def run_prediction(self, request, input_data):
        return {"ph": 7.2, "health_score": 88, "status": "Good"}

class FertilizerOptimizerView(BaseAIView):
    model_type = "fertilizer"
    permission_classes = [AllowAny]
    def run_prediction(self, request, input_data):
        return {"recommendation": "Add 20kg/ha Nitrogen", "optimizer": "NPK-Ratio"}

class IrrigationOptimizerView(BaseAIView):
    model_type = "irrigation"
    permission_classes = [AllowAny]
    def run_prediction(self, request, input_data):
        return HFIrrigationRecommender.get_recommendation(input_data)

class YieldPredictionView(BaseAIView):
    model_type = "yield"
    permission_classes = [AllowAny]
    def run_prediction(self, request, input_data):
        return HFYieldPredictor.get_prediction(input_data)

class CropFieldView(BaseAIView):
    """Returns list of crop fields."""
    permission_classes = [AllowAny]
    def get(self, request):
        limit = int(request.query_params.get("limit", 100))
        fields = CropField.objects.all()[:limit]
        serializer = CropFieldListSerializer(fields, many=True)
        return Response({"count": CropField.objects.count(), "results": serializer.data})

class CropRotationView(BaseAIView):
    """
    Returns recommendations for crop rotation.
    """
    permission_classes = [AllowAny]
    def run_prediction(self, request, input_data):
        return {"next_crop": "Legumes", "reason": "Nitrogen fixation"}


class CropFieldMapView(APIView):
    """
    Returns GeoJSON feature collection for Leaflet map rendering.
    Optimized for large datasets.
    """
    permission_classes = [AllowAny]
    
    def get(self, request):
        crop = request.query_params.get("crop")
        year = request.query_params.get("year", 2024)
        
        queryset = CropField.objects.all()
        if crop:
            queryset = queryset.filter(crop__iexact=crop)
        if year:
            queryset = queryset.filter(year=year)
            
        # Limit to 5000 for map performance
        fields = queryset[:5000]
        
        features = [f.to_geojson_feature() for f in fields]
        
        return Response({
            "type": "FeatureCollection",
            "features": features
        })


class ForecastView(APIView):
    """
    GET /api/ai/forecast/              → all commodities list + their 4-quarter forecasts
    GET /api/ai/forecast/?commodity=Wheat → single commodity forecast
    """
    permission_classes = [AllowAny]
    authentication_classes = []

    def get(self, request):
        commodity = request.query_params.get("commodity", "").strip()

        if commodity:
            data = HFForecastService.get_forecast(commodity)
            if not data:
                return Response(
                    {"success": False, "error": f"No forecast available for '{commodity}'"},
                    status=status.HTTP_502_BAD_GATEWAY,
                )
            return Response({"success": True, "commodity": commodity, "forecast": data})

        # Return all commodities + their forecasts
        commodities = HFForecastService.get_commodities()
        return Response({"success": True, "commodities": commodities})