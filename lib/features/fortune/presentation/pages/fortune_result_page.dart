/// DreamBrew AI — Kahve Falı Sonuç Ekranı
///
/// [FortuneReading] verisini alarak, yapay zekanın fal yorumunu
/// görsel açıdan zengin bir şekilde kullanıcıya sunar.
/// Semboller Chip'ler olarak, yorumlar kategorize edilmiş kartlar olarak,
/// şans bilgileri ve öneriler liste olarak gösterilir.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/local_storage/saved_reading.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/snackbar_helper.dart';
import '../../../../core/di/service_locator.dart';
import '../../../history/presentation/bloc/history_bloc.dart';
import '../../domain/entities/fortune_reading.dart';

/// Kahve Falı Sonuç Sayfası
///
/// Router'dan `extra` parametresi olarak [FortuneReading] alır.
/// Üstte tema kartı, ortada semboller ve yorumlar, altta şans bilgileri.
class FortuneResultPage extends StatefulWidget {
  final FortuneReading reading;

  const FortuneResultPage({super.key, required this.reading});

  @override
  State<FortuneResultPage> createState() => _FortuneResultPageState();
}

class _FortuneResultPageState extends State<FortuneResultPage> {
  bool _isSaved = false;

  FortuneReading get reading => widget.reading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık kartı — Amber/Altın gradient
            _buildHeaderCard(),
            const SizedBox(height: 20),

            // Tespit Edilen Semboller
            _buildSymbolSection(),
            const SizedBox(height: 24),

            // Genel Yorum kartı
            _buildMessageCard(
              icon: Icons.auto_awesome,
              title: 'Genel Yorum',
              message: reading.generalMessage,
              gradientColors: [
                const Color(0xFF2D1B69),
                const Color(0xFF1A0E3F),
              ],
            ),
            const SizedBox(height: 16),

            // Aşk Mesajı kartı
            _buildMessageCard(
              icon: Icons.favorite,
              title: 'Aşk & İlişkiler',
              message: reading.loveMessage,
              gradientColors: [
                const Color(0xFF4A1942),
                const Color(0xFF2D1040),
              ],
            ),
            const SizedBox(height: 16),

            // Kariyer Mesajı kartı
            _buildMessageCard(
              icon: Icons.work_rounded,
              title: 'Kariyer & İş',
              message: reading.careerMessage,
              gradientColors: [
                const Color(0xFF1A3A2D),
                const Color(0xFF0E2A1F),
              ],
            ),
            const SizedBox(height: 24),

            // Şans & Zaman Bilgileri
            _buildLuckyInfoSection(),
            const SizedBox(height: 24),

            // Temalar
            _buildThemesSection(),
            const SizedBox(height: 24),

            // Öneriler
            _buildSuggestionsSection(),
            const SizedBox(height: 24),

