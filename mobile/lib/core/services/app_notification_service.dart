import 'dart:convert';

import 'package:farmtec/core/services/notification_settings_service.dart';
import 'package:farmtec/core/services/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum NotifType { general, weather, market, disease }

class AppNotification {
  final String id;
  final String? titleKey;
  final String? bodyKey;
  final Map<String, String>? bodyParams;
  final String title;
  final String body;
  final String timeKey;
  final DateTime createdAt;
  final Color color;
  final bool isRead;
  final NotifType type;

  AppNotification({
    required this.id,
    this.titleKey,
    this.bodyKey,
    this.bodyParams,
    this.title = '',
    this.body = '',
    this.timeKey = 'just_now',
    DateTime? createdAt,
    required this.color,
    this.isRead = false,
    this.type = NotifType.general,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'titleKey': titleKey,
        'bodyKey': bodyKey,
        'bodyParams': bodyParams,
        'title': title,
        'body': body,
        'timeKey': timeKey,
        'createdAt': createdAt.toIso8601String(),
        'color': color.toARGB32(),
        'isRead': isRead,
        'type': type.name,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      titleKey: json['titleKey'] as String?,
      bodyKey: json['bodyKey'] as String?,
      bodyParams: (json['bodyParams'] as Map?)?.cast<String, String>(),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      timeKey: json['timeKey'] as String? ?? 'just_now',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      color: Color(json['color'] as int? ?? 0xFF4CAF50),
      isRead: json['isRead'] as bool? ?? false,
      type: NotifType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => NotifType.general,
      ),
    );
  }
}

class AppNotificationService extends ChangeNotifier {
  static const _storageKey = 'app_notifications_v1';

  final List<AppNotification> _notifications = [];
  bool _loaded = false;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _notifications
        ..clear()
        ..addAll(
          list
              .map((e) => AppNotification.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList(),
        );
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_notifications.map((n) => n.toJson()).toList()),
    );
  }

  Future<void> fetchDynamicAlerts(
    NotificationSettingsService settings, {
    bool showPush = true,
  }) async {
    await load();

    var canPush = settings.pushEnabled && showPush;
    if (canPush) {
      canPush = await PushNotificationService.instance.requestPermission();
    }

    if (settings.marketPriceAlerts) {
      try {
        final res = await http.get(Uri.parse(
            'https://commodities-api.com/api/latest?access_key=DEMO&base=USD&symbols=WHEAT,CORN'));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['data'] != null && data['data']['rates'] != null) {
            final double wheatPrice =
                data['data']['rates']['WHEAT'] ?? 287.50;
            await _addNotif(
              titleKey: 'market_update',
              bodyKey: 'notif_market_changed',
              bodyParams: {'price': wheatPrice.toStringAsFixed(2)},
              color: const Color(0xFF4CAF50),
              type: NotifType.market,
              showPush: canPush,
            );
          }
        } else {
          await _addMockMarket(showPush: canPush);
        }
      } catch (_) {
        await _addMockMarket(showPush: canPush);
      }
    }

    if (settings.weatherAlerts) {
      await _addNotif(
        titleKey: 'weather_alert',
        bodyKey: 'notif_weather_adjust',
        color: const Color(0xFFFF9800),
        type: NotifType.weather,
        showPush: canPush,
      );
    }

    notifyListeners();
  }

  Future<void> _addMockMarket({bool showPush = true}) async {
    await _addNotif(
      titleKey: 'market_update',
      bodyKey: 'notif_market_up',
      color: const Color(0xFF4CAF50),
      type: NotifType.market,
      showPush: showPush,
    );
  }

  Future<void> addManual({
    required String titleKey,
    required String bodyKey,
    Map<String, String>? bodyParams,
    required Color color,
    NotifType type = NotifType.general,
    bool showPush = false,
  }) async {
    await _addNotif(
      titleKey: titleKey,
      bodyKey: bodyKey,
      bodyParams: bodyParams,
      color: color,
      type: type,
      showPush: showPush,
    );
    notifyListeners();
  }

  Future<void> _addNotif({
    String? titleKey,
    String? bodyKey,
    Map<String, String>? bodyParams,
    required Color color,
    required NotifType type,
    bool showPush = true,
  }) async {
    if (_notifications.any((n) => n.titleKey == titleKey && n.type == type)) {
      return;
    }

    final id = 'notif_${DateTime.now().microsecondsSinceEpoch}';
    _notifications.insert(
      0,
      AppNotification(
        id: id,
        titleKey: titleKey,
        bodyKey: bodyKey,
        bodyParams: bodyParams,
        timeKey: 'just_now',
        color: color,
        type: type,
      ),
    );
    await _persist();

    if (showPush) {
      await PushNotificationService.instance.showAlert(
        id: id.hashCode,
        title: _fallbackTitle(titleKey),
        body: _fallbackBody(bodyKey, bodyParams),
      );
    }
  }

  String _fallbackTitle(String? titleKey) {
    switch (titleKey) {
      case 'market_update':
        return 'Market Update';
      case 'weather_alert':
        return 'Weather Alert';
      default:
        return 'FarmTec';
    }
  }

  String _fallbackBody(String? bodyKey, Map<String, String>? params) {
    switch (bodyKey) {
      case 'notif_market_changed':
        return 'Wheat price changed to ${params?['price'] ?? '287.50'}/t.';
      case 'notif_market_up':
        return 'Wheat price up 2.3% to \$287.50/t.';
      case 'notif_weather_adjust':
        return 'Temperature change expected tomorrow. Adjust irrigation.';
      default:
        return 'You have a new farm alert.';
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1 || _notifications[index].isRead) return;
    final item = _notifications[index];
    _notifications[index] = AppNotification(
      id: item.id,
      titleKey: item.titleKey,
      bodyKey: item.bodyKey,
      bodyParams: item.bodyParams,
      title: item.title,
      body: item.body,
      timeKey: item.timeKey,
      createdAt: item.createdAt,
      color: item.color,
      isRead: true,
      type: item.type,
    );
    await _persist();
    notifyListeners();
  }

  Future<void> markAllRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      final item = _notifications[i];
      if (!item.isRead) {
        _notifications[i] = AppNotification(
          id: item.id,
          titleKey: item.titleKey,
          bodyKey: item.bodyKey,
          bodyParams: item.bodyParams,
          title: item.title,
          body: item.body,
          timeKey: item.timeKey,
          createdAt: item.createdAt,
          color: item.color,
          isRead: true,
          type: item.type,
        );
      }
    }
    await _persist();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _notifications.clear();
    await _persist();
    notifyListeners();
  }
}
