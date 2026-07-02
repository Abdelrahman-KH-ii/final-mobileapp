import 'dart:convert';

import 'package:farmtec/core/config/farmbrain_config.dart';
import 'package:http/http.dart' as http;

/// Client for the agriculture RAG chat API on Hugging Face.
class FarmbrainChatService {
  FarmbrainChatService({http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final http.Client _http;

  static const _timeout = Duration(seconds: 120);

  Uri get _chatUri => Uri.parse('${FarmbrainConfig.apiBaseUrl}/chat');

  Future<String> sendMessage(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      throw const FarmbrainChatException('Message cannot be empty');
    }

    final response = await _http
        .post(
          _chatUri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'message': trimmed}),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw FarmbrainChatException(
        'Chat API returned status ${response.statusCode}',
      );
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw const FarmbrainChatException('Unexpected API response format');
    }

    var reply = body['answer'];
    reply ??= body['response'];
    if (reply is! String || reply.trim().isEmpty) {
      throw const FarmbrainChatException('Empty response from assistant');
    }

    return reply.trim();
  }

  void dispose() => _http.close();
}

class FarmbrainChatException implements Exception {
  const FarmbrainChatException(this.message);
  final String message;

  @override
  String toString() => message;
}
