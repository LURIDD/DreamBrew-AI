/// DreamBrew AI — Kayıtlı Okuma Detay Ekranı
///
/// Geçmiş listesinden seçilen bir okumanın tam detayını gösterir.
/// saved_reading_details.png tasarımına birebir sadık kalınmıştır.
///
/// Alt bar: FAVORITE (kalp) | SHARE | DELETE (çöp kutusu)
/// Silme işlemi onay diyaloğu ile korunur.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/local_storage/saved_reading.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/snackbar_helper.dart';
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

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.reading.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final isDream = widget.reading.type == SavedReadingType.dream;

    return BlocListener<HistoryBloc, HistoryState>(
      listener: (context, state) {
        // Silme veya favori sonrası hata oluşursa snackbar göster
        if (state is HistoryError) {
          SnackbarHelper.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,

          // ─── AppBar ────────────────────────────────────────────
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
            title: Text(
              'Reading Details',
              style: GoogleFonts.cinzel(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 0.8,
              ),
            ),
          ),

          // ─── Alt Bar: Favorite / Share / Delete ─────────────────
          bottomNavigationBar: _buildBottomBar(context),

          // ─── Gövde İçerik ──────────────────────────────────────
          body: SingleChildScrollView(
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
                  '${isDream ? 'Dream Interpretation' : 'Coffee Cup Reading'} • ${_formatFullDate(widget.reading.date)}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textHint,
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
                    color: AppColors.surface.withValues(alpha: 0.5),
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
                      color: AppColors.textSecondary,
                      height: 1.8,
                    ),
                  ),
                ),
              ],
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
    final bgColor = isDream ? AppColors.surface : AppColors.fortuneCardStart;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TESPİT EDİLEN SEMBOLLER',
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
                      color: AppColors.textSecondary,
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

  // ============================================================
  // Alt Bar
  // ============================================================

  /// Tasarımdaki FAVORITE | SHARE | DELETE alt çubuğu.
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
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
              label: 'FAVORITE',
              color: _isFavorite ? AppColors.primary : AppColors.textHint,
              onTap: () => _handleToggleFavorite(context),
            ),

            // SHARE
            _BottomAction(
              icon: Icons.share_outlined,
              label: 'SHARE',
              color: AppColors.textHint,
              onTap: () {
                SnackbarHelper.showInfo(
                  context,
                  'Paylaşım özelliği yakında aktif olacak!',
                );
              },
            ),

            // DELETE
            _BottomAction(
              icon: Icons.delete_outline,
              label: 'DELETE',
              color: AppColors.textHint,
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
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Okumayı Sil',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            'Bu okuma kalıcı olarak silinecek.\nDevam etmek istiyor musunuz?',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
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
                  color: AppColors.textHint,
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

  /// Uzun tarih formatı: "October 24, 2023"
  String _formatFullDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
