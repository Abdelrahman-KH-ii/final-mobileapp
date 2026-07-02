"""
Hugging Face Space integration for crop recommendation and image analysis.
API: https://youssef-d1aa-croprecommend.hf.space/predict
"""

import requests
import base64
import logging
from typing import Dict, List, Optional, Union
from io import BytesIO
from PIL import Image

logger = logging.getLogger(__name__)

HF_SPACE_URL = "https://youssef-d1aa-croprecommend.hf.space/predict"


class HFCropRecommender:
    """Integration with Hugging Face Space for crop recommendations and CV analysis."""

    @staticmethod
    def get_recommendation(input_data: dict) -> dict:
        """Helper for view integration."""
        return HFCropRecommender.predict_crop(
            soil_type=input_data.get("soil_type", input_data.get("soilType", "loamy")),
            ph=input_data.get("ph", input_data.get("pH", 6.5)),
            nitrogen=input_data.get("nitrogen", input_data.get("N", 50)),
            phosphorus=input_data.get("phosphorus", input_data.get("phosphorous", input_data.get("P", 30))),
            potassium=input_data.get("potassium", input_data.get("K", 40)),
            temperature=input_data.get("temperature", 25),
            humidity=input_data.get("humidity", 60),
            lat=input_data.get("lat", input_data.get("latitude", 30.0)),
            lon=input_data.get("lon", input_data.get("lng", input_data.get("longitude", 31.0))),
        )

    @staticmethod
    def predict_crop(
        soil_type: str,
        ph: float,
        nitrogen: float,
        phosphorus: float,
        potassium: float,
        temperature: float,
        humidity: float,
        rainfall: float = None,
        lat: float = 30.0,
        lon: float = 31.0,
    ) -> Dict:
        """
        Get crop recommendations based on soil and climate parameters.

        Args:
            soil_type: Type of soil (loamy, sandy, clay, etc.)
            ph: Soil pH value (0-14)
            nitrogen: Nitrogen content (ppm)
            phosphorus: Phosphorus content (ppm)
            potassium: Potassium content (ppm)
            temperature: Temperature in Celsius
            humidity: Humidity percentage (0-100)
            rainfall: Annual rainfall in mm (optional)

        Returns:
            Dict with recommended crops and scores
        """
        try:
            payload = {
                "soil_type": soil_type,
                "ph": float(ph),
                "nitrogen": float(nitrogen),
                "phosphorus": float(phosphorus),
                "potassium": float(potassium),
                "temperature": float(temperature),
                "humidity": float(humidity),
                "lat": float(lat),
                "lon": float(lon),
            }
            if rainfall:
                payload["rainfall"] = float(rainfall)

            response = requests.post(
                HF_SPACE_URL,
                json=payload,
                timeout=30,
            )
            response.raise_for_status()
            return response.json()

        except requests.exceptions.Timeout:
            logger.error("HF Space request timed out")
            return {"error": "Model service timed out", "recommendations": []}
        except requests.exceptions.ConnectionError:
            logger.error("Failed to connect to HF Space")
            return {"error": "Model service unavailable", "recommendations": []}
        except Exception as e:
            logger.error(f"Unexpected error in crop prediction: {str(e)}")
            return {"error": str(e), "recommendations": []}

    @staticmethod
    def predict_from_image(image_input: Union[str, bytes]) -> Dict:
        """
        Analyze crop health or disease from image.

        Args:
            image_input: Image file path or bytes

        Returns:
            Dict with analysis results (disease detection, health status, etc.)
        """
        try:
            # Load image
            if isinstance(image_input, str):
                img = Image.open(image_input)
            else:
                img = Image.open(BytesIO(image_input))

            # Convert to base64
            buffered = BytesIO()
            img.save(buffered, format="JPEG")
            img_base64 = base64.b64encode(buffered.getvalue()).decode()

            payload = {"image": f"data:image/jpeg;base64,{img_base64}"}

            response = requests.post(
                HF_SPACE_URL,
                json=payload,
                timeout=30,
            )
            response.raise_for_status()
            return response.json()

        except Exception as e:
            logger.error(f"Error in image analysis: {str(e)}")
            return {"error": str(e), "analysis": None}

    @staticmethod
    def batch_predict(crop_fields_data: List[Dict]) -> List[Dict]:
        """
        Get recommendations for multiple crop fields.

        Args:
            crop_fields_data: List of dicts with field parameters

        Returns:
            List of prediction results
        """
        results = []
        for field_data in crop_fields_data:
            result = HFCropRecommender.predict_crop(
                soil_type=field_data.get("soil_type"),
                ph=field_data.get("ph", 6.5),
                nitrogen=field_data.get("nitrogen", 50),
                phosphorus=field_data.get("phosphorus", 30),
                potassium=field_data.get("potassium", 40),
                temperature=field_data.get("temperature", 25),
                humidity=field_data.get("humidity", 60),
                rainfall=field_data.get("rainfall"),
            )
            result["field_id"] = field_data.get("field_id")
            results.append(result)

        return results


class CropRecommendationCache:
    """Simple in-memory cache for recommendation results."""

    def __init__(self):
        self.cache = {}

    def get(self, key: str) -> Optional[Dict]:
        """Get cached recommendation."""
        return self.cache.get(key)

    def set(self, key: str, value: Dict, ttl: int = 3600):
        """Cache recommendation with TTL in seconds."""
        self.cache[key] = {"data": value, "ttl": ttl}

    def clear(self):
        """Clear all cache."""
        self.cache.clear()


# Global cache instance
recommendation_cache = CropRecommendationCache()
