/// DreamBrew AI — Kayıtlı Okuma Detay Ekranı
///
/// Geçmiş listesinden seçilen bir okumanın tam detayını gösterir.
/// saved_reading_details.png tasarımına birebir sadık kalınmıştır.
///
/// Alt bar: FAVORITE (kalp) | SHARE | DELETE (çöp kutusu)
/// Silme işlemi onay diyaloğu ile korunur.
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/local_storage/saved_reading.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/snackbar_helper.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../visualization/presentation/cubit/visualization_cubit.dart';
import '../../../visualization/presentation/cubit/visualization_state.dart';
import '../../../visualization/presentation/widgets/visualization_view.dart';
import '../bloc/history_bloc.dart';

/// Kayıtlı okuma detay sayfası.
///
/// [reading] parametresi route extra'sı olarak iletilir.
/// BlocProvider ile HistoryBloc sağlanır; favori/silme işlemleri
/// bu BLoC üzerinden gerçekleştirilir.
class ReadingDetailPage extends StatefulWidget {
  final SavedReading reading;

  const ReadingDetailPage({super.key, required this.reading});

  @override
  State<ReadingDetailPage> createState() => _ReadingDetailPageState();
}

class _ReadingDetailPageState extends State<ReadingDetailPage> {
  late bool _isFavorite;
  late ThemedColors colors;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.reading.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    colors = AppColors.of(context);
    final isDream = widget.reading.type == SavedReadingType.dream;