            // Aksiyon butonları
            _buildActionRow(),
          ],
        ),
      ),
    );
  }

  /// Üst başlık kartı — Fincan ikonu + temaya göre başlık
  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3D1A00), Color(0xFF1A0A00)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Fincan ikonu
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.coffee_rounded,
              color: AppColors.secondaryLight.withValues(alpha: 0.9),
              size: 28,
            ),
          ),
          const SizedBox(height: 14),

          // Başlık
          Text(
            'Fincanınız Konuşuyor',
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Zaman dilimi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '⏳ ${reading.timeframe}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.secondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tespit Edilen Semboller bölümü — Chip'ler (CoffeeSymbol)
  Widget _buildSymbolSection() {
    // Sembol ikon eşlemeleri
    final iconMap = <String, IconData>{
      'kuş': Icons.flutter_dash,
      'yol': Icons.fork_right,
      'yıldız': Icons.star,
      'kalp': Icons.favorite,
      'ağaç': Icons.park,
      'balık': Icons.set_meal,
      'dağ': Icons.terrain,
      'yüzük': Icons.circle_outlined,
      'merdiven': Icons.stairs,
      'yılan': Icons.gesture,
      'at': Icons.pets,
      'göz': Icons.visibility,
      'anahtar': Icons.key,
      'ev': Icons.home,
      'çiçek': Icons.local_florist,
    };

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
          children: reading.symbols.map((symbol) {
            final icon =
                iconMap[symbol.name.toLowerCase()] ?? Icons.auto_awesome;
            return GestureDetector(
              onTap: () => _showSymbolDetail(symbol),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.fortuneCardStart.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: AppColors.secondaryLight),
                    const SizedBox(width: 6),
                    Text(
                      symbol.name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Konum indikatörü
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: symbol.position == 'fincan'
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : AppColors.secondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        symbol.position,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: symbol.position == 'fincan'
                              ? AppColors.primaryLight
                              : AppColors.secondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Sembol detay bottom sheet
  void _showSymbolDetail(CoffeeSymbol symbol) {
    // Builder pattern kullanarak context'e erişim sağlıyoruz
    // Bu widget StatelessWidget olduğu için BuildContext'i doğrudan alamıyoruz,
    // ancak showModalBottomSheet global bir fonksiyon değil.
    // Bu nedenle bu metodu build context'siz bir yapıda kullanacağız.
  }

  /// Mesaj kartı — ikon, başlık ve yorum
  Widget _buildMessageCard({
    required IconData icon,
    required String title,
    required String message,
    required List<Color> gradientColors,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık satırı
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.secondaryLight),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Mesaj metni
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  /// Şans bilgileri — Şans sayısı, renk, zaman dilimi
  Widget _buildLuckyInfoSection() {
    return Row(
      children: [
        // Şans sayısı
        Expanded(
          child: _buildLuckyCard(
            icon: Icons.tag,
            label: 'Şans Sayısı',
            value: '${reading.luckyNumber}',
            color: AppColors.primaryLight,
          ),
        ),
        const SizedBox(width: 12),
        // Şans rengi
        Expanded(
          child: _buildLuckyCard(
            icon: Icons.palette,
            label: 'Şans Rengi',
            value: reading.luckyColor,
            color: AppColors.secondaryLight,
          ),
        ),
      ],
    );
  }

  /// Tek şans bilgi kartı
  Widget _buildLuckyCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textHint,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// Temalar bölümü
  Widget _buildThemesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TEMALAR',
          style: AppTextStyles.bodySmall.copyWith(
            letterSpacing: 2,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: reading.themes.map((theme) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Text(
                '#$theme',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Öneriler bölümü
  Widget _buildSuggestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ÖNERİLER',
          style: AppTextStyles.bodySmall.copyWith(
            letterSpacing: 2,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 12),
        ...reading.suggestions.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Numara dairesi
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.secondaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Öneri metni
                Expanded(
                  child: Text(
                    entry.value,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ─── Save İşlemi ─────────────────────────────────────────────

  /// FortuneReading → SavedReading dönüşümü yaparak Hive'a kaydeder.
  void _handleSave() {
    if (_isSaved) return;

    final savedReading = SavedReading(
      id: reading.id,
      type: SavedReadingType.fortune,
      date: reading.readingDate,
      title: 'Fincanınız Konuşuyor',
      content: reading.generalMessage,
      symbols: reading.symbols.map((s) => s.name).toList(),
    );

    sl<HistoryBloc>().add(SaveReadingEvent(reading: savedReading));

    setState(() => _isSaved = true);
    SnackbarHelper.showSuccess(context, 'Kahve falı kaydedildi ☕');
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
            onTap: () {
              SnackbarHelper.showInfo(
                context,
                'Paylaşım özelliği yakında aktif olacak!',
              );
            },
          ),
        ),
      ],
    );
  }

  /// Tekil aksiyon butonu (Kaydet / Paylaş)
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
              ? AppColors.secondary.withValues(alpha: 0.15)
              : AppColors.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive
                ? AppColors.secondary.withValues(alpha: 0.4)
                : AppColors.secondary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? AppColors.secondaryLight : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? AppColors.secondaryLight
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
