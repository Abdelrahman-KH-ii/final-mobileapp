import 'package:farmtec/core/services/push_notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsService extends ChangeNotifier {
  static const _pushKey = 'notifications_push_enabled';
  static const _weatherKey = 'notifications_weather_enabled';
  static const _marketKey = 'notifications_market_enabled';

  bool _pushEnabled = true;
  bool _weatherAlerts = true;
  bool _marketPriceAlerts = false;

  bool get pushEnabled => _pushEnabled;
  bool get weatherAlerts => _pushEnabled && _weatherAlerts;
  bool get marketPriceAlerts => _pushEnabled && _marketPriceAlerts;
  bool get weatherSwitchValue => _weatherAlerts;
  bool get marketSwitchValue => _marketPriceAlerts;

  NotificationSettingsService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _pushEnabled = prefs.getBool(_pushKey) ?? _pushEnabled;
    _weatherAlerts = prefs.getBool(_weatherKey) ?? _weatherAlerts;
    _marketPriceAlerts = prefs.getBool(_marketKey) ?? _marketPriceAlerts;
    notifyListeners();
  }

  Future<void> setPushEnabled(bool value) async {
    _pushEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushKey, value);
    if (value) {
      await PushNotificationService.instance.requestPermission();
    }
    notifyListeners();
  }

  Future<void> setWeatherAlerts(bool value) async {
    _weatherAlerts = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_weatherKey, value);
    notifyListeners();
  }

  Future<void> setMarketPriceAlerts(bool value) async {
    _marketPriceAlerts = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_marketKey, value);
    notifyListeners();
  }
}
