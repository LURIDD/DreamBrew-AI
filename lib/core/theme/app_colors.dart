import 'package:flutter/material.dart';

/// DreamBrew AI renk paleti.
/// Mistik morlar, koyu laciverdler ve altın sarısı vurgular.
///
/// Dark ve Light mod desteği:
/// - Statik sabitler dark moda aittir (geriye uyumluluk).
/// - [of] factory metodu ile context bazlı theme-aware renkler alınabilir.
class AppColors {
  AppColors._();

  // --- Arka Plan Renkleri ---
  /// Ana arka plan: Çok koyu lacivert-mor
  static const Color background = Color(0xFF0D0A1E);

  /// İkincil arka plan: Biraz daha açık koyu mor
  static const Color surface = Color(0xFF1A1040);

  /// Kart arka planı katmanı
  static const Color cardBackground = Color(0xFF1E1350);

  // --- Birincil (Rüya) Renkleri ---
  /// Birincil mor: Canlı mistik mor
  static const Color primary = Color(0xFF7C3AED);

  /// Birincil açık tonu
  static const Color primaryLight = Color(0xFF9B6DFF);

  /// Birincil koyu tonu
  static const Color primaryDark = Color(0xFF4C1D95);

  /// Rüya kartı arka planı: Koyu mor gradient başlangıcı
  static const Color dreamCardStart = Color(0xFF2D1B69);

  /// Rüya kartı arka planı: Gradient sonu
  static const Color dreamCardEnd = Color(0xFF1A0E3F);

  // --- İkincil (Kahve Falı) Renkleri ---
  /// İkincil altın/amber: Kahve falı vurgusu
  static const Color secondary = Color(0xFFF59E0B);

  /// İkincil açık tonu
  static const Color secondaryLight = Color(0xFFFBBF24);

  /// Kahve falı kartı arka planı: Koyu kahve gradient başlangıcı
  static const Color fortuneCardStart = Color(0xFF3D1A00);

  /// Kahve falı kartı arka planı: Gradient sonu
  static const Color fortuneCardEnd = Color(0xFF1A0A00);

  // --- Metin Renkleri ---
  /// Birincil metin: Beyaz
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// İkincil metin: Soluk beyaz/mor
  static const Color textSecondary = Color(0xFFB8A9D4);

  /// Üçüncül metin: Çok soluk, ipucu metni
  static const Color textHint = Color(0xFF6B5E8E);

  // --- Hata / Uyarı Renkleri ---
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFCA5A5);

  // --- Diğer ---
  /// Yıldız / vurgu beyazı
  static const Color starColor = Color(0xFFE2D9F3);

  /// Gradient tanımları
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1040), Color(0xFF0D0A1E)],
  );

  static const LinearGradient dreamCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [dreamCardStart, dreamCardEnd],
  );

  static const LinearGradient fortuneCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [fortuneCardStart, fortuneCardEnd],
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, primaryLight],
  );

  // ==========================================================
  // Light Tema Renkleri
  // ==========================================================

  // --- Light Arka Plan Renkleri ---
  static const Color backgroundLight = Color(0xFFF7F5FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardBackgroundLight = Color(0xFFF0ECF7);

  // --- Light Metin Renkleri ---
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF4A4A6A);
  static const Color textHintLight = Color(0xFF9090AA);

  // --- Light Kart Renkleri ---
  static const Color dreamCardStartLight = Color(0xFFEDE7FA);
  static const Color dreamCardEndLight = Color(0xFFE0D5F5);
  static const Color fortuneCardStartLight = Color(0xFFFFF3E0);
  static const Color fortuneCardEndLight = Color(0xFFFFE8CC);

  // ==========================================================
  // Context-Aware Renk Sistemi
  // ==========================================================

  /// Mevcut tema moduna göre uygun rengi döndürür.
  /// Kullanım: `AppColors.of(context).bg`
  static ThemedColors of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const ThemedColors._dark()
        : const ThemedColors._light();
  }
}

/// Tema moduna göre renk sağlayan yardımcı sınıf.
class ThemedColors {
  final Color bg;
  final Color surfaceColor;
  final Color cardBg;
  final Color textMain;
  final Color textSub;
  final Color textMuted;
  final Color dreamStart;
  final Color dreamEnd;
  final Color fortuneStart;
  final Color fortuneEnd;

  const ThemedColors._dark()
      : bg = AppColors.background,
        surfaceColor = AppColors.surface,
        cardBg = AppColors.cardBackground,
        textMain = AppColors.textPrimary,
        textSub = AppColors.textSecondary,
        textMuted = AppColors.textHint,
        dreamStart = AppColors.dreamCardStart,
        dreamEnd = AppColors.dreamCardEnd,
        fortuneStart = AppColors.fortuneCardStart,
        fortuneEnd = AppColors.fortuneCardEnd;

  const ThemedColors._light()
      : bg = AppColors.backgroundLight,
        surfaceColor = AppColors.surfaceLight,
        cardBg = AppColors.cardBackgroundLight,
        textMain = AppColors.textPrimaryLight,
        textSub = AppColors.textSecondaryLight,
        textMuted = AppColors.textHintLight,
        dreamStart = AppColors.dreamCardStartLight,
        dreamEnd = AppColors.dreamCardEndLight,
        fortuneStart = AppColors.fortuneCardStartLight,
        fortuneEnd = AppColors.fortuneCardEndLight;
}
