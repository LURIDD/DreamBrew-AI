import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/local_storage/preferences_service.dart';
import '../../../../core/widgets/dream_button.dart';
import '../../../../core/widgets/star_background.dart';
import '../bloc/onboarding_bloc.dart';

/// DreamBrew AI giriş ekranı — 2 sayfalık Onboarding.
/// Sayfa 1: Karşılama ekranı (Ay görseli, logo, açıklama)
/// Sayfa 2: Burç seçim ekranı (Grid)
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
class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _selectedSign;
  late ThemedColors colors;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    if (_selectedSign != null) {
      await sl<PreferencesService>().setZodiacSign(_selectedSign!);
    }
    await sl<PreferencesService>().setFirstOpen(false);
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    colors = AppColors.of(context);

    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingComplete) {
          context.go(AppRouter.home);
        }
      },
      child: Scaffold(
        backgroundColor: colors.bg,
        body: StarBackground(
          child: SafeArea(
            child: Column(
              children: [
                // Sayfa indikatörü
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(2, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primaryLight
                              : colors.textMuted.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() => _currentPage = page);
                    },
                    children: [
                      // Sayfa 1: Karşılama
                      _buildWelcomePage(),

                      // Sayfa 2: Burç seçimi
                      _buildZodiacPage(),
                    ],
                  ),
                ),

                // Alt buton
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: DreamButton(
                          label: _currentPage == 0
                              ? 'Devam Et'
                              : (_selectedSign != null
                                  ? 'Hemen Başla ✨'
                                  : 'Atla'),
                          onPressed: () {
                            if (_currentPage == 0) {
                              _goToNextPage();
                            } else {
                              _completeOnboarding();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'SADECE EĞLENCE AMAÇLIDIR.',
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

  // ============================================================
  // Sayfa 1: Karşılama
  // ============================================================

  Widget _buildWelcomePage() {
    return Column(
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
    );
  }

  // ============================================================
  // Sayfa 2: Burç Seçimi
  // ============================================================

  Widget _buildZodiacPage() {
    final signs = [
      {'name': 'Koç', 'icon': '♈', 'date': '21 Mar - 19 Nis'},
      {'name': 'Boğa', 'icon': '♉', 'date': '20 Nis - 20 May'},
      {'name': 'İkizler', 'icon': '♊', 'date': '21 May - 20 Haz'},
      {'name': 'Yengeç', 'icon': '♋', 'date': '21 Haz - 22 Tem'},
      {'name': 'Aslan', 'icon': '♌', 'date': '23 Tem - 22 Ağu'},
      {'name': 'Başak', 'icon': '♍', 'date': '23 Ağu - 22 Eyl'},
      {'name': 'Terazi', 'icon': '♎', 'date': '23 Eyl - 22 Eki'},
      {'name': 'Akrep', 'icon': '♏', 'date': '23 Eki - 21 Kas'},
      {'name': 'Yay', 'icon': '♐', 'date': '22 Kas - 21 Ara'},
      {'name': 'Oğlak', 'icon': '♑', 'date': '22 Ara - 19 Oca'},
      {'name': 'Kova', 'icon': '♒', 'date': '20 Oca - 18 Şub'},
      {'name': 'Balık', 'icon': '♓', 'date': '19 Şub - 20 Mar'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Başlık
          Text(
            'Burcunuzu Seçin',
            style: GoogleFonts.cinzel(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Size özel kozmik rehberinizi oluşturmamız için\nburcunuzu bilmemiz gerekiyor.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colors.textSub,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Burç Grid'i (3 sütun)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: signs.length,
            itemBuilder: (context, index) {
              final sign = signs[index];
              final isSelected = _selectedSign == sign['name'];

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedSign = sign['name']);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : colors.surfaceColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryLight
                          : AppColors.primary.withValues(alpha: 0.15),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Burç sembolü
                      Text(
                        sign['icon']!,
                        style: TextStyle(
                          fontSize: 28,
                          color: isSelected
                              ? AppColors.primaryLight
                              : colors.textSub,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Burç adı
                      Text(
                        sign['name']!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primaryLight
                              : colors.textMain,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Tarih aralığı
                      Text(
                        sign['date']!,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Seçim durumu
          if (_selectedSign != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.primaryLight, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '$_selectedSign burcu seçildi',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryLight,
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
        'Rüyalarınızın ve kahve telvenizin gizemlerini keşfedin.',
        style: AppTextStyles.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}
