/// DreamBrew AI — Kahve Falı Fincan Fotoğrafı Yükleme Ekranı
///
/// Kullanıcının kahve fincanı fotoğrafını kamera veya galeriden seçip,
/// yorum tarzını belirleyerek fal analizini başlatmasını sağlar.
/// Tasarım referansı: fortune_cup_upload.png
///
/// BLoC ile state yönetimi yapılır; analiz başarılıysa FortuneResultPage'e
/// yönlendirilir.
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/repositories/i_fortune_repository.dart';
import '../bloc/fortune_bloc.dart';

/// Kahve Falı Yükleme Sayfası — Tasarım: fortune_cup_upload.png
///
/// Kullanıcıdan fincan fotoğrafı ve yorum tarzı alır,
/// [FortuneBloc] aracılığıyla analizi tetikler.
class FortuneUploadPage extends StatelessWidget {
  const FortuneUploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FortuneBloc(sl<IFortuneRepository>()),
      child: const _FortuneUploadView(),
    );
  }
}

/// Yükleme ekranının iç görünümü (state yönetimi burada)
class _FortuneUploadView extends StatefulWidget {
  const _FortuneUploadView();

  @override
  State<_FortuneUploadView> createState() => _FortuneUploadViewState();
}

class _FortuneUploadViewState extends State<_FortuneUploadView> {
  String _selectedStyle = 'Mistik';
  late ThemedColors colors;

  /// Yorum tarzları — ikon ve etiket eşleşmeleri
  static const _styles = [
    {'label': 'Mistik', 'icon': Icons.auto_awesome},
    {'label': 'Eğlenceli', 'icon': Icons.emoji_emotions},
    {'label': 'Derin', 'icon': Icons.psychology},
  ];

  /// Fal analizi başlat — validasyon + BLoC event
  void _analyzeFortune() {
    context.read<FortuneBloc>().add(AnalyzeFortuneEvent(style: _selectedStyle));
  }

  /// Görsel seçimi — kamera veya galeri
  void _pickImage(ImageSource source) {
    context.read<FortuneBloc>().add(PickImageEvent(source: source));
  }

