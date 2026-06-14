// lib/app/modules/generate_bill/views/generate_bill_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maheksync/app/modules/generate_bill/controllers/generate_bill_controller.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:provider/provider.dart';

class GenerateBillListView extends StatelessWidget {
  const GenerateBillListView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.isDarkTheme();
    final controller = Get.find<GenerateBillController>();

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark, controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.bills.isEmpty) {
                  return _buildEmptyState(isDark);
                }
                return _buildBillsList(context, isDark, controller);
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildGenerateButton(context, isDark, controller),
    );
  }

  Widget _buildHeader(
      BuildContext context, bool isDark, GenerateBillController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppThemeData.surfaceDark, AppThemeData.surfaceMid]
              : [AppThemeData.primary1, AppThemeData.primaryWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppThemeData.primary50.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              'assets/icons/ic_bill.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                AppThemeData.primary50,
                BlendMode.srcIn,
              ),
            ),
          ),
          spaceW(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  title: 'Generate Bills',
                  fontSize: 22,
                  fontFamily: FontFamily.bold,
                  color: isDark ? AppThemeData.primaryWhite : AppThemeData.grey10,
                ),
                spaceH(height: 2),
                TextCustom(
                  title: 'Manage and export your invoices',
                  fontSize: 13,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
              ],
            ),
          ),
          _buildStatsChip(isDark, controller),
        ],
      ),
    );
  }

  Widget _buildStatsChip(bool isDark, GenerateBillController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppThemeData.primary300.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppThemeData.primary300.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Obx(() {
        final total = controller.bills.fold<double>(
            0, (sum, b) => sum + (b.totalAmount ?? 0));
        return Text(
          '${controller.bills.length} bills • ₹${total.toStringAsFixed(0)}',
          style: TextStyle(
            color: AppThemeData.primary300,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppThemeData.primary50.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: AppThemeData.primary50.withValues(alpha: 0.5),
            ),
          ),
          spaceH(height: 20),
          TextCustom(
            title: 'No bills yet',
            fontSize: 18,
            fontFamily: FontFamily.semiBold,
            color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
          ),
          spaceH(height: 8),
          TextCustom(
            title: 'Generate your first bill to get started',
            fontSize: 14,
            fontFamily: FontFamily.regular,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
        ],
      ),
    );
  }

  Widget _buildBillsList(
      BuildContext context, bool isDark, GenerateBillController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.bills.length,
      itemBuilder: (context, index) {
        final bill = controller.bills[index];
        return _buildBillCard(context, isDark, controller, bill);
      },
    );
  }

  Widget _buildBillCard(BuildContext context, bool isDark,
      GenerateBillController controller, dynamic bill) {
    final formattedDate = bill.billDate != null
        ? DateFormat('dd/MM/yyyy').format(bill.billDate!)
        : 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.viewBillPreview(bill),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppThemeData.neonBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${bill.itemCount}',
                      style: TextStyle(
                        color: AppThemeData.neonBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                spaceW(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextCustom(
                        title: bill.toName ?? 'N/A',
                        fontSize: 15,
                        fontFamily: FontFamily.semiBold,
                        color: isDark
                            ? AppThemeData.primaryWhite
                            : AppThemeData.grey10,
                      ),
                      spaceH(height: 4),
                      Row(
                        children: [
                          Icon(Icons.receipt_outlined,
                              size: 12,
                              color: isDark
                                  ? AppThemeData.grey5
                                  : AppThemeData.grey6),
                          spaceW(width: 4),
                          TextCustom(
                            title: bill.formattedInvoiceNumber,
                            fontSize: 12,
                            fontFamily: FontFamily.regular,
                            color: isDark
                                ? AppThemeData.grey5
                                : AppThemeData.grey6,
                          ),
                          spaceW(width: 12),
                          Icon(Icons.calendar_today_outlined,
                              size: 12,
                              color: isDark
                                  ? AppThemeData.grey5
                                  : AppThemeData.grey6),
                          spaceW(width: 4),
                          TextCustom(
                            title: formattedDate,
                            fontSize: 12,
                            fontFamily: FontFamily.regular,
                            color: isDark
                                ? AppThemeData.grey5
                                : AppThemeData.grey6,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextCustom(
                      title: '₹${(bill.totalAmount ?? 0).toStringAsFixed(2)}',
                      fontSize: 16,
                      fontFamily: FontFamily.bold,
                      color: AppThemeData.primary300,
                    ),
                    spaceH(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionChip(
                          isDark,
                          Icons.edit_outlined,
                          () => controller.editBill(bill),
                          AppThemeData.neonBlue,
                        ),
                        spaceW(width: 8),
                        _buildActionChip(
                          isDark,
                          Icons.delete_outline,
                          () => controller.deleteBill(bill.id!),
                          AppThemeData.neonRed,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip(
      bool isDark, IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildGenerateButton(
      BuildContext context, bool isDark, GenerateBillController controller) {
    return GestureDetector(
      onTap: () async {
        controller.resetForm();
        final result = await Get.toNamed(Routes.GENERATE_BILL_CREATE);
        if (result == true) {
          controller.loadBills();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppThemeData.neonPurpleBlueGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppThemeData.neonGlow(AppThemeData.primary50, opacity: 0.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            spaceW(width: 8),
            const Text(
              'Generate Bill',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: FontFamily.semiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
