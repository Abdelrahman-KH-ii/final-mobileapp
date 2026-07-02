import 'dart:convert';

import 'package:farmtec/core/config/disease_detection_config.dart';
import 'package:http/http.dart' as http;

/// Client for the plant disease vision-language model on Hugging Face.
class PlantDiseaseVisionService {
  PlantDiseaseVisionService({http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final http.Client _http;

  static const _timeout = Duration(seconds: 90);

  Future<String> analyze({
    required List<int> imageBytes,
    required String prompt,
  }) async {
    if (imageBytes.isEmpty) {
      throw const PlantDiseaseVisionException('Image is required');
    }

    final imageBase64 = base64Encode(imageBytes);
    final trimmedPrompt = prompt.trim().isEmpty
        ? 'Identify any plant disease in this image and recommend treatment.'
        : prompt.trim();

    final response = await _http
        .post(
          Uri.parse(DiseaseDetectionConfig.predictUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'data': [imageBase64, trimmedPrompt],
            'image': imageBase64,
            'prompt': trimmedPrompt,
            'message': trimmedPrompt,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw PlantDiseaseVisionException(
        'Vision API returned status ${response.statusCode}',
      );
    }

    final body = jsonDecode(utf8.decode(response.bodyBytes));
    final text = _extractText(body);
    if (text == null || text.trim().isEmpty) {
      throw const PlantDiseaseVisionException('Empty response from vision model');
    }
    return text.trim();
  }

  String? _extractText(dynamic body) {
    if (body is String) return body;

    if (body is Map) {
      for (final key in const [
        'response',
        'result',
        'prediction',
        'diagnosis',
        'analysis',
        'output',
        'text',
        'answer',
      ]) {
        final value = body[key];
        final parsed = _extractText(value);
        if (parsed != null && parsed.isNotEmpty) return parsed;
      }

      if (body['data'] != null) {
        return _extractText(body['data']);
      }
    }

    if (body is List && body.isNotEmpty) {
      for (final item in body) {
        final parsed = _extractText(item);
        if (parsed != null && parsed.isNotEmpty) return parsed;
      }
    }

    return null;
  }

  void dispose() => _http.close();
}

class PlantDiseaseVisionException implements Exception {
  const PlantDiseaseVisionException(this.message);
  final String message;

  @override
  String toString() => message;
}
