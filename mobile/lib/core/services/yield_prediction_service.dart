import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class YieldPredictionService extends ChangeNotifier {
  static const _yieldKey = 'latest_predicted_yield';
  static const _cropKey = 'latest_predicted_crop';
  static const _fieldKey = 'latest_predicted_field';
  static const _unitKey = 'latest_predicted_unit';

  double _yieldPerHa = 4.5;
  String _crop = 'Wheat';
  String _field = 'Field Alpha';
  String _unit = 't/ha';

  double get yieldPerHa => _yieldPerHa;
  String get crop => _crop;
  String get field => _field;
  String get unit => _unit;

  YieldPredictionService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _yieldPerHa = prefs.getDouble(_yieldKey) ?? _yieldPerHa;
    _crop = prefs.getString(_cropKey) ?? _crop;
    _field = prefs.getString(_fieldKey) ?? _field;
    _unit = prefs.getString(_unitKey) ?? _unit;
    notifyListeners();
  }

  Future<void> updatePrediction({
    required double yieldPerHa,
    required String crop,
    required String field,
    String unit = 't/ha',
  }) async {
    _yieldPerHa = yieldPerHa;
    _crop = crop;
    _field = field;
    _unit = unit;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_yieldKey, yieldPerHa);
    await prefs.setString(_cropKey, crop);
    await prefs.setString(_fieldKey, field);
    await prefs.setString(_unitKey, unit);
    notifyListeners();
  }
}
