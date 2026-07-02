import requests
import logging

logger = logging.getLogger(__name__)


class HFForecastService:
    """Service to interact with the FarmTech Commodity Forecast HF Space API."""

    BASE_URL = "https://b1r-14n15-forecast.hf.space"

    @staticmethod
    def get_commodities() -> list:
        """Return list of available commodities."""
        try:
            r = requests.get(f"{HFForecastService.BASE_URL}/commodities", timeout=10)
            if r.status_code == 200:
                return r.json()
            return []
        except Exception as e:
            logger.error(f"HF Forecast commodities error: {e}")
            return []

    @staticmethod
    def get_forecast(commodity: str) -> list:
        """
        Return 4-quarter price forecast for a commodity.

        Response shape:
            [
              {"commodity": "Wheat", "year": 2026, "quarter": 3, "price": 2593.67},
              ...
            ]
        """
        try:
            r = requests.get(
                f"{HFForecastService.BASE_URL}/forecast/{commodity}",
                timeout=15,
            )
            logger.info(f"HF Forecast [{commodity}]: {r.status_code} — {r.text[:200]}")
            if r.status_code == 200:
                return r.json()
            logger.error(f"HF Forecast error {r.status_code}: {r.text[:200]}")
            return []
        except requests.exceptions.Timeout:
            logger.error(f"HF Forecast timed out for {commodity}")
            return []
        except Exception as e:
            logger.error(f"HF Forecast request error: {e}")
            return []

    @staticmethod
    def get_all_forecasts() -> dict:
        """Return forecast for ALL commodities keyed by commodity name."""
        commodities = HFForecastService.get_commodities()
        results = {}
        for c in commodities:
            results[c] = HFForecastService.get_forecast(c)
        return results
