import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _key = 'app_locale';
  static String currentLanguageCode = 'ar';

  Locale _locale = const Locale('ar');
  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  LocaleProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'ar';
    _locale = Locale(code);
    currentLanguageCode = code;
    notifyListeners();
  }

  Future<void> setLocale(Locale l) async {
    _locale = l;
    currentLanguageCode = l.languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, l.languageCode);
    notifyListeners();
  }

  Future<void> toggleLocale() async {
    final next = isArabic ? const Locale('en') : const Locale('ar');
    await setLocale(next);
  }
}
