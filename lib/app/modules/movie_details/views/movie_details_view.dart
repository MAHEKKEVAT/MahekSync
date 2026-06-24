import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/round_shape_button.dart';
import 'package:maheksync/app/models/movie_model.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/mahek_responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../controllers/movie_details_controller.dart';

class MovieDetailsView extends GetView<MovieDetailsController> {
  const MovieDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.surfaceVoid : AppThemeData.grey2,
      appBar: AppBar(
        backgroundColor: isDark ? AppThemeData.surfaceObsidian : AppThemeData.primaryWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7, size: 20),
        ),
        title: Obx(() {
          final movie = controller.movie.value;
          return TextCustom(
            title: movie?.movieName ?? '',
            fontSize: 18,
            fontFamily: FontFamily.bold,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          );
        }),
        centerTitle: false,
        actions: [
          IconButton(onPressed: controller.editMovie, icon: Icon(Icons.edit_rounded, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7, size: 20)),
          IconButton(onPressed: () => _showDeleteDialog(context, isDark), icon: Icon(Icons.delete_outline_rounded, color: AppThemeData.danger300, size: 20)),
        ],
      ),
      body: Obx(() {
        if (controller.movie.value == null) return const Center(child: MahekLoader(message: 'Loading...', size: 50, textSize: 16));
        return _buildContent(context, isDark);
      }),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    final movie = controller.movie.value!;
    final progress = movie.progressPercent.clamp(0.0, 100.0);
    final remaining = movie.remainingMinutes;
    final remainingH = remaining ~/ 60;
    final remainingM = remaining % 60;
    final remainingText = remainingH > 0 ? '${remainingH}h ${remainingM}m left' : '${remainingM}m left';
    final pad = MahekResponsive.responsivePadding(context);

    return SingleChildScrollView(
      padding: pad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(context, movie, isDark),
          spaceH(height: 16),
          _buildStatsRow(movie, progress, remaining, remainingText, isDark),
          spaceH(height: 16),
          _buildActionSection(context, movie, isDark),
          spaceH(height: 16),
          _buildActivitySection(movie, isDark),
          spaceH(height: 40),
        ],
      ),
    );
  }

  // ── HERO ──

  Widget _buildHeroSection(BuildContext context, MovieModel movie, bool isDark) {
    final isWide = MediaQuery.of(context).size.width > 800;
    if (isWide) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildPosterCard(movie, isDark, height: 420, width: 280),
        spaceW(width: 24),
        Expanded(child: _buildInfoColumn(movie, isDark)),
      ]);
    }
    return Column(children: [
      _buildPosterCard(movie, isDark, height: 360, width: double.infinity),
      spaceH(height: 16),
      _buildInfoColumn(movie, isDark),
    ]);
  }

  Widget _buildPosterCard(MovieModel movie, bool isDark, {required double height, required double width}) {
    return Container(
      height: height, width: width,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: movie.posterUrl != null && movie.posterUrl!.isNotEmpty
            ? Stack(fit: StackFit.expand, children: [
                NetworkImageWidget(imageUrl: movie.posterUrl!, fit: BoxFit.cover, borderRadius: 0),
                Positioned(
                  bottom: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(8)),
                    child: TextCustom(title: movie.formattedTotalDuration, fontSize: 12, fontFamily: FontFamily.bold, color: Colors.white),
                  ),
                ),
              ])
            : Container(
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.surfaceElevated : AppThemeData.grey2,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(child: Icon(Icons.movie_rounded, size: 64, color: AppThemeData.primary50)),
              ),
      ),
    );
  }

  Widget _buildInfoColumn(MovieModel movie, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(title: movie.movieName ?? 'Untitled', fontSize: 28, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
        spaceH(height: 10),
        _buildTagsRow(movie, isDark),
        spaceH(height: 14),
        if (movie.description != null && movie.description!.isNotEmpty) ...[
          Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: _cardDeco(isDark),
            child: TextCustom(title: movie.description!, fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7, maxLine: 4),
          ),
          spaceH(height: 14),
        ],
        _buildInfoCardsRow(movie, isDark),
      ],
    );
  }

  Widget _buildTagsRow(MovieModel movie, bool isDark) {
    final tags = <Widget>[];
    for (final g in movie.genreTags) {
      tags.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
        child: TextCustom(title: g.toUpperCase(), fontSize: 11, fontFamily: FontFamily.bold, color: AppThemeData.primary50),
      ));
      tags.add(spaceW(width: 8));
    }
    if (movie.formattedTotalDuration != '0h 0m') {
      tags.add(_pillTag(movie.formattedTotalDuration, Icons.access_time_rounded, isDark));
      tags.add(spaceW(width: 8));
    }
    tags.add(_statusPill(movie, isDark));
    return Wrap(children: tags);
  }

  Widget _pillTag(String text, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: isDark ? AppThemeData.surfaceElevated : AppThemeData.grey2, borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        spaceW(width: 4),
        TextCustom(title: text, fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
      ]),
    );
  }

  Widget _statusPill(MovieModel movie, bool isDark) {
    final color = _statusColor(movie.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        spaceW(width: 6),
        TextCustom(title: movie.statusLabel.toUpperCase(), fontSize: 10, fontFamily: FontFamily.bold, color: color),
      ]),
    );
  }

  Widget _buildInfoCardsRow(MovieModel movie, bool isDark) {
    final cards = <Widget>[];
    if (movie.year != null && movie.year!.isNotEmpty) {
      cards.add(Expanded(child: _accentCard('YEAR', movie.year!, Icons.calendar_today_outlined, AppThemeData.neonOrange, isDark)));
      cards.add(spaceW(width: 12));
    }
    if (movie.director != null && movie.director!.isNotEmpty) {
      cards.add(Expanded(child: _accentCard('DIRECTOR', movie.director!, Icons.person_outline_rounded, AppThemeData.neonBlue, isDark)));
      cards.add(spaceW(width: 12));
    }
    if (movie.rating != null) {
      cards.add(Expanded(child: _accentCard('RATING', '${movie.rating!.toStringAsFixed(1)}/10', Icons.star_outline_rounded, AppThemeData.neonYellow, isDark)));
    }
    if (cards.isEmpty) return const SizedBox.shrink();
    return Row(children: cards);
  }

  Widget _accentCard(String label, String value, IconData icon, Color accent, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceLight : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(children: [
        Icon(icon, size: 20, color: accent),
        spaceH(height: 6),
        TextCustom(title: value, fontSize: 14, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10, maxLine: 1, textOverflow: TextOverflow.ellipsis),
        spaceH(height: 2),
        TextCustom(title: label, fontSize: 9, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
      ]),
    );
  }

  // ── STATS (Gradient cards) ──

  Widget _buildStatsRow(MovieModel movie, double progress, int remaining, String remainingText, bool isDark) {
    return Row(children: [
      Expanded(child: _progressGradientCard(movie, progress, isDark)),
      spaceW(width: 12),
      Expanded(child: _remainingGradientCard(remaining, remainingText, isDark)),
    ]);
  }

  Widget _progressGradientCard(MovieModel movie, double progress, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppThemeData.primary50, AppThemeData.primary4]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextCustom(title: 'WATCH PROGRESS', fontSize: 9, fontFamily: FontFamily.bold, color: Colors.white.withValues(alpha: 0.7)),
          Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(7)), child: const Icon(Icons.bar_chart_rounded, size: 16, color: Colors.white)),
        ]),
        spaceH(height: 10),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          TextCustom(title: '${progress.toInt()}%', fontSize: 32, fontFamily: FontFamily.bold, color: Colors.white),
          spaceW(width: 6),
          Padding(padding: const EdgeInsets.only(bottom: 4), child: TextCustom(title: 'complete', fontSize: 11, fontFamily: FontFamily.regular, color: Colors.white.withValues(alpha: 0.7))),
        ]),
        spaceH(height: 10),
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: (progress / 100).clamp(0.0, 1.0), minHeight: 6, backgroundColor: Colors.white.withValues(alpha: 0.2), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
        spaceH(height: 10),
        TextCustom(title: '${movie.formattedWatchedDuration} / ${movie.formattedTotalDuration}', fontSize: 12, fontFamily: FontFamily.medium, color: Colors.white.withValues(alpha: 0.8)),
      ]),
    );
  }

  Widget _remainingGradientCard(int remaining, String remainingText, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppThemeData.neonTeal, AppThemeData.neonCyan]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextCustom(title: 'TIME REMAINING', fontSize: 9, fontFamily: FontFamily.bold, color: Colors.white.withValues(alpha: 0.7)),
          Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(7)), child: const Icon(Icons.timer_outlined, size: 16, color: Colors.white)),
        ]),
        spaceH(height: 10),
        TextCustom(title: remainingText, fontSize: 20, fontFamily: FontFamily.bold, color: Colors.white),
        spaceH(height: 14),
        Row(children: [
          _miniWhiteStat('HRS', '${(remaining / 60).floor()}'), spaceW(width: 8), _miniWhiteStat('MIN', '${remaining % 60}'),
        ]),
      ]),
    );
  }

  Widget _miniWhiteStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
        child: Column(children: [
          TextCustom(title: value, fontSize: 16, fontFamily: FontFamily.bold, color: Colors.white),
          TextCustom(title: label, fontSize: 8, fontFamily: FontFamily.bold, color: Colors.white.withValues(alpha: 0.7)),
        ]),
      ),
    );
  }

  // ── ACTIONS ──

  Widget _buildActionSection(BuildContext context, MovieModel movie, bool isDark) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (movie.status != 'COMPLETED') Expanded(flex: 3, child: _updateProgressCard(movie, isDark)),
      if (movie.status != 'COMPLETED') spaceW(width: 12),
      Expanded(flex: 2, child: _statusCard(movie, isDark)),
    ]);
  }

  Widget _updateProgressCard(MovieModel movie, bool isDark) {
    final total = movie.totalDuration ?? 1;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDeco(isDark),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.update_rounded, size: 18, color: AppThemeData.primary50),
          spaceW(width: 8),
          TextCustom(title: 'Update Progress', fontSize: 14, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
        ]),
        spaceH(height: 16),
        Obx(() {
          final val = controller.currentSliderMinutes.value.toDouble().clamp(0.0, total.toDouble());
          final h = controller.currentSliderMinutes.value ~/ 60;
          final m = controller.currentSliderMinutes.value % 60;
          final display = h > 0 ? '${h}h ${m}m' : '${m}m';
          return Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              TextCustom(title: display, fontSize: 15, fontFamily: FontFamily.bold, color: AppThemeData.primary50),
              TextCustom(title: movie.formattedTotalDuration, fontSize: 12, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            ]),
            spaceH(height: 6),
            SliderTheme(
              data: SliderThemeData(activeTrackColor: AppThemeData.primary50, inactiveTrackColor: isDark ? AppThemeData.surfaceDark : AppThemeData.grey3, thumbColor: AppThemeData.primary50, overlayColor: AppThemeData.primary50.withValues(alpha: 0.1), trackHeight: 5, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7)),
              child: Slider(value: val, min: 0, max: total.toDouble(), divisions: total > 0 ? (total / 5).ceil() : 1, onChanged: (v) => controller.currentSliderMinutes.value = v.round()),
            ),
          ]);
        }),
        spaceH(height: 10),
        Row(children: [
          Expanded(child: RoundShapeButton(title: controller.isUpdating.value ? 'Saving...' : 'Save Progress', buttonColor: AppThemeData.primary50, buttonTextColor: Colors.white, onTap: controller.isUpdating.value ? () {} : () => controller.updateProgress(controller.currentSliderMinutes.value), height: 42)),
          spaceW(width: 10),
          Expanded(child: RoundShapeButton(title: 'Mark Complete', buttonColor: AppThemeData.success300, buttonTextColor: Colors.white, onTap: controller.isUpdating.value ? () {} : controller.markComplete, height: 42)),
        ]),
      ]),
    );
  }

  Widget _statusCard(MovieModel movie, bool isDark) {
    final color = _statusColor(movie.status);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDeco(isDark, accent: color),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.info_outline_rounded, size: 18, color: color),
          spaceW(width: 8),
          TextCustom(title: 'STATUS', fontSize: 9, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        ]),
        spaceH(height: 14),
        Row(children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          spaceW(width: 10),
          TextCustom(title: movie.statusLabel, fontSize: 16, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
        ]),
        spaceH(height: 16),
        Container(
          width: double.infinity, padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
          child: TextCustom(title: _statusDesc(movie.status), fontSize: 11, fontFamily: FontFamily.regular, color: color, maxLine: 3),
        ),
      ]),
    );
  }

  String _statusDesc(String? s) {
    switch (s) { case 'WATCHING': return 'Currently watching. Keep going!'; case 'COMPLETED': return 'Finished watching.'; default: return 'Haven\'t started yet.'; }
  }

  Color _statusColor(String? s) {
    switch (s) { case 'WATCHING': return AppThemeData.neonBlue; case 'COMPLETED': return AppThemeData.success300; default: return AppThemeData.pending300; }
  }

  // ── ACTIVITY ──

  Widget _buildActivitySection(MovieModel movie, bool isDark) {
    final createdStr = movie.createdAt != null ? _formatDate(movie.createdAt!.toDate()) : 'Unknown date';
    return Container(
      padding: const EdgeInsets.all(18), decoration: _cardDeco(isDark),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.history_rounded, size: 18, color: AppThemeData.primary50),
          spaceW(width: 8),
          TextCustom(title: 'RECENT ACTIVITY', fontSize: 9, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        ]),
        spaceH(height: 14),
        Row(children: [
          Container(width: 3, height: 32, decoration: BoxDecoration(color: AppThemeData.primary50, borderRadius: BorderRadius.circular(2))),
          spaceW(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextCustom(title: 'Movie Added', fontSize: 12, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
            spaceH(height: 2),
            TextCustom(title: createdStr, fontSize: 10, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          ]),
        ]),
      ]),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  // ── HELPERS ──

  BoxDecoration _cardDeco(bool isDark, {Color? accent}) {
    return BoxDecoration(
      color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: accent != null ? accent.withValues(alpha: 0.15) : (isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3)),
    );
  }

  void _showDeleteDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
        title: TextCustom(title: 'Delete Movie', fontSize: 18, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
        content: TextCustom(title: 'Are you sure you want to delete this movie?', fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: TextCustom(title: 'Cancel', fontSize: 13, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7)),
          TextButton(onPressed: () { Navigator.of(context).pop(); controller.deleteMovie(); }, child: TextCustom(title: 'Delete', fontSize: 13, fontFamily: FontFamily.medium, color: AppThemeData.danger300)),
        ],
      ),
    );
  }
}
