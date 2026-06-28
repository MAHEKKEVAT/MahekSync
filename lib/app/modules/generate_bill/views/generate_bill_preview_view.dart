// lib/app/modules/generate_bill/views/generate_bill_preview_view.dart
// ignore: avoid_web_libraries_in_flutter
import 'dart:io';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maheksync/app/models/bill_model.dart';
import 'package:maheksync/app/modules/generate_bill/controllers/generate_bill_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/mahek_responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class GenerateBillPreviewView extends StatefulWidget {
  const GenerateBillPreviewView({super.key});

  @override
  State<GenerateBillPreviewView> createState() => _GenerateBillPreviewViewState();
}

class _GenerateBillPreviewViewState extends State<GenerateBillPreviewView> {
  final GlobalKey _previewKey = GlobalKey();
  final GenerateBillController _controller = Get.find<GenerateBillController>();

  final Map<String, bool> _visibleColumns = {
    'index': true,
    'name': true,
    'payment': true,
    'qty': true,
    'price': true,
    'total': true,
  };

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.isDarkTheme();
    final BillModel bill = Get.arguments;

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
                    _buildInvoicePreview(isDark, bill),
                    spaceH(height: 24),
                    _buildExportSection(context, isDark, bill),
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

  // ── Header ──────────────────────────────────────────────────────────

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

  // ── Invoice Preview ─────────────────────────────────────────────────

