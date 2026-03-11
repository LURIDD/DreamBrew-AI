/// DreamBrew AI — Ana Sayfa (Home Screen)
///
/// Astroloji & mistik temalı yeni tasarım.
/// Günlük Kozmik Rehber, Ay Fazı kartı ve selamlama metni.
/// Sol üstte History butonu, başlıkta DreamBrew AI logosu.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/home_bloc.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

/// DreamBrew AI ana ekranı — Astroloji & Mistik temalı Home.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeBloc()..add(const HomeLoadRequested())),
        BlocProvider(create: (_) => sl<HomeCubit>()),
      ],
      child: const _HomeView(),
    );
  }
}

/// Home ekranının asıl görünümü
class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── AppBar: Leading=History, Title=DreamBrew AI ──
            SliverAppBar(
              pinned: false,
              floating: true,
              backgroundColor: colors.bg,
              centerTitle: true,
              leading: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () => context.push(AppRouter.history),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.history,
                        color: AppColors.primaryLight,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
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
            ),

            // ── Ana İçerik ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Selamlama Başlığı
                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      final greeting = state is HomeLoaded
                          ? state.greeting
                          : 'İyi Akşamlar';
                      return Text(
                        greeting,
                        style: AppTextStyles.greetingTitle.copyWith(color: colors.textMain),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Yıldızlar bu gece senin için ne söylüyor?',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colors.textSub,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ─── Günlük Kozmik Rehber Kartı ───
                  const _CosmicGuideCard(),
                  const SizedBox(height: 16),

                  // ─── Günün Ay Fazı Kartı ───
                  const _MoonPhaseCard(),
                  const SizedBox(height: 16),

                  // ─── Mistik İpucu Kartı ───
                  const _MysticTipCard(),
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
// Günlük Kozmik Rehber Kartı
// ============================================================

/// Astrolojik günlük yorum kartı.
/// Placeholder metin ile burç bazlı kozmik rehberlik sunar.
class _CosmicGuideCard extends StatelessWidget {
  const _CosmicGuideCard();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.dreamStart, colors.surfaceColor, colors.bg],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst: İkon + Başlık
          Row(
            children: [
              // Yıldız ikonu
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9B6DFF), Color(0xFF6D28D9)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Günlük Kozmik Rehber',
                      style: GoogleFonts.cinzel(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.textMain,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '✦ Bugünün enerjisi',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Ayırıcı çizgi
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.0),
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Dinamik astroloji metni
          BlocBuilder<HomeCubit, HomeCubitState>(
            builder: (context, state) {
              return Text(
                state.dailyGuide,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colors.textSub,
                  height: 1.65,
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // Alt not / Burç Seçme Butonu
          GestureDetector(
            onTap: () => _showZodiacPicker(context),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Icon(
                  Icons.edit_calendar,
                  color: AppColors.primaryLight.withValues(alpha: 0.8),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: BlocBuilder<HomeCubit, HomeCubitState>(
                    builder: (context, state) {
                      final hasSign = state.zodiacSign != null;
                      return Text(
                        hasSign 
                            ? '${state.zodiacSign} burcu için özel yorumunuz. Değiştirmek için dokunun.' 
                            : 'Burcunuzu seçin ve size özel kozmik rehberinizi okuyun.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryLight,
                          letterSpacing: 0.2,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showZodiacPicker(BuildContext context) {
    final colors = AppColors.of(context);
    final signs = [
      'Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak',
      'Terazi', 'Akrep', 'Yay', 'Oğlak', 'Kova', 'Balık'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Burcunuzu Seçin',
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: signs.map((sign) {
                  return InkWell(
                    onTap: () {
                      context.read<HomeCubit>().setZodiacSign(sign);
                      Navigator.pop(bottomSheetContext);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        sign,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colors.textMain,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// Günün Ay Fazı Kartı
// ============================================================

/// Ay fazı bilgi kartı.
/// Dolunay ikonu ve mistik metin içerir.
class _MoonPhaseCard extends StatelessWidget {
  const _MoonPhaseCard();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.surfaceColor, colors.bg],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Dolunay ikonu
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.secondary.withValues(alpha: 0.25),
                  AppColors.secondary.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Text(
                '🌕',
                style: TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Metin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Günün Ay Fazı',
                  style: GoogleFonts.cinzel(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bu gece rüyalar daha canlı ve sembolik olabilir. '
                  'Dolunay enerjisi bilinçaltını güçlendiriyor.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: colors.textSub,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Mistik İpucu Kartı
// ============================================================

/// Gün içi mistik bir ipucu/öneri kartı.
class _MysticTipCard extends StatelessWidget {
  const _MysticTipCard();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colors.cardBg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Mum/ışık ikonu
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('🕯️', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 14),

          // İpucu metni
          Expanded(
            child: Text(
              'Rüyanı unutmadan hemen yorumla — '
              'ortadaki ✦ butonuna dokun ve keşfet.',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: colors.textSub,
                height: 1.45,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
