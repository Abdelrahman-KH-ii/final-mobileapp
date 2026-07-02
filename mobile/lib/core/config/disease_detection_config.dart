/// Vision LLM API for plant disease detection (Hugging Face Space).
abstract final class DiseaseDetectionConfig {
  static const String predictUrl = String.fromEnvironment(
    'DISEASE_DETECTION_API_URL',
    defaultValue: 'https://b1r-14n15-plantvision.hf.space/predict',
  );
}
