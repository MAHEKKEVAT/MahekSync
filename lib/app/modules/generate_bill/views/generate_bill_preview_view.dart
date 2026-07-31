// lib/app/modules/generate_bill/views/generate_bill_preview_view.dart
// ignore: avoid_web_libraries_in_flutter
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:archive/archive.dart';
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

// Conditional web import
import 'dart:html' as html;

class GenerateBillPreviewView extends StatefulWidget {
  const GenerateBillPreviewView({super.key});

  @override
  State<GenerateBillPreviewView> createState() => _GenerateBillPreviewViewState();
}

class _GenerateBillPreviewViewState extends State<GenerateBillPreviewView> {
  final GlobalKey _previewKey = GlobalKey();
  final GenerateBillController _controller = Get.find<GenerateBillController>();

  static const double _a4Width = 595.0;
  static const double _a4Height = 842.0;
  static const double _headerH = 76.0;
  static const double _customerInfoH = 120.0;
  static const double _itemsHeaderH = 40.0;
  static const double _itemsRowH = 34.0;
  static const double _notesH = 80.0;
  static const double _totalH = 70.0;
  static const double _footerH = 100.0;
  static const double _spacerH = 20.0;
  static const double _pagePadding = 64.0;
  static const double _usableHeight = _a4Height - _pagePadding;

  final Map<String, bool> _visibleColumns = {
    'index': true,
    'name': true,
    'payment': true,
    'qty': true,
    'price': true,
    'total': true,
  };

