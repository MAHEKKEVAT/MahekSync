// lib/app/modules/dues_tracker/controllers/dues_tracker_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/dues_tracker_model.dart';
import 'package:maheksync/app/models/payment_method_model.dart';
import 'package:maheksync/app/utils/dues_tracker_firestore_utils.dart';
import 'package:maheksync/app/utils/payment_method_firestore_utils.dart';
import 'package:maheksync/app/constant/show_toast.dart';

class DuesTrackerController extends GetxController {
  final dues = <DuesTrackerModel>[].obs;
  final filteredDues = <DuesTrackerModel>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final isGridView = true.obs;

  // Payment methods for dropdown
  final paymentMethods = <PaymentMethodModel>[].obs;

  // Filters
  final selectedDueType = 'ALL'.obs;
  final selectedPaymentMethod = Rxn<PaymentMethodModel>();
  final selectedStatus = 'ALL'.obs;

  final dueTypeOptions = ['ALL', 'owe', 'take'];
  final statusOptions = ['ALL', 'PENDING', 'PARTIAL', 'SETTLED'];

  // Form controllers
  final customerNameController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final selectedDueTypeForm = 'owe'.obs;
  final selectedPaymentMethodForm = Rxn<String>();
  final selectedPaymentMethodIconForm = Rxn<String>();
  final selectedGiveDate = Rxn<DateTime>();
  final selectedOweDate = Rxn<DateTime>();
  final selectedStatusForm = 'PENDING'.obs;
  final editingDue = Rxn<DuesTrackerModel>();
  final isSaving = false.obs;

  String? get ownerId => MahekConstant.ownerModel?.id;

  // Computed stats
  double get totalOweAmount => filteredDues
      .where((d) => d.dueType == 'owe' && d.status != 'SETTLED')
      .fold(0.0, (sum, d) => sum + (d.amount ?? 0.0));

  double get totalTakeAmount => filteredDues
      .where((d) => d.dueType == 'take' && d.status != 'SETTLED')
      .fold(0.0, (sum, d) => sum + (d.amount ?? 0.0));

  double get netBalance => totalTakeAmount - totalOweAmount;

  int get pendingCount => filteredDues.where((d) => d.status == 'PENDING').length;
  int get settledCount => filteredDues.where((d) => d.status == 'SETTLED').length;

  @override
  void onInit() {
    super.onInit();
    loadPaymentMethods();
    loadDues();
  }

  @override
  void onClose() {
    customerNameController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }

  void loadPaymentMethods() {
    PaymentMethodFirestoreUtils.getPaymentMethods().listen((methods) {
      paymentMethods.value = methods;
    });
  }

  void loadDues() {
    if (ownerId == null) return;
    DuesTrackerFirestoreUtils.getUserDues(ownerId!).listen((dueList) {
      // Enrich dues with payment method icons from the loaded payment methods list
      for (var due in dueList) {
        final matchedMethod = paymentMethods.firstWhereOrNull(
              (m) => m.pName == due.paymentMethod,
        );
        if (matchedMethod != null && matchedMethod.pIcon != null) {
          due.paymentMethodIcon = matchedMethod.pIcon;
        }
      }
      dues.value = dueList;
      _applyFilters();
      isLoading.value = false;
    });
  }

