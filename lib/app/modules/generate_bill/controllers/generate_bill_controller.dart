// lib/app/modules/generate_bill/controllers/generate_bill_controller.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/constant/show_toast.dart';
import 'package:maheksync/app/firestore_utills/bill_firestore_utils.dart';
import 'package:maheksync/app/firestore_utills/payment_method_firestore_utils.dart';
import 'package:maheksync/app/models/bill_model.dart';
import 'package:maheksync/app/models/payment_method_model.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class GenerateBillController extends GetxController {
  final bills = <BillModel>[].obs;
  final paymentMethods = <PaymentMethodModel>[].obs;
  final isLoading = true.obs;
  final isSaving = false.obs;

  final toNameController = TextEditingController();
  final notesController = TextEditingController();
  final paymentInfoController = TextEditingController();
  final myNameController = TextEditingController();

  final billDate = Rxn<DateTime>();
  final invoiceNumber = ''.obs;
  final items = <BillItemModel>[].obs;
  final grandTotal = 0.0.obs;

  final isEditMode = false.obs;
  final editingBill = Rxn<BillModel>();

  final billPreviewKey = GlobalKey();

  final List<TextEditingController> itemNameControllers = [];
  final List<TextEditingController> itemQtyControllers = [];
  final List<TextEditingController> itemPriceControllers = [];

  final ValueNotifier<double> liveGrandTotal = ValueNotifier(0);

  String? get ownerId => MahekConstant.ownerModel?.id;

  // ── Computed stats for stat cards ──────────────────────────────────
  double get totalAmount => bills.fold<double>(0, (sum, b) => sum + (b.totalAmount ?? 0));
  double get avgBill => bills.isEmpty ? 0 : totalAmount / bills.length;
  int get thisMonthCount {
    final now = DateTime.now();
    return bills.where((b) =>
      b.billDate != null &&
      b.billDate!.year == now.year &&
      b.billDate!.month == now.month
    ).length;
  }
  double get thisMonthAmount {
    final now = DateTime.now();
    return bills
      .where((b) =>
        b.billDate != null &&
        b.billDate!.year == now.year &&
        b.billDate!.month == now.month)
      .fold<double>(0, (sum, b) => sum + (b.totalAmount ?? 0));
  }

  @override
  void onInit() {
    super.onInit();
    loadBills();
    loadPaymentMethods();
    if (!isEditMode.value) {
      _initNewBill();
    }
  }

  @override
  void onClose() {
    toNameController.dispose();
    notesController.dispose();
    paymentInfoController.dispose();
    myNameController.dispose();
    liveGrandTotal.dispose();
    _disposeItemControllers();
    super.onClose();
  }

  void _initNewBill() {
    billDate.value = DateTime.now();
    invoiceNumber.value = _generateInvoiceNumber();
    myNameController.text = 'MahekSync';
    liveGrandTotal.value = 0;
    addItem();
  }

  String _generateInvoiceNumber() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  }

  void loadBills() {
    if (ownerId == null) return;
    isLoading.value = true;
    BillFirestoreUtils.getUserBills(ownerId!).listen((billList) {
      bills.value = billList;
      isLoading.value = false;
    });
  }

  void loadPaymentMethods() {
    PaymentMethodFirestoreUtils.getPaymentMethods().listen((methods) {
      paymentMethods.value = methods;
    });
  }

  void addItem() {
    items.add(BillItemModel(qty: 1, unitPrice: 0, total: 0));
    itemNameControllers.add(TextEditingController());
    itemQtyControllers.add(TextEditingController(text: '1'));
    itemPriceControllers.add(TextEditingController(text: '0'));
    _calculateTotals();
    updateLiveGrandTotal();
  }

  void removeItem(int index) {
    if (items.length > 1) {
      items.removeAt(index);
      itemNameControllers[index].dispose();
      itemQtyControllers[index].dispose();
      itemPriceControllers[index].dispose();
      itemNameControllers.removeAt(index);
      itemQtyControllers.removeAt(index);
      itemPriceControllers.removeAt(index);
      _calculateTotals();
      updateLiveGrandTotal();
    } else {
      ShowToastDialog.showError('At least one item is required');
    }
  }

  void updateItemField(int index, {String? itemName, int? qty, double? unitPrice}) {
    if (index >= items.length) return;
    final item = items[index];
    if (itemName != null) item.itemName = itemName;
    if (qty != null) item.qty = qty;
    if (unitPrice != null) item.unitPrice = unitPrice;
    item.total = (item.qty ?? 0) * (item.unitPrice ?? 0);
    items[index] = item;
    _calculateTotals();
  }

  void updateItemPaymentMethod(int index, PaymentMethodModel? method) {
    if (index >= items.length || method == null) return;
    final item = items[index];
    item.paymentMethodId = method.id;
    item.paymentMethodName = method.pName;
    item.paymentMethodIcon = method.pIcon;
    items[index] = item;
  }

  void _calculateTotals() {
    double total = 0;
    for (final item in items) {
      total += (item.qty ?? 0) * (item.unitPrice ?? 0);
    }
    grandTotal.value = total;
  }

  void updateLiveGrandTotal() {
    double total = 0;
    for (int i = 0; i < itemQtyControllers.length; i++) {
      final qty = int.tryParse(itemQtyControllers[i].text) ?? 1;
      final price = double.tryParse(itemPriceControllers[i].text) ?? 0;
      total += qty * price;
    }
    liveGrandTotal.value = total;
  }

  void loadBillForEdit(BillModel bill) {
    isEditMode.value = true;
    editingBill.value = bill;
    toNameController.text = bill.toName ?? '';
    notesController.text = bill.notes ?? '';
    paymentInfoController.text = bill.paymentInfo ?? '';
    myNameController.text = bill.myName ?? 'MahekSync';
    billDate.value = bill.billDate ?? DateTime.now();
    invoiceNumber.value = bill.invoiceNumber ?? _generateInvoiceNumber();
    _disposeItemControllers();
    items.clear();
    items.addAll(bill.items ?? []);
    for (final item in items) {
      itemNameControllers.add(TextEditingController(text: item.itemName ?? ''));
      itemQtyControllers.add(TextEditingController(text: '${item.qty ?? 1}'));
      itemPriceControllers.add(TextEditingController(text: '${item.unitPrice ?? 0}'));
    }
    _calculateTotals();
  }

  void resetForm() {
    isEditMode.value = false;
    editingBill.value = null;
    toNameController.clear();
    notesController.clear();
    paymentInfoController.clear();
    myNameController.clear();
    _disposeItemControllers();
    items.clear();
    _initNewBill();
  }

  void _disposeItemControllers() {
    for (final c in itemNameControllers) {
      c.dispose();
    }
    for (final c in itemQtyControllers) {
      c.dispose();
    }
    for (final c in itemPriceControllers) {
      c.dispose();
    }
    itemNameControllers.clear();
    itemQtyControllers.clear();
    itemPriceControllers.clear();
  }

  void _syncControllersToItems() {
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      item.itemName = itemNameControllers[i].text;
      final qty = int.tryParse(itemQtyControllers[i].text) ?? 1;
      final price = double.tryParse(itemPriceControllers[i].text) ?? 0;
      item.qty = qty;
      item.unitPrice = price;
      item.total = qty * price;
      items[i] = item;
    }
    _calculateTotals();
  }

  Future<void> saveBill() async {
    if (toNameController.text.trim().isEmpty) {
      ShowToastDialog.showError('Please enter a name');
      return;
    }
    if (items.isEmpty) {
      ShowToastDialog.showError('Please add at least one item');
      return;
    }

    _syncControllersToItems();

    for (int i = 0; i < items.length; i++) {
      if (items[i].itemName == null || items[i].itemName!.trim().isEmpty) {
        ShowToastDialog.showError('Please enter item name for row ${i + 1}');
        return;
      }
    }

    isSaving.value = true;

    final bill = BillModel(
      id: isEditMode.value ? editingBill.value?.id : null,
      ownerId: ownerId,
      toName: toNameController.text.trim(),
      invoiceNumber: invoiceNumber.value,
      billDate: billDate.value,
      items: items.toList(),
      notes: notesController.text.trim(),
      totalAmount: grandTotal.value,
      paymentInfo: paymentInfoController.text.trim(),
      myName: myNameController.text.trim(),
    );

    bool success;
    if (isEditMode.value) {
      success = await BillFirestoreUtils.updateBill(bill);
    } else {
      success = await BillFirestoreUtils.addBill(bill);
    }

    if (success) {
      ShowToastDialog.showSuccess(
          isEditMode.value ? 'Bill updated successfully' : 'Bill created successfully');
      resetForm();
      Get.back(result: true);
    } else {
      ShowToastDialog.showError('Failed to save bill');
    }

    isSaving.value = false;
  }

  Future<void> deleteBill(String billId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Bill'),
        content: const Text('Are you sure you want to delete this bill?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await BillFirestoreUtils.deleteBill(billId);
      if (success) {
        ShowToastDialog.showSuccess('Bill deleted successfully');
      } else {
        ShowToastDialog.showError('Failed to delete bill');
      }
    }
  }

  void viewBillPreview(BillModel bill) {
    Get.toNamed(Routes.GENERATE_BILL_PREVIEW, arguments: bill);
  }

  void editBill(BillModel bill) {
    Get.toNamed(Routes.GENERATE_BILL_CREATE, arguments: bill);
  }

  Future<Uint8List?> captureBillAsImage() async {
    try {
      final boundary = billPreviewKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> exportAsPng() async {
    final bytes = await captureBillAsImage();
    if (bytes == null) {
      _showSnack('Failed to capture bill', isError: true);
      return;
    }

    try {
      if (kIsWeb) {
        final xfile = XFile.fromData(bytes, mimeType: 'image/png', name: 'bill_${invoiceNumber.value}.png');
        await Share.shareXFiles([xfile], text: 'Bill ${invoiceNumber.value}');
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/bill_${invoiceNumber.value}.png');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(file.path)], text: 'Bill ${invoiceNumber.value}');
      }
      _showSnack('PNG exported successfully');
    } catch (e) {
      _showSnack('Failed to export PNG', isError: true);
    }
  }

  Future<void> exportAsJpeg() async {
    final bytes = await captureBillAsImage();
    if (bytes == null) {
      _showSnack('Failed to capture bill', isError: true);
      return;
    }

    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        _showSnack('Failed to process image', isError: true);
        return;
      }

      final jpegBytes = img.encodeJpg(decoded, quality: 90);
      if (kIsWeb) {
        final xfile = XFile.fromData(jpegBytes, mimeType: 'image/jpeg', name: 'bill_${invoiceNumber.value}.jpg');
        await Share.shareXFiles([xfile], text: 'Bill ${invoiceNumber.value}');
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/bill_${invoiceNumber.value}.jpg');
        await file.writeAsBytes(jpegBytes);
        await Share.shareXFiles([XFile(file.path)], text: 'Bill ${invoiceNumber.value}');
      }
      _showSnack('JPEG exported successfully');
    } catch (e) {
      _showSnack('Failed to export JPEG', isError: true);
    }
  }

  Future<void> exportAsPdf() async {
    try {
      _syncControllersToItems();
      final bill = _buildBillModel();
      await _generateAndExportPdf(bill);
    } catch (e) {
      _showSnack('Failed to export PDF', isError: true);
    }
  }

  Future<void> exportBillAsPdf(BillModel bill) async {
    try {
      await _generateAndExportPdf(bill);
    } catch (e) {
      _showSnack('Failed to export PDF', isError: true);
    }
  }

  Future<void> shareBillAsPdf(BillModel bill) async {
    try {
      final pdfBytes = await _buildPdfBytes(bill);
      if (kIsWeb) {
        await Printing.sharePdf(bytes: pdfBytes, filename: 'bill_${bill.invoiceNumber}.pdf');
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/bill_${bill.invoiceNumber}.pdf');
        await file.writeAsBytes(pdfBytes);
        await Share.shareXFiles([XFile(file.path)], text: 'Bill ${bill.formattedInvoiceNumber}');
      }
      _showSnack('PDF shared successfully');
    } catch (e) {
      _showSnack('Failed to share PDF', isError: true);
    }
  }

  Future<void> printBillAsPdf(BillModel bill) async {
    try {
      final pdfBytes = await _buildPdfBytes(bill);
      await Printing.layoutPdf(
        onLayout: (format) => pdfBytes,
        name: 'bill_${bill.invoiceNumber}',
      );
    } catch (e) {
      _showSnack('Failed to print PDF', isError: true);
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

  Future<void> _generateAndExportPdf(BillModel bill) async {
    final pdfBytes = await _buildPdfBytes(bill);
    if (kIsWeb) {
      await Printing.sharePdf(bytes: pdfBytes, filename: 'bill_${bill.invoiceNumber}.pdf');
    } else {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/bill_${bill.invoiceNumber}.pdf');
      await file.writeAsBytes(pdfBytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Bill ${bill.formattedInvoiceNumber}');
    }
    _showSnack('PDF exported successfully');
  }

  Future<Uint8List> _buildPdfBytes(BillModel bill) async {
    final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/noto/NotoSans-Regular.ttf'));
    final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/noto/NotoSans-Bold.ttf'));
    final medium = pw.Font.ttf(await rootBundle.load('assets/fonts/noto/NotoSans-Medium.ttf'));

    pw.MemoryImage? signatureImage;
    try {
      final signatureData = await rootBundle.load('assets/images/my_signature.png');
      signatureImage = pw.MemoryImage(signatureData.buffer.asUint8List());
    } catch (_) {}

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        build: (context) => [
          _buildPdfHeader(bill, regular, bold, medium),
          pw.SizedBox(height: 20),
          _buildPdfCustomerInfo(bill, regular, bold, medium),
          pw.SizedBox(height: 20),
          _buildPdfItemTable(bill, regular, bold, medium),
          pw.SizedBox(height: 16),
          if (bill.notes != null && bill.notes!.isNotEmpty) ...[
            _buildPdfNotes(bill, regular, bold),
            pw.SizedBox(height: 16),
          ],
          _buildPdfTotal(bill, regular, bold),
          pw.SizedBox(height: 36),
          _buildPdfFooter(bill, regular, bold, medium, signatureImage),
        ],
      ),
    );

    return pdf.save();
  }

  BillModel _buildBillModel() {
    _syncControllersToItems();
    return BillModel(
      toName: toNameController.text.trim(),
      invoiceNumber: invoiceNumber.value,
      billDate: billDate.value,
      items: items.toList(),
      notes: notesController.text.trim(),
      totalAmount: liveGrandTotal.value,
      paymentInfo: paymentInfoController.text.trim(),
      myName: myNameController.text.trim(),
    );
  }

  static const PdfColor _primary = PdfColor(0.365, 0.329, 0.949);
  static const PdfColor _primaryLight = PdfColor(0.482, 0.561, 1.0);
  static const PdfColor _primaryBg = PdfColor(0.961, 0.965, 1.0);
  static const PdfColor _dark = PdfColor(0.067, 0.075, 0.102);
  static const PdfColor _grey = PdfColor(0.604, 0.604, 0.604);

  pw.Widget _buildPdfHeader(BillModel bill, pw.Font font, pw.Font fontBold, pw.Font fontMedium) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [_primary, _primaryLight],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'MahekSync',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 28,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'INVOICE',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 12,
                  color: PdfColors.white,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Invoice #: ${bill.invoiceNumber ?? 'N/A'}',
                style: pw.TextStyle(font: fontMedium, fontSize: 12, color: PdfColors.white),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Date: ${bill.formattedBillDate}',
                style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfCustomerInfo(BillModel bill, pw.Font font, pw.Font fontBold, pw.Font fontMedium) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _primaryBg,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'BILL TO',
                  style: pw.TextStyle(font: font, fontSize: 8, color: _grey, letterSpacing: 1.5),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  bill.toName ?? 'N/A',
                  style: pw.TextStyle(font: fontBold, fontSize: 14, color: _dark),
                ),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PAYMENT INFO',
                  style: pw.TextStyle(font: font, fontSize: 8, color: _grey, letterSpacing: 1.5),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  bill.paymentInfo ?? 'N/A',
                  style: pw.TextStyle(font: font, fontSize: 11, color: _dark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfItemTable(BillModel bill, pw.Font font, pw.Font fontBold, pw.Font fontMedium) {
    final items = bill.items ?? [];

    return pw.Column(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(
              colors: [_primary, _primaryLight],
              begin: pw.Alignment.topLeft,
              end: pw.Alignment.bottomRight,
            ),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(
            children: [
              pw.SizedBox(
                width: 32,
                child: pw.Text('#', style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.white)),
              ),
              pw.Expanded(
                flex: 3,
                child: pw.Text('Item Name', style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.white)),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text('Payment', style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.white)),
              ),
              pw.SizedBox(
                width: 40,
                child: pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text('Qty', style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.white)),
                ),
              ),
              pw.SizedBox(
                width: 80,
                child: pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text('Total', style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.white)),
                ),
              ),
            ],
          ),
        ),
        ...items.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final item = entry.value;
          final isOdd = index % 2 == 1;

          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 9, horizontal: 4),
            decoration: isOdd
                ? null
                : pw.BoxDecoration(color: _primaryBg, borderRadius: pw.BorderRadius.circular(4)),
            child: pw.Row(
              children: [
                pw.SizedBox(
                  width: 32,
                  child: pw.Text('$index', style: pw.TextStyle(font: font, fontSize: 9, color: _grey)),
                ),
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(item.itemName ?? 'N/A', style: pw.TextStyle(font: fontMedium, fontSize: 9, color: _dark)),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(item.paymentMethodName ?? 'N/A', style: pw.TextStyle(font: font, fontSize: 9, color: _grey)),
                ),
                pw.SizedBox(
                  width: 40,
                  child: pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Text('${item.qty ?? 0}', style: pw.TextStyle(font: font, fontSize: 9, color: _dark)),
                  ),
                ),
                pw.SizedBox(
                  width: 80,
                  child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text('\u20B9${(item.total ?? 0).toStringAsFixed(2)}',
                        style: pw.TextStyle(font: fontMedium, fontSize: 9, color: _dark)),
                  ),
                ),
              ],
            ),
          );
        }),
        pw.Container(height: 0.5, color: _primaryLight),
      ],
    );
  }

  pw.Widget _buildPdfNotes(BillModel bill, pw.Font font, pw.Font fontBold) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _primaryBg,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'NOTES',
            style: pw.TextStyle(font: fontBold, fontSize: 8, color: _primary, letterSpacing: 1.5),
          ),
          pw.SizedBox(height: 4),
          pw.Text(bill.notes ?? '', style: pw.TextStyle(font: font, fontSize: 9, color: _dark)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTotal(BillModel bill, pw.Font font, pw.Font fontBold) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 260,
          padding: const pw.EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(
              colors: [_primary, _primaryLight],
              begin: pw.Alignment.topLeft,
              end: pw.Alignment.bottomRight,
            ),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Grand Total',
                style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColors.white),
              ),
              pw.Text(
                '\u20B9${(bill.totalAmount ?? 0).toStringAsFixed(2)}',
                style: pw.TextStyle(font: fontBold, fontSize: 18, color: PdfColors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfFooter(BillModel bill, pw.Font font, pw.Font fontBold, pw.Font fontMedium, pw.MemoryImage? signatureImage) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'PAYMENT INFO',
              style: pw.TextStyle(font: fontBold, fontSize: 7, color: _grey, letterSpacing: 1.5),
            ),
            pw.SizedBox(height: 3),
            pw.Text(bill.paymentInfo ?? 'N/A', style: pw.TextStyle(font: font, fontSize: 9, color: _dark)),
            pw.SizedBox(height: 10),
            pw.Text(
              'AUTHORIZED SIGNATORY',
              style: pw.TextStyle(font: fontBold, fontSize: 7, color: _grey, letterSpacing: 1.5),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              bill.myName ?? 'MahekSync',
              style: pw.TextStyle(font: fontBold, fontSize: 11, color: _primary),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            if (signatureImage != null)
              pw.Image(signatureImage, height: 40, width: 140)
            else
              pw.Container(
                width: 140,
                height: 1,
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: _primary, width: 1),
                  ),
                ),
              ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Authorized Signature',
              style: pw.TextStyle(font: font, fontSize: 7, color: _grey),
            ),
          ],
        ),
      ],
    );
  }
}
