import 'package:farmtec/features/auth/presentation/screens/login_screen.dart';
import 'package:farmtec/features/auth/presentation/screens/signup_screen.dart';
import 'package:farmtec/features/farm_selection/presentation/screens/farm_selection_screen.dart';
import 'package:farmtec/features/home/presentation/screens/home_screen.dart';
import 'package:farmtec/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:farmtec/features/profile/presentation/screens/support_info_screen.dart';
import 'package:farmtec/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';

Route<dynamic> onGenerateRoutes(RouteSettings settings) {
  switch (settings.name) {
    case SplashScreen.routeName:
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    case OnboardingScreen.routeName:
      return MaterialPageRoute(builder: (_) => const OnboardingScreen());
    case LoginScreen.routeName:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case SignupScreen.routeName:
      return MaterialPageRoute(builder: (_) => const SignupScreen());
    case FarmSelectionScreen.routeName:
      return MaterialPageRoute(builder: (_) => const FarmSelectionScreen());
    case HomeScreen.routeName:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    case SupportInfoScreen.helpRouteName:
      return MaterialPageRoute(
        builder: (_) => const SupportInfoScreen(page: SupportInfoPage.helpFaq),
      );
    case SupportInfoScreen.privacyRouteName:
      return MaterialPageRoute(
        builder:
            (_) => const SupportInfoScreen(page: SupportInfoPage.privacyPolicy),
      );
    case SupportInfoScreen.aboutRouteName:
      return MaterialPageRoute(
        builder: (_) => const SupportInfoScreen(page: SupportInfoPage.aboutUs),
      );
    case SupportInfoScreen.contactRouteName:
      return MaterialPageRoute(
        builder: (_) => const SupportInfoScreen(page: SupportInfoPage.contact),
      );
    default:
      return MaterialPageRoute(builder: (_) => const SplashScreen());
  }
}
