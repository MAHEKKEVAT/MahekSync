// lib/app/modules/dues_tracker/views/dues_tracker_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maheksync/app/models/payment_method_model.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/mahek_responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_field_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:provider/provider.dart';
import '../controllers/dues_tracker_controller.dart';
import 'package:maheksync/app/models/dues_tracker_model.dart';

class DuesTrackerView extends GetView<DuesTrackerController> {
  const DuesTrackerView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DarkThemeProvider>(context);
    final isDark = theme.isDarkTheme();

    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: AppThemeData.primary50),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MahekResponsive.isMobile(context) ? 4 : 12,
          vertical: 4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isDark),
            spaceH(height: 18),
            _buildStatsRow(context, isDark),
            spaceH(height: 18),
            Expanded(
              child: controller.isGridView.value
                  ? _buildGridView(context, isDark)
                  : _buildListView(context, isDark),
            ),
          ],
        ),
      );
    });
  }

  // ═══════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════
  Widget _buildHeader(BuildContext context, bool isDark) {
    final isMobile = MahekResponsive.isMobile(context);

    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        // Search field
        SizedBox(
          width: isMobile ? double.infinity : 260,
          child: TextFieldWidget(
            title: '',
            hintText: 'Search by name or note...',
            controller: TextEditingController(text: controller.searchQuery.value),
            onPress: () {},
            prefix: Icon(Icons.search, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7, size: 20),
            enabled: true,
            validator: (_) => null,
          ),
        ),
        // Due Type Filter
        Obx(() => _buildFilterChip(
          isDark,
          label: controller.selectedDueType.value == 'ALL'
              ? 'All Types'
              : controller.selectedDueType.value.toUpperCase(),
          onTap: () => _showDueTypeFilter(context, isDark),
        )),
        // Status Filter
        Obx(() => _buildFilterChip(
          isDark,
          label: controller.selectedStatus.value == 'ALL'
              ? 'All Status'
              : controller.selectedStatus.value,
          onTap: () => _showStatusFilter(context, isDark),
        )),
        // Toggle Grid/List
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3),
          ),
          child: Obx(() => IconButton(
            onPressed: controller.toggleView,
            icon: Icon(
              controller.isGridView.value ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: AppThemeData.primary50,
              size: 22,
            ),
          )),
        ),
        // Add button
        ElevatedButton.icon(
          onPressed: () => _showAddEditDialog(context, isDark),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: TextCustom(
            title: 'Add Due',
            fontSize: 14,
            fontFamily: FontFamily.medium,
            color: AppThemeData.primaryWhite,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppThemeData.primary50,
            foregroundColor: AppThemeData.primaryWhite,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(bool isDark, {required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextCustom(
              title: label,
              fontSize: 13,
              fontFamily: FontFamily.medium,
              color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            ),
            spaceW(width: 4),
            Icon(Icons.arrow_drop_down, size: 18, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // STATS ROW
  // ═══════════════════════════════════════
  Widget _buildStatsRow(BuildContext context, bool isDark) {
    return Row(
      children: [
        _buildStatCard(
          isDark,
          title: 'I Owe',
          amount: controller.totalOweAmount,
          icon: Icons.arrow_upward_rounded,
          color: AppThemeData.danger300,
        ),
        spaceW(width: 12),
        _buildStatCard(
          isDark,
          title: 'They Owe Me',
          amount: controller.totalTakeAmount,
          icon: Icons.arrow_downward_rounded,
          color: AppThemeData.success300,
        ),
        spaceW(width: 12),
        _buildStatCard(
          isDark,
          title: 'Net Balance',
          amount: controller.netBalance.abs(),
          icon: controller.netBalance >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          color: controller.netBalance >= 0 ? AppThemeData.success300 : AppThemeData.danger300,
          isNet: true,
        ),
      ],
    );
  }

  Widget _buildStatCard(bool isDark, {
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    bool isNet = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            spaceW(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(
                    title: title,
                    fontSize: 11,
                    fontFamily: FontFamily.medium,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  ),
                  spaceH(height: 2),
                  TextCustom(
                    title: (isNet && controller.netBalance < 0 ? '-' : '') + '\u20B9${amount.toStringAsFixed(2)}',
                    fontSize: 18,
                    fontFamily: FontFamily.bold,
                    color: color,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // GRID VIEW — Fixed with proper aspect ratio
  // ═══════════════════════════════════════
  Widget _buildGridView(BuildContext context, bool isDark) {
    return Obx(() {
      if (controller.filteredDues.isEmpty) {
        return _buildEmptyState(isDark);
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          // Calculate proper cross axis count based on available width
          int crossAxisCount;
          if (screenWidth >= 1200) {
            crossAxisCount = 4;
          } else if (screenWidth >= 900) {
            crossAxisCount = 3;
          } else if (screenWidth >= 600) {
            crossAxisCount = 2;
          } else {
            crossAxisCount = 1;
          }

          final cardWidth = (screenWidth - (crossAxisCount - 1) * 14) / crossAxisCount;
          // Fixed height for cards — not using aspect ratio to avoid cramping
          final cardHeight = 220.0;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: cardWidth / cardHeight,
            ),
            itemCount: controller.filteredDues.length,
            padding: const EdgeInsets.only(bottom: 20),
            itemBuilder: (context, index) {
              final due = controller.filteredDues[index];
              return _buildDueCard(due, isDark);
            },
          );
        },
      );
    });
  }

  // ═══════════════════════════════════════
  // LIST VIEW
  // ═══════════════════════════════════════
  Widget _buildListView(BuildContext context, bool isDark) {
    return Obx(() {
      if (controller.filteredDues.isEmpty) {
        return _buildEmptyState(isDark);
      }

      return ListView.separated(
        itemCount: controller.filteredDues.length,
        padding: const EdgeInsets.only(bottom: 20),
        separatorBuilder: (_, __) => spaceH(height: 10),
        itemBuilder: (context, index) {
          final due = controller.filteredDues[index];
          return _buildDueListTile(due, isDark);
        },
      );
    });
  }

  // ═══════════════════════════════════════
  // DUE CARD (Grid) — Redesigned with proper padding & payment icon
  // ═══════════════════════════════════════
  Widget _buildDueCard(DuesTrackerModel due, bool isDark) {
    final isOwe = due.dueType == 'owe';
    final typeColor = due.dueTypeColor;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppThemeData.grey8.withValues(alpha: 0.3) : AppThemeData.grey3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row: Type badge + Status + Menu
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextCustom(
                  title: isOwe ? 'I OWE' : 'TAKE',
                  fontSize: 10,
                  fontFamily: FontFamily.bold,
                  color: typeColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: due.statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextCustom(
                  title: due.status ?? 'PENDING',
                  fontSize: 9,
                  fontFamily: FontFamily.bold,
                  color: due.statusColor,
                ),
              ),
              spaceW(width: 2),
              _buildPopupMenu(due, isDark),
            ],
          ),
          spaceH(height: 14),

          // Customer Name
          TextCustom(
            title: due.customerName ?? 'Unknown',
            fontSize: 16,
            fontFamily: FontFamily.bold,
            color: isDark ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
            maxLine: 1,
          ),
          spaceH(height: 6),

          // Amount
          TextCustom(
            title: due.formattedAmount,
            fontSize: 22,
            fontFamily: FontFamily.bold,
            color: typeColor,
          ),
          spaceH(height: 12),

          // Payment Method with icon from DB
          Row(
            children: [
              _buildPaymentMethodIcon(due, isDark, size: 18),
              spaceW(width: 6),
              Expanded(
                child: TextCustom(
                  title: due.paymentMethod ?? 'N/A',
                  fontSize: 12,
                  fontFamily: FontFamily.medium,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  maxLine: 1,
                ),
              ),
            ],
          ),
          spaceH(height: 6),

          // Dates row
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 13, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
              spaceW(width: 4),
              TextCustom(
                title: 'Give: ${due.formattedGiveDate}',
                fontSize: 11,
                fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
              ),
              spaceW(width: 10),
              Icon(Icons.event_rounded, size: 13, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
              spaceW(width: 4),
              TextCustom(
                title: 'Due: ${due.formattedOweDate}',
                fontSize: 11,
                fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // DUE LIST TILE — Redesigned with payment method icon
  // ═══════════════════════════════════════
  Widget _buildDueListTile(DuesTrackerModel due, bool isDark) {
    final isOwe = due.dueType == 'owe';
    final typeColor = due.dueTypeColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppThemeData.grey8.withValues(alpha: 0.3) : AppThemeData.grey3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.06 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Payment method icon from DB
          _buildPaymentMethodIcon(due, isDark, size: 40),
          spaceW(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Type badge
                Row(
                  children: [
                    Expanded(
                      child: TextCustom(
                        title: due.customerName ?? 'Unknown',
                        fontSize: 15,
                        fontFamily: FontFamily.semiBold,
                        color: isDark ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
                        maxLine: 1,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextCustom(
                        title: isOwe ? 'I OWE' : 'TAKE',
                        fontSize: 9,
                        fontFamily: FontFamily.bold,
                        color: typeColor,
                      ),
                    ),
                  ],
                ),
                spaceH(height: 4),
                // Payment method + dates
                Row(
                  children: [
                    TextCustom(
                      title: due.paymentMethod ?? 'N/A',
                      fontSize: 12,
                      fontFamily: FontFamily.medium,
                      color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                    ),
                    TextCustom(
                      title: '  |  ',
                      fontSize: 12,
                      color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
                    ),
                    TextCustom(
                      title: 'Give: ${due.formattedGiveDate}',
                      fontSize: 12,
                      fontFamily: FontFamily.regular,
                      color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                    ),
                    TextCustom(
                      title: '  |  ',
                      fontSize: 12,
                      color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
                    ),
                    TextCustom(
                      title: 'Due: ${due.formattedOweDate}',
                      fontSize: 12,
                      fontFamily: FontFamily.regular,
                      color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                    ),
                  ],
                ),
                spaceH(height: 4),
                // Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: due.statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextCustom(
                    title: due.status ?? 'PENDING',
                    fontSize: 10,
                    fontFamily: FontFamily.bold,
                    color: due.statusColor,
                  ),
                ),
              ],
            ),
          ),
          spaceW(width: 14),
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextCustom(
                title: due.formattedAmount,
                fontSize: 18,
                fontFamily: FontFamily.bold,
                color: typeColor,
              ),
              _buildPopupMenu(due, isDark),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // PAYMENT METHOD ICON — From DB (pIcon)
  // ═══════════════════════════════════════
  Widget _buildPaymentMethodIcon(DuesTrackerModel due, bool isDark, {double size = 20}) {
    final hasIcon = due.paymentMethodIcon != null && due.paymentMethodIcon!.isNotEmpty;

    if (hasIcon) {
      return Container(
        width: size + 8,
        height: size + 8,
        padding: EdgeInsets.all(size > 24 ? 6 : 3),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey8.withValues(alpha: 0.4) : AppThemeData.grey2,
          borderRadius: BorderRadius.circular(size > 24 ? 12 : 8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size > 24 ? 8 : 5),
          child: NetworkImageWidget(
            imageUrl: due.paymentMethodIcon!,
            height: size,
            width: size,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // Fallback icon when no image
    return Container(
      width: size + 8,
      height: size + 8,
      padding: EdgeInsets.all(size > 24 ? 6 : 3),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey8.withValues(alpha: 0.4) : AppThemeData.grey2,
        borderRadius: BorderRadius.circular(size > 24 ? 12 : 8),
      ),
      child: Icon(
        Icons.payment_rounded,
        size: size - 2,
        color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
      ),
    );
  }

  // ═══════════════════════════════════════
  // POPUP MENU
  // ═══════════════════════════════════════
  Widget _buildPopupMenu(DuesTrackerModel due, bool isDark) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, size: 20, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'edit') {
          _showAddEditDialog(Get.context!, isDark, due: due);
        } else if (value == 'delete') {
          controller.deleteDue(due);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
  }

  // ═══════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 56,
                color: AppThemeData.primary50.withValues(alpha: 0.6),
              ),
            ),
            spaceH(height: 20),
            TextCustom(
              title: 'No dues found',
              fontSize: 18,
              fontFamily: FontFamily.semiBold,
              color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            ),
            spaceH(height: 8),
            TextCustom(
              title: 'Tap "Add Due" to start tracking',
              fontSize: 14,
              fontFamily: FontFamily.regular,
              color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // ADD / EDIT DIALOG — With proper padding & payment icon in dropdown
  // ═══════════════════════════════════════
  void _showAddEditDialog(BuildContext context, bool isDark, {DuesTrackerModel? due}) {
    if (due != null) {
      controller.startEditing(due);
    } else {
      controller.startAdding();
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MahekResponsive.isMobile(context) ? MediaQuery.of(context).size.width * 0.92 : 540,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppThemeData.primary50.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        due != null ? Icons.edit_rounded : Icons.add_rounded,
                        color: AppThemeData.primary50,
                        size: 22,
                      ),
                    ),
                    spaceW(width: 14),
                    TextCustom(
                      title: due != null ? 'Edit Due' : 'Add Due',
                      fontSize: 20,
                      fontFamily: FontFamily.bold,
                      color: isDark ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        controller.cancelEditing();
                        Get.back();
                      },
                      icon: Icon(Icons.close_rounded, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
                    ),
                  ],
                ),
                spaceH(height: 24),

                // Customer Name
                TextFieldWidget(
                  title: 'Customer Name',
                  hintText: 'Enter customer name',
                  controller: controller.customerNameController,
                  onPress: () {},
                  enabled: true,
                  prefix: Icon(Icons.person_outline_rounded, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6, size: 20),
                ),
                spaceH(height: 18),

                // Due Type - Owe / Take Radio
                Obx(() => customRadioButton(
                  context,
                  parameter: controller.selectedDueTypeForm.value,
                  onChangeOne: () => controller.selectedDueTypeForm.value = 'owe',
                  onChangeTwo: () => controller.selectedDueTypeForm.value = 'take',
                  title: 'Due Type',
                  radioOne: 'owe',
                  radioTwo: 'take',
                )),
                spaceH(height: 18),

                // Amount
                TextFieldWidget(
                  title: 'Amount',
                  hintText: 'Enter amount',
                  controller: controller.amountController,
                  onPress: () {},
                  enabled: true,
                  textInputType: TextInputType.numberWithOptions(decimal: true),
                  prefix: TextCustom(
                    title: '\u20B9',
                    fontSize: 18,
                    fontFamily: FontFamily.bold,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  ),
                ),
                spaceH(height: 18),

                // Payment Method Dropdown with icon
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextCustom(
                      title: 'Payment Method',
                      fontSize: 14,
                      fontFamily: FontFamily.medium,
                      color: isDark ? AppThemeData.grey4 : AppThemeData.grey8,
                    ),
                    spaceH(height: 8),
                    Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedPaymentMethodForm.value,
                          hint: TextCustom(
                            title: 'Select payment method',
                            fontSize: 14,
                            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                          ),
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
                          items: controller.paymentMethods.map((PaymentMethodModel method) {
                            return DropdownMenuItem<String>(
                              value: method.pName,
                              child: Row(
                                children: [
                                  // Payment method icon from DB
                                  if (method.pIcon != null && method.pIcon!.isNotEmpty) ...[
                                    Container(
                                      width: 26,
                                      height: 26,
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: NetworkImageWidget(
                                          imageUrl: method.pIcon!,
                                          height: 22,
                                          width: 22,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    spaceW(width: 10),
                                  ] else ...[
                                    Icon(Icons.payment_rounded, size: 18, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                                    spaceW(width: 10),
                                  ],
                                  TextCustom(
                                    title: method.pName ?? '',
                                    fontSize: 14,
                                    color: isDark ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: controller.onPaymentMethodSelected,
                        ),
                      ),
                    )),
                  ],
                ),
                spaceH(height: 18),

                // Give Date
                Obx(() => _buildDatePickerField(
                  isDark,
                  label: 'Give Date',
                  date: controller.selectedGiveDate.value,
                  onTap: () => controller.pickGiveDate(context),
                )),
                spaceH(height: 18),

                // Owe Date
                Obx(() => _buildDatePickerField(
                  isDark,
                  label: 'Owe / Due Date',
                  date: controller.selectedOweDate.value,
                  onTap: () => controller.pickOweDate(context),
                )),
                spaceH(height: 18),

                // Status Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextCustom(
                      title: 'Status',
                      fontSize: 14,
                      fontFamily: FontFamily.medium,
                      color: isDark ? AppThemeData.grey4 : AppThemeData.grey8,
                    ),
                    spaceH(height: 8),
                    Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedStatusForm.value,
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
                          items: ['PENDING', 'PARTIAL', 'SETTLED'].map((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  spaceW(width: 10),
                                  TextCustom(
                                    title: status,
                                    fontSize: 14,
                                    color: isDark ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            controller.selectedStatusForm.value = value!;
                          },
                        ),
                      ),
                    )),
                  ],
                ),
                spaceH(height: 18),

                // Note
                TextFieldWidget(
                  title: 'Note',
                  hintText: 'Add a note (optional)',
                  controller: controller.noteController,
                  onPress: () {},
                  enabled: true,
                  line: 3,
                ),
                spaceH(height: 28),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          controller.cancelEditing();
                          Get.back();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          side: BorderSide(color: isDark ? AppThemeData.grey7 : AppThemeData.grey4),
                        ),
                        child: TextCustom(
                          title: 'Cancel',
                          fontSize: 15,
                          fontFamily: FontFamily.medium,
                          color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
                        ),
                      ),
                    ),
                    spaceW(width: 14),
                    Expanded(
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.isSaving.value ? null : controller.saveDue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemeData.primary50,
                          foregroundColor: AppThemeData.primaryWhite,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          elevation: 0,
                        ),
                        child: controller.isSaving.value
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppThemeData.primaryWhite),
                        )
                            : TextCustom(
                          title: due != null ? 'Update' : 'Save',
                          fontSize: 15,
                          fontFamily: FontFamily.semiBold,
                          color: AppThemeData.primaryWhite,
                        ),
                      )),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'SETTLED':
        return const Color(0xFF10B981);
      case 'PARTIAL':
        return const Color(0xFFF59E0B);
      case 'PENDING':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  // ═══════════════════════════════════════
  // DATE PICKER FIELD
  // ═══════════════════════════════════════
  Widget _buildDatePickerField(bool isDark, {
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: label,
          fontSize: 14,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey4 : AppThemeData.grey8,
        ),
        spaceH(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 18, color: AppThemeData.primary50),
                spaceW(width: 10),
                TextCustom(
                  title: date != null
                      ? DateFormat('MMM dd, yyyy').format(date)
                      : 'Select date',
                  fontSize: 14,
                  fontFamily: FontFamily.regular,
                  color: date != null
                      ? (isDark ? AppThemeData.primaryWhite : AppThemeData.primaryBlack)
                      : (isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // FILTER BOTTOM SHEETS
  // ═══════════════════════════════════════
  void _showDueTypeFilter(BuildContext context, bool isDark) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.grey7 : AppThemeData.grey3,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            spaceH(height: 18),
            TextCustom(
              title: 'Filter by Type',
              fontSize: 18,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
            ),
            spaceH(height: 16),
            ...controller.dueTypeOptions.map((type) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: TextCustom(
                title: type == 'ALL' ? 'All Types' : type.toUpperCase(),
                fontSize: 15,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
              ),
              trailing: controller.selectedDueType.value == type
                  ? Icon(Icons.check_rounded, color: AppThemeData.primary50)
                  : null,
              onTap: () {
                controller.filterByDueType(type);
                Get.back();
              },
            )),
            spaceH(height: 8),
          ],
        ),
      ),
    );
  }

  void _showStatusFilter(BuildContext context, bool isDark) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.grey7 : AppThemeData.grey3,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            spaceH(height: 18),
            TextCustom(
              title: 'Filter by Status',
              fontSize: 18,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
            ),
            spaceH(height: 16),
            ...controller.statusOptions.map((status) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: status == 'ALL' ? AppThemeData.primary50 : _getStatusColor(status),
                  shape: BoxShape.circle,
                ),
              ),
              title: TextCustom(
                title: status == 'ALL' ? 'All Status' : status,
                fontSize: 15,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.primaryWhite : AppThemeData.primaryBlack,
              ),
              trailing: controller.selectedStatus.value == status
                  ? Icon(Icons.check_rounded, color: AppThemeData.primary50)
                  : null,
              onTap: () {
                controller.filterByStatus(status);
                Get.back();
              },
            )),
            spaceH(height: 8),
          ],
        ),
      ),
    );
  }
}
