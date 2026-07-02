import 'package:farmtec/core/services/farmbrain_chat_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('sendMessage parses response field', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/chat');
      expect(request.method, 'POST');
      return http.Response(
        '{"response":"Tomato blight needs fungicide."}',
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final service = FarmbrainChatService(httpClient: client);
    final reply = await service.sendMessage('What is tomato blight?');

    expect(reply, 'Tomato blight needs fungicide.');
    service.dispose();
  });

  test('sendMessage throws on non-200', () async {
    final client = MockClient((_) async => http.Response('error', 500));
    final service = FarmbrainChatService(httpClient: client);

    expect(
      () => service.sendMessage('hello'),
      throwsA(isA<FarmbrainChatException>()),
    );
    service.dispose();
  });
}