  Widget _buildInvoicePreview(bool isDark, BillModel bill) {
    final formattedDate = bill.billDate != null
        ? DateFormat('dd/MM/yyyy').format(bill.billDate!)
        : 'N/A';
    final screenWidth = MediaQuery.of(context).size.width;
    final a4Width = 595.0;
    final needsScale = screenWidth < a4Width + 64;

    return Center(
      child: SizedBox(
        width: a4Width,
        child: needsScale
            ? FittedBox(
                alignment: Alignment.topCenter,
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: a4Width,
                  child: RepaintBoundary(
                    key: _previewKey,
                    child: _buildInvoiceContent(isDark, bill, formattedDate),
                  ),
                ),
              )
            : RepaintBoundary(
                key: _previewKey,
                child: _buildInvoiceContent(isDark, bill, formattedDate),
              ),
      ),
    );
  }

  Widget _buildInvoiceContent(bool isDark, BillModel bill, String formattedDate) {
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
            spaceH(height: 24),
            _buildCustomerInfo(bill),
            spaceH(height: 20),
            _buildItemsTable(bill),
            spaceH(height: 20),
            if (bill.notes != null && bill.notes!.isNotEmpty) ...[
              _buildNotesSection(bill),
              spaceH(height: 20),
            ],
            _buildTotalSection(bill),
            spaceH(height: 32),
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
        border: Border.all(color: AppThemeData.grey3, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bill To
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
          // Divider
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14),
            height: 0.5,
            color: AppThemeData.grey3,
          ),
          // Payment Info
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
    );
  }

  // ── Items Table (conditionally renders columns) ─────────────────────

  Widget _buildItemsTable(BillModel bill) {
    final indexW = 36.0;
    final qtyW = 44.0;
    final priceW = 72.0;
    final totalW = 76.0;
    const headerFontSize = 10.0;
    const rowFontSize = 12.0;

    final showIndex = _visibleColumns['index'] == true;
    final showName = _visibleColumns['name'] == true;
    final showPayment = _visibleColumns['payment'] == true;
    final showQty = _visibleColumns['qty'] == true;
    final showPrice = _visibleColumns['price'] == true;
    final showTotal = _visibleColumns['total'] == true;

    return Column(
      children: [
        // Header row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: AppThemeData.primary50,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              if (showIndex)
                SizedBox(
                  width: indexW,
                  child: Text('#', style: TextStyle(fontSize: headerFontSize, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: FontFamily.semiBold)),
                ),
              if (showName)
                Expanded(
                  flex: 4,
                  child: Text('Item Name', style: TextStyle(fontSize: headerFontSize, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: FontFamily.semiBold)),
                ),
              if (showPayment)
                Expanded(
                  flex: 3,
                  child: Text('Payment Method', style: TextStyle(fontSize: headerFontSize, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: FontFamily.semiBold)),
                ),
              if (showQty)
                SizedBox(
                  width: qtyW,
                  child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontSize: headerFontSize, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: FontFamily.semiBold)),
                ),
              if (showPrice)
                SizedBox(
                  width: priceW,
                  child: Text('Price', textAlign: TextAlign.right, style: TextStyle(fontSize: headerFontSize, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: FontFamily.semiBold)),
                ),
              if (showTotal)
                SizedBox(
                  width: totalW,
                  child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontSize: headerFontSize, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: FontFamily.semiBold)),
                ),
            ],
          ),
        ),
        // Data rows
        ...(bill.items ?? []).asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isEven = index % 2 == 0;

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: isEven ? AppThemeData.grey1 : AppThemeData.primaryWhite,
              border: Border(bottom: BorderSide(color: AppThemeData.grey3, width: 0.5)),
            ),
            child: Row(
              children: [
                if (showIndex)
                  SizedBox(
                    width: indexW,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(fontSize: rowFontSize, color: AppThemeData.primary50, fontWeight: FontWeight.w600, fontFamily: FontFamily.semiBold),
                    ),
                  ),
                if (showName)
                  Expanded(
                    flex: 4,
                    child: Text(
                      item.itemName ?? 'N/A',
                      style: TextStyle(fontSize: rowFontSize, color: AppThemeData.grey10, fontFamily: FontFamily.regular),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (showPayment)
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        if (item.paymentMethodIcon != null && item.paymentMethodIcon!.isNotEmpty)
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
                                  child: Icon(Icons.payment_rounded, size: 12, color: AppThemeData.primary300),
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
                            child: Icon(Icons.payment_rounded, size: 12, color: AppThemeData.primary300),
                          ),
                        spaceW(width: 6),
                        Expanded(
                          child: Text(
                            item.paymentMethodName ?? 'N/A',
                            style: TextStyle(fontSize: 11, color: AppThemeData.grey7, fontFamily: FontFamily.regular),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (showQty)
                  SizedBox(
                    width: qtyW,
                    child: Text(
                      '${item.qty ?? 0}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: rowFontSize, color: AppThemeData.grey7, fontFamily: FontFamily.regular),
                    ),
                  ),
                if (showPrice)
                  SizedBox(
                    width: priceW,
                    child: Text(
                      '\u20B9${(item.unitPrice ?? 0).toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: rowFontSize, color: AppThemeData.grey7, fontFamily: FontFamily.regular),
                    ),
                  ),
                if (showTotal)
                  SizedBox(
                    width: totalW,
                    child: Text(
                      '\u20B9${(item.total ?? 0).toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: rowFontSize, fontWeight: FontWeight.w600, color: AppThemeData.grey10, fontFamily: FontFamily.semiBold),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Notes ───────────────────────────────────────────────────────────

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

  // ── Total Section ───────────────────────────────────────────────────

  Widget _buildTotalSection(BillModel bill) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 240,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppThemeData.primary50, AppThemeData.neonBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontFamily: FontFamily.semiBold,
                ),
              ),
              Text(
                '\u20B9${(bill.totalAmount ?? 0).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
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

  // ── Footer ──────────────────────────────────────────────────────────

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
                    border: Border(bottom: BorderSide(color: AppThemeData.grey4, width: 1)),
                  ),
                  child: Center(
                    child: Text(
                      'Signature',
                      style: TextStyle(fontSize: 10, color: AppThemeData.grey5, fontFamily: FontFamily.regular),
                    ),
                  ),
                );
              },
            ),
            spaceH(height: 4),
            Text(
              'Authorized Signature',
              style: TextStyle(fontSize: 10, color: AppThemeData.grey5, fontFamily: FontFamily.regular),
            ),
          ],
        ),
      ],
    );
  }

  // ── Column Picker Dialog ────────────────────────────────────────────

  static const _columnLabels = {
    'index': '#',
    'name': 'Item Name',
    'payment': 'Payment',
    'qty': 'Qty',
    'price': 'Price',
    'total': 'Total',
  };

  Future<Map<String, bool>?> _showColumnPickerDialog(bool isDark) async {
    final selections = Map<String, bool>.from(_visibleColumns);

    final result = await showModalBottomSheet<Map<String, bool>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.45,
              ),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.surfaceDark : AppThemeData.primaryWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3,
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.view_column_rounded, size: 18, color: AppThemeData.primary50),
                      spaceW(width: 8),
                      Text(
                        'Select Columns',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppThemeData.primaryWhite : AppThemeData.grey10,
                          fontFamily: FontFamily.semiBold,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? AppThemeData.surfaceElevated : AppThemeData.grey2,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.close_rounded, size: 16, color: AppThemeData.grey5),
                        ),
                      ),
                    ],
                  ),
                  spaceH(height: 16),
                  ...selections.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            setModalState(() {
                              selections[entry.key] = !selections[entry.key]!;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: entry.value
                                        ? AppThemeData.primary50
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: entry.value
                                          ? AppThemeData.primary50
                                          : (isDark ? AppThemeData.grey4 : AppThemeData.grey4),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: entry.value
                                      ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                                      : null,
                                ),
                                spaceW(width: 12),
                                Text(
                                  _columnLabels[entry.key] ?? entry.key,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? AppThemeData.primaryWhite : AppThemeData.grey10,
                                    fontFamily: FontFamily.medium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  spaceH(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() {
                              for (final key in selections.keys) {
                                selections[key] = true;
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: AppThemeData.primary50.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppThemeData.primary50.withValues(alpha: 0.3)),
                            ),
                            child: Center(
                              child: Text(
                                'Select All',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppThemeData.primary50,
                                  fontFamily: FontFamily.semiBold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      spaceW(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() {
                              for (final key in selections.keys) {
                                selections[key] = false;
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: AppThemeData.neonRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppThemeData.neonRed.withValues(alpha: 0.3)),
                            ),
                            child: Center(
                              child: Text(
                                'Deselect All',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppThemeData.neonRed,
                                  fontFamily: FontFamily.semiBold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  spaceH(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx, selections),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppThemeData.primary50, AppThemeData.neonBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Apply & Export',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: FontFamily.semiBold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    return result;
  }

  // ── Export Section (premium) ──────────────────────────────────────

  Widget _buildExportSection(BuildContext context, bool isDark, BillModel bill) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppThemeData.primary50.withValues(alpha: isDark ? 0.06 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: AppThemeData.primaryBlack.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppThemeData.primary50.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.file_download_outlined, size: 18, color: AppThemeData.primary50),
              ),
              spaceW(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(
                    title: 'Export Invoice',
                    fontSize: 14,
                    fontFamily: FontFamily.semiBold,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                  TextCustom(
                    title: 'Download as PDF, share, or export as image',
                    fontSize: 11,
                    fontFamily: FontFamily.regular,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  ),
                ],
              ),
            ],
          ),
          spaceH(height: 16),
          _buildExportButtons(context, isDark, bill),
        ],
      ),
    );
  }

  Widget _buildExportButtons(BuildContext context, bool isDark, BillModel bill) {
    final width = MahekResponsive.screenWidth(context);
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1200;

    final buttons = <_ExportButtonData>[
      _ExportButtonData(Icons.picture_as_pdf_rounded, 'PDF', AppThemeData.neonRed, () => _onExportPdf(bill), isPrimary: true),
      _ExportButtonData(Icons.share_rounded, 'Share', AppThemeData.neonBlue, () => _onSharePdf(bill)),
      _ExportButtonData(Icons.print_rounded, 'Print', AppThemeData.neonOrange, () => _onPrintPdf(bill)),
      _ExportButtonData(Icons.image_rounded, 'PNG', AppThemeData.primary300, () => _onSavePng(bill)),
      _ExportButtonData(Icons.photo_rounded, 'JPEG', AppThemeData.neonPurple, () => _onSaveJpeg(bill)),
    ];

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _HoverableExportButton(isDark: isDark, data: buttons[0])),
              spaceW(width: 10),
              Expanded(child: _HoverableExportButton(isDark: isDark, data: buttons[1])),
            ],
          ),
          spaceH(height: 10),
          Row(
            children: [
              Expanded(child: _HoverableExportButton(isDark: isDark, data: buttons[2])),
              spaceW(width: 10),
              Expanded(child: _HoverableExportButton(isDark: isDark, data: buttons[3])),
            ],
          ),
          spaceH(height: 10),
          SizedBox(
            width: (width - 52) / 2,
            child: _HoverableExportButton(isDark: isDark, data: buttons[4]),
          ),
        ],
      );
    }

    if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              for (int i = 0; i < 3; i++) ...[
                if (i > 0) spaceW(width: 10),
                Expanded(child: _HoverableExportButton(isDark: isDark, data: buttons[i])),
              ],
            ],
          ),
          spaceH(height: 10),
          Row(
            children: [
              for (int i = 3; i < 5; i++) ...[
                if (i > 3) spaceW(width: 10),
                Expanded(child: _HoverableExportButton(isDark: isDark, data: buttons[i])),
              ],
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          if (i > 0) spaceW(width: 10),
          Expanded(child: _HoverableExportButton(isDark: isDark, data: buttons[i])),
        ],
      ],
    );
  }

  // ── Export Actions ──────────────────────────────────────────────────

  Future<void> _onExportPdf(BillModel bill) async {
    final cols = await _showColumnPickerDialog(
      Provider.of<DarkThemeProvider>(context, listen: false).isDarkTheme(),
    );
    if (cols == null) return;
    await _controller.exportBillAsPdf(bill, visibleColumns: cols);
  }

  Future<void> _onSharePdf(BillModel bill) async {
    final cols = await _showColumnPickerDialog(
      Provider.of<DarkThemeProvider>(context, listen: false).isDarkTheme(),
    );
    if (cols == null) return;
    await _controller.shareBillAsPdf(bill, visibleColumns: cols);
  }

  Future<void> _onPrintPdf(BillModel bill) async {
    final cols = await _showColumnPickerDialog(
      Provider.of<DarkThemeProvider>(context, listen: false).isDarkTheme(),
    );
    if (cols == null) return;
    await _controller.printBillAsPdf(bill, visibleColumns: cols);
  }

  Future<void> _onSavePng(BillModel bill) async {
    final cols = await _showColumnPickerDialog(
      Provider.of<DarkThemeProvider>(context, listen: false).isDarkTheme(),
    );
    if (cols == null) return;

    final prevCols = Map<String, bool>.from(_visibleColumns);
    setState(() => _visibleColumns.addAll(cols));
    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      final image = await _capturePngBytes();
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
    } finally {
      setState(() => _visibleColumns.addAll(prevCols));
    }
  }

  Future<void> _onSaveJpeg(BillModel bill) async {
    final cols = await _showColumnPickerDialog(
      Provider.of<DarkThemeProvider>(context, listen: false).isDarkTheme(),
    );
    if (cols == null) return;

    final prevCols = Map<String, bool>.from(_visibleColumns);
    setState(() => _visibleColumns.addAll(cols));
    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      final pngBytes = await _capturePngBytes();
      if (pngBytes == null) {
        _showSnack('Failed to capture invoice', isError: true);
        return;
      }

      if (kIsWeb) {
        final pngBlob = html.Blob([pngBytes], 'image/png');
        final pngUrl = html.Url.createObjectUrlFromBlob(pngBlob);
        final imgElement = html.ImageElement(src: pngUrl);
        await imgElement.onLoad.first;

        final canvas = html.CanvasElement(
          width: imgElement.naturalWidth,
          height: imgElement.naturalHeight,
        );
        canvas.context2D.drawImage(imgElement, 0, 0);
        final jpegBlob = await canvas.toBlob('image/jpeg', 0.9);
        final jpegUrl = html.Url.createObjectUrlFromBlob(jpegBlob);
        html.AnchorElement(href: jpegUrl)
          ..setAttribute('download', '${bill.formattedInvoiceNumber}.jpg')
          ..click();
        html.Url.revokeObjectUrl(pngUrl);
        html.Url.revokeObjectUrl(jpegUrl);
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/bill_${bill.formattedInvoiceNumber}.jpg');
        await file.writeAsBytes(pngBytes);
        await Share.shareXFiles([XFile(file.path)], text: 'Bill ${bill.formattedInvoiceNumber}');
      }
      _showSnack('JPEG exported successfully');
    } catch (e) {
      _showSnack('Failed to save JPEG', isError: true);
    } finally {
      setState(() => _visibleColumns.addAll(prevCols));
    }
  }

  // ── Capture ─────────────────────────────────────────────────────────

  Future<Uint8List?> _capturePngBytes() async {
    try {
      final boundary = _previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      if (!mounted) return null;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Capture error: $e');
      return null;
    }
  }

  // ── Snack ───────────────────────────────────────────────────────────

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

