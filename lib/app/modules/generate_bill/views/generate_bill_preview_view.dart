// lib/app/modules/generate_bill/views/generate_bill_preview_view.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:maheksync/app/models/bill_model.dart';
import 'package:maheksync/app/modules/generate_bill/controllers/generate_bill_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class GenerateBillPreviewView extends StatelessWidget {
  const GenerateBillPreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.isDarkTheme();
    final controller = Get.find<GenerateBillController>();
    final BillModel bill = Get.arguments;
    final GlobalKey previewKey = GlobalKey();

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark, bill),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    RepaintBoundary(
                      key: previewKey,
                      child: _buildInvoicePreview(isDark, bill),
                    ),
                    spaceH(height: 24),
                    _buildExportButtons(
                        context, isDark, controller, previewKey, bill),
                    spaceH(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, BillModel bill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceDark : AppThemeData.primaryWhite,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.surfaceElevated : AppThemeData.grey2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
              ),
            ),
          ),
          spaceW(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  title: 'Invoice Preview',
                  fontSize: 18,
                  fontFamily: FontFamily.bold,
                  color: isDark ? AppThemeData.primaryWhite : AppThemeData.grey10,
                ),
                spaceH(height: 2),
                TextCustom(
                  title: 'Invoice #${bill.formattedInvoiceNumber}',
                  fontSize: 12,
                  fontFamily: FontFamily.regular,
                  color: AppThemeData.primary50,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicePreview(bool isDark, BillModel bill) {
    final formattedDate = bill.billDate != null
        ? DateFormat('dd/MM/yyyy').format(bill.billDate!)
        : 'N/A';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInvoiceHeader(formattedDate, bill),
            spaceH(height: 32),
            _buildCustomerInfo(bill),
            spaceH(height: 28),
            _buildItemsTable(bill),
            spaceH(height: 24),
            if (bill.notes != null && bill.notes!.isNotEmpty) ...[
              _buildNotesSection(bill),
              spaceH(height: 24),
            ],
            _buildTotalSection(bill),
            spaceH(height: 40),
            _buildFooter(bill),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader(String formattedDate, BillModel bill) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MahekSync',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppThemeData.primary50,
                fontFamily: FontFamily.bold,
              ),
            ),
            spaceH(height: 4),
            Text(
              'INVOICE',
              style: TextStyle(
                fontSize: 14,
                color: AppThemeData.grey5,
                fontFamily: FontFamily.medium,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildInfoRow('Invoice #', bill.formattedInvoiceNumber),
            spaceH(height: 6),
            _buildInfoRow('Date', formattedDate),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: AppThemeData.grey5,
            fontFamily: FontFamily.regular,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: AppThemeData.grey10,
            fontFamily: FontFamily.semiBold,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo(BillModel bill) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeData.grey1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppThemeData.grey3,
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BILL TO',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppThemeData.grey5,
                    fontFamily: FontFamily.medium,
                    letterSpacing: 1,
                  ),
                ),
                spaceH(height: 6),
                Text(
                  bill.toName ?? 'N/A',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppThemeData.grey10,
                    fontFamily: FontFamily.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PAYMENT INFO',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppThemeData.grey5,
                    fontFamily: FontFamily.medium,
                    letterSpacing: 1,
                  ),
                ),
                spaceH(height: 6),
                Text(
                  bill.paymentInfo ?? 'N/A',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppThemeData.grey7,
                    fontFamily: FontFamily.regular,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable(BillModel bill) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppThemeData.primary50,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  '#',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: FontFamily.semiBold,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Item Name',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: FontFamily.semiBold,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: FontFamily.semiBold,
                  ),
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  'Qty',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: FontFamily.semiBold,
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  'Price',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: FontFamily.semiBold,
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  'Total',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: FontFamily.semiBold,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...(bill.items ?? []).asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isEven = index % 2 == 0;

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isEven ? AppThemeData.grey1 : AppThemeData.primaryWhite,
              border: Border(
                bottom: BorderSide(color: AppThemeData.grey3, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppThemeData.primary50,
                      fontWeight: FontWeight.w600,
                      fontFamily: FontFamily.semiBold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    item.itemName ?? 'N/A',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppThemeData.grey10,
                      fontFamily: FontFamily.regular,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      if (item.paymentMethodIcon != null &&
                          item.paymentMethodIcon!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            item.paymentMethodIcon!,
                            width: 18,
                            height: 18,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: AppThemeData.primary300.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(Icons.payment_rounded,
                                    size: 12, color: AppThemeData.primary300),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppThemeData.primary300.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(Icons.payment_rounded,
                              size: 12, color: AppThemeData.primary300),
                        ),
                      spaceW(width: 6),
                      Expanded(
                        child: Text(
                          item.paymentMethodName ?? 'N/A',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppThemeData.grey7,
                            fontFamily: FontFamily.regular,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: 50,
                child: Text(
                  '${item.qty ?? 0}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppThemeData.grey7,
                    fontFamily: FontFamily.regular,
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  '₹${(item.unitPrice ?? 0).toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppThemeData.grey7,
                    fontFamily: FontFamily.regular,
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  '₹${(item.total ?? 0).toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppThemeData.grey10,
                    fontFamily: FontFamily.semiBold,
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

  Widget _buildNotesSection(BillModel bill) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeData.grey1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppThemeData.grey3, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppThemeData.grey5,
              fontFamily: FontFamily.medium,
              letterSpacing: 1,
            ),
          ),
          spaceH(height: 6),
          Text(
            bill.notes ?? '',
            style: TextStyle(
              fontSize: 13,
              color: AppThemeData.grey7,
              fontFamily: FontFamily.regular,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection(BillModel bill) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppThemeData.primary50,
                AppThemeData.neonBlue,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppThemeData.primary50.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontFamily: FontFamily.semiBold,
                ),
              ),
              Text(
                '₹${(bill.totalAmount ?? 0).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: FontFamily.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BillModel bill) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PAYMENT INFORMATION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppThemeData.grey5,
                  fontFamily: FontFamily.medium,
                  letterSpacing: 1,
                ),
              ),
              spaceH(height: 6),
              Text(
                bill.paymentInfo ?? 'N/A',
                style: TextStyle(
                  fontSize: 13,
                  color: AppThemeData.grey7,
                  fontFamily: FontFamily.regular,
                ),
              ),
              spaceH(height: 16),
              Text(
                'My Name',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppThemeData.grey5,
                  fontFamily: FontFamily.medium,
                  letterSpacing: 1,
                ),
              ),
              spaceH(height: 6),
              Text(
                bill.myName ?? 'MahekSync',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppThemeData.grey10,
                  fontFamily: FontFamily.bold,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Image.asset(
              'assets/images/my_signature.png',
              width: 120,
              height: 60,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 120,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppThemeData.grey4, width: 1),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Signature',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppThemeData.grey5,
                        fontFamily: FontFamily.regular,
                      ),
                    ),
                  ),
                );
              },
            ),
            spaceH(height: 4),
            Text(
              'Authorized Signature',
              style: TextStyle(
                fontSize: 10,
                color: AppThemeData.grey5,
                fontFamily: FontFamily.regular,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExportButtons(
    BuildContext context,
    bool isDark,
    GenerateBillController controller,
    GlobalKey previewKey,
    BillModel bill,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.file_download_outlined,
                  size: 18, color: AppThemeData.primary50),
              spaceW(width: 8),
              TextCustom(
                title: 'EXPORT OPTIONS',
                fontSize: 11,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ],
          ),
          spaceH(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildExportButton(
                  isDark,
                  Icons.picture_as_pdf_rounded,
                  'Download PDF',
                  AppThemeData.neonRed,
                  () => _exportPdf(controller, bill),
                ),
              ),
              spaceW(width: 12),
              Expanded(
                child: _buildExportButton(
                  isDark,
                  Icons.share_rounded,
                  'Share PDF',
                  AppThemeData.neonBlue,
                  () => _sharePdf(controller, bill),
                ),
              ),
            ],
          ),
          spaceH(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildExportButton(
                  isDark,
                  Icons.print_rounded,
                  'Print',
                  AppThemeData.neonOrange,
                  () => _printPdf(controller, bill),
                ),
              ),
              spaceW(width: 12),
              Expanded(
                child: _buildExportButton(
                  isDark,
                  Icons.image_rounded,
                  'Save PNG',
                  AppThemeData.primary300,
                  () => _savePng(previewKey, bill),
                ),
              ),
              spaceW(width: 12),
              Expanded(
                child: _buildExportButton(
                  isDark,
                  Icons.photo_rounded,
                  'Save JPEG',
                  AppThemeData.neonPurple,
                  () => _saveJpeg(previewKey, bill),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(
    bool isDark,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            spaceH(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
                fontFamily: FontFamily.semiBold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPdf(GenerateBillController controller, BillModel bill) async {
    await controller.exportBillAsPdf(bill);
  }

  Future<void> _sharePdf(GenerateBillController controller, BillModel bill) async {
    await controller.shareBillAsPdf(bill);
  }

  Future<void> _printPdf(GenerateBillController controller, BillModel bill) async {
    await controller.printBillAsPdf(bill);
  }

  Future<Uint8List?> _capturePngBytes(GlobalKey previewKey) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final ctx = previewKey.currentContext;
      if (ctx == null) return null;
      final boundary = ctx.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Capture error: $e');
      return null;
    }
  }

  Future<void> _savePng(GlobalKey previewKey, BillModel bill) async {
    try {
      final image = await _capturePngBytes(previewKey);
      if (image == null) {
        _showSnack('Failed to capture invoice', isError: true);
        return;
      }

      if (kIsWeb) {
        final blob = html.Blob([image], 'image/png');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', '${bill.formattedInvoiceNumber}.png')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/bill_${bill.formattedInvoiceNumber}.png');
        await file.writeAsBytes(image);
        await Share.shareXFiles([XFile(file.path)], text: 'Bill ${bill.formattedInvoiceNumber}');
      }
      _showSnack('PNG exported successfully');
    } catch (e) {
      _showSnack('Failed to save PNG', isError: true);
    }
  }

  Future<void> _saveJpeg(GlobalKey previewKey, BillModel bill) async {
    try {
      final pngBytes = await _capturePngBytes(previewKey);
      if (pngBytes == null) {
        _showSnack('Failed to capture invoice', isError: true);
        return;
      }

      final decoded = img.decodeImage(pngBytes);
      if (decoded == null) {
        _showSnack('Failed to process image', isError: true);
        return;
      }

      final jpegBytes = img.encodeJpg(decoded, quality: 90);
      if (kIsWeb) {
        final blob = html.Blob([jpegBytes], 'image/jpeg');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', '${bill.formattedInvoiceNumber}.jpg')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/bill_${bill.formattedInvoiceNumber}.jpg');
        await file.writeAsBytes(jpegBytes);
        await Share.shareXFiles([XFile(file.path)], text: 'Bill ${bill.formattedInvoiceNumber}');
      }
      _showSnack('JPEG exported successfully');
    } catch (e) {
      _showSnack('Failed to save JPEG', isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: isError ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
      colorText: Colors.white,
      titleText: Text(
        isError ? 'Error' : 'Success',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
      ),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
      duration: const Duration(seconds: 3),
    );
  }
}
