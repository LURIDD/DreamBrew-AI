/// DreamBrew AI — Kahve Falı Yorumu Domain Varlığı
/// Bu katman yalnızca saf Dart sınıfları içerir; framework bağımlılığı yoktur.
library;

/// Fincan ya da tabakta görülen bir kahve sembolünü temsil eder.
class CoffeeSymbol {
  /// Sembolün adı (ör. "kuş", "yılan", "merdiven", "kalp")
  final String name;

  /// Sembolün konumu: fincan içi veya tabak
  /// Olası değerler: "fincan" | "tabak"
  final String position;

  /// Sembolün falsal yorumu
  final String meaning;

  const CoffeeSymbol({
    required this.name,
    required this.position,
    required this.meaning,
  });

  /// JSON map'ten CoffeeSymbol oluşturur.
  factory CoffeeSymbol.fromMap(Map<String, dynamic> map) {
    return CoffeeSymbol(
      name: map['name'] as String,
      position: map['position'] as String,
      meaning: map['meaning'] as String,
    );
  }

  /// CoffeeSymbol'ü JSON map'e dönüştürür.
  Map<String, dynamic> toMap() {
    return {'name': name, 'position': position, 'meaning': meaning};
  }

  @override
  String toString() =>
      'CoffeeSymbol(name: $name, position: $position, meaning: $meaning)';
}

/// Bir kahve falı oturumunu temsil eden ana entity sınıfı.
///
/// Kullanıcının kahve fincanı fotoğrafını yapay zekaya göndermesi sonucu
/// dönen falı tüm alt başlıklarıyla tutar.
class FortuneReading {
  /// Benzersiz oturum kimliği (UUID)
  final String id;

  /// Falın bakıldığı tarih/saat
  final DateTime readingDate;

  /// Fincan ve tabakta tespit edilen semboller
  final List<CoffeeSymbol> symbols;

  /// Falın genel temaları (ör. "yolculuk", "yeni başlangıç", "bekleyiş")
  final List<String> themes;

  /// Falın hangi zaman dilimine işaret ettiği
  /// Olası değerler: "yakın gelecek (1-3 hafta)" | "orta vadeli (1-3 ay)" | "uzak gelecek (3+ ay)"
  final String timeframe;

  /// Aşk ve ilişkiler için özel mesaj
  final String loveMessage;

  /// Kariyer ve iş hayatı için özel mesaj
  final String careerMessage;

  /// Genel hayat mesajı
  final String generalMessage;

  /// Şans sayısı
  final int luckyNumber;

  /// Şans rengi
  final String luckyColor;

  /// Kullanıcıya yönelik öneriler
  final List<String> suggestions;

  const FortuneReading({
    required this.id,
    required this.readingDate,
    required this.symbols,
    required this.themes,
    required this.timeframe,
    required this.loveMessage,
    required this.careerMessage,
    required this.generalMessage,
    required this.luckyNumber,
    required this.luckyColor,
    required this.suggestions,
  });

  /// JSON map'ten FortuneReading oluşturur.
  factory FortuneReading.fromMap(Map<String, dynamic> map) {
    return FortuneReading(
      id: map['id'] as String,
      readingDate: DateTime.parse(map['readingDate'] as String),
      symbols: (map['symbols'] as List)
          .map((e) => CoffeeSymbol.fromMap(e as Map<String, dynamic>))
          .toList(),
      themes: List<String>.from(map['themes'] as List),
      timeframe: map['timeframe'] as String,
      loveMessage: map['loveMessage'] as String,
      careerMessage: map['careerMessage'] as String,
      generalMessage: map['generalMessage'] as String,
      luckyNumber: map['luckyNumber'] as int,
      luckyColor: map['luckyColor'] as String,
      suggestions: List<String>.from(map['suggestions'] as List),
    );
  }

  /// FortuneReading'i JSON map'e dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'readingDate': readingDate.toIso8601String(),
      'symbols': symbols.map((s) => s.toMap()).toList(),
      'themes': themes,
      'timeframe': timeframe,
      'loveMessage': loveMessage,
      'careerMessage': careerMessage,
      'generalMessage': generalMessage,
      'luckyNumber': luckyNumber,
      'luckyColor': luckyColor,
      'suggestions': suggestions,
    };
  }

  /// Değerleri kopyalayarak yeni bir FortuneReading oluşturur.
  FortuneReading copyWith({
    String? id,
    DateTime? readingDate,
    List<CoffeeSymbol>? symbols,
    List<String>? themes,
    String? timeframe,
    String? loveMessage,
    String? careerMessage,
    String? generalMessage,
    int? luckyNumber,
    String? luckyColor,
    List<String>? suggestions,
  }) {
    return FortuneReading(
      id: id ?? this.id,
      readingDate: readingDate ?? this.readingDate,
      symbols: symbols ?? this.symbols,
      themes: themes ?? this.themes,
      timeframe: timeframe ?? this.timeframe,
      loveMessage: loveMessage ?? this.loveMessage,
      careerMessage: careerMessage ?? this.careerMessage,
      generalMessage: generalMessage ?? this.generalMessage,
      luckyNumber: luckyNumber ?? this.luckyNumber,
      luckyColor: luckyColor ?? this.luckyColor,
      suggestions: suggestions ?? this.suggestions,
    );
  }

  @override
  String toString() {
    return 'FortuneReading(id: $id, themes: $themes, timeframe: $timeframe)';
  }
}
