import 'package:farmtec/core/providers/locale_provider.dart';
import 'package:farmtec/core/providers/theme_provider.dart';
import 'package:farmtec/core/services/farm_history_service.dart';
import 'package:farmtec/core/services/farm_service.dart';
import 'package:farmtec/core/services/notification_settings_service.dart';
import 'package:farmtec/core/services/yield_prediction_service.dart';
import 'package:farmtec/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('FarmTec app smoke test', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => FarmService()),
          ChangeNotifierProvider(create: (_) => FarmHistoryService()),
          ChangeNotifierProvider(create: (_) => YieldPredictionService()),
          ChangeNotifierProvider(create: (_) => NotificationSettingsService()),
        ],
        child: const FarmTecApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
