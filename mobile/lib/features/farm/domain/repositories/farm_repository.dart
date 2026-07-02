import 'package:farmtec/features/farm/domain/entities/farm.dart';

abstract class FarmRepository {
  Future<List<Farm>> getFarms();
  Future<Farm?> getSelectedFarm();
  Future<void> selectFarm(String farmId);
  Future<void> addFarm(Farm farm);
  Future<void> removeFarm(String farmId);
  Future<void> updateFarm(Farm farm);
}
