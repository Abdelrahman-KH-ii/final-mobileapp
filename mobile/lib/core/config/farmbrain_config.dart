/// FarmBrain RAG API (Hugging Face Space: Rady10/rag-mode-api).
abstract final class FarmbrainConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'FARMBRAIN_API_URL',
    defaultValue: 'https://rady10-rag-mode-api.hf.space',
  );
}
