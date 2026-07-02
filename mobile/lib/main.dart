import 'package:farmtec/core/helpers/on_generate_routes.dart';
import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/providers/locale_provider.dart';
import 'package:farmtec/core/providers/theme_provider.dart';
import 'package:farmtec/core/services/api_client.dart';
import 'package:farmtec/core/services/auth_service.dart';
import 'package:farmtec/core/services/push_notification_service.dart';
import 'package:farmtec/core/services/app_notification_service.dart';
import 'package:farmtec/core/services/farm_history_service.dart';
import 'package:farmtec/features/farm/data/repositories/farm_repository_impl.dart';
import 'package:farmtec/features/farm/presentation/providers/farm_provider.dart';
import 'package:farmtec/core/services/notification_settings_service.dart';
import 'package:farmtec/core/services/yield_prediction_service.dart';
import 'package:farmtec/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationService.instance.initialize();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => ApiClient()),
        ChangeNotifierProvider(
          create: (context) => AuthService(apiClient: context.read<ApiClient>()),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => FarmHistoryService()),
        ChangeNotifierProvider(
          create: (context) => FarmProvider(
            repository: FarmRepositoryImpl(apiClient: context.read<ApiClient>()),
            historyService: context.read<FarmHistoryService>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => YieldPredictionService()),
        ChangeNotifierProvider(create: (_) => NotificationSettingsService()),
        ChangeNotifierProvider(create: (_) => AppNotificationService()),
      ],
      child: const FarmTecApp(),
    ),
  );
}

class FarmTecApp extends StatelessWidget {
  const FarmTecApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'FarmTec',
      debugShowCheckedModeBanner: false,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: themeProvider.mode,
      builder: (context, child) {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                themeProvider.isDark ? Brightness.light : Brightness.dark,
          ),
        );
        return child!;
      },
      locale: localeProvider.locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: SplashScreen.routeName,
      onGenerateRoute: onGenerateRoutes,
    );
  }
}
