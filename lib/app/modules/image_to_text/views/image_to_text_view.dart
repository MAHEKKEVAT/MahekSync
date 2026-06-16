import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:provider/provider.dart';
import '../controllers/image_to_text_controller.dart';

class ImageToTextView extends GetView<ImageToTextController> {
  const ImageToTextView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.isDarkTheme();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey2,
      body: Column(
        children: [
          _buildHeader(isDark, context),
          Expanded(
            child: Obx(() {
              if (controller.isProcessing.value) {
                return _buildProcessingState(isDark, context);
              }
              if (controller.hasResult) {
                return _buildResultState(isDark, context, size);
              }
              return _buildUploadState(isDark, context, size);
            }),
          ),
          Obx(() => controller.hasResult ? _buildFooter(isDark) : const SizedBox.shrink()),
        ],
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────────────────
  Widget _buildHeader(bool isDark, BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: isDark
                ? AppThemeData.primaryBlack.withValues(alpha: 0.7)
                : AppThemeData.primaryWhite.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? AppThemeData.primaryWhite.withValues(alpha: 0.08)
                    : AppThemeData.primaryBlack.withValues(alpha: 0.06),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppThemeData.neonPurple, AppThemeData.neonBlue],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/ic_image_text.svg',
                    width: 22,
                    height: 22,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ),
              spaceW(width: 14),
              const TextCustom(
                title: 'Image to Text',
                fontSize: 20,
                fontFamily: FontFamily.bold,
              ),
              spaceW(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppThemeData.pending400.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppThemeData.pending400.withValues(alpha: 0.3)),
                ),
                child: const TextCustom(
                  title: 'BETA',
                  fontSize: 10,
                  fontFamily: FontFamily.bold,
                  color: AppThemeData.pending400,
                ),
              ),
              const Spacer(),
              // Language Selector
              _buildLanguageDropdown(isDark),
              spaceW(width: 12),
              // Choose Another File button (when result showing)
              Obx(() => controller.hasResult
                  ? _buildHeaderButton(
                      icon: Icons.upload_file_rounded,
                      label: 'Choose File',
                      isDark: isDark,
                      onTap: controller.pickFile,
                    )
                  : const SizedBox.shrink()),
              spaceW(width: 8),
              // Clear button
              Obx(() => controller.hasResult
                  ? _buildHeaderButton(
                      icon: Icons.delete_outline_rounded,
                      label: 'Clear',
                      isDark: isDark,
                      onTap: controller.clearAll,
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(bool isDark) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? AppThemeData.primaryWhite.withValues(alpha: 0.08)
              : AppThemeData.primaryBlack.withValues(alpha: 0.06),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedLanguage.value,
          isDense: true,
          dropdownColor: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
          style: TextStyle(
            color: isDark ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
            fontFamily: FontFamily.medium,
            fontSize: 13,
          ),
          items: controller.languages.entries.map((e) {
            return DropdownMenuItem(
              value: e.key,
              child: TextCustom(
                title: '${e.value} (${e.key.toUpperCase()})',
                fontSize: 13,
                color: isDark ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) controller.setLanguage(val);
          },
        ),
      ),
    ));
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? AppThemeData.primaryWhite.withValues(alpha: 0.08)
                : AppThemeData.primaryBlack.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppThemeData.danger400),
            spaceW(width: 6),
            TextCustom(
              title: label,
              fontSize: 13,
              color: AppThemeData.danger400,
            ),
          ],
        ),
      ),
    );
  }

  // ── UPLOAD STATE ────────────────────────────────────────────────────────
  Widget _buildUploadState(bool isDark, BuildContext context, Size size) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Upload area
              GestureDetector(
                onTap: controller.pickFile,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppThemeData.primaryWhite.withValues(alpha: 0.03)
                        : AppThemeData.primaryWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppThemeData.neonPurple.withValues(alpha: 0.2)
                          : AppThemeData.primary50.withValues(alpha: 0.15),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppThemeData.neonPurple.withValues(alpha: 0.15),
                              AppThemeData.neonBlue.withValues(alpha: 0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/ic_image_text.svg',
                            width: 40,
                            height: 40,
                            colorFilter: const ColorFilter.mode(
                                AppThemeData.neonPurple, BlendMode.srcIn),
                          ),
                        ),
                      ),
                      spaceH(height: 20),
                      const TextCustom(
                        title: 'Upload Image or PDF',
                        fontSize: 20,
                        fontFamily: FontFamily.bold,
                      ),
                      spaceH(height: 8),
                      TextCustom(
                        title: 'Supports PNG, JPEG, WEBP, BMP, TIFF, GIF, PDF',
                        fontSize: 14,
                        color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                      ),
                      spaceH(height: 20),
                      // Language selector in upload area
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppThemeData.primaryWhite.withValues(alpha: 0.06)
                              : AppThemeData.grey2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppThemeData.neonPurple.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.language_rounded, size: 18, color: AppThemeData.neonPurple),
                            spaceW(width: 8),
                            const TextCustom(
                              title: 'OCR Language:',
                              fontSize: 13,
                              fontFamily: FontFamily.medium,
                              color: AppThemeData.neonPurple,
                            ),
                            spaceW(width: 10),
                            Obx(() => DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: controller.selectedLanguage.value,
                                isDense: true,
                                dropdownColor: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
                                style: TextStyle(
                                  color: isDark ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
                                  fontFamily: FontFamily.medium,
                                  fontSize: 14,
                                ),
                                items: controller.languages.entries.map((e) {
                                  return DropdownMenuItem(
                                    value: e.key,
                                    child: TextCustom(
                                      title: '${e.value} (${e.key.toUpperCase()})',
                                      fontSize: 13,
                                      color: isDark ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) controller.setLanguage(val);
                                },
                              ),
                            )),
                          ],
                        ),
                      ),
                      spaceH(height: 24),
                      // Upload button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppThemeData.neonPurple, AppThemeData.neonBlue],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppThemeData.neonPurple.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.upload_file_rounded, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            TextCustom(
                              title: 'Choose File',
                              fontSize: 15,
                              fontFamily: FontFamily.medium,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── PROCESSING STATE ────────────────────────────────────────────────────
  Widget _buildProcessingState(bool isDark, BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingAnimationWidget.threeArchedCircle(
            color: AppThemeData.neonPurple,
            size: 60,
          ),
          spaceH(height: 24),
          Obx(() => TextCustom(
                title: controller.processingMessage.value,
                fontSize: 16,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              )),
          spaceH(height: 12),
          Obx(() {
            if (controller.isPdf && controller.pdfPageCount.value > 0) {
              return SizedBox(
                width: 240,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: controller.currentPdfPage.value /
                            controller.pdfPageCount.value,
                        backgroundColor:
                            isDark ? AppThemeData.grey9 : AppThemeData.grey3,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppThemeData.neonPurple),
                        minHeight: 6,
                      ),
                    ),
                    spaceH(height: 8),
                    TextCustom(
                      title:
                          'Page ${controller.currentPdfPage.value} of ${controller.pdfPageCount.value}',
                      fontSize: 12,
                      color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          spaceH(height: 28),
          // Cancel button
          InkWell(
            onTap: controller.cancelProcessing,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: AppThemeData.danger400.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppThemeData.danger400.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stop_rounded, color: AppThemeData.danger400, size: 18),
                  SizedBox(width: 8),
                  TextCustom(
                    title: 'Cancel',
                    fontSize: 14,
                    fontFamily: FontFamily.medium,
                    color: AppThemeData.danger400,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── RESULT STATE ────────────────────────────────────────────────────────
  Widget _buildResultState(bool isDark, BuildContext context, Size size) {
    final isWide = size.width > 900;

    if (isWide) {
      return Row(
        children: [
          // Left: Image preview
          Expanded(
            flex: 4,
            child: _buildImagePreview(isDark),
          ),
          // Right: Text output
          Expanded(
            flex: 5,
            child: _buildTextOutput(isDark),
          ),
        ],
      );
    }

    // Narrow: stacked
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildImagePreview(isDark),
          _buildTextOutput(isDark),
        ],
      ),
    );
  }

  Widget _buildImagePreview(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppThemeData.primaryWhite.withValues(alpha: 0.06)
              : AppThemeData.primaryBlack.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File name header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.image_rounded,
                    size: 18, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                spaceW(width: 8),
                Expanded(
                  child: TextCustom(
                    title: controller.selectedFileName.value,
                    fontSize: 14,
                    fontFamily: FontFamily.medium,
                    color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
                  ),
                ),
                if (controller.isPdf) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppThemeData.neonPurple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: TextCustom(
                      title: '${controller.pdfPageCount.value} pages',
                      fontSize: 11,
                      color: AppThemeData.neonPurple,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          // Image content
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: _buildFilePreview(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview(bool isDark) {
    if (controller.isPdf) {
      return _buildPdfPreview(isDark);
    }
    return _buildImagePreviewContent(isDark);
  }

  Widget _buildImagePreviewContent(bool isDark) {
    final bytes = controller.selectedFileBytes.value;
    if (bytes == null) return const SizedBox.shrink();

    return SizedBox.expand(
      child: InteractiveViewer(
        maxScale: 3.0,
        child: Image.memory(
          bytes,
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),
      ),
    );
  }

  Widget _buildPdfPreview(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.picture_as_pdf_rounded,
              size: 64, color: AppThemeData.danger400),
          spaceH(height: 12),
          TextCustom(
            title: 'PDF Document',
            fontSize: 16,
            fontFamily: FontFamily.medium,
            color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
          ),
          spaceH(height: 4),
          TextCustom(
            title: '${controller.pdfPageCount.value} pages processed',
            fontSize: 13,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
        ],
      ),
    );
  }

  Widget _buildTextOutput(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppThemeData.primaryWhite.withValues(alpha: 0.06)
              : AppThemeData.primaryBlack.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.text_snippet_rounded,
                    size: 18,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                spaceW(width: 8),
                const TextCustom(
                  title: 'Extracted Text',
                  fontSize: 14,
                  fontFamily: FontFamily.medium,
                ),
                const Spacer(),
                // Copy button
                _buildActionButton(
                  icon: Icons.copy_rounded,
                  label: 'Copy',
                  isDark: isDark,
                  onTap: controller.copyText,
                ),
                spaceW(width: 8),
                // Download button
                _buildActionButton(
                  icon: Icons.download_rounded,
                  label: 'Download',
                  isDark: isDark,
                  onTap: controller.downloadText,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Text content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                controller.fullDisplayText,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey3 : AppThemeData.grey8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? AppThemeData.primaryWhite.withValues(alpha: 0.06)
              : AppThemeData.primaryBlack.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppThemeData.neonPurple),
            spaceW(width: 6),
            TextCustom(
              title: label,
              fontSize: 12,
              color: AppThemeData.neonPurple,
            ),
          ],
        ),
      ),
    );
  }

  // ── FOOTER ──────────────────────────────────────────────────────────────
  Widget _buildFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppThemeData.primaryBlack.withValues(alpha: 0.5)
            : AppThemeData.primaryWhite.withValues(alpha: 0.7),
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppThemeData.primaryWhite.withValues(alpha: 0.06)
                : AppThemeData.primaryBlack.withValues(alpha: 0.04),
          ),
        ),
      ),
      child: Row(
        children: [
          _buildFooterChip(
            icon: Icons.check_circle_outline,
            label: 'Success',
            color: AppThemeData.success400,
            isDark: isDark,
          ),
          spaceW(width: 16),
          Obx(() => _buildFooterChip(
                icon: Icons.language_rounded,
                label: controller.languages[controller.selectedLanguage.value] ?? '',
                color: AppThemeData.neonPurple,
                isDark: isDark,
              )),
          spaceW(width: 16),
          Obx(() {
            final wordCount = controller.fullDisplayText
                .split(RegExp(r'\s+'))
                .where((w) => w.isNotEmpty)
                .length;
            return _buildFooterChip(
              icon: Icons.format_list_numbered,
              label: '$wordCount words',
              color: AppThemeData.neonBlue,
              isDark: isDark,
            );
          }),
          const Spacer(),
          Obx(() => controller.isPdf
              ? _buildFooterChip(
                  icon: Icons.description_rounded,
                  label: '${controller.pdfPageCount.value} pages',
                  color: AppThemeData.secondary4,
                  isDark: isDark,
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildFooterChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          spaceW(width: 5),
          TextCustom(
            title: label,
            fontSize: 11,
            color: color,
          ),
        ],
      ),
    );
  }
}
