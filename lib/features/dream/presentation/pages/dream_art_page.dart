/// DreamBrew AI — Rüya Görseli Sayfası (Bonus UI)
///
/// Rüya yorumundan sonra kullanıcının rüyasını görselleştirmek için
/// tasarlanmış placeholder ekranı.
/// Şimdilik tamamen statik UI — gerçek görsel üretimi sonraki iterasyonda.
/// Tasarım referansı: dream_visualization_art.png
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/dream_reading.dart';

/// Rüya Görseli Sayfası — Placeholder UI
///
/// [DreamReading] bilgisini alarak başlık ve açıklama gösterir.
/// Görsel üretim henüz aktif değil, yalnızca arayüz tasarımı mevcuttur.
class DreamArtPage extends StatelessWidget {
  final DreamReading? reading;

  const DreamArtPage({super.key, this.reading});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomNavBar(context),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Dream Art',
          style: GoogleFonts.cinzel(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryLight,
            letterSpacing: 0.8,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          children: [
            // Görsel placeholder alanı
            _buildImagePlaceholder(),
            const SizedBox(height: 28),

            // Başlık
            Text(
              'Your Dream Visualization',
              style: AppTextStyles.headlineMedium.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),

            // Alt açıklama
            Text(
              reading != null
                  ? 'A mystical journey through your dream world.'
                  : 'A mystical journey through the cosmic forest.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 28),

            // Save Image butonu
            _buildPrimaryButton(
              icon: Icons.download,
              label: 'Save Image',
              onTap: () {
                _showComingSoon(context);
              },
            ),
            const SizedBox(height: 12),

            // Share Image butonu
            _buildSecondaryButton(
              icon: Icons.ios_share,
              label: 'Share Image',
              onTap: () {
                _showComingSoon(context);
              },
            ),
            const SizedBox(height: 16),

            // Generate Again text butonu
            GestureDetector(
              onTap: () {
                _showComingSoon(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Generate Again',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Görsel placeholder — mistik gradient arka plan + ikon
  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A2040), Color(0xFF0A1628), Color(0xFF0D1B2A)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // İç glow efekti
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF7FFFD4).withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Merkez ikon
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 48,
                color: AppColors.primaryLight.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 12),
              Text(
                'AI Art Generation',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Coming Soon',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textHint.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Birincil mor gradient buton
  Widget _buildPrimaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.primaryButtonGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(label, style: AppTextStyles.buttonPrimary),
          ],
        ),
      ),
    );
  }

  /// İkincil çerçeveli buton
  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTextStyles.buttonPrimary.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "Yakında" Snackbar'ı
  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Bu özellik yakında aktif olacak ✨',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Alt navigasyon çubuğu — Home, Dreams, Coffee, Profile
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_filled, 'Home', false),
              _navItem(Icons.nightlight_round, 'Dreams', true),
              _navItem(Icons.coffee, 'Coffee', false),
              _navItem(Icons.person_outline, 'Profile', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isSelected) {
    final color = isSelected ? AppColors.primary : AppColors.textHint;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: color, fontSize: 11),
        ),
      ],
    );
  }
}
