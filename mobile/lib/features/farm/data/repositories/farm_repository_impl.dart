import 'package:farmtec/core/services/api_client.dart';
import 'package:farmtec/features/farm/data/datasources/farm_local_datasource.dart';
import 'package:farmtec/features/farm/domain/entities/farm.dart';
import 'package:farmtec/features/farm/domain/repositories/farm_repository.dart';

/// Farm repository that keeps a local cache (SharedPreferences) and
/// syncs with the Django mobile API (/api/mobile/farms/).
///
/// Strategy:
/// - On read  → try remote first, fall back to cache on error.
/// - On write → call remote, then refresh local cache.
class FarmRepositoryImpl implements FarmRepository {
  FarmRepositoryImpl({
    FarmLocalDataSource? dataSource,
    ApiClient? apiClient,
  })  : _dataSource = dataSource ?? FarmLocalDataSource(),
        _api = apiClient ?? ApiClient();

  final FarmLocalDataSource _dataSource;
  final ApiClient _api;

  List<Farm> _farms = [];
  String? _selectedFarmId;

  // ─── Read ──────────────────────────────────────────────────────────────────

  @override
  Future<List<Farm>> getFarms() async {
    try {
      // Try remote first
      final response = await _api.get('farms/');
      final data = response['data'] as List<dynamic>;
      _farms = data
          .map((item) => Farm.fromApiJson(item as Map<String, dynamic>))
          .toList();
      // Keep local cache in sync
      await _dataSource.saveFarms(_farms, _selectedFarmId);
    } catch (_) {
      // Fallback to local cache
      if (_farms.isEmpty) {
        _farms = await _dataSource.loadFarms();
      }
    }
    return List.unmodifiable(_farms);
  }

  @override
  Future<Farm?> getSelectedFarm() async {
    if (_farms.isEmpty) await getFarms();
    _selectedFarmId ??= await _dataSource.loadSelectedFarmId();
    if (_farms.isEmpty) return null;
    return _farms.firstWhere(
      (f) => f.id == _selectedFarmId,
      orElse: () => _farms.first,
    );
  }

  // ─── Select ────────────────────────────────────────────────────────────────

  @override
  Future<void> selectFarm(String farmId) async {
    _selectedFarmId = farmId;
    await _dataSource.saveFarms(_farms, farmId);
  }

  // ─── Create ────────────────────────────────────────────────────────────────

  @override
  Future<void> addFarm(Farm farm) async {
    try {
      // POST to backend
      final response = await _api.post('farms/', body: farm.toApiJson());
      final created = Farm.fromApiJson(response['data'] as Map<String, dynamic>);
      _farms = [..._farms, created];
      _selectedFarmId = created.id;
    } catch (_) {
      // Offline fallback: store locally with temp id
      _farms = [..._farms, farm];
      _selectedFarmId = farm.id;
    }
    await _dataSource.saveFarms(_farms, _selectedFarmId);
  }

  // ─── Update ────────────────────────────────────────────────────────────────

  @override
  Future<void> updateFarm(Farm farm) async {
    try {
      final response = await _api.put('farms/${farm.id}/', body: farm.toApiJson());
      final updated = Farm.fromApiJson(response['data'] as Map<String, dynamic>);
      _farms = _farms.map((f) => f.id == farm.id ? updated : f).toList();
    } catch (_) {
      // Offline fallback: update locally
      _farms = _farms.map((f) => f.id == farm.id ? farm : f).toList();
    }
    await _dataSource.saveFarms(_farms, _selectedFarmId);
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

  @override
  Future<void> removeFarm(String farmId) async {
    try {
      await _api.delete('farms/$farmId/');
    } catch (_) {
      // Best-effort; still remove locally
    }
    _farms = _farms.where((f) => f.id != farmId).toList();
    if (_selectedFarmId == farmId) {
      _selectedFarmId = _farms.isNotEmpty ? _farms.first.id : null;
    }
    await _dataSource.saveFarms(_farms, _selectedFarmId);
  }
}
