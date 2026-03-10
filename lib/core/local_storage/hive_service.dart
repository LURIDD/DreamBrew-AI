/// DreamBrew AI — Hive CRUD Servis Katmanı
///
/// [SavedReading] nesneleri üzerinde temel CRUD işlemleri sunar.
/// Uygulama genelinde tekil (singleton) olarak kullanılır.
library;

import 'package:hive/hive.dart';
import 'saved_reading.dart';

/// Hive üzerinden [SavedReading] verilerine erişim sağlayan servis.
///
/// Kullanım:
/// ```dart
/// final service = HiveService();
/// await service.init(); // uygulama başlangıcında bir kez çağrılır
///
/// await service.saveReading(reading);
/// final all = service.getAllReadings();
/// ```
class HiveService {
  /// Hive box ismi — tüm okumaların tutulduğu kutu
  static const String _boxName = 'saved_readings';

  /// Açılmış Hive box referansı
  late Box<SavedReading> _box;

  /// Box'a dışarıdan da erişim sağlamak için getter
  Box<SavedReading> get box => _box;

  /// Hive box'ını açar. [setupLocator] içinde çağrılmalıdır.
  Future<void> init() async {
    _box = await Hive.openBox<SavedReading>(_boxName);
  }

  // ─── CRUD İşlemleri ─────────────────────────────────────────

  /// Yeni bir okumayı kaydeder. Anahtar olarak [reading.id] kullanılır.
  Future<void> saveReading(SavedReading reading) async {
    await _box.put(reading.id, reading);
  }

  /// Tüm kayıtlı okumaları tarihe göre sıralı döner (en yeni önce).
  List<SavedReading> getAllReadings() {
    final readings = _box.values.toList();
    readings.sort((a, b) => b.date.compareTo(a.date));
    return readings;
  }

  /// Belirli bir türdeki okumaları döner.
  List<SavedReading> getReadingsByType(SavedReadingType type) {
    return getAllReadings().where((r) => r.type == type).toList();
  }

  /// Bir okumanın favori durumunu tersine çevirip kaydeder.
  Future<void> toggleFavorite(String id) async {
    final reading = _box.get(id);
    if (reading != null) {
      reading.toggleFavorite();
      await reading.save(); // HiveObject.save() — aynı key ile günceller
    }
  }

  /// Bir okumayı kalıcı olarak siler.
  Future<void> deleteReading(String id) async {
    await _box.delete(id);
  }

  /// Tüm okumaları kalıcı olarak siler.
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Box'taki toplam okuma sayısını döner.
  int get count => _box.length;
}
