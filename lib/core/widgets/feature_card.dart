import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'dream_button.dart';

/// DreamBrew AI ana özellik kartı bileşeni.
///
/// Rüya Yorumu ve Kahve Falı için kullanılır.
/// [iconData] kart üzerindeki ikon.
/// [iconBackgroundColor] ikon arka plan rengi.
/// [title] kart başlığı.
/// [description] kart açıklama metni.
/// [buttonLabel] CTA buton metni.
/// [gradient] kartın arka plan gradient'i.
/// [buttonColor] CTA buton rengi (düz renk).
/// [onTap] bir aksiyona tıklanınca tetiklenir.
class FeatureCard extends StatelessWidget {
  final IconData iconData;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String title;
  final String description;
  final String buttonLabel;
  final LinearGradient gradient;
  final Color? buttonGradientStart;
  final Color? buttonGradientEnd;
  final Color? buttonSolidColor;
  final VoidCallback? onTap;

  const FeatureCard({
    super.key,
    required this.iconData,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.gradient,
    this.buttonGradientStart,
    this.buttonGradientEnd,
    this.buttonSolidColor,
    this.onTap,
  });

  /// Rüya Yorumu kartı için hazır fabrika constructor
  factory FeatureCard.dream({Key? key, VoidCallback? onTap, BuildContext? context}) {
    final colors = context != null ? AppColors.of(context) : null;
    return FeatureCard(
      key: key,
      iconData: Icons.nightlight_round,
      iconBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
      iconColor: AppColors.primaryLight,
      title: 'Rüya Yorumu',
      description: 'Bilinçaltının sana gönderdiği gizli\nmesajları keşfet',
      buttonLabel: 'Yorumlamaya Başla',
      gradient: colors != null
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.dreamStart, colors.dreamEnd],
            )
          : AppColors.dreamCardGradient,
      buttonGradientStart: AppColors.primary,
      buttonGradientEnd: AppColors.primaryLight,
      onTap: onTap,
    );
  }

  /// Kahve Falı kartı için hazır fabrika constructor
  factory FeatureCard.fortune({Key? key, VoidCallback? onTap, BuildContext? context}) {
    final colors = context != null ? AppColors.of(context) : null;
    return FeatureCard(
      key: key,
      iconData: Icons.coffee,
      iconBackgroundColor: AppColors.secondary.withValues(alpha: 0.3),
      iconColor: AppColors.secondary,
      title: 'Kahve Falı',
      description: 'Kahve telvelerinden geleceğini\noku',
      buttonLabel: 'Falı Oku',
      gradient: colors != null
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.fortuneStart, colors.fortuneEnd],
            )
          : AppColors.fortuneCardGradient,
      buttonSolidColor: AppColors.secondary,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Buton gradient'ini belirle
    final buttonGradient = buttonSolidColor == null
        ? LinearGradient(
            colors: [
              buttonGradientStart ?? AppColors.primary,
              buttonGradientEnd ?? AppColors.primaryLight,
            ],
          )
        : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İkon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(iconData, color: iconColor, size: 28),
          ),
          const SizedBox(height: 16),

          // Başlık
          Text(
            title,
            style: AppTextStyles.cardTitle.copyWith(
                color: AppColors.of(context).textMain),
          ),
          const SizedBox(height: 6),

          // Açıklama
          Text(
            description,
            style: AppTextStyles.cardDescription.copyWith(
                color: AppColors.of(context).textSub),
          ),
          const SizedBox(height: 20),

          // CTA Butonu
          DreamButton(
            label: buttonLabel,
            gradient: buttonGradient,
            backgroundColor: buttonSolidColor,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
