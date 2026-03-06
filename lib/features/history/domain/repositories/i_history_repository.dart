/// DreamBrew AI — Geçmiş Repository Arayüzü (Domain Katmanı)
///
/// Clean Architecture gereği domain katmanında tanımlanan soyut arayüz.
/// [HistoryBloc] yalnızca bu sözleşmeye bağımlıdır; implementasyondan habersizdir.
library;

import '../../../../core/local_storage/saved_reading.dart';

/// Geçmiş okumaların yönetimine ait repository sözleşmesi.
///
/// Hive implementasyonu ([HiveHistoryRepository]) bu arayüzü uygular.
/// İleride farklı bir depolama mekanizmasına (SQLite, Cloud vb.) geçildiğinde
/// yalnızca implementasyon değişir; BLoC etkilenmez.
abstract interface class IHistoryRepository {
  /// Tüm kayıtlı okumaları tarihe göre sıralı döner.
  Future<List<SavedReading>> getAll();

  /// Belirli bir türdeki okumaları döner.
  Future<List<SavedReading>> getByType(SavedReadingType type);

  /// Yeni bir okumayı kaydeder.
  Future<void> save(SavedReading reading);

  /// Bir okumanın favori durumunu tersine çevirir.
  Future<void> toggleFavorite(String id);

  /// Bir okumayı kalıcı olarak siler.
  Future<void> delete(String id);
}