  int _estimatePageCount(BillModel bill) {
    final items = bill.items ?? [];
    final notesH = (bill.notes != null && bill.notes!.isNotEmpty) ? _notesH + _spacerH : 0.0;
    final contentH = _headerH + _spacerH + _customerInfoH + _spacerH + _itemsHeaderH +
        (items.length * _itemsRowH) + notesH + _totalH + _footerH + (_spacerH * 3);
    return math.max(1, (contentH / _usableHeight).ceil());
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.isDarkTheme();
    final BillModel bill = Get.arguments;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Container(
      color: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark, bill),
            Expanded(
              child: isDesktop
                  ? _buildDesktopLayout(context, isDark, bill)
                  : _buildMobileLayout(context, isDark, bill),
            ),
          ],
        ),
      ),
    );
  }

  // ── Layout ─────────

  Widget _buildDesktopLayout(BuildContext context, bool isDark, BillModel bill) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildInvoicePreview(isDark, bill),
          ),
        ),
        SizedBox(
          width: 280,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
            child: _buildExportSection(context, isDark, bill),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark, BillModel bill) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInvoicePreview(isDark, bill),
          spaceH(height: 24),
          _buildExportSection(context, isDark, bill),
          spaceH(height: 20),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────

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
          _buildPageCountChip(bill),
        ],
      ),
    );
  }

  Widget _buildPageCountChip(BillModel bill) {
    final pageCount = _estimatePageCount(bill);
    if (pageCount <= 1) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppThemeData.primary50.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeData.primary50.withValues(alpha: 0.3)),
      ),
      child: TextCustom(
        title: '$pageCount pages',
        fontSize: 12,
        fontFamily: FontFamily.semiBold,
        color: AppThemeData.primary50,
      ),
    );
  }

  // ── Invoice Preview ────────────────────────────────────────────────

  Widget _buildInvoicePreview(bool isDark, BillModel bill) {
    final formattedDate = bill.billDate != null
        ? DateFormat('dd/MM/yyyy').format(bill.billDate!)
        : 'N/A';
    final screenWidth = MediaQuery.of(context).size.width;
    final needsScale = screenWidth < _a4Width + 64;

    return Center(
      child: SizedBox(
        width: _a4Width,
        child: needsScale
            ? FittedBox(
                alignment: Alignment.topCenter,
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: _a4Width,
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
      constraints: const BoxConstraints(minHeight: _a4Height),
      decoration: BoxDecoration(
        color: AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppThemeData.primaryBlack.withValues(alpha: 0.1),
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
            Builder(
              builder: (ctx) {
                final items = bill.items ?? [];
                final notesH = (bill.notes != null && bill.notes!.isNotEmpty) ? _notesH + _spacerH : 0.0;
                final contentH = _headerH + _spacerH + _customerInfoH + _spacerH + _itemsHeaderH +
                    (items.length * _itemsRowH) + notesH;
                final totalFooterH = _totalH + _footerH + _spacerH;
                final remaining = _usableHeight - contentH - totalFooterH;
                final spacerH = remaining > 0 ? remaining : 0.0;
                return SizedBox(height: spacerH);
              },
            ),
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
            TextCustom(
              title: 'MahekSync',
              fontSize: 32,
              fontFamily: FontFamily.bold,
              color: AppThemeData.primary50,
            ),
            spaceH(height: 4),
            TextCustom(
              title: 'INVOICE',
              fontSize: 14,
              fontFamily: FontFamily.medium,
              color: AppThemeData.grey5,
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
        TextCustom(
          title: '$label: ',
          fontSize: 12,
          fontFamily: FontFamily.regular,
          color: AppThemeData.grey5,
        ),
        TextCustom(
          title: value,
          fontSize: 12,
          fontFamily: FontFamily.semiBold,
          color: AppThemeData.grey10,
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
          TextCustom(title: 'BILL TO', fontSize: 10, fontFamily: FontFamily.medium, color: AppThemeData.grey5),
          spaceH(height: 6),
          TextCustom(title: bill.toName ?? 'N/A', fontSize: 18, fontFamily: FontFamily.bold, color: AppThemeData.grey10),
          Container(margin: const EdgeInsets.symmetric(vertical: 14), height: 0.5, color: AppThemeData.grey3),
          TextCustom(title: 'PAYMENT INFO', fontSize: 10, fontFamily: FontFamily.medium, color: AppThemeData.grey5),
          spaceH(height: 6),
          TextCustom(title: bill.paymentInfo ?? 'N/A', fontSize: 13, fontFamily: FontFamily.regular, color: AppThemeData.grey7),
        ],
      ),
    );
  }

  // ── Items Table ───────────────────────────────────────────────────

  Widget _buildItemsTable(BillModel bill) {
    final indexW = 36.0;
    final qtyW = 44.0;
    final priceW = 72.0;
    final totalW = 76.0;

    final showIndex = _visibleColumns['index'] == true;
    final showName = _visibleColumns['name'] == true;
    final showPayment = _visibleColumns['payment'] == true;
    final showQty = _visibleColumns['qty'] == true;
    final showPrice = _visibleColumns['price'] == true;
    final showTotal = _visibleColumns['total'] == true;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: AppThemeData.primary50,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              if (showIndex)
                SizedBox(width: indexW, child: TextCustom(title: '#', fontSize: 10, fontFamily: FontFamily.semiBold, color: AppThemeData.primaryWhite)),
              if (showName)
                Expanded(flex: 4, child: TextCustom(title: 'Item Name', fontSize: 10, fontFamily: FontFamily.semiBold, color: AppThemeData.primaryWhite)),
              if (showPayment)
                Expanded(flex: 3, child: TextCustom(title: 'Payment Method', fontSize: 10, fontFamily: FontFamily.semiBold, color: AppThemeData.primaryWhite)),
              if (showQty)
                SizedBox(width: qtyW, child: TextCustom(title: 'Qty', fontSize: 10, fontFamily: FontFamily.semiBold, color: AppThemeData.primaryWhite, textAlign: TextAlign.center)),
              if (showPrice)
                SizedBox(width: priceW, child: TextCustom(title: 'Price', fontSize: 10, fontFamily: FontFamily.semiBold, color: AppThemeData.primaryWhite, textAlign: TextAlign.right)),
              if (showTotal)
                SizedBox(width: totalW, child: TextCustom(title: 'Total', fontSize: 10, fontFamily: FontFamily.semiBold, color: AppThemeData.primaryWhite, textAlign: TextAlign.right)),
            ],
          ),
        ),
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
                  SizedBox(width: indexW, child: TextCustom(title: '${index + 1}', fontSize: 12, fontFamily: FontFamily.semiBold, color: AppThemeData.primary50)),
                if (showName)
                  Expanded(flex: 4, child: TextCustom(title: item.itemName ?? 'N/A', fontSize: 12, maxLine: 1, color: AppThemeData.grey10)),
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
                              width: 18, height: 18, fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 18, height: 18,
                                  decoration: BoxDecoration(color: AppThemeData.primary300.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                  child: Icon(Icons.payment_rounded, size: 12, color: AppThemeData.primary300),
                                );
                              },
                            ),
                          )
                        else
                          Container(
                            width: 18, height: 18,
                            decoration: BoxDecoration(color: AppThemeData.primary300.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: Icon(Icons.payment_rounded, size: 12, color: AppThemeData.primary300),
                          ),
                        spaceW(width: 6),
                        Expanded(child: TextCustom(title: item.paymentMethodName ?? 'N/A', fontSize: 11, maxLine: 1, color: AppThemeData.grey7)),
                      ],
                    ),
                  ),
                if (showQty)
                  SizedBox(width: qtyW, child: TextCustom(title: '${item.qty ?? 0}', fontSize: 12, color: AppThemeData.grey7, textAlign: TextAlign.center)),
                if (showPrice)
                  SizedBox(width: priceW, child: TextCustom(title: '\u20B9${(item.unitPrice ?? 0).toStringAsFixed(2)}', fontSize: 12, color: AppThemeData.grey7, textAlign: TextAlign.right)),
                if (showTotal)
                  SizedBox(width: totalW, child: TextCustom(title: '\u20B9${(item.total ?? 0).toStringAsFixed(2)}', fontSize: 12, fontFamily: FontFamily.semiBold, color: AppThemeData.grey10, textAlign: TextAlign.right)),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Notes ─────────────────────────────────────────────────────────

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
          TextCustom(title: 'Notes', fontSize: 11, fontFamily: FontFamily.medium, color: AppThemeData.grey5),
          spaceH(height: 6),
          TextCustom(title: bill.notes ?? '', fontSize: 13, color: AppThemeData.grey7),
        ],
      ),
    );
  }

  // ── Total Section ─────────────────────────────────────────────────

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
              BoxShadow(color: AppThemeData.primary50.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextCustom(title: 'Grand Total', fontSize: 14, fontFamily: FontFamily.semiBold, color: AppThemeData.primaryWhite.withValues(alpha: 0.9)),
              TextCustom(title: '\u20B9${(bill.totalAmount ?? 0).toStringAsFixed(2)}', fontSize: 20, fontFamily: FontFamily.bold, color: AppThemeData.primaryWhite),
            ],
          ),
        ),
      ],
    );
  }

  // ── Footer ────────────────────────────────────────────────────────

  Widget _buildFooter(BillModel bill) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(title: 'PAYMENT INFORMATION', fontSize: 10, fontFamily: FontFamily.medium, color: AppThemeData.grey5),
                spaceH(height: 6),
                TextCustom(title: bill.paymentInfo ?? 'N/A', fontSize: 13, color: AppThemeData.grey7),
                spaceH(height: 16),
                TextCustom(title: 'My Name', fontSize: 10, fontFamily: FontFamily.medium, color: AppThemeData.grey5),
                spaceH(height: 6),
                TextCustom(title: bill.myName ?? 'MahekSync', fontSize: 14, fontFamily: FontFamily.bold, color: AppThemeData.grey10),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset(
                'assets/images/my_signature.png',
                width: 120, height: 60, fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120, height: 60,
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppThemeData.grey4, width: 1))),
                    child: Center(child: TextCustom(title: 'Signature', fontSize: 10, color: AppThemeData.grey5)),
                  );
                },
              ),
              spaceH(height: 4),
              TextCustom(title: 'Authorized Signature', fontSize: 10, color: AppThemeData.grey5),
            ],
          ),
        ],
    );
  }

  // ── Column Picker Dialog ──────────────────────────────────────────

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
              constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.45),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.surfaceDark : AppThemeData.primaryWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3, width: 0.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.view_column_rounded, size: 18, color: AppThemeData.primary50),
                      spaceW(width: 8),
                      TextCustom(title: 'Select Columns', fontSize: 15, fontFamily: FontFamily.semiBold, color: isDark ? AppThemeData.primaryWhite : AppThemeData.grey10),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: isDark ? AppThemeData.surfaceElevated : AppThemeData.grey2, borderRadius: BorderRadius.circular(8)),
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
                          onTap: () => setModalState(() => selections[entry.key] = !selections[entry.key]!),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 22, height: 22,
                                  decoration: BoxDecoration(
                                    color: entry.value ? AppThemeData.primary50 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: entry.value ? AppThemeData.primary50 : AppThemeData.grey4, width: 1.5),
                                  ),
                                  child: entry.value ? Icon(Icons.check_rounded, size: 14, color: AppThemeData.primaryWhite) : null,
                                ),
                                spaceW(width: 12),
                                TextCustom(title: _columnLabels[entry.key] ?? entry.key, fontSize: 14, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.primaryWhite : AppThemeData.grey10),
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
                          onTap: () => setModalState(() {
                            for (final key in selections.keys) { selections[key] = true; }
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppThemeData.primary50.withValues(alpha: 0.3))),
                            child: Center(child: TextCustom(title: 'Select All', fontSize: 13, fontFamily: FontFamily.semiBold, color: AppThemeData.primary50)),
                          ),
                        ),
                      ),
                      spaceW(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() {
                            for (final key in selections.keys) { selections[key] = false; }
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(color: AppThemeData.neonRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppThemeData.neonRed.withValues(alpha: 0.3))),
                            child: Center(child: TextCustom(title: 'Deselect All', fontSize: 13, fontFamily: FontFamily.semiBold, color: AppThemeData.neonRed)),
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
                        gradient: LinearGradient(colors: [AppThemeData.primary50, AppThemeData.neonBlue], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: TextCustom(title: 'Apply & Export', fontSize: 14, fontFamily: FontFamily.semiBold, color: AppThemeData.primaryWhite)),
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

  // ── Export Section ────────────────────────────────────────────────

  Widget _buildExportSection(BuildContext context, bool isDark, BillModel bill) {
    final width = MahekResponsive.screenWidth(context);
    final isDesktop = width >= 900;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3, width: 0.5),
        boxShadow: [
          BoxShadow(color: AppThemeData.primary50.withValues(alpha: isDark ? 0.06 : 0.04), blurRadius: 20, offset: const Offset(0, 6)),
          BoxShadow(color: AppThemeData.primaryBlack.withValues(alpha: isDark ? 0.15 : 0.04), blurRadius: 12, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.file_download_outlined, size: 18, color: AppThemeData.primary50),
              ),
              spaceW(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextCustom(title: 'Export Invoice', fontSize: 14, fontFamily: FontFamily.semiBold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                    TextCustom(title: 'Download as PDF or export as image', fontSize: 11, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                  ],
                ),
              ),
            ],
          ),
          spaceH(height: 16),
          _buildExportButtons(context, isDark, bill, isDesktop),
        ],
      ),
    );
  }

  Widget _buildExportButtons(BuildContext context, bool isDark, BillModel bill, bool isDesktop) {
    final buttons = <_ExportButtonData>[
      _ExportButtonData(Icons.picture_as_pdf_rounded, 'PDF', AppThemeData.neonRed, () => _onExportPdf(bill), isPrimary: true),
      _ExportButtonData(Icons.print_rounded, 'Print', AppThemeData.neonOrange, () => _onPrintPdf(bill)),
      _ExportButtonData(Icons.image_rounded, 'PNG', AppThemeData.primary300, () => _onSavePng(bill)),
      _ExportButtonData(Icons.photo_rounded, 'JPEG', AppThemeData.neonPurple, () => _onSaveJpeg(bill)),
    ];

    if (isDesktop) {
      return Column(
        children: [
          for (int i = 0; i < buttons.length; i++) ...[
            if (i > 0) spaceH(height: 10),
            _HoverableExportButton(isDark: isDark, data: buttons[i]),
          ],
        ],
      );
    }

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
      ],
    );
  }

  // ── Export Actions ────────────────────────────────────────────────

  Future<void> _onExportPdf(BillModel bill) async {
    final cols = await _showColumnPickerDialog(Provider.of<DarkThemeProvider>(context, listen: false).isDarkTheme());
    if (cols == null) return;
    await _controller.exportBillAsPdf(bill, visibleColumns: cols);
  }

  Future<void> _onPrintPdf(BillModel bill) async {
    final cols = await _showColumnPickerDialog(Provider.of<DarkThemeProvider>(context, listen: false).isDarkTheme());
    if (cols == null) return;
    await _controller.printBillAsPdf(bill, visibleColumns: cols);
  }

  Future<void> _onSavePng(BillModel bill) async {
    final cols = await _showColumnPickerDialog(Provider.of<DarkThemeProvider>(context, listen: false).isDarkTheme());
    if (cols == null) return;

    final prevCols = Map<String, bool>.from(_visibleColumns);
    setState(() => _visibleColumns.addAll(cols));
    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      final pageCount = _estimatePageCount(bill);
      if (pageCount <= 1) {
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
      } else {
        final pageImages = await _captureMultiPageImages();
        if (pageImages == null || pageImages.isEmpty) {
          _showSnack('Failed to capture invoice', isError: true);
          return;
        }
        await _downloadAsZip(pageImages, bill.formattedInvoiceNumber, 'png');
        _showSnack('PNG pages exported as ZIP');
      }
    } catch (e) {
      _showSnack('Failed to save PNG', isError: true);
    } finally {
      setState(() => _visibleColumns.addAll(prevCols));
    }
  }

  Future<void> _onSaveJpeg(BillModel bill) async {
    final cols = await _showColumnPickerDialog(Provider.of<DarkThemeProvider>(context, listen: false).isDarkTheme());
    if (cols == null) return;

    final prevCols = Map<String, bool>.from(_visibleColumns);
    setState(() => _visibleColumns.addAll(cols));
    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      final pageCount = _estimatePageCount(bill);
      if (pageCount <= 1) {
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
          final canvas = html.CanvasElement(width: imgElement.naturalWidth, height: imgElement.naturalHeight);
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
      } else {
        final pageImages = await _captureMultiPageImages();
        if (pageImages == null || pageImages.isEmpty) {
          _showSnack('Failed to capture invoice', isError: true);
          return;
        }
        await _downloadAsZip(pageImages, bill.formattedInvoiceNumber, 'jpg');
        _showSnack('JPEG pages exported as ZIP');
      }
    } catch (e) {
      _showSnack('Failed to save JPEG', isError: true);
    } finally {
      setState(() => _visibleColumns.addAll(prevCols));
    }
  }

  // ── Multi-Page Capture & ZIP ─────────────────────────────────────

  Future<List<Uint8List>?> _captureMultiPageImages() async {
    try {
      final boundary = _previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      if (!mounted) return null;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final fullBytes = byteData.buffer.asUint8List();
      final pageHeightPx = (_a4Height * 2).toInt();
      final totalHeightPx = image.height;
      final pageWidthPx = image.width;

      if (totalHeightPx <= pageHeightPx) {
        return [fullBytes];
      }

      final pages = <Uint8List>[];
      int srcY = 0;

      while (srcY < totalHeightPx) {
        final chunkHeight = math.min(pageHeightPx, totalHeightPx - srcY);
        final pageRecorder = ui.PictureRecorder();
        final pageCanvas = Canvas(pageRecorder);

        final srcRect = Rect.fromLTWH(0, srcY.toDouble(), pageWidthPx.toDouble(), chunkHeight.toDouble());
        final dstRect = Rect.fromLTWH(0, 0, pageWidthPx.toDouble(), chunkHeight.toDouble());

        pageCanvas.drawImageRect(
          image,
          srcRect,
          dstRect,
          Paint()..filterQuality = FilterQuality.high,
        );

        final pagePicture = pageRecorder.endRecording();
        final pageImage = await pagePicture.toImage(pageWidthPx, chunkHeight);
        final pageByteData = await pageImage.toByteData(format: ui.ImageByteFormat.png);
        if (pageByteData != null) {
          pages.add(pageByteData.buffer.asUint8List());
        }

        srcY += pageHeightPx;
      }

      return pages;
    } catch (e) {
      debugPrint('Multi-page capture error: $e');
      return null;
    }
  }

  Future<void> _downloadAsZip(List<Uint8List> images, String invoiceNumber, String ext) async {
    final archive = Archive();
    for (int i = 0; i < images.length; i++) {
      archive.add(ArchiveFile('page_${i + 1}.$ext', images[i].length, images[i]));
    }
    final zipData = ZipEncoder().encode(archive);
    final zipBytes = Uint8List.fromList(zipData);

    if (kIsWeb) {
      final blob = html.Blob([zipBytes], 'application/zip');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'bill_$invoiceNumber.zip')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/bill_$invoiceNumber.zip');
      await file.writeAsBytes(zipBytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Bill $invoiceNumber (${images.length} pages)');
    }
  }

  // ── Capture ───────────────────────────────────────────────────────

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

  // ── Snack ─────────────────────────────────────────────────────────

  void _showSnack(String message, {bool isError = false}) {
    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: isError ? AppThemeData.danger300 : AppThemeData.success300,
      colorText: AppThemeData.primaryWhite,
      titleText: TextCustom(
        title: isError ? 'Error' : 'Success',
        fontSize: 14,
        fontFamily: FontFamily.semiBold,
        color: AppThemeData.primaryWhite,
      ),
      messageText: TextCustom(
        title: message,
        fontSize: 13,
        color: AppThemeData.primaryWhite,
      ),
      duration: const Duration(seconds: 3),
    );
  }
}

