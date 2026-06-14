// lib/app/modules/generate_bill/views/generate_bill_create_view.dart
import 'package:flutter/material.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/models/bill_model.dart';
import 'package:maheksync/app/models/payment_method_model.dart';
import 'package:maheksync/app/modules/generate_bill/controllers/generate_bill_controller.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_field_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:provider/provider.dart';

class GenerateBillCreateView extends StatefulWidget {
  const GenerateBillCreateView({super.key});

  @override
  State<GenerateBillCreateView> createState() => _GenerateBillCreateViewState();
}

class _GenerateBillCreateViewState extends State<GenerateBillCreateView> {
  late GenerateBillController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<GenerateBillController>();
    final bill = Get.arguments;
    if (bill != null && bill is BillModel) {
      controller.loadBillForEdit(bill);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.isDarkTheme();

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBillInfoSection(isDark, context: context),
                    spaceH(height: 24),
                    _buildItemsSection(isDark),
                    spaceH(height: 24),
                    _buildSummarySection(isDark),
                    spaceH(height: 24),
                    _buildSaveButton(isDark),
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

  Widget _buildHeader(BuildContext context, bool isDark) {
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
                  title: controller.isEditMode.value ? 'Edit Bill' : 'New Bill',
                  fontSize: 18,
                  fontFamily: FontFamily.bold,
                  color: isDark ? AppThemeData.primaryWhite : AppThemeData.grey10,
                ),
                spaceH(height: 2),
                Obx(() => TextCustom(
                      title: 'Invoice #${controller.invoiceNumber.value}',
                      fontSize: 12,
                      fontFamily: FontFamily.regular,
                      color: AppThemeData.primary50,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillInfoSection(bool isDark, {required BuildContext context}) {
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
              Icon(Icons.person_outline_rounded,
                  size: 18, color: AppThemeData.primary50),
              spaceW(width: 8),
              TextCustom(
                title: 'BILL TO',
                fontSize: 11,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ],
          ),
          spaceH(height: 12),
          TextFieldWidget(
            title: 'To Name',
            hintText: 'Enter customer name',
            controller: controller.toNameController,
            onPress: () {},
            prefix: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.person_outline_rounded, color: AppThemeData.primary50, size: 18),
            ),
          ),
          spaceH(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 18, color: AppThemeData.primary50),
              spaceW(width: 8),
              TextCustom(
                title: 'BILL DATE',
                fontSize: 11,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ],
          ),
          spaceH(height: 12),
          Obx(() => GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: controller.billDate.value ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    controller.billDate.value = date;
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppThemeData.primary50.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.calendar_today_outlined,
                            color: AppThemeData.primary50, size: 18),
                      ),
                      spaceW(width: 12),
                      TextCustom(
                        title: controller.billDate.value != null
                            ? '${controller.billDate.value!.day.toString().padLeft(2, '0')}/${controller.billDate.value!.month.toString().padLeft(2, '0')}/${controller.billDate.value!.year}'
                            : 'Select date',
                        fontSize: 14,
                        fontFamily: FontFamily.regular,
                        color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildItemsSection(bool isDark) {
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
              Icon(Icons.list_alt_rounded,
                  size: 18, color: AppThemeData.primary50),
              spaceW(width: 8),
              TextCustom(
                title: 'ITEMS',
                fontSize: 11,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ],
          ),
          spaceH(height: 16),
          _buildItemsHeader(isDark),
          spaceH(height: 8),
          Obx(() => Column(
                children: List.generate(controller.items.length, (index) {
                  return _buildItemRow(index, isDark);
                }),
              )),
          spaceH(height: 12),
          _buildAddItemButton(isDark),
        ],
      ),
    );
  }

  Widget _buildItemsHeader(bool isDark) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: TextCustom(
            title: '#',
            fontSize: 11,
            fontFamily: FontFamily.medium,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
        ),
        Expanded(
          flex: 3,
          child: TextCustom(
            title: 'Item Name',
            fontSize: 11,
            fontFamily: FontFamily.medium,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
        ),
        Expanded(
          flex: 2,
          child: TextCustom(
            title: 'Payment',
            fontSize: 11,
            fontFamily: FontFamily.medium,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
        ),
        SizedBox(
          width: 60,
          child: TextCustom(
            title: 'Qty',
            fontSize: 11,
            fontFamily: FontFamily.medium,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
        ),
        SizedBox(
          width: 80,
          child: TextCustom(
            title: 'Price',
            fontSize: 11,
            fontFamily: FontFamily.medium,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
        ),
        SizedBox(
          width: 80,
          child: TextCustom(
            title: 'Total',
            fontSize: 11,
            fontFamily: FontFamily.medium,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
        ),
        SizedBox(width: 40),
      ],
    );
  }

  Widget _buildItemRow(int index, bool isDark) {
    final nameCtrl = controller.itemNameControllers[index];
    final qtyCtrl = controller.itemQtyControllers[index];
    final priceCtrl = controller.itemPriceControllers[index];

    return StatefulBuilder(
      builder: (context, setRowState) {
        final qty = int.tryParse(qtyCtrl.text) ?? 1;
        final price = double.tryParse(priceCtrl.text) ?? 0;
        final rowTotal = qty * price;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.surfaceDark : AppThemeData.grey1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: TextCustom(
                  title: '${index + 1}',
                  fontSize: 13,
                  fontFamily: FontFamily.medium,
                  color: AppThemeData.primary50,
                ),
              ),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    controller: nameCtrl,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Item name',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppThemeData.primary50,
                        ),
                      ),
                      filled: true,
                      fillColor:
                          isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
                    ),
                  ),
                ),
              ),
              spaceW(width: 8),
              Expanded(
                flex: 2,
                child: _buildPaymentMethodDropdown(index, isDark, controller.items[index]),
              ),
              spaceW(width: 8),
              SizedBox(
                width: 60,
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    controller: qtyCtrl,
                    textDirection: TextDirection.ltr,
                    onChanged: (_) {
                      setRowState(() {});
                      controller.updateLiveGrandTotal();
                    },
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                    ),
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppThemeData.primary50,
                        ),
                      ),
                      filled: true,
                      fillColor:
                          isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
                    ),
                  ),
                ),
              ),
              spaceW(width: 8),
              SizedBox(
                width: 80,
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    controller: priceCtrl,
                    textDirection: TextDirection.ltr,
                    onChanged: (_) {
                      setRowState(() {});
                      controller.updateLiveGrandTotal();
                    },
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                    ),
                    decoration: InputDecoration(
                      prefixText: '₹',
                      prefixStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppThemeData.primary50,
                        ),
                      ),
                      filled: true,
                      fillColor:
                          isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
                    ),
                  ),
                ),
              ),
              spaceW(width: 8),
              SizedBox(
                width: 80,
                child: TextCustom(
                  title: '₹${rowTotal.toStringAsFixed(2)}',
                  fontSize: 13,
                  fontFamily: FontFamily.semiBold,
                  color: AppThemeData.primary300,
                ),
              ),
              GestureDetector(
                onTap: () {
                  controller.removeItem(index);
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppThemeData.danger300.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppThemeData.danger300,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodDropdown(
      int index, bool isDark, BillItemModel item) {
    return Obx(() => Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
              width: 0.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<PaymentMethodModel>(
              value: controller.paymentMethods
                      .any((m) => m.id == item.paymentMethodId)
                  ? controller.paymentMethods
                      .firstWhere((m) => m.id == item.paymentMethodId)
                  : null,
              isExpanded: true,
              isDense: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
              hint: Text(
                'Select',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                ),
              ),
              dropdownColor:
                  isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
              items: controller.paymentMethods.map((method) {
                return DropdownMenuItem<PaymentMethodModel>(
                  value: method,
                  child: Row(
                    children: [
                      if (method.pIcon != null && method.pIcon!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            method.pIcon!,
                            width: 18,
                            height: 18,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: AppThemeData.primary300
                                      .withValues(alpha: 0.1),
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
                            color:
                                AppThemeData.primary300.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(Icons.payment_rounded,
                              size: 12, color: AppThemeData.primary300),
                        ),
                      spaceW(width: 6),
                      Expanded(
                        child: Text(
                          method.pName ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppThemeData.grey4
                                : AppThemeData.grey7,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (method) {
                controller.updateItemPaymentMethod(index, method);
              },
            ),
          ),
        ));
  }

  Widget _buildAddItemButton(bool isDark) {
    return GestureDetector(
      onTap: () => controller.addItem(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppThemeData.primary50.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppThemeData.primary50.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded,
                size: 20, color: AppThemeData.primary50),
            spaceW(width: 8),
            TextCustom(
              title: 'Add Item',
              fontSize: 14,
              fontFamily: FontFamily.semiBold,
              color: AppThemeData.primary50,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(bool isDark) {
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
          TextFieldWidget(
            title: 'Notes (Optional)',
            hintText: 'Add any additional notes...',
            controller: controller.notesController,
            onPress: () {},
            line: 2,
            prefix: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.notes_rounded, color: AppThemeData.primary50, size: 18),
            ),
          ),
          spaceH(height: 16),
          TextFieldWidget(
            title: 'Payment Info',
            hintText: 'UPI: your@upi / Acct: 1234...',
            controller: controller.paymentInfoController,
            onPress: () {},
            prefix: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.account_balance_rounded, color: AppThemeData.primary50, size: 18),
            ),
          ),
          spaceH(height: 16),
          TextFieldWidget(
            title: 'Your Name',
            hintText: 'Enter your name',
            controller: controller.myNameController,
            onPress: () {},
            prefix: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.badge_outlined, color: AppThemeData.primary50, size: 18),
            ),
          ),
          spaceH(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppThemeData.primary300.withValues(alpha: 0.1),
                  AppThemeData.primary50.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppThemeData.primary300.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextCustom(
                  title: 'Grand Total',
                  fontSize: 16,
                  fontFamily: FontFamily.bold,
                  color: isDark ? AppThemeData.primaryWhite : AppThemeData.grey10,
                ),
                ValueListenableBuilder<double>(
                  valueListenable: controller.liveGrandTotal,
                  builder: (context, total, _) {
                    return TextCustom(
                      title: '₹${total.toStringAsFixed(2)}',
                      fontSize: 22,
                      fontFamily: FontFamily.bold,
                      color: AppThemeData.primary300,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return Obx(() => GestureDetector(
          onTap: controller.isSaving.value ? null : () => controller.saveBill(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: controller.isSaving.value
                  ? null
                  : AppThemeData.neonPurpleBlueGradient,
              color: controller.isSaving.value ? AppThemeData.grey8 : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: controller.isSaving.value
                  ? []
                  : AppThemeData.neonGlow(AppThemeData.primary50, opacity: 0.3),
            ),
            child: Center(
              child: controller.isSaving.value
                  ? const MahekLoader(size: 22, showBranding: false)
                  : TextCustom(
                      title: controller.isEditMode.value ? 'Update Bill' : 'Save Bill',
                      fontSize: 16,
                      fontFamily: FontFamily.bold,
                      color: Colors.white,
                    ),
            ),
          ),
        ));
  }
}
