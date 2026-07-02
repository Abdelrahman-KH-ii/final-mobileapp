import 'package:farmtec/core/services/farm_history_service.dart';
import 'package:farmtec/features/farm/data/repositories/farm_repository_impl.dart';
import 'package:farmtec/features/farm/domain/entities/farm.dart';
import 'package:farmtec/features/farm/domain/repositories/farm_repository.dart';
import 'package:flutter/material.dart';

export 'package:farmtec/features/farm/domain/entities/farm.dart';

class FarmProvider extends ChangeNotifier {
  FarmProvider({
    FarmRepository? repository,
    FarmHistoryService? historyService,
  })  : _repository = repository ?? FarmRepositoryImpl(),
        _historyService = historyService {
    _load();
  }

  final FarmRepository _repository;
  final FarmHistoryService? _historyService;
  List<Farm> _farms = [];
  Farm? _selectedFarm;

  List<Farm> get farms => _farms;
  Farm? get selectedFarm => _selectedFarm;
  bool get hasFarms => _farms.isNotEmpty;

  Future<void> _load() async {
    final repo = _repository;
    if (repo is FarmRepositoryImpl) {
      await repo.refreshFromServer();
    }
    _farms = await _repository.getFarms();
    _selectedFarm = await _repository.getSelectedFarm();
    final history = _historyService;
    if (history != null) {
      await history.pruneOrphaned(_farms.map((f) => f.id).toSet());
    }
    notifyListeners();
  }

  Future<void> refresh() => _load();

  Future<void> selectFarm(String farmId) async {
    await _repository.selectFarm(farmId);
    _selectedFarm = await _repository.getSelectedFarm();
    notifyListeners();
  }

  Future<void> addFarm(Farm farm) async {
    await _repository.addFarm(farm);
    _farms = await _repository.getFarms();
    _selectedFarm = await _repository.getSelectedFarm();
    notifyListeners();
  }

  Future<void> removeFarm(String farmId) async {
    await _repository.removeFarm(farmId);
    _farms = await _repository.getFarms();
    _selectedFarm = await _repository.getSelectedFarm();
    notifyListeners();
  }

  Future<void> updateFarm(Farm farm) async {
    await _repository.updateFarm(farm);
    _farms = await _repository.getFarms();
    _selectedFarm = await _repository.getSelectedFarm();
    notifyListeners();
  }
}
