/// DreamBrew AI — Kaydedilmiş Okuma Modeli
///
/// Hive ile yerel olarak saklanan rüya/fal okumalarının veri modeli.
/// Her okuma benzersiz bir [id], tipini belirten [type],
/// ve favori durumunu tutan [isFavorite] alanı içerir.
library;

import 'package:hive/hive.dart';

/// Okuma türlerini temsil eden enum.
/// Hive TypeAdapter'da int değer olarak saklanır.
enum SavedReadingType {
  /// Rüya yorumu
  dream,

  /// Kahve falı okuması
  fortune,
}

/// Cihazda saklanan tek bir okumayı temsil eder.
///
/// Hem rüya yorumu hem de kahve falı okumaları bu modelde
/// birleşik olarak saklanır. [type] alanı ayrımı sağlar.
class SavedReading extends HiveObject {
  /// Benzersiz okuma kimliği (UUID)
  final String id;

  /// Okuma türü: dream veya fortune
  final SavedReadingType type;

  /// Okumanın yapıldığı tarih
  final DateTime date;

  /// Okuma başlığı (ör. "Falling into an Abyss", "The Obsidian Owl")
  final String title;

  /// Okuma içeriğinin tam metni
  final String content;

  /// Kullanıcı bu okumayı favorilere eklediyse true
  bool isFavorite;

  /// Okumada tespit edilen sembollerin listesi (örn. kuş, uçmak)
  final List<String>? symbols;

  SavedReading({
    required this.id,
    required this.type,
    required this.date,
    required this.title,
    required this.content,
    this.isFavorite = false,
    this.symbols,
  });

  /// Favori durumunu tersine çevirir.
  void toggleFavorite() {
    isFavorite = !isFavorite;
  }

  /// Değerleri kopyalayarak yeni bir SavedReading oluşturur.
  SavedReading copyWith({
    String? id,
    SavedReadingType? type,
    DateTime? date,
    String? title,
    String? content,
    bool? isFavorite,
    List<String>? symbols,
  }) {
    return SavedReading(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
      isFavorite: isFavorite ?? this.isFavorite,
      symbols: symbols ?? this.symbols,
    );
  }

  @override
  String toString() =>
      'SavedReading(id: $id, type: $type, title: $title, isFavorite: $isFavorite)';
}
