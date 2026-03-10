/// DreamBrew AI — Hive Tabanlı Geçmiş Repository Implementasyonu
///
/// [IHistoryRepository] arayüzünü Hive ile uygular.
/// [HiveService] üzerinden tüm CRUD işlemlerini gerçekleştirir.
library;

import '../../../../core/local_storage/hive_service.dart';
import '../../../../core/local_storage/saved_reading.dart';
import '../../domain/repositories/i_history_repository.dart';

/// Hive kullanarak kaydedilmiş okumaları yöneten repository.
///
/// DI (get_it) aracılığıyla enjekte edilir.
/// İleride farklı bir veri kaynağına geçildiğinde yalnızca
/// service_locator kayıt satırı değiştirilir.
class HiveHistoryRepository implements IHistoryRepository {
  final HiveService _hiveService;

  HiveHistoryRepository(this._hiveService);

  @override
  Future<List<SavedReading>> getAll() async {
    return _hiveService.getAllReadings();
  }

  @override
  Future<List<SavedReading>> getByType(SavedReadingType type) async {
    return _hiveService.getReadingsByType(type);
  }

  @override
  Future<void> save(SavedReading reading) async {
    await _hiveService.saveReading(reading);
  }

  @override
  Future<void> toggleFavorite(String id) async {
    await _hiveService.toggleFavorite(id);
  }

  @override
  Future<void> delete(String id) async {
    await _hiveService.deleteReading(id);
  }

  @override
  Future<void> clearAll() async {
    await _hiveService.clearAll();
  }
}
