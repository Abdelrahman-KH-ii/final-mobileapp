"""
Services module for AI Core

Provides model loaders, prediction engines, and utilities for AI model inference.
"""

from ai_core.services.model_loader import (
    crop_model,
    fertilizer_model,
    irrigation_model,
    price_forecast_model,
    scenario_model,
    yield_model,
    cv_model,
)

__all__ = [
    "crop_model",
    "fertilizer_model",
    "irrigation_model",
    "price_forecast_model",
    "scenario_model",
    "yield_model",
    "cv_model",
]