// ── Export Button Data ────────────────────────────────────────────────

class _ExportButtonData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;
  const _ExportButtonData(this.icon, this.label, this.color, this.onTap, {this.isPrimary = false});
}

// ── Hoverable Export Button ───────────────────────────────────────────

class _HoverableExportButton extends StatefulWidget {
  final bool isDark;
  final _ExportButtonData data;

  const _HoverableExportButton({required this.isDark, required this.data});

  @override
  State<_HoverableExportButton> createState() => _HoverableExportButtonState();
}

class _HoverableExportButtonState extends State<_HoverableExportButton> {
  bool _isHovered = false;

  void _onHover(bool v) {
    if (_isHovered == v) return;
    _isHovered = v;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final isPrimary = data.isPrimary;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
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
                    border: Border.all(color: data.color.withValues(alpha: _isHovered ? 0.40 : 0.25), width: 1),
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
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPrimary ? AppThemeData.primaryWhite.withValues(alpha: 0.20) : data.color.withValues(alpha: 0.15),
                  ),
                  child: Icon(data.icon, size: 18, color: isPrimary ? AppThemeData.primaryWhite : data.color),
                ),
                spaceW(width: 8),
                TextCustom(
                  title: data.label,
                  fontSize: 13,
                  fontFamily: FontFamily.semiBold,
                  color: isPrimary ? AppThemeData.primaryWhite : data.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
