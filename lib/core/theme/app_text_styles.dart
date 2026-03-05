import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// DreamBrew AI tipografi sistemi.
/// Logo/başlıklar için Cinzel (mistik, serif),
/// gövde metni için Inter (modern, sans-serif) kullanılmaktadır.
class AppTextStyles {
  AppTextStyles._();

  // --- Logo & Başlık Stilleri (Cinzel) ---

  /// Uygulama logosu için büyük başlık stili
  static TextStyle get logoTitle => GoogleFonts.cinzel(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 1.5,
  );

  /// AppBar logo metni (normal boyut)
  static TextStyle get appBarLogo => GoogleFonts.cinzel(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryLight,
    letterSpacing: 1.0,
  );

  /// Büyük bölüm başlıkları
  static TextStyle get headlineLarge => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  /// Orta bölüm başlıkları
  static TextStyle get headlineMedium => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // --- Kart Stilleri ---

  /// Kart başlığı
  static TextStyle get cardTitle => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Kart açıklaması
  static TextStyle get cardDescription => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // --- Buton Stilleri ---

  /// Birincil buton metni
  static TextStyle get buttonPrimary => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  // --- Gövde Metin Stilleri ---

  /// Normal gövde metni
  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  /// Küçük yardımcı metin
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    letterSpacing: 1.5,
  );

  /// Selamlama başlığı (Home ekranı)
  static TextStyle get greetingTitle => GoogleFonts.inter(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
}
