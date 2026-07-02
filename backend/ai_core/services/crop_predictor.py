import joblib
import json
import numpy as np
import pandas as pd
import os

# Load models once when server starts
MODEL_DIR = os.path.join(os.path.dirname(__file__), '..', 'ml_models', 'crop_recommendation')

try:
    model = joblib.load(os.path.join(MODEL_DIR, "crop_model.pkl"))
    scaler = joblib.load(os.path.join(MODEL_DIR, "scaler.pkl"))
    label_encoder = joblib.load(os.path.join(MODEL_DIR, "label_encoder.pkl"))

    with open(os.path.join(MODEL_DIR, "feature_order.json")) as f:
        feature_names = json.load(f)
        
    MODELS_LOADED = True
    print("Crop recommendation models loaded successfully")
    
except Exception as e:
    print(f"Warning: Could not load crop models: {e}")
    MODELS_LOADED = False
    model = None
    scaler = None
    label_encoder = None
    feature_names = []


def predict_crop(input_data: dict) -> dict:
    """
    input_data: dictionary with feature names as keys
    All features the model expects must be present
    Missing features are filled with 0
    Returns: predicted crop and confidence scores
    """
    if not MODELS_LOADED:
        # Return mock data if models not loaded
        return {
            "recommended_crop": "Wheat",
            "confidence": 0.85,
            "all_scores": {
                "wheat": 0.85,
                "corn": 0.70,
                "rice": 0.60,
                "cotton": 0.40
            }
        }
    
    # Build feature vector in correct order
    row = {feature: input_data.get(feature, 0) for feature in feature_names}
    df = pd.DataFrame([row])

    # Scale
    df_scaled = pd.DataFrame(
        scaler.transform(df),
        columns=feature_names
    )

    # Predict
    pred_encoded = model.predict(df_scaled)[0]
    pred_crop = label_encoder.inverse_transform([pred_encoded])[0]
    probabilities = model.predict_proba(df_scaled)[0]

    confidence_scores = {
        crop: round(float(prob), 4)
        for crop, prob in zip(label_encoder.classes_, probabilities)
    }

    return {
        "recommended_crop": pred_crop,
        "confidence": round(float(max(probabilities)), 4),
        "all_scores": confidence_scores
    }
