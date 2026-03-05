/// DreamBrew AI — Rüya Yorumu Domain Varlığı
/// Bu katman yalnızca saf Dart sınıfları içerir; framework bağımlılığı yoktur.
library;

/// Rüyada tespit edilen tek bir sembolü ve anlamını temsil eder.
class DreamSymbol {
  /// Sembolün adı (ör. "uçmak", "yılan", "su")
  final String symbol;

  /// Sembolün yorumu / anlamı
  final String meaning;

  const DreamSymbol({required this.symbol, required this.meaning});

  /// JSON map'ten DreamSymbol oluşturur.
  factory DreamSymbol.fromMap(Map<String, dynamic> map) {
    return DreamSymbol(
      symbol: map['symbol'] as String,
      meaning: map['meaning'] as String,
    );
  }

  /// DreamSymbol'ü JSON map'e dönüştürür.
  Map<String, dynamic> toMap() {
    return {'symbol': symbol, 'meaning': meaning};
  }

  @override
  String toString() => 'DreamSymbol(symbol: $symbol, meaning: $meaning)';
}

/// Bir rüya yorumu oturumunu temsil eden ana entity sınıfı.
///
/// Kullanıcının rüya metnini yapay zekaya göndermesi sonucu dönen
/// yorumu tüm alt başlıklarıyla tutar.
class DreamReading {
  /// Benzersiz oturum kimliği (UUID)
  final String id;

  /// Kullanıcının girdiği ham rüya metni
  final String dreamDescription;

  /// Yorumun yapıldığı tarih/saat
  final DateTime interpretedAt;

  /// Rüyada öne çıkan genel temalar (ör. "dönüşüm", "özgürlük", "kayıp")
  final List<String> themes;

  /// Rüyada tespit edilen semboller ve anlamları
  final List<DreamSymbol> symbols;

  /// Rüyanın genel duygusal tonu (ör. "huzurlu", "kaygılı", "umut dolu")
  final String emotionalTone;

  /// Kullanıcıya yönelik pratik veya ruhsal öneriler
  final List<String> suggestions;

  /// Yapay zekanın tüm yorumu özetleyen ana mesajı
  final String overallMessage;

  const DreamReading({
    required this.id,
    required this.dreamDescription,
    required this.interpretedAt,
    required this.themes,
    required this.symbols,
    required this.emotionalTone,
    required this.suggestions,
    required this.overallMessage,
  });

  /// JSON map'ten DreamReading oluşturur.
  factory DreamReading.fromMap(Map<String, dynamic> map) {
    return DreamReading(
      id: map['id'] as String,
      dreamDescription: map['dreamDescription'] as String,
      interpretedAt: DateTime.parse(map['interpretedAt'] as String),
      themes: List<String>.from(map['themes'] as List),
      symbols: (map['symbols'] as List)
          .map((e) => DreamSymbol.fromMap(e as Map<String, dynamic>))
          .toList(),
      emotionalTone: map['emotionalTone'] as String,
      suggestions: List<String>.from(map['suggestions'] as List),
      overallMessage: map['overallMessage'] as String,
    );
  }

  /// DreamReading'i JSON map'e dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dreamDescription': dreamDescription,
      'interpretedAt': interpretedAt.toIso8601String(),
      'themes': themes,
      'symbols': symbols.map((s) => s.toMap()).toList(),
      'emotionalTone': emotionalTone,
      'suggestions': suggestions,
      'overallMessage': overallMessage,
    };
  }

  /// Değerleri kopyalayarak yeni bir DreamReading oluşturur.
  DreamReading copyWith({
    String? id,
    String? dreamDescription,
    DateTime? interpretedAt,
    List<String>? themes,
    List<DreamSymbol>? symbols,
    String? emotionalTone,
    List<String>? suggestions,
    String? overallMessage,
  }) {
    return DreamReading(
      id: id ?? this.id,
      dreamDescription: dreamDescription ?? this.dreamDescription,
      interpretedAt: interpretedAt ?? this.interpretedAt,
      themes: themes ?? this.themes,
      symbols: symbols ?? this.symbols,
      emotionalTone: emotionalTone ?? this.emotionalTone,
      suggestions: suggestions ?? this.suggestions,
      overallMessage: overallMessage ?? this.overallMessage,
    );
  }

  @override
  String toString() {
    return 'DreamReading(id: $id, themes: $themes, emotionalTone: $emotionalTone)';
  }
}
