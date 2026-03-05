/// DreamBrew AI — Rüya Yorumu Sonuç Ekranı
///
/// [DreamReading] verisini alarak, yapay zekanın yorumunu
/// görsel açıdan zengin bir şekilde kullanıcıya sunar.
/// Tasarım referansı: ai_interpretation_results.png
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/dream_reading.dart';

/// Rüya Yorumu Sonuç Sayfası
///
/// Router'dan `extra` parametresi olarak [DreamReading] alır.
/// Üstte header kartı, ortada yorum, altta sembol chip'leri ve butonlar.
class DreamResultPage extends StatelessWidget {
  final DreamReading reading;

  const DreamResultPage({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomNavBar(context),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık kartı — Mor gradient
            _buildHeaderCard(),
            const SizedBox(height: 20),

            // Yorum metin alanı
            _buildInterpretationCard(),
            const SizedBox(height: 24),

            // Tespit Edilen Semboller
            _buildSymbolSection(),
            const SizedBox(height: 24),

            // "Generate Dream Image" butonu
            _buildGenerateButton(context),
            const SizedBox(height: 14),

            // Save & Share satırı
            _buildActionRow(),
          ],
        ),
      ),
    );
  }

  /// Üst başlık kartı — Yıldız ikonu + emotionalTone'dan türetilmiş başlık
  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D1B69), Color(0xFF1A0E3F)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Yıldız ikonu
          Icon(
            Icons.auto_awesome,
            color: AppColors.primaryLight.withValues(alpha: 0.9),
            size: 40,
          ),
          const SizedBox(height: 12),

          // Başlık — emotionalTone'u kullan
          Text(
            _generateTitle(),
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// emotionalTone'dan mistik bir başlık üret
  String _generateTitle() {
    final tone = reading.emotionalTone.toLowerCase();
    if (tone.contains('özgür') || tone.contains('umut')) {
      return 'The Path of Stars';
    } else if (tone.contains('merak') || tone.contains('içe')) {
      return 'Whispers of Wisdom';
    } else if (tone.contains('huzur')) {
      return 'Moonlit Serenity';
    } else {
      return 'The Path of Stars';
    }
  }

  /// Ana yorum kartı — overallMessage + sembol vurgulama
  Widget _buildInterpretationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: _buildHighlightedText(reading.overallMessage),
    );
  }

  /// Metin içindeki sembol isimlerini mor renkle vurgula
  Widget _buildHighlightedText(String text) {
    // Sembol isimlerini topla
    final symbolNames = reading.symbols
        .map((s) => s.symbol.toLowerCase())
        .toList();

    // Basit bir vurgulama yaklaşımı: sembol kelimelerini bul ve renklendir
    final words = text.split(' ');
    final spans = <InlineSpan>[];
    final buffer = StringBuffer();

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final cleanWord = word
          .replaceAll(RegExp(r'[^\wığüşöçİĞÜŞÖÇ]'), '')
          .toLowerCase();

      bool isSymbol = false;
      for (final sym in symbolNames) {
        if (sym.contains(cleanWord) && cleanWord.length > 2) {
          isSymbol = true;
          break;
        }
      }

      if (isSymbol) {
        // Önceki tampon metni ekle
        if (buffer.isNotEmpty) {
          spans.add(
            TextSpan(
              text: buffer.toString(),
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.7,
              ),
            ),
          );
          buffer.clear();
        }
        spans.add(
          TextSpan(
            text: '$word ',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w600,
              height: 1.7,
            ),
          ),
        );
      } else {
        buffer.write('$word ');
      }
    }

    // Kalan metni ekle
    if (buffer.isNotEmpty) {
      spans.add(
        TextSpan(
          text: buffer.toString(),
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.7,
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  /// Detected Symbols bölümü — Chip'ler
  Widget _buildSymbolSection() {
    // Semboller → Chip ikonları eşleme
    final iconMap = <String, IconData>{
      'uçmak': Icons.flight,
      'deniz': Icons.water,
      'mavi deniz': Icons.water,
      'su': Icons.water,
      'kuş': Icons.flutter_dash,
      'kuş sürüsü': Icons.flutter_dash,
      'bulut': Icons.cloud,
      'bulutlar': Icons.cloud,
      'ay': Icons.nightlight_round,
      'yıldız': Icons.star,
      'kitap': Icons.menu_book,
      'kütüphane': Icons.local_library,
      'eski kütüphane': Icons.local_library,
      'mum': Icons.local_fire_department,
      'mum ışığı': Icons.local_fire_department,
      'adının yazılı olduğu kitaplar': Icons.auto_stories,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DETECTED SYMBOLS',
          style: AppTextStyles.bodySmall.copyWith(
            letterSpacing: 2,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: reading.symbols.map((symbol) {
            final icon =
                iconMap[symbol.symbol.toLowerCase()] ?? Icons.auto_awesome;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: AppColors.primaryLight),
                  const SizedBox(width: 6),
                  Text(
                    '#${symbol.symbol}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// "Generate Dream Image" butonu
  Widget _buildGenerateButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(AppRouter.dreamArt, extra: reading);
      },
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.primaryButtonGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text('Generate Dream Image', style: AppTextStyles.buttonPrimary),
          ],
        ),
      ),
    );
  }

  /// Save & Share buton satırı
  Widget _buildActionRow() {
    return Row(
      children: [
        // Save butonu
        Expanded(
          child: _actionButton(
            icon: Icons.bookmark_border,
            label: 'Save',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        // Share butonu
        Expanded(
          child: _actionButton(
            icon: Icons.ios_share,
            label: 'Share',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  /// Tekil aksiyon butonu (Save / Share)
  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Alt navigasyon çubuğu — Home, Readings, Profile
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
              _navItem(Icons.home_filled, 'Home', false),
              _navItem(Icons.menu_book, 'Readings', true),
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
