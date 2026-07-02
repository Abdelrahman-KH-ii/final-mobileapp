import 'dart:convert';

import 'package:farmtec/features/farm/domain/entities/farm.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmLocalDataSource {
  static const _farmsKey = 'user_farms';
  static const _selectedFarmKey = 'selected_farm_id';

  Future<List<Farm>> loadFarms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_farmsKey);
    if (jsonStr == null) return [];

    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list.map((e) => Farm.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<String?> loadSelectedFarmId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedFarmKey);
  }

  Future<void> saveFarms(List<Farm> farms, String? selectedFarmId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _farmsKey,
      jsonEncode(farms.map((f) => f.toJson()).toList()),
    );
    if (selectedFarmId != null) {
      await prefs.setString(_selectedFarmKey, selectedFarmId);
    }
  }
}