  void _applyFilters() {
    var result = dues.toList();

    if (searchQuery.isNotEmpty) {
      result = result.where((d) {
        return (d.customerName ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            (d.note ?? '').toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    if (selectedDueType.value != 'ALL') {
      result = result.where((d) => d.dueType == selectedDueType.value).toList();
    }

    if (selectedPaymentMethod.value != null) {
      result = result.where((d) => d.paymentMethod == selectedPaymentMethod.value!.pName).toList();
    }

    if (selectedStatus.value != 'ALL') {
      result = result.where((d) => d.status == selectedStatus.value).toList();
    }

    filteredDues.value = result;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void filterByDueType(String type) {
    selectedDueType.value = type;
    _applyFilters();
  }

  void filterByPaymentMethod(PaymentMethodModel? method) {
    selectedPaymentMethod.value = method;
    _applyFilters();
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedDueType.value = 'ALL';
    selectedPaymentMethod.value = null;
    selectedStatus.value = 'ALL';
    _applyFilters();
  }

  // ── Form Methods ──

  void startAdding() {
    editingDue.value = null;
    customerNameController.clear();
    amountController.clear();
    noteController.clear();
    selectedDueTypeForm.value = 'owe';
    selectedPaymentMethodForm.value = null;
    selectedPaymentMethodIconForm.value = null;
    selectedGiveDate.value = null;
    selectedOweDate.value = null;
    selectedStatusForm.value = 'PENDING';
  }

  void startEditing(DuesTrackerModel due) {
    editingDue.value = due;
    customerNameController.text = due.customerName ?? '';
    amountController.text = due.amount?.toStringAsFixed(2) ?? '';
    noteController.text = due.note ?? '';
    selectedDueTypeForm.value = due.dueType ?? 'owe';
    selectedPaymentMethodForm.value = due.paymentMethod;
    selectedPaymentMethodIconForm.value = due.paymentMethodIcon;
    selectedGiveDate.value = due.giveDate;
    selectedOweDate.value = due.oweDate;
    selectedStatusForm.value = due.status ?? 'PENDING';
  }

  void cancelEditing() {
    editingDue.value = null;
    customerNameController.clear();
    amountController.clear();
    noteController.clear();
    selectedDueTypeForm.value = 'owe';
    selectedPaymentMethodForm.value = null;
    selectedPaymentMethodIconForm.value = null;
    selectedGiveDate.value = null;
    selectedOweDate.value = null;
    selectedStatusForm.value = 'PENDING';
  }

  void onPaymentMethodSelected(String? methodName) {
    selectedPaymentMethodForm.value = methodName;
    if (methodName != null) {
      final method = paymentMethods.firstWhereOrNull((m) => m.pName == methodName);
      selectedPaymentMethodIconForm.value = method?.pIcon;
    } else {
      selectedPaymentMethodIconForm.value = null;
    }
  }

  Future<void> saveDue() async {
    if (customerNameController.text.trim().isEmpty) {
      ShowToastDialog.showError('Customer name is required');
      return;
    }

    if (amountController.text.trim().isEmpty) {
      ShowToastDialog.showError('Amount is required');
      return;
    }

    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      ShowToastDialog.showError('Please enter a valid amount');
      return;
    }

    if (selectedPaymentMethodForm.value == null || selectedPaymentMethodForm.value!.isEmpty) {
      ShowToastDialog.showError('Please select a payment method');
      return;
    }

    isSaving.value = true;

    try {
      final due = DuesTrackerModel(
        id: editingDue.value?.id ?? MahekConstant.getUuid(),
        ownerId: ownerId,
        customerName: customerNameController.text.trim(),
        dueType: selectedDueTypeForm.value,
        amount: amount,
        paymentMethod: selectedPaymentMethodForm.value,
        paymentMethodIcon: selectedPaymentMethodIconForm.value,
        giveDate: selectedGiveDate.value,
        oweDate: selectedOweDate.value,
        note: noteController.text.trim(),
        status: selectedStatusForm.value,
        createdAt: editingDue.value?.createdAt,
      );

      bool success;
      if (editingDue.value == null) {
        success = await DuesTrackerFirestoreUtils.addDue(due);
      } else {
        success = await DuesTrackerFirestoreUtils.updateDue(due);
      }

      if (success) {
        ShowToastDialog.showSuccess(
          editingDue.value == null
              ? 'Due added successfully!'
              : 'Due updated successfully!',
        );
        cancelEditing();
      } else {
        ShowToastDialog.showError('Failed to save due');
      }
    } catch (e) {
      ShowToastDialog.showError('Error: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteDue(DuesTrackerModel due) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Due'),
        content: Text('Are you sure you want to delete "${due.customerName}" due?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (due.id == null) return;

    final success = await DuesTrackerFirestoreUtils.deleteDue(due.id!);
    if (success) {
      ShowToastDialog.showSuccess('Due deleted successfully!');
    } else {
      ShowToastDialog.showError('Failed to delete due');
    }
  }

  Future<void> pickGiveDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedGiveDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      selectedGiveDate.value = date;
    }
  }

  Future<void> pickOweDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedOweDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      selectedOweDate.value = date;
    }
  }

  void toggleView() {
    isGridView.value = !isGridView.value;
  }

  Future<void> refreshDues() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    loadDues();
  }
}
