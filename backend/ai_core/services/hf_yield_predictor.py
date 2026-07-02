import requests
import logging

logger = logging.getLogger(__name__)


class HFYieldPredictor:
    """Service to call the FarmTec Multi-Crop Yield HF Space API."""

    BASE_URL = "https://youssef-d1aa-yieldpredict.hf.space"

    @staticmethod
    def get_prediction(input_data: dict) -> dict:
        """Helper for view integration."""
        lat = input_data.get("lat", input_data.get("latitude", 30.0))
        lon = input_data.get("lon", input_data.get("lng", input_data.get("longitude", 31.0)))
        year = input_data.get("year", 2025)
        crop = input_data.get("crop", input_data.get("cropType", "wheat"))
        return HFYieldPredictor.predict(lat, lon, year, crop)

    @staticmethod
    def predict(lat: float, lon: float, year: int, crop: str) -> dict:
        """
        Predict crop yield.

        Args:
            lat:  Latitude  (e.g. 30.0 for Cairo)
            lon:  Longitude (e.g. 31.0 for Cairo)
            year: Target year (e.g. 2026)
            crop: Crop name  (e.g. 'wheat', 'rice', 'maize')

        Returns:
            dict with keys: status, crop, yield, unit
            Example: {"status": "success", "crop": "wheat", "yield": 6.774, "unit": "Tonnes/Feddan"}
        """
        payload = {
            "lat": float(lat),
            "lon": float(lon),
            "year": int(year),
            "crop": str(crop).lower().strip(),
        }
        try:
            r = requests.post(
                f"{HFYieldPredictor.BASE_URL}/predict_yield",
                json=payload,
                timeout=30,
            )
            logger.info(f"HF Yield [{crop}]: {r.status_code} — {r.text[:200]}")
            if r.status_code == 200:
                return r.json()
            logger.error(f"HF Yield error {r.status_code}: {r.text[:200]}")
            return {"status": "error", "message": r.text[:200]}
        except requests.exceptions.Timeout:
            logger.error("HF Yield prediction timed out")
            return {"status": "error", "message": "Request timed out"}
        except Exception as e:
            logger.error(f"HF Yield request error: {e}")
            return {"status": "error", "message": str(e)}
