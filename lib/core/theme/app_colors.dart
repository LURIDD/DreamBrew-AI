import 'package:flutter/material.dart';

/// DreamBrew AI renk paleti.
/// Mistik morlar, koyu laciverdler ve altın sarısı vurgular.
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
}
