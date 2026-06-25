import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/mahek_responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../../../models/movie_model.dart';
import '../controllers/movies_controller.dart';

// ── HOVERABLE CARD WRAPPER ──

class _HoverableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _HoverableCard({required this.child, this.onTap});

  @override
  State<_HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<_HoverableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: AppThemeData.neonMint.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: AppThemeData.neonMint.withValues(alpha: 0.08),
                        blurRadius: 40,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppThemeData.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class MoviesView extends GetView<MoviesController> {
  const MoviesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.surfaceVoid : AppThemeData.grey2,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: MahekLoader(message: 'Loading Movies...', size: 50, textSize: 16));
        }
        return _buildContent(context, isDark);
      }),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: MahekResponsive.responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isDark),
          spaceH(height: 20),
          _buildStatsRow(context, isDark),
          spaceH(height: 24),
          if (controller.watchingMovies.isNotEmpty) ...[
            _buildWatchingSection(context, isDark),
            spaceH(height: 24),
          ],
          _buildLatestMoviesSection(context, isDark),
          spaceH(height: 40),
        ],
      ),
    );
  }

  // ── HEADER ──

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(
              title: 'Movies',
              fontSize: 22,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
            ),
            spaceH(height: 2),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: 'Track. ', style: TextStyle(fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6)),
                  TextSpan(text: 'Watch. ', style: TextStyle(fontSize: 13, fontFamily: FontFamily.bold, color: AppThemeData.primary50)),
                  TextSpan(text: 'Enjoy.', style: TextStyle(fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6)),
                ],
              ),
            ),
          ],
        ),
        const Spacer(),
        _buildSearchButton(isDark),
        spaceW(width: 10),
        _buildAddButton(isDark),
      ],
    );
  }

  Widget _buildSearchButton(bool isDark) {
    return GestureDetector(
      onTap: () => _showSearchSheet(Get.context!),
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3),
        ),
        child: Icon(Icons.search_rounded, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6, size: 20),
      ),
    );
  }

  Widget _buildAddButton(bool isDark) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.MOVIE_CRUD),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          gradient: AppThemeData.appleIntelligenceGradientCool,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppThemeData.primary50.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            spaceW(width: 6),
            TextCustom(title: 'Add Movie', fontSize: 13, fontFamily: FontFamily.semiBold, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _showSearchSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchCtrl = TextEditingController(text: controller.searchQuery.value);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border.all(color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppThemeData.grey4, borderRadius: BorderRadius.circular(2))),
                  ),
                  spaceH(height: 16),
                  TextCustom(title: 'Search Movies', fontSize: 18, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                  spaceH(height: 12),
                  TextField(
                    controller: searchCtrl,
                    autofocus: true,
                    style: TextStyle(fontSize: 14, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                    decoration: InputDecoration(
                      hintText: 'Search by name, year, or genre...',
                      hintStyle: TextStyle(fontSize: 13, fontFamily: FontFamily.regular, color: AppThemeData.grey4),
                      prefixIcon: Icon(Icons.search_rounded, color: AppThemeData.grey4, size: 20),
                      suffixIcon: searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded, color: AppThemeData.grey4, size: 18),
                              onPressed: () {
                                searchCtrl.clear();
                                controller.updateSearch('');
                                setSheetState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark ? AppThemeData.surfaceDark : AppThemeData.grey2,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppThemeData.primary50),
                      ),
                    ),
                    onChanged: (val) {
                      controller.updateSearch(val);
                      setSheetState(() {});
                    },
                  ),
                  spaceH(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemeData.primary50,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const TextCustom(title: 'Done', fontSize: 14, fontFamily: FontFamily.semiBold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      searchCtrl.dispose();
    });
  }

  // ── STATS ROW ──

  Widget _buildStatsRow(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(isDark, 'Movies tracked', controller.totalMovies.toString(), Icons.movie_rounded, AppThemeData.neonPurpleBlueGradient)),
        spaceW(width: 12),
        Expanded(child: _buildStatCard(isDark, 'In progress', controller.watchingCount.toString(), Icons.play_circle_outline_rounded, AppThemeData.neonBlueTealGradient)),
        spaceW(width: 12),
        Expanded(child: _buildStatCard(isDark, 'Movies finished', controller.completedCount.toString(), Icons.check_circle_outline_rounded, AppThemeData.neonCyanMintGradient)),
        spaceW(width: 12),
        Expanded(child: _buildStatCard(isDark, 'Plan to watch', controller.notStartedCount.toString(), Icons.pause_circle_outline_rounded, AppThemeData.neonPinkOrangeGradient)),
      ],
    );
  }

  Widget _buildStatCard(bool isDark, String subtitle, String value, IconData icon, Gradient gradient) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppThemeData.surfaceVoid.withValues(alpha: isDark ? 0.2 : 0.08), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppThemeData.surfaceVoid.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: AppThemeData.primaryWhite.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: AppThemeData.grey1, size: 22),
                ),
                spaceW(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextCustom(title: value, fontSize: 20, fontFamily: FontFamily.bold, color: AppThemeData.grey1),
                      spaceH(height: 2),
                      TextCustom(title: subtitle, fontSize: 11, fontFamily: FontFamily.regular, color: AppThemeData.grey2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── CONTINUE WATCHING SECTION ──

  Widget _buildWatchingSection(BuildContext context, bool isDark) {
    final watching = controller.watchingMovies;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(title: 'Continue Watching', fontSize: 18, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
        spaceH(height: 14),
        SizedBox(
          height: 175,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: watching.length,
            separatorBuilder: (a, b) => spaceW(width: 12),
            itemBuilder: (ctx, i) => SizedBox(
              width: 400,
              child: _buildContinueWatchingCard(watching[i], isDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueWatchingCard(MovieModel movie, bool isDark) {
    final progress = movie.progressPercent.clamp(0.0, 100.0);
    final remaining = (movie.totalDuration ?? 0) - (movie.watchedDuration ?? 0);
    final remainingH = remaining ~/ 60;
    final remainingM = remaining % 60;
    final remainingText = remainingH > 0 ? '$remainingH hrs $remainingM mins left' : '$remainingM mins left';

    return _HoverableCard(
      onTap: () => Get.toNamed(Routes.MOVIE_DETAILS, arguments: movie),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 100, height: 148,
                child: movie.posterUrl != null && movie.posterUrl!.isNotEmpty
                    ? Stack(fit: StackFit.expand, children: [
                        NetworkImageWidget(imageUrl: movie.posterUrl!, fit: BoxFit.cover, borderRadius: 0),
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, AppThemeData.primaryBlack.withValues(alpha: 0.5)]),
                            ),
                          ),
                        ),
                      ])
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppThemeData.primary50.withValues(alpha: 0.2), AppThemeData.primary4.withValues(alpha: 0.1)],
                          ),
                        ),
                        child: Icon(Icons.movie_rounded, color: AppThemeData.primary50, size: 30),
                      ),
              ),
            ),
            spaceW(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppThemeData.neonMint.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                        child: TextCustom(title: 'WATCHING', fontSize: 9, fontFamily: FontFamily.bold, color: AppThemeData.neonMint),
                      ),
                      const Spacer(),
                      Icon(Icons.more_vert_rounded, color: AppThemeData.grey4, size: 18),
                    ],
                  ),
                  spaceH(height: 8),
                  TextCustom(title: movie.movieName ?? 'Untitled', fontSize: 15, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10, maxLine: 1, textOverflow: TextOverflow.ellipsis),
                  spaceH(height: 4),
                  TextCustom(title: remainingText, fontSize: 12, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                  spaceH(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextCustom(title: '${progress.toInt()}% Complete', fontSize: 11, fontFamily: FontFamily.bold, color: AppThemeData.neonMint),
                      TextCustom(title: movie.formattedTotalDuration, fontSize: 11, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                    ],
                  ),
                  spaceH(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 5,
                      backgroundColor: isDark ? AppThemeData.surfaceLight : AppThemeData.grey3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppThemeData.neonMint),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ALL MOVIES SECTION ──

  Widget _buildLatestMoviesSection(BuildContext context, bool isDark) {
    final latest = controller.latestMovies;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextCustom(title: 'All Movies', fontSize: 18, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
            const Spacer(),
            GestureDetector(
              onTap: () => Get.toNamed(Routes.ALL_MOVIES),
              child: Row(
                children: [
                  TextCustom(title: 'View All', fontSize: 13, fontFamily: FontFamily.medium, color: AppThemeData.primary50),
                  spaceW(width: 6),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppThemeData.primary50),
                ],
              ),
            ),
          ],
        ),
        spaceH(height: 14),
        SizedBox(
          height: 175,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: latest.length,
            separatorBuilder: (a, b) => spaceW(width: 12),
            itemBuilder: (ctx, i) => SizedBox(
              width: 400,
              child: _buildAllMovieCard(latest[i], isDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllMovieCard(MovieModel movie, bool isDark) {
    return _HoverableCard(
      onTap: () => Get.toNamed(Routes.MOVIE_DETAILS, arguments: movie),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 100, height: 148,
                child: movie.posterUrl != null && movie.posterUrl!.isNotEmpty
                    ? Stack(fit: StackFit.expand, children: [
                        NetworkImageWidget(imageUrl: movie.posterUrl!, fit: BoxFit.cover, borderRadius: 0),
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, AppThemeData.primaryBlack.withValues(alpha: 0.5)]),
                            ),
                          ),
                        ),
                      ])
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppThemeData.primary50.withValues(alpha: 0.2), AppThemeData.primary4.withValues(alpha: 0.1)],
                          ),
                        ),
                        child: Icon(Icons.movie_rounded, color: AppThemeData.primary50, size: 30),
                      ),
              ),
            ),
            spaceW(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bookmark_border_rounded, color: AppThemeData.grey4, size: 18),
                      const Spacer(),
                      Icon(Icons.more_vert_rounded, color: AppThemeData.grey4, size: 18),
                    ],
                  ),
                  spaceH(height: 4),
                  TextCustom(title: movie.movieName ?? 'Untitled', fontSize: 15, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10, maxLine: 1, textOverflow: TextOverflow.ellipsis),
                  spaceH(height: 4),
                  Row(
                    children: [
                      if (movie.year != null && movie.year!.isNotEmpty)
                        TextCustom(title: movie.year!, fontSize: 11, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                      if (movie.year != null && movie.year!.isNotEmpty && movie.genreTags.isNotEmpty)
                        TextCustom(title: ' \u2022 ', fontSize: 11, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                      if (movie.genreTags.isNotEmpty)
                        Expanded(
                          child: TextCustom(
                            title: movie.genreTags.first,
                            fontSize: 11,
                            fontFamily: FontFamily.regular,
                            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                            maxLine: 1,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  spaceH(height: 8),
                  _buildStatusBadge(movie.status),
                  if (movie.rating != null && movie.rating! > 0) ...[
                    spaceH(height: 6),
                    _buildRatingStars(movie.rating!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'WATCHING':
        bgColor = AppThemeData.neonMint.withValues(alpha: 0.2);
        textColor = AppThemeData.neonMint;
        label = 'WATCHING';
        break;
      case 'COMPLETED':
        bgColor = AppThemeData.success300.withValues(alpha: 0.2);
        textColor = AppThemeData.success300;
        label = 'COMPLETED';
        break;
      case 'NOT_STARTED':
        bgColor = AppThemeData.pending300.withValues(alpha: 0.2);
        textColor = AppThemeData.pending300;
        label = 'NOT STARTED';
        break;
      default:
        bgColor = AppThemeData.pending300.withValues(alpha: 0.2);
        textColor = AppThemeData.pending300;
        label = 'NOT STARTED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: TextCustom(title: label, fontSize: 9, fontFamily: FontFamily.bold, color: textColor),
    );
  }

  Widget _buildRatingStars(double rating) {
    final fullStars = rating.floor();
    final hasHalf = (rating - fullStars) >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalf ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < fullStars; i++)
          Icon(Icons.star_rounded, color: AppThemeData.pending300, size: 14),
        if (hasHalf)
          Icon(Icons.star_half_rounded, color: AppThemeData.pending300, size: 14),
        for (var i = 0; i < emptyStars; i++)
          Icon(Icons.star_border_rounded, color: AppThemeData.grey4, size: 14),
      ],
    );
  }
}
