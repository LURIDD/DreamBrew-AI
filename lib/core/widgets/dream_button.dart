import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// DreamBrew AI genel amaçlı buton bileşeni.
///
/// [label] butonun üzerinde gösterilecek metin.
/// [onPressed] buton tıklama geri çağrısı.
/// [gradient] özel gradient tanımı (varsayılan: birincil mor gradient).
/// [backgroundColor] gradient yerine düz renk kullanmak için.
/// [showArrow] sağ tarafta ok ikonu gösterilsin mi.
class DreamButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final bool showArrow;
  final double height;
  final double borderRadius;

  const DreamButton({
    super.key,
    required this.label,
    this.onPressed,
    this.gradient,
    this.backgroundColor,
    this.showArrow = true,
    this.height = 56,
    this.borderRadius = 30,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? AppColors.primaryButtonGradient;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: backgroundColor == null ? effectiveGradient : null,
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: AppTextStyles.buttonPrimary),
              if (showArrow) ...[
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
