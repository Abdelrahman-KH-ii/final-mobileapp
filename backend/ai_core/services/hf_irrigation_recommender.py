import requests
import logging

logger = logging.getLogger(__name__)


class HFIrrigationRecommender:
    """Service to interact with the Hugging Face Irrigation Recommendation Space."""

    API_URL = "https://b1r-14n15-irrigation.hf.space/predict"

    @staticmethod
    def get_recommendation(input_data: dict) -> dict:
        """Helper for view integration."""
        return HFIrrigationRecommender.predict_irrigation(input_data)

    @staticmethod
    def predict_irrigation(input_data: dict) -> dict:
        """
        Sends prediction request to the HF Irrigation Space API.

        The HF Space expects:
            POST /predict
            Body: {"data": {"temperature": 30, "humidity": 45, "moisture": 30,
                            "soil_type": "Loamy", "crop_type": "wheat"}}

        Returns dict with keys:
            irrigation_need_mm (float)
            irrigation_class   (str, e.g. "🔴 High")
        """
        try:
            payload = {"data": input_data}
            response = requests.post(
                HFIrrigationRecommender.API_URL,
                json=payload,
                timeout=15,
                headers={"Content-Type": "application/json"},
            )

            logger.info(
                f"HF Irrigation API response: {response.status_code} — {response.text[:200]}"
            )

            if response.status_code == 200:
                return response.json()

            logger.error(
                f"HF Irrigation API Error {response.status_code}: {response.text}"
            )
            return {"error": f"API returned status {response.status_code}: {response.text[:200]}"}

        except requests.exceptions.Timeout:
            logger.error("HF Irrigation API timed out")
            return {"error": "Prediction service timed out. Please try again."}

        except requests.exceptions.ConnectionError as e:
            logger.error(f"HF Irrigation API connection error: {e}")
            return {"error": "Cannot reach irrigation prediction service."}

        except requests.exceptions.RequestException as e:
            logger.error(f"HF Irrigation API request error: {e}")
            return {"error": f"Request failed: {str(e)}"}