    return BlocListener<HistoryBloc, HistoryState>(
      listener: (context, state) {
        // Silme veya favori sonrası hata oluşursa snackbar göster
        if (state is HistoryError) {
          SnackbarHelper.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: colors.bg,

          // ─── AppBar ────────────────────────────────────────────
          appBar: AppBar(
            backgroundColor: colors.bg,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRouter.home);
                }
              },
              icon: Icon(Icons.arrow_back, color: colors.textMain),
            ),
            title: Text(
              'Okuma Detayları',
              style: GoogleFonts.cinzel(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textMain,
                letterSpacing: 0.8,
              ),
            ),
          ),

          // ─── Alt Bar: Favorite / Share / Delete ─────────────────
          bottomNavigationBar: _buildBottomBar(context),

          // ─── Gövde İçerik ──────────────────────────────────────
          body: BlocProvider(
            create: (_) => sl<VisualizationCubit>(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),

                // Büyük ikon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: (isDream ? AppColors.primary : AppColors.secondary)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    isDream ? Icons.nightlight_round : Icons.coffee,
                    color: isDream
                        ? AppColors.primaryLight
                        : AppColors.secondary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),

                // Başlık (Cinzel, büyük)
                Text(
                  widget.reading.title,
                  style: GoogleFonts.cinzel(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Alt başlık: tür + tarih
                Text(
                  '${isDream ? 'Rüya Yorumu' : 'Kahve Falı'} • ${_formatFullDate(widget.reading.date)}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: colors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Eğer semboller varsa göster
                _buildSymbolSection(),

                // İçerik metni (Özel Kart İçinde)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surfaceColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (isDream ? AppColors.primary : AppColors.secondary).withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.reading.content,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: colors.textSub,
                      height: 1.8,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Kayıtlı görsel varsa doğrudan göster
                if (widget.reading.imageBase64 != null)
                  _buildSavedImage(widget.reading.imageBase64!),

                // AI Visualization (yeni üretim için)
                const VisualizationView(),

                // Görselleştir Butonu — kayıtlı görsel veya yeni üretilmiş görsel varsa gizle
                Builder(
                  builder: (context) {
                    if (widget.reading.imageBase64 != null) {
                      return const SizedBox.shrink();
                    }
                    final vizState = context.watch<VisualizationCubit>().state;
                    if (vizState is VisualizationLoaded) {
                      return const SizedBox.shrink();
                    }
                    return _buildGenerateButton(context, isDream);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // UI Bileşenleri
  // ============================================================

  /// Kaydedilen sembolleri şık çipler (chip) halinde gösterir
  Widget _buildSymbolSection() {
    final symbols = widget.reading.symbols;
    if (symbols == null || symbols.isEmpty) return const SizedBox.shrink();

    final isDream = widget.reading.type == SavedReadingType.dream;
    final color = isDream ? AppColors.primaryLight : AppColors.secondaryLight;
    final borderColor = isDream ? AppColors.primary : AppColors.secondary;
    final bgColor = isDream ? colors.surfaceColor : colors.fortuneStart;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TESPİT EDİLEN SEMBOLLER',
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
          children: symbols.map((symbol) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: bgColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: borderColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: color),
                  const SizedBox(width: 6),
                  Text(
                    '#$symbol',
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
        const SizedBox(height: 32),
      ],
    );
  }

  /// Daha önce kaydedilmiş görseli Base64'ten gösterir
  Widget _buildSavedImage(String imageBase64) {
    final imageBytes = base64Decode(imageBase64);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  // ============================================================
  // Alt Bar
  // ============================================================

  /// Tasarımdaki FAVORITE | SHARE | DELETE alt çubuğu.
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceColor,
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // FAVORITE
            _BottomAction(
              icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
              label: 'FAVORİ',
              color: _isFavorite ? AppColors.primary : colors.textMuted,
              onTap: () => _handleToggleFavorite(context),
            ),

            // SHARE
            _BottomAction(
              icon: Icons.share_outlined,
              label: 'PAYLAŞ',
              color: colors.textMuted,
              onTap: _handleShare,
            ),

            // DELETE
            _BottomAction(
              icon: Icons.delete_outline,
              label: 'SİL',
              color: colors.textMuted,
              onTap: () => _handleDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Favori toggle işlemi
  void _handleToggleFavorite(BuildContext context) {
    context.read<HistoryBloc>().add(
      ToggleFavoriteEvent(readingId: widget.reading.id),
    );

    setState(() {
      _isFavorite = !_isFavorite;
    });

    SnackbarHelper.showSuccess(
      context,
      _isFavorite ? 'Favorilere eklendi ♥' : 'Favorilerden çıkarıldı',
    );
  }

  /// Silme işlemi — önce onay diyaloğu göster
  void _handleDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Okumayı Sil',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.textMain,
            ),
          ),
          content: Text(
            'Bu okuma kalıcı olarak silinecek.\nDevam etmek istiyor musunuz?',
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
                Navigator.of(dialogContext).pop(); // Diyaloğu kapat
                context.read<HistoryBloc>().add(
                  DeleteReadingEvent(readingId: widget.reading.id),
                );
                SnackbarHelper.showSuccess(context, 'Okuma silindi');
                context.pop(); // Detay ekranından geri dön
              },
              child: Text(
                'Sil',
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

  /// Kayıtlı yorum içeriğini cihazın paylaşım menüsüyle paylaşır.
  void _handleShare() {
    final reading = widget.reading;
    final buffer = StringBuffer();
    final emoji = reading.type == SavedReadingType.dream ? '✨' : '☕';
    final label = reading.type == SavedReadingType.dream
        ? 'Rüya Yorumum'
        : 'Kahve Falı Yorumum';

    buffer.writeln('$emoji DreamBrew AI — $label');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln();
    buffer.writeln(reading.content);
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

  /// Uzun tarih formatı: "24 Ekim 2023"
  String _formatFullDate(DateTime date) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// "Görselleştir" butonu (Tema renklerine göre uyumlu)
  Widget _buildGenerateButton(BuildContext context, bool isDream) {
    if (widget.reading.symbols == null || widget.reading.symbols!.isEmpty) {
      return const SizedBox.shrink(); // Sembol yoksa görsel üretilemesin
    }

    final color = isDream ? AppColors.primaryLight : AppColors.secondaryLight;
    final bgColor = isDream 
        ? AppColors.primary.withValues(alpha: 0.15) 
        : AppColors.secondary.withValues(alpha: 0.15);
    final borderColor = isDream 
        ? AppColors.primary.withValues(alpha: 0.4) 
        : AppColors.secondary.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: () {
        // Free Tier kontrolü
        final isFreeTier = dotenv.env['IS_FREE_TIER']?.toLowerCase() == 'true';
        if (isFreeTier) {
          _showFreeTierDialog(context);
          return;
        }
        context.read<VisualizationCubit>().generateImage(
          widget.reading.symbols!,
          readingId: widget.reading.id,
        );
      },
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              'Görselleştir',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Alt Bar Aksiyon Widget'ı
// ============================================================

/// Alt bardaki tekil aksiyon butonu: ikon + etiket
class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BottomAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
