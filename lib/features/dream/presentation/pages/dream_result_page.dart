/// DreamBrew AI — Rüya Yorumu Sonuç Ekranı
///
/// [DreamReading] verisini alarak, yapay zekanın yorumunu
/// görsel açıdan zengin bir şekilde kullanıcıya sunar.
/// Tasarım referansı: ai_interpretation_results.png
library;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/local_storage/saved_reading.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/snackbar_helper.dart';
import '../../../../core/di/service_locator.dart';
import '../../../history/presentation/bloc/history_bloc.dart';
import '../../domain/entities/dream_reading.dart';
import '../../../visualization/presentation/cubit/visualization_cubit.dart';
import '../../../visualization/presentation/widgets/visualization_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Rüya Yorumu Sonuç Sayfası
///
/// Router'dan `extra` parametresi olarak [DreamReading] alır.
/// Üstte header kartı, ortada yorum, altta sembol chip'leri ve butonlar.
class DreamResultPage extends StatefulWidget {
  final DreamReading reading;

  const DreamResultPage({super.key, required this.reading});

  @override
  State<DreamResultPage> createState() => _DreamResultPageState();
}

class _DreamResultPageState extends State<DreamResultPage> {
  bool _isSaved = false;
  late ThemedColors colors;

  DreamReading get reading => widget.reading;

  @override
  Widget build(BuildContext context) {
    colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textMain),
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
      body: BlocProvider(
        create: (_) => sl<VisualizationCubit>(),
        child: SingleChildScrollView(
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

            // AI Visualization Görünümü
            const VisualizationView(),

            // "Generate Dream Image" butonu
            Builder(
              builder: (context) => _buildGenerateButton(context),
            ),
            const SizedBox(height: 14),

            // Save & Share satırı
            _buildActionRow(),
            const SizedBox(height: 24),

            // Ana Sayfaya Dön Butonu
            Center(child: _buildHomeButton(context)),
          ],
        ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.dreamStart, colors.dreamEnd],
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
              color: colors.textMain,
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
        color: colors.surfaceColor.withValues(alpha: 0.5),
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
                color: colors.textSub,
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
            color: colors.textSub,
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
            color: colors.textMuted,
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
                color: colors.surfaceColor.withValues(alpha: 0.6),
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
                      color: colors.textSub,
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
        // Free Tier kontrolü
        final isFreeTier = dotenv.env['IS_FREE_TIER']?.toLowerCase() == 'true';
        if (isFreeTier) {
          _showFreeTierDialog(context);
          return;
        }
        final keywords = reading.symbols.map((e) => e.symbol).toList();
        context.read<VisualizationCubit>().generateImage(keywords);
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
            Text('Rüyayı Görselleştir', style: AppTextStyles.buttonPrimary),
          ],
        ),
      ),
    );
  }

  /// "Ana Sayfaya Dön" butonu
  Widget _buildHomeButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.go(AppRouter.home);
      },
      child: Text(
        'Ana Sayfaya Dön',
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: colors.textMuted,
        ),
      ),
    );
  }

  // ─── Save İşlemi ─────────────────────────────────────────────

  /// DreamReading → SavedReading dönüşümü yaparak Hive'a kaydeder.
  /// Tüm yorum alanlarını birleştirerek detaylı içerik oluşturur.
  void _handleSave() {
    if (_isSaved) return;

    // Tüm mesajları birleştirerek zengin içerik oluştur
    final buffer = StringBuffer();
    buffer.writeln('✦ Genel Yorum');
    buffer.writeln(reading.overallMessage);

    if (reading.symbols.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('🔮 Sembol Yorumları');
      for (final symbol in reading.symbols) {
        buffer.writeln('• ${symbol.symbol}: ${symbol.meaning}');
      }
    }

    if (reading.suggestions.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('🎯 Öneriler');
      for (int i = 0; i < reading.suggestions.length; i++) {
        buffer.writeln('${i + 1}. ${reading.suggestions[i]}');
      }
    }

    if (reading.themes.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('🎨 Temalar: ${reading.themes.map((t) => '#$t').join(' ')}');
    }

    buffer.writeln('🌙 Duygusal Ton: ${reading.emotionalTone}');

    final savedReading = SavedReading(
      id: reading.id,
      type: SavedReadingType.dream,
      date: reading.interpretedAt,
      title: _generateTitle(),
      content: buffer.toString().trim(),
      symbols: reading.symbols.map((s) => s.symbol).toList(),
    );

    sl<HistoryBloc>().add(SaveReadingEvent(reading: savedReading));

    setState(() => _isSaved = true);
    SnackbarHelper.showSuccess(context, 'Rüya yorumu kaydedildi ✨');
  }

  /// Save & Share buton satırı
  Widget _buildActionRow() {
    return Row(
      children: [
        // Save butonu
        Expanded(
          child: _actionButton(
            icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
            label: _isSaved ? 'Kaydedildi ✓' : 'Kaydet',
            onTap: _handleSave,
            isActive: _isSaved,
          ),
        ),
        const SizedBox(width: 12),
        // Share butonu
        Expanded(
          child: _actionButton(
            icon: Icons.ios_share,
            label: 'Paylaş',
            onTap: _handleShare,
          ),
        ),
      ],
    );
  }

  /// Rüya yorumunu cihazın paylaşım menüsüyle paylaşır.
  void _handleShare() {
    final buffer = StringBuffer();
    buffer.writeln('✨ DreamBrew AI — Rüya Yorumum');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln();
    buffer.writeln('✦ Genel Yorum');
    buffer.writeln(reading.overallMessage);

    if (reading.symbols.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('🔮 Semboller');
      for (final symbol in reading.symbols) {
        buffer.writeln('• ${symbol.symbol}: ${symbol.meaning}');
      }
    }

    if (reading.suggestions.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('🎯 Öneriler');
      for (int i = 0; i < reading.suggestions.length; i++) {
        buffer.writeln('${i + 1}. ${reading.suggestions[i]}');
      }
    }

    buffer.writeln();
    buffer.writeln('🌙 Duygusal Ton: ${reading.emotionalTone}');
    buffer.writeln();
    buffer.writeln('— DreamBrew AI ile oluşturuldu ✨');

    SharePlus.instance.share(
      ShareParams(text: buffer.toString().trim()),
    );
  }

  /// Free Tier kullanıcılarına görsel üretiminin kullanılamadığını bildirir.
  void _showFreeTierDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.secondary, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Yakında Sizlerle! 🌠',
                style: GoogleFonts.cinzel(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Görsel üretim özelliği şu anda geliştirme aşamasındadır.\n\n'
          'Premium sürümle birlikte yapay zeka destekli '
          'mistik görseller oluşturabileceksiniz.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: colors.textSub,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Anladım',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tekil aksiyon butonu (Save / Share)
  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.2)
              : colors.surfaceColor.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.primary.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? AppColors.primaryLight : colors.textSub,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? AppColors.primaryLight
                    : colors.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
