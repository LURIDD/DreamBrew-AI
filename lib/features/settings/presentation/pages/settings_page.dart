/// DreamBrew AI — Ayarlar Sayfası
///
/// Uygulama ayarları, veri yönetimi ve yasal bilgileri içerir.
/// Tema değişimine duyarlı — AppColors.of(context) kullanır.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/snackbar_helper.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../history/presentation/bloc/history_bloc.dart';

/// Ayarlar ana sayfası.
///
/// BlocProvider ile HistoryBloc sağlanır (veri temizleme için).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsView();
  }
}

/// Ayarlar ekranının asıl görünümü.
class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Ayarlar',
          style: GoogleFonts.cinzel(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colors.textMain,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Veri Yönetimi Bölümü ──────────────────────────
            _buildSectionHeader('VERİ YÖNETİMİ', colors),
            const SizedBox(height: 12),
            _buildClearDataTile(context, colors),
            const SizedBox(height: 32),

            // ─── Görünüm Bölümü ────────────────────────────────
            _buildSectionHeader('GÖRÜNÜM', colors),
            const SizedBox(height: 12),
            _buildThemeToggleTile(context, colors),
            const SizedBox(height: 32),

            // ─── Hakkında Bölümü ───────────────────────────────
            _buildSectionHeader('HAKKINDA', colors),
            const SizedBox(height: 12),
            _buildAboutCard(colors),
            const SizedBox(height: 20),

            // ─── Yasal Uyarı / Feragatname ─────────────────────
            _buildDisclaimerCard(colors),
            const SizedBox(height: 32),

            // ─── Versiyon Bilgisi ──────────────────────────────
            Center(
              child: Text(
                'DreamBrew AI v1.0.0',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: colors.textMuted.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Bölüm Başlığı
  // ============================================================

  Widget _buildSectionHeader(String title, ThemedColors colors) {
    return Text(
      title,
      style: AppTextStyles.bodySmall.copyWith(
        letterSpacing: 2,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colors.textMuted,
      ),
    );
  }

  // ============================================================
  // Verileri Temizle
  // ============================================================

  Widget _buildClearDataTile(BuildContext context, ThemedColors colors) {
    return _SettingsTile(
      icon: Icons.delete_outline,
      iconColor: const Color(0xFFEF5350),
      title: 'Tüm Verileri Temizle',
      subtitle: 'Kayıtlı tüm rüya ve fal okumalarını sil',
      onTap: () => _showClearDataDialog(context, colors),
      colors: colors,
    );
  }

  void _showClearDataDialog(BuildContext context, ThemedColors colors) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFEF5350), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Verileri Temizle',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.textMain,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Tüm kayıtlı rüya yorumları ve kahve falı okumaları '
            'kalıcı olarak silinecek.\n\nBu işlem geri alınamaz. '
            'Devam etmek istiyor musunuz?',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colors.textSub,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'İptal',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textMuted,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context
                    .read<HistoryBloc>()
                    .add(const ClearAllReadingsEvent());
                SnackbarHelper.showSuccess(
                  context,
                  'Tüm veriler başarıyla temizlendi',
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFEF5350).withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Tümünü Sil',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFEF5350),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // Tema Anahtarı
  // ============================================================

  Widget _buildThemeToggleTile(BuildContext context, ThemedColors colors) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        return _SettingsTile(
          icon: isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
          iconColor: AppColors.primaryLight,
          title: isDarkMode ? 'Karanlık Tema' : 'Aydınlık Tema',
          subtitle: 'Açık / Koyu Tema Seçimi',
          trailing: Switch(
            value: isDarkMode,
            onChanged: (value) {
              context.read<ThemeCubit>().toggleTheme();
            },
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            inactiveThumbColor: colors.textMuted,
            inactiveTrackColor: colors.textMuted.withValues(alpha: 0.2),
          ),
          colors: colors,
        );
      },
    );
  }

  // ============================================================
  // Hakkında Kartı
  // ============================================================

  Widget _buildAboutCard(ThemedColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.dreamStart, colors.dreamEnd],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.primaryLight.withValues(alpha: 0.8),
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'DreamBrew AI',
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryLight,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'DreamBrew AI, yapay zeka destekli rüya yorumu ve '
            'kahve falı okuma deneyimi sunan bir mobil uygulamadır. '
            'Gemini AI teknolojisi ile güçlendirilmiştir.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: colors.textSub,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Yasal Uyarı / Feragatname
  // ============================================================

  Widget _buildDisclaimerCard(ThemedColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.secondary.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Yasal Uyarı & Feragatname',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Bu uygulama yalnızca eğlence amaçlıdır. '
            'DreamBrew AI tarafından sağlanan rüya yorumları ve '
            'kahve falı okumaları, yapay zeka modelleri tarafından '
            'üretilmektedir ve bilimsel bir geçerliliği yoktur.\n\n'
            'Sağlanan içerikler profesyonel psikolojik danışmanlık, '
            'tıbbi tavsiye veya gelecek tahmini değildir. '
            'Herhangi bir önemli yaşam kararını bu uygulamadaki '
            'yorumlara dayandırmamanızı tavsiye ederiz.\n\n'
            'Uygulamayı kullanarak bu feragatnameyi kabul etmiş sayılırsınız.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: colors.textMuted,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Ayarlar Satır Widget'ı
// ============================================================

/// Tekil ayar satırı: ikon, başlık, alt başlık ve opsiyonel sağ widget.
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final ThemedColors colors;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.colors,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Sol ikon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),

            // Başlık + Alt başlık
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Sağ widget (trailing) veya ok ikonu
            if (trailing != null)
              trailing!
            else
              Icon(
                Icons.chevron_right,
                color: colors.textMuted.withValues(alpha: 0.5),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
