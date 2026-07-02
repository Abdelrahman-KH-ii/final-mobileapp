import os
import json
import pickle
import joblib
import numpy as np
from sklearn.tree import DecisionTreeClassifier
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import StandardScaler, LabelEncoder

def main():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    ml_models_dir = os.path.join(base_dir, "ai_core", "ml_models")
    os.makedirs(ml_models_dir, exist_ok=True)
    
    print(f"Generating mock models in: {ml_models_dir}")
    
    # 1. Generate models for base LazyModelLoader
    # crop.pkl
    X = np.random.rand(10, 5)
    y = np.array(["wheat", "rice", "corn", "cotton"] * 2 + ["wheat", "rice"])
    le_crop = LabelEncoder().fit(y)
    clf_crop = DecisionTreeClassifier().fit(X, le_crop.transform(y))
    with open(os.path.join(ml_models_dir, "crop.pkl"), "wb") as f:
        pickle.dump(clf_crop, f)
    print("Generated crop.pkl")
    
    # y_pred.pkl (yield)
    reg_yield = LinearRegression().fit(X, np.random.rand(10) * 10)
    with open(os.path.join(ml_models_dir, "y_pred.pkl"), "wb") as f:
        pickle.dump(reg_yield, f)
    print("Generated y_pred.pkl")
    
    # fertilizeropt.pkl
    clf_fert = DecisionTreeClassifier().fit(X, np.array([0, 1, 2, 3] * 2 + [0, 1]))
    with open(os.path.join(ml_models_dir, "fertilizeropt.pkl"), "wb") as f:
        pickle.dump(clf_fert, f)
    print("Generated fertilizeropt.pkl")
    
    # irrigation.pkl
    reg_irr = LinearRegression().fit(X, np.random.rand(10) * 50)
    with open(os.path.join(ml_models_dir, "irrigation.pkl"), "wb") as f:
        pickle.dump(reg_irr, f)
    print("Generated irrigation.pkl")
    
    # p_forcast.pkl
    reg_price = LinearRegression().fit(X, np.random.rand(10) * 1000)
    with open(os.path.join(ml_models_dir, "p_forcast.pkl"), "wb") as f:
        pickle.dump(reg_price, f)
    print("Generated p_forcast.pkl")
    
    # scenario_sem.pkl
    clf_scen = DecisionTreeClassifier().fit(X, np.array([0, 1] * 5))
    with open(os.path.join(ml_models_dir, "scenario_sem.pkl"), "wb") as f:
        pickle.dump(clf_scen, f)
    print("Generated scenario_sem.pkl")
    
    # 2. Generate models for crop_recommendation subfolder
    subfolder = os.path.join(ml_models_dir, "crop_recommendation")
    os.makedirs(subfolder, exist_ok=True)
    
    features = ["nitrogen", "phosphorous", "potassium", "pH", "rainfall"]
    with open(os.path.join(subfolder, "feature_order.json"), "w") as f:
        json.dump(features, f)
        
    X_cr = np.random.rand(20, 5) * 100
    y_cr = np.array(["wheat", "rice", "corn", "cotton", "soybeans"] * 4)
    
    scaler = StandardScaler().fit(X_cr)
    le = LabelEncoder().fit(y_cr)
    model = DecisionTreeClassifier().fit(scaler.transform(X_cr), le.transform(y_cr))
    
    joblib.dump(model, os.path.join(subfolder, "crop_model.pkl"))
    joblib.dump(scaler, os.path.join(subfolder, "scaler.pkl"))
    joblib.dump(le, os.path.join(subfolder, "label_encoder.pkl"))
    print("Generated crop_recommendation/ files (crop_model.pkl, scaler.pkl, label_encoder.pkl, feature_order.json)")

if __name__ == "__main__":
    main()
