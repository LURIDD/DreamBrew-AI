import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/dream_button.dart';
import '../../../../core/widgets/star_background.dart';
import '../bloc/onboarding_bloc.dart';

/// DreamBrew AI giriş ekranı.
/// Ay görseli, uygulama logosu, açıklama metni ve "Get Started" butonu içerir.
/// Eğlence amaçlı uyarı metni en altta gösterilir.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(),
      child: const _OnboardingView(),
    );
  }
}

/// Onboarding'in BlocListener'a sahip asıl görünümü
class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        // OnboardingComplete durumunda Home Dashboard'a geç
        if (state is OnboardingComplete) {
          context.go(AppRouter.home);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: StarBackground(
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- Ay + Mistik Daire Görseli ---
                      _MoonIllustration(),
                      const SizedBox(height: 48),

                      // --- Logo Metni ---
                      _LogoText(),
                      const SizedBox(height: 20),

                      // --- Açıklama Metni ---
                      _DescriptionText(),
                    ],
                  ),
                ),

                // --- Buton ve Alt Uyarı Bölümü ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // "Get Started →" Butonu
                      BlocBuilder<OnboardingBloc, OnboardingState>(
                        builder: (context, state) {
                          return DreamButton(
                            label: 'Get Started',
                            onPressed: () {
                              context.read<OnboardingBloc>().add(
                                const OnboardingStarted(),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Eğlence amaçlı uyarı metni
                      Text(
                        'FOR ENTERTAINMENT PURPOSES ONLY.',
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Yardımcı alt widget'lar — Ekranı parçalara böler
// ============================================================

/// Ay + Mistik daire illüstrasyonu
class _MoonIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dıştaki mistik daire (koyu mavi-mor)
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF1E1B4B).withValues(alpha: 0.9),
                  const Color(0xFF0D0A1E).withValues(alpha: 0.6),
                ],
              ),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
          ),

          // Artı/pusula işaretleri (ince çizgiler)
          CustomPaint(
            size: const Size(180, 180),
            painter: _CompassLinePainter(),
          ),

          // Ay ikonu (merkez)
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.grey.shade300.withValues(alpha: 0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.nightlight_round,
              color: Color(0xFF4A4A8A),
              size: 48,
            ),
          ),
        ],
      ),
    );
  }
}

/// Artı işareti çizen CustomPainter (ay etrafındaki navigasyon çizgileri)
class _CompassLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Dikey çizgi (üst)
    canvas.drawLine(Offset(cx, 0), Offset(cx, cy - 52), paint);
    // Dikey çizgi (alt)
    canvas.drawLine(Offset(cx, cy + 52), Offset(cx, size.height), paint);
    // Yatay çizgi (sol)
    canvas.drawLine(Offset(0, cy), Offset(cx - 52, cy), paint);
    // Yatay çizgi (sağ)
    canvas.drawLine(Offset(cx + 52, cy), Offset(size.width, cy), paint);

    // Küçük nokta süslemeleri çizgi uçlarında
    final dotPaint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    for (final offset in [
      Offset(cx, 8),
      Offset(cx, size.height - 8),
      Offset(8, cy),
      Offset(size.width - 8, cy),
    ]) {
      canvas.drawCircle(offset, 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// "DreamBrew AI" logo metni bileşeni
class _LogoText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'DreamBrew ',
            style: GoogleFonts.cinzel(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          TextSpan(
            text: 'AI',
            style: GoogleFonts.cinzel(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryLight,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Açıklama paragrafı bileşeni
class _DescriptionText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Text(
        'Unlock the secrets of your subconscious mind through '
        'ancient dream interpretation and mystic coffee cup readings.',
        style: AppTextStyles.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}