  @override
  Widget build(BuildContext context) {
    colors = AppColors.of(context);

    return BlocListener<FortuneBloc, FortuneState>(
      listener: (context, state) {
        if (state is FortuneSuccess) {
          // Sonuç ekranına yönlendir
          context.push(AppRouter.fortuneResult, extra: state.reading);
        } else if (state is FortuneError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: colors.bg,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: Column(
            children: [
              // Kaydırılabilir ana içerik
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fotoğraf yükleme alanı
                      _buildUploadArea(),
                      const SizedBox(height: 20),

                      // Önizleme + ekle butonu
                      _buildPreviewRow(),
                      const SizedBox(height: 24),

                      // Kamera ve Galeri butonları
                      _buildPickerButtons(),
                      const SizedBox(height: 28),

                      // Yorum tarzı seçimi
                      Text(
                        'Yorum Tarzı',
                        style: AppTextStyles.cardTitle.copyWith(
                          fontSize: 18,
                          color: colors.textMain,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildStyleChips(),
                    ],
                  ),
                ),
              ),

              // Alt buton alanı
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: _buildAnalyzeButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// AppBar — Geri butonu ve logo
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: colors.bg,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.chevron_left,
          color: colors.textMain,
          size: 28,
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'DreamBrew AI',
        style: GoogleFonts.cinzel(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryLight,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  /// Fotoğraf yükleme alanı — kesikli kenarlık, kamera ikonu
  Widget _buildUploadArea() {
    return BlocBuilder<FortuneBloc, FortuneState>(
      builder: (context, state) {
        final hasImage =
            state is FortuneImagePicked ||
            state is FortuneAnalyzing ||
            (state is FortuneError && state.imagePath != null);

        String? imagePath;
        if (state is FortuneImagePicked) imagePath = state.imagePath;
        if (state is FortuneAnalyzing) imagePath = state.imagePath;
        if (state is FortuneError) imagePath = state.imagePath;

        return GestureDetector(
          onTap: () => _pickImage(ImageSource.gallery),
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 1.5,
                // Dashed border efekti için CustomPainter kullanacağız
              ),
              color: colors.surfaceColor.withValues(alpha: 0.3),
            ),
            child: hasImage && imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(imagePath), fit: BoxFit.cover),
                        // Üzerine hafif overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.background.withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                        ),
                        // Değiştir ikonu
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colors.surfaceColor.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: AppColors.primaryLight,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : CustomPaint(
                    painter: _DashedBorderPainter(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      borderRadius: 16,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Kamera ikonu container'ı
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: AppColors.primary.withValues(alpha: 0.8),
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Fincan Fotoğrafı Yükle',
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: 20,
                              color: colors.textMain,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Fincanın içinin ve telvelerin doğru yorumlanabilmesi için\nnet olarak göründüğünden emin olun.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.cardDescription.copyWith(
                                fontSize: 13,
                                color: colors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  /// Önizleme satırı — seçilen görselin küçük thumbnail'i + ekle butonu
  Widget _buildPreviewRow() {
    return BlocBuilder<FortuneBloc, FortuneState>(
      builder: (context, state) {
        String? imagePath;
        if (state is FortuneImagePicked) imagePath = state.imagePath;
        if (state is FortuneAnalyzing) imagePath = state.imagePath;
        if (state is FortuneError) imagePath = state.imagePath;

        return Row(
          children: [
            Text(
              'Önizleme:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                color: colors.textSub,
              ),
            ),
            const SizedBox(width: 12),

            // Seçilen görsel thumbnail
            if (imagePath != null)
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(File(imagePath), fit: BoxFit.cover),
                ),
              ),

            if (imagePath != null) const SizedBox(width: 10),

            // Ekle butonu
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: colors.surfaceColor.withValues(alpha: 0.5),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: colors.textSub.withValues(alpha: 0.7),
                  size: 24,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Kamera ve Galeri butonları
  Widget _buildPickerButtons() {
    return Column(
      children: [
        // Kamera butonu
        _buildPickerButton(
          icon: Icons.camera_alt_outlined,
          label: 'Kamera',
          onTap: () => _pickImage(ImageSource.camera),
        ),
        const SizedBox(height: 10),
        // Galeri butonu
        _buildPickerButton(
          icon: Icons.photo_library_outlined,
          label: 'Galeri',
          onTap: () => _pickImage(ImageSource.gallery),
        ),
      ],
    );
  }

  /// Tek bir picker butonu (Kamera/Galeri)
  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surfaceColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryLight, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: colors.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Yorum tarzı seçim chip'leri — Mystical, Fun, Deep
  Widget _buildStyleChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _styles.map((style) {
        final label = style['label'] as String;
        final icon = style['icon'] as IconData;
        final isSelected = _selectedStyle == label;

        return GestureDetector(
          onTap: () => setState(() => _selectedStyle = label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : colors.surfaceColor.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryLight
                    : AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : colors.textSub,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : colors.textSub,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// "✨ Analyze Fortune" gönderim butonu — Loading durumunda spinner
  Widget _buildAnalyzeButton() {
    return BlocBuilder<FortuneBloc, FortuneState>(
      builder: (context, state) {
        final isLoading = state is FortuneAnalyzing;
        final hasImage =
            state is FortuneImagePicked ||
            state is FortuneAnalyzing ||
            (state is FortuneError && state.imagePath != null);

        return GestureDetector(
          onTap: (isLoading || !hasImage) ? null : _analyzeFortune,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: (isLoading || !hasImage)
                  ? null
                  : AppColors.primaryButtonGradient,
              color: (isLoading || !hasImage)
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : null,
              borderRadius: BorderRadius.circular(30),
              boxShadow: (isLoading || !hasImage)
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Falı Yorumla',
                          style: AppTextStyles.buttonPrimary,
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// Yardımcı: Kesikli (dashed) kenarlık çizici
// ============================================================

/// Upload alanı için kesikli kenarlık çizen [CustomPainter].
///
/// [color] — çizgi rengi
/// [borderRadius] — köşe yuvarlaklığı
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  _DashedBorderPainter({required this.color, this.borderRadius = 16});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    // Kesikli çizgi efekti
    const dashWidth = 8.0;
    const dashSpace = 5.0;

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0, metric.length).toDouble();
        final extractPath = metric.extractPath(distance, end);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius;
  }
}
