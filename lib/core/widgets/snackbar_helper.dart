/// DreamBrew AI — Snackbar Yardımcı Sınıfı
///
/// Uygulama genelinde tutarlı başarı / hata bildirimlerini gösterir.
/// Tema renkleriyle uyumlu, ikon + mesaj formatında.
library;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Uygulama genelinde kullanılacak Snackbar helper metotları.
///
/// Kullanım:
/// ```dart
/// SnackbarHelper.showSuccess(context, 'Okuma kaydedildi!');
/// SnackbarHelper.showError(context, 'Bir hata oluştu.');
/// ```
class SnackbarHelper {
  SnackbarHelper._();

  /// Başarı mesajı gösterir (yeşil tonda).
  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_outline,
      backgroundColor: const Color(0xFF1B5E20).withValues(alpha: 0.9),
      iconColor: const Color(0xFF66BB6A),
    );
  }

  /// Hata mesajı gösterir (kırmızı tonda).
  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.error_outline,
      backgroundColor: const Color(0xFFB71C1C).withValues(alpha: 0.9),
      iconColor: const Color(0xFFEF5350),
    );
  }

  /// Bilgi mesajı gösterir (mor tonda).
  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.info_outline,
      backgroundColor: AppColors.surface.withValues(alpha: 0.95),
      iconColor: AppColors.primaryLight,
    );
  }

  /// Dahili Snackbar gösterme metodu.
  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