class _ExportButtonData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;
  const _ExportButtonData(this.icon, this.label, this.color, this.onTap, {this.isPrimary = false});
}

class _HoverableExportButton extends StatefulWidget {
  final bool isDark;
  final _ExportButtonData data;

  const _HoverableExportButton({required this.isDark, required this.data});

  @override
  State<_HoverableExportButton> createState() => _HoverableExportButtonState();
}

class _HoverableExportButtonState extends State<_HoverableExportButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final data = widget.data;
    final isPrimary = data.isPrimary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: data.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: 52,
            decoration: isPrimary
                ? BoxDecoration(
                    gradient: AppThemeData.appleIntelligenceGradientCool,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppThemeData.primary50.withValues(alpha: _isHovered ? 0.45 : 0.30),
                        blurRadius: _isHovered ? 18 : 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  )
                : BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        data.color.withValues(alpha: _isHovered ? 0.18 : 0.12),
                        data.color.withValues(alpha: _isHovered ? 0.08 : 0.04),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: data.color.withValues(alpha: _isHovered ? 0.40 : 0.25),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: data.color.withValues(alpha: _isHovered ? 0.20 : 0.10),
                        blurRadius: _isHovered ? 16 : 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPrimary
                        ? Colors.white.withValues(alpha: 0.20)
                        : data.color.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    data.icon,
                    size: 18,
                    color: isPrimary ? Colors.white : data.color,
                  ),
                ),
                spaceW(width: 8),
                Text(
                  data.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? Colors.white : data.color,
                    fontFamily: FontFamily.semiBold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
