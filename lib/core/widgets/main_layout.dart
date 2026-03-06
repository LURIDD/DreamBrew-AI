/// DreamBrew AI — Ana Düzen (MainLayout)
///
/// ShellRoute ile kullanılan evrensel BottomNavigationBar.
/// Home, History ve Settings sekmelerini içerir.
/// Bu widget yalnızca ana sekme sayfalarını sararken;
/// Dream/Fortune gibi detay ekranları bu layout dışında açılır.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

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

      // Evrensel alt navigasyon çubuğu
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  /// Material 3 uyumlu, 3 sekmeli alt navigasyon çubuğu.
  ///
  /// Home | History | Settings
  /// SafeArea ile sistem gesture bar'ına uyum sağlar.
  Widget _buildBottomNavBar(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

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
          height: 80, // Material 3 standart yükseklik
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_filled,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => _onTabTapped(0),
              ),
              _NavItem(
                icon: Icons.history,
                label: 'History',
                isSelected: currentIndex == 1,
                onTap: () => _onTabTapped(1),
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                isSelected: currentIndex == 2,
                onTap: () => _onTabTapped(2),
              ),
            ],
          ),
        ),
      ),
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
        width: 72,
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
