/// DreamBrew AI — Ana Sayfa (Home Dashboard)
///
/// Rüya Yorumu ve Kahve Falı giriş kartlarını içerir.
/// MainLayout (ShellRoute) tarafından sarıldığı için
/// kendi BottomNavigationBar'ı yoktur.
library;

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

      // BottomNavigationBar artık MainLayout'ta (ShellRoute)
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
              actions: [
                // Geçmiş ikonu — tıklanınca History sekmesine geç
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () => context.go(AppRouter.history),
                    child: const Icon(
                      Icons.history,
                      color: AppColors.textSecondary,
                      size: 24,
                    ),
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
                      context.push(AppRouter.fortuneUpload);
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
