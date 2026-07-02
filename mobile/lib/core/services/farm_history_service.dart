import 'dart:convert';

import 'package:farmtec/core/constants/farm_icons.dart';
import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum OperationType {
  fertilizer,
  irrigation,
  diseaseScan,
  cropPlant,
  weatherAlert,
  ndviScan,
  aiModelRun,
}

class FarmOperation {
  final String id;
  final String farmId;
  final OperationType type;
  final String title;
  final String description;
  final DateTime timestamp;
  /// Localization key for [title]. When set, UI uses [titleKey] instead of [title].
  final String? titleKey;

  const FarmOperation({
    required this.id,
    required this.farmId,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.titleKey,
  });

  IconData get icon {
    switch (type) {
      case OperationType.fertilizer:
        return Icons.science_rounded;
      case OperationType.irrigation:
        return Icons.water_drop_rounded;
      case OperationType.diseaseScan:
        return Icons.biotech_rounded;
      case OperationType.ndviScan:
        return Icons.satellite_alt_rounded;
      case OperationType.cropPlant:
        return FarmIcons.farm;
      case OperationType.weatherAlert:
        return Icons.cloud_rounded;
      case OperationType.aiModelRun:
        return Icons.psychology_rounded;
    }
  }

  Color get color {
    switch (type) {
      case OperationType.fertilizer:
        return const Color(0xFF9C27B0);
      case OperationType.irrigation:
        return const Color(0xFF2196F3);
      case OperationType.diseaseScan:
        return const Color(0xFF4CAF50);
      case OperationType.ndviScan:
        return const Color(0xFF1B8F3A);
      case OperationType.cropPlant:
        return const Color(0xFFFF9800);
      case OperationType.weatherAlert:
        return const Color(0xFFF44336);
      case OperationType.aiModelRun:
        return const Color(0xFF7B1FA2);
    }
  }

  String displayTitle(AppLocalizations l) =>
      titleKey != null ? l.tr(titleKey!) : title;

  Map<String, dynamic> toJson() => {
    'id': id,
    'farmId': farmId,
    'type': type.index,
    'title': title,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
    if (titleKey != null) 'titleKey': titleKey,
  };

  factory FarmOperation.fromJson(Map<String, dynamic> json) => FarmOperation(
    id: json['id'],
    farmId: json['farmId'],
    type: OperationType.values[json['type']],
    title: json['title'],
    description: json['description'],
    timestamp: DateTime.parse(json['timestamp']),
    titleKey: json['titleKey'] as String?,
  );
}

class FarmHistoryService extends ChangeNotifier {
  static const _key = 'farm_history';
  List<FarmOperation> _operations = [];

  List<FarmOperation> get operations => _operations;

  FarmHistoryService() {
    _load();
  }

  List<FarmOperation> getForFarm(String farmId) =>
      _operations.where((o) => o.farmId == farmId).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr != null) {
      final List<dynamic> list = jsonDecode(jsonStr);
      _operations = list.map((e) => FarmOperation.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_operations.map((o) => o.toJson()).toList());
    await prefs.setString(_key, jsonStr);
  }

  Future<void> addOperation(FarmOperation op) async {
    _operations.insert(0, op);
    await _save();
    notifyListeners();
  }

  /// Drops history entries for farms that no longer exist.
  Future<void> pruneOrphaned(Set<String> validFarmIds) async {
    final filtered =
        _operations.where((o) => validFarmIds.contains(o.farmId)).toList();
    if (filtered.length == _operations.length) return;
    _operations = filtered;
    await _save();
    notifyListeners();
  }
}

