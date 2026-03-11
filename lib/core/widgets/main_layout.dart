/// DreamBrew AI — Ana Düzen (MainLayout)
///
/// Circular Notched Bottom App Bar + merkezi FAB yapısı.
/// Sol: Home | Orta: FAB (Aksiyon Merkezi) | Sağ: Settings
/// History alt bardan kaldırılmıştır.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/feature_card.dart';

/// Uygulamanın ana iskelet widget'ı.
///
/// go_router [ShellRoute] builder'ı tarafından çağrılır.
/// [navigationShell] parametresi, aktif sekmenin sayfasını içerir.
class MainLayout extends StatelessWidget {
  /// go_router tarafından sağlanan navigasyon kabuğu
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // Aktif sekmenin sayfasını göster
      body: navigationShell,

      // ── Circular Notched Bottom App Bar ──
      bottomNavigationBar: _buildNotchedBottomBar(context),

      // ── Merkezi FAB — Aksiyon Merkezi ──
      floatingActionButton: _buildCenterFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // extendBody: true animasyon/layout fazında geometry crash'e neden olabiliyor.
      extendBody: false,
      resizeToAvoidBottomInset: false,
    );
  }

  /// Circular Notched Rectangle şeklinde alt bar.
  /// Sol: Home | Sağ: Settings
  Widget _buildNotchedBottomBar(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: AppColors.surface,
      elevation: 0,
      padding: EdgeInsets.zero,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // ── Sol: Home ──
            Expanded(
              child: _NavItem(
                icon: Icons.home_filled,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => _onTabTapped(0),
              ),
            ),

            // ── Orta boşluk (FAB için) ──
            const SizedBox(width: 72),

            // ── Sağ: Settings ──
            Expanded(
              child: _NavItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                isSelected: currentIndex == 1,
                onTap: () => _onTabTapped(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Merkezdeki FAB — Aksiyon Merkezi.
  /// Mistik gradient renkli, auto_awesome ikonu.
  /// Tıklanınca "Interpret Dream" ve "Analyze Cup" kartlarını
  /// Modal Bottom Sheet olarak açar.
  Widget _buildCenterFAB(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9B6DFF), // primaryLight
            Color(0xFF7C3AED), // primary
            Color(0xFFE040FB), // mistik pembe-mor
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.45),
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFFE040FB).withValues(alpha: 0.25),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _showActionSheet(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.auto_awesome,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  /// Aksiyon Merkezi Modal Bottom Sheet.
  /// Rüya Yorumu ve Kahve Falı kartlarını gösterir.
  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: Color(0xFF2A1E5C),
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sürükleme tutamağı
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textHint.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Başlık
              Text(
                '✦ Keşfet ✦',
                style: GoogleFonts.cinzel(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryLight,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ne yapmak istersin?',
                style: AppTextStyles.cardDescription,
              ),
              const SizedBox(height: 24),

              // Rüya Yorumu Kartı
              FeatureCard.dream(
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push(AppRouter.dreamInput);
                },
              ),
              const SizedBox(height: 16),

              // Kahve Falı Kartı
              FeatureCard.fortune(
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push(AppRouter.fortuneUpload);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// Sekme tıklandığında ilgili branch'e geç
  void _onTabTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

// ============================================================
// Tek Navigasyon Öğesi
// ============================================================

/// Alt bardaki tekil sekme öğesi: ikon + etiket.
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textHint;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
