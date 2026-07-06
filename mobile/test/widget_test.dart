import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/providers/locale_provider.dart';
import 'package:farmtec/core/providers/theme_provider.dart';
import 'package:farmtec/core/services/farm_history_service.dart';
import 'package:farmtec/core/services/farm_service.dart';
import 'package:farmtec/core/services/notification_settings_service.dart';
import 'package:farmtec/core/services/yield_prediction_service.dart';
import 'package:farmtec/features/ai_models/presentation/screens/ai_model_run_screen.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/ai_models_view.dart';
import 'package:farmtec/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

  testWidgets('AI models view renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ar')],
        home: const Scaffold(body: AIModelsView()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(AIModelsView), findsOneWidget);
  });

  test('model formatter localizes disease detection output', () {
    final l = AppLocalizations(const Locale('en'));
    final result = formatModelResult(
      modelName: 'Disease Detection',
      data: 'Leaf spot detected',
      l: l,
    );

    expect(result, contains('Plant Analysis'));
  });

  test('model formatter parses fertilizer planner nested API response', () {
    final l = AppLocalizations(const Locale('en'));
    final result = formatModelResult(
      modelName: 'Fertilizer Planner',
      data: {
        'data': [
          '### Recommendation',
          {
            'status': 'success',
            'Selected Fertilizer': 'Urea (46% N)',
            'recommended_fertilizer_amount': 3.2,
            'schedule_summary': 'Apply at tillering stage',
          }
        ]
      },
      l: l,
    );

    expect(result, contains('Fertilizer'));
    expect(result, contains('Urea (46% N)'));
    expect(result, contains('3.2'));
    expect(result, contains('Apply at tillering stage'));
  });

  test('model formatter parses crop rotation response', () {
    final l = AppLocalizations(const Locale('en'));
    final result = formatModelResult(
      modelName: 'Crop Rotation',
      data: {
        'recommended_crop': 'maize',
        'reason': 'Improves soil nitrogen balance',
        'rotation_plan': 'Plant maize after wheat for two seasons',
      },
      l: l,
    );

    expect(result, contains('Crop Rotation'));
    expect(result, contains('Maize'));
    expect(result, contains('Improves soil nitrogen balance'));
  });
}
