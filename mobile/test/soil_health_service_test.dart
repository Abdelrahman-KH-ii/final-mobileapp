import 'package:farmtec/core/services/soil_health_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('treats out-of-Egypt coordinates as zero score', () {
    expect(SoilHealthService.isInEgyptLocation(10.0, 30.0), isFalse);
  });

  test('extracts the overall score from the model payload', () {
    final score = SoilHealthService.scoreFromPayload({
      'data': {'overall_score': 78.4},
    });

    expect(score, 78.4);
  });
}
