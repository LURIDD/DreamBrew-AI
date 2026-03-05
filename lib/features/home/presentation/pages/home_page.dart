import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/feature_card.dart';
import '../bloc/home_bloc.dart';

/// DreamBrew AI ana ekranı (Home Dashboard).
/// Rüya Yorumu ve Kahve Falı giriş kartlarını içerir.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Ekran açılır açılmaz selamlama metnini yükle
      create: (_) => HomeBloc()..add(const HomeLoadRequested()),
      child: const _HomeView(),
    );
  }
}

/// Home Dashboard'un asıl görünümü
class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // Alt navigasyon çubuğu
      bottomNavigationBar: _BottomNavBar(),

      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // AppBar: Logo + Geçmiş İkonu
            SliverAppBar(
              pinned: false,
              floating: true,
              backgroundColor: AppColors.background,
              centerTitle: true,
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'DreamBrew ',
                      style: GoogleFonts.cinzel(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryLight,
                        letterSpacing: 0.8,
                      ),
                    ),
                    TextSpan(
                      text: 'AI',
                      style: GoogleFonts.cinzel(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryLight,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              actions: const [
                // Geçmiş ikonu
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.history,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                ),
              ],
            ),

            // Ana içerik
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Selamlama başlığı
                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      final greeting = state is HomeLoaded
                          ? state.greeting
                          : 'Good Evening';
                      return Text(greeting, style: AppTextStyles.greetingTitle);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Rüya Yorumu Kartı
                  FeatureCard.dream(
                    onTap: () {
                      context.push(AppRouter.dreamInput);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Kahve Falı Kartı
                  FeatureCard.fortune(
                    onTap: () {
                      // TODO: Kahve falı ekranına git
                    },
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Alt Navigasyon Çubuğu
// ============================================================

/// Merkezdeki artı (+) FAB ile birlikte Home ve Settings sekmeleri
class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
      child: SizedBox(
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Sol: Home sekmesi
            Positioned(
              left: 0,
              bottom: 0,
              top: 0,
              width: MediaQuery.of(context).size.width / 2 - 36,
              child: _NavBarItem(
                icon: Icons.home_filled,
                label: 'Home',
                isSelected: true,
              ),
            ),

            // Merkez: Büyük mor artı butonu
            Positioned(top: 0, child: _CenterFab()),

            // Sağ: Settings sekmesi
            Positioned(
              right: 0,
              bottom: 0,
              top: 0,
              width: MediaQuery.of(context).size.width / 2 - 36,
              child: _NavBarItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                isSelected: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Navigasyon çubuğu tek sekme öğesi
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textHint;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: color,
            letterSpacing: 0.3,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Ortadaki büyük mor yuvarlak artı (+) butonu
class _CenterFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryButtonGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 30),
    );
  }
}
