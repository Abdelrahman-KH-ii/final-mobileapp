import 'package:farmtec/core/services/api_client.dart';
import 'package:farmtec/features/farm/data/datasources/farm_local_datasource.dart';
import 'package:farmtec/features/farm/data/datasources/farm_remote_datasource.dart';
import 'package:farmtec/features/farm/domain/entities/farm.dart';
import 'package:farmtec/features/farm/domain/repositories/farm_repository.dart';

class FarmRepositoryImpl implements FarmRepository {
  FarmRepositoryImpl({
    FarmLocalDataSource? localDataSource,
    FarmRemoteDataSource? remoteDataSource,
    ApiClient? apiClient,
  })  : _local = localDataSource ?? FarmLocalDataSource(),
        _remote = remoteDataSource ?? FarmRemoteDataSource(apiClient: apiClient),
        _api = apiClient ?? ApiClient();

  final FarmLocalDataSource _local;
  final FarmRemoteDataSource _remote;
  final ApiClient _api;

  List<Farm> _farms = [];
  String? _selectedFarmId;

  @override
  Future<List<Farm>> getFarms() async {
    if (_farms.isEmpty) await _reload();
    return List.unmodifiable(_farms);
  }

  @override
  Future<Farm?> getSelectedFarm() async {
    if (_farms.isEmpty) await _reload();
    if (_farms.isEmpty) return null;
    return _farms.firstWhere(
      (f) => f.id == _selectedFarmId,
      orElse: () => _farms.first,
    );
  }

  @override
  Future<void> selectFarm(String farmId) async {
    _selectedFarmId = farmId;
    await _local.saveFarms(_farms, farmId);
  }

  @override
  Future<void> addFarm(Farm farm) async {
    if (await _api.isAuthenticated) {
      final created = await _remote.createFarm(farm.toApiPayload());
      _farms = [..._farms, created];
      _selectedFarmId = created.id;
    } else {
      _farms = [..._farms, farm];
      _selectedFarmId = farm.id;
    }
    await _local.saveFarms(_farms, _selectedFarmId);
  }

  @override
  Future<void> removeFarm(String farmId) async {
    if (await _api.isAuthenticated) {
      await _remote.deleteFarm(farmId);
    }
    _farms = _farms.where((f) => f.id != farmId).toList();
    if (_selectedFarmId == farmId) {
      _selectedFarmId = _farms.isNotEmpty ? _farms.first.id : null;
    }
    await _local.saveFarms(_farms, _selectedFarmId);
  }

  @override
  Future<void> updateFarm(Farm farm) async {
    if (await _api.isAuthenticated) {
      final updated = await _remote.updateFarm(farm.id, farm.toApiPayload());
      final index = _farms.indexWhere((f) => f.id == farm.id);
      if (index != -1) {
        final list = List<Farm>.from(_farms);
        list[index] = updated;
        _farms = list;
      }
    } else {
      final index = _farms.indexWhere((f) => f.id == farm.id);
      if (index != -1) {
        final list = List<Farm>.from(_farms);
        list[index] = farm;
        _farms = list;
      }
    }
    await _local.saveFarms(_farms, _selectedFarmId);
  }

  Future<void> refreshFromServer() async {
    if (!await _api.isAuthenticated) return;
    _farms = await _remote.fetchFarms();
    _selectedFarmId = await _local.loadSelectedFarmId();
    if (_farms.isNotEmpty &&
        (_selectedFarmId == null ||
            !_farms.any((farm) => farm.id == _selectedFarmId))) {
      _selectedFarmId = _farms.first.id;
    }
    await _local.saveFarms(_farms, _selectedFarmId);
  }

  Future<void> _reload() async {
    if (await _api.isAuthenticated) {
      try {
        await refreshFromServer();
        return;
      } catch (_) {
        // Fall back to cached local farms when offline.
      }
    }
    _farms = await _local.loadFarms();
    _selectedFarmId = await _local.loadSelectedFarmId();
    if (_farms.isNotEmpty && _selectedFarmId == null) {
      _selectedFarmId = _farms.first.id;
      await _local.saveFarms(_farms, _selectedFarmId);
    }
  }
}
