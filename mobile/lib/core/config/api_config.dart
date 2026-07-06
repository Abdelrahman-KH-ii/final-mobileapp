import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Django REST API configuration for FarmTec mobile app.
///
/// Override at build/run time:
///   flutter run --dart-define=FARMTEC_API_URL=http://192.168.1.10:8000
abstract final class ApiConfig {
  static const String _envUrl = String.fromEnvironment('FARMTEC_API_URL');

  /// HuggingFace Space URL (production backend).
  static const String _hfSpaceUrl = 'https://khalilab-backendmb.hf.space';

  /// Resolved API origin (no trailing slash).
  static String get baseUrl {
    if (_envUrl.isNotEmpty) return _stripTrailingSlash(_envUrl);
    // Local dev overrides
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    // Default → HuggingFace Space (production)
    return _hfSpaceUrl;
  }

  static String get mobileApiBase => '$baseUrl/api/mobile';

  static String mobilePath(String path) {
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    return '$mobileApiBase/$normalized';
  }

  static String _stripTrailingSlash(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
}
