/// DreamBrew AI — Rüya Girdi Ekranı
///
/// Kullanıcının rüyasını yazıp yorum tarzı seçerek gönderdiği ana ekran.
/// BLoC ile state yönetimi yapılır; sonuç başarılıysa DreamResultPage'e
/// yönlendirilir.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/repositories/i_dream_repository.dart';
import '../bloc/dream_bloc.dart';

/// Rüya Girdi Sayfası — Tasarım: dream_input_form.png
///
/// Kullanıcıdan rüya metni ve yorum tarzı alır,
/// [DreamBloc] aracılığıyla yorumu tetikler.
class DreamInputPage extends StatelessWidget {
  const DreamInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DreamBloc(sl<IDreamRepository>()),
      child: const _DreamInputView(),
    );
  }
}

/// Girdi ekranının iç görünümü (state yönetimi burada)
class _DreamInputView extends StatefulWidget {
  const _DreamInputView();

  @override
  State<_DreamInputView> createState() => _DreamInputViewState();
}

class _DreamInputViewState extends State<_DreamInputView> {
  final _dreamController = TextEditingController();
  String _selectedStyle = 'Mystical';

  /// Yorum tarzları — ikon ve etiket eşleşmeleri
  static const _styles = [
    {'label': 'Mystical', 'icon': Icons.auto_awesome},
    {'label': 'Fun', 'icon': Icons.emoji_emotions},
    {'label': 'Psychological', 'icon': Icons.psychology},
  ];

  @override
  void dispose() {
    _dreamController.dispose();
    super.dispose();
  }

  /// Rüya gönderim işlemi — validasyon + BLoC event
  void _submitDream() {
    final text = _dreamController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lütfen rüyanızı yazın ✍️',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    context.read<DreamBloc>().add(
      SubmitDreamEvent(dreamText: text, style: _selectedStyle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DreamBloc, DreamState>(
      listener: (context, state) {
        if (state is DreamSuccess) {
          // Sonuç ekranına yönlendir
          context.push(AppRouter.dreamResult, extra: state.reading);
        } else if (state is DreamError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,

        // Alt navigasyon çubuğu
        bottomNavigationBar: _buildBottomNavBar(context),

        body: SafeArea(
          child: Column(
            children: [
              // Kaydırılabilir ana içerik
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık
                      Center(
                        child: Text(
                          'Dream Interpretation',
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 26,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Alt metin
                      Center(
                        child: Text(
                          'Tell me what you saw while you were sleeping,\nand I\'ll reveal its meaning.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Çok satırlı rüya metin alanı
                      _buildDreamTextField(),
                      const SizedBox(height: 28),

                      // Yorum tarzı seçimi
                      Text(
                        'Reading Style',
                        style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
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
                child: _buildSubmitButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Çok satırlı rüya metin alanı — mor kenarlıklı, mikrofon ikonlu
  Widget _buildDreamTextField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
        color: AppColors.surface.withValues(alpha: 0.5),
      ),
      child: Stack(
        children: [
          TextField(
            controller: _dreamController,
            maxLines: 7,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText:
                  'Describe your dream... (e.g., I was flying\nover a city made of glass...)',
              hintStyle: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.textHint,
                height: 1.6,
              ),
              contentPadding: const EdgeInsets.all(18),
              border: InputBorder.none,
            ),
          ),
          // Mikrofon ikonu — sağ alt köşe
          Positioned(
            right: 12,
            bottom: 12,
            child: Icon(
              Icons.mic,
              color: AppColors.textHint.withValues(alpha: 0.7),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  /// Yorum tarzı seçim chip'leri — Mystical, Fun, Psychological
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.surface.withValues(alpha: 0.6),
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
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// "★ Interpret Dream" gönderim butonu — Loading durumunda spinner
  Widget _buildSubmitButton() {
    return BlocBuilder<DreamBloc, DreamState>(
      builder: (context, state) {
        final isLoading = state is DreamLoading;

        return GestureDetector(
          onTap: isLoading ? null : _submitDream,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: isLoading ? null : AppColors.primaryButtonGradient,
              color: isLoading
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : null,
              borderRadius: BorderRadius.circular(30),
              boxShadow: isLoading
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
                        const Icon(Icons.star, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Interpret Dream',
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

  /// Alt navigasyon çubuğu — Dreams, Readings, Profile
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
              _navItem(Icons.nightlight_round, 'Dreams', true),
              _navItem(Icons.menu_book, 'Readings', false),
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
