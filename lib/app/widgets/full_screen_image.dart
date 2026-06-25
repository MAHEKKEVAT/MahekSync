import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/mahek_responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;

  const FullScreenImageViewer({super.key, required this.imageUrl, this.heroTag});

  @override
  Widget build(BuildContext context) {
    final pad = MahekResponsive.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppThemeData.primaryBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Interactive image
          InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            child: Center(
              child: heroTag != null
                  ? Hero(tag: heroTag!, child: _buildImage())
                  : _buildImage(),
            ),
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(pad.left, MediaQuery.of(context).padding.top + 8, pad.right, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppThemeData.primaryBlack.withValues(alpha: 0.8),
                    AppThemeData.primaryBlack.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Row(
                children: [
                  _buildCircleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Get.back(),
                  ),
                  spaceW(width: 12),
                  Expanded(
                    child: TextCustom(
                      title: 'Image',
                      fontSize: 16,
                      fontFamily: FontFamily.semiBold,
                      color: AppThemeData.grey1,
                    ),
                  ),
                  _buildCircleButton(
                    icon: Icons.close_rounded,
                    onTap: () => Get.back(),
                  ),
                ],
              ),
            ),
          ),

          // Bottom hint
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(pad.left, 16, pad.right, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppThemeData.primaryBlack.withValues(alpha: 0.8),
                    AppThemeData.primaryBlack.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.zoom_in_rounded, size: 16, color: AppThemeData.grey5),
                  spaceW(width: 6),
                  TextCustom(
                    title: 'Pinch to zoom \u2022 Drag to pan',
                    fontSize: 12,
                    fontFamily: FontFamily.regular,
                    color: AppThemeData.grey5,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
      placeholder: (ctx, url) => const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppThemeData.grey5,
          ),
        ),
      ),
      errorWidget: (ctx, url, error) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_rounded, size: 48, color: AppThemeData.grey6),
            spaceH(height: 8),
            TextCustom(
              title: 'Failed to load image',
              fontSize: 13,
              fontFamily: FontFamily.regular,
              color: AppThemeData.grey5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppThemeData.primaryWhite.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: AppThemeData.primaryWhite.withValues(alpha: 0.15)),
        ),
        child: Icon(icon, color: AppThemeData.grey1, size: 18),
      ),
    );
  }
}
