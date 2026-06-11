

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/dues_tracker_model.dart';
import 'package:maheksync/app/models/payment_method_model.dart';
import 'package:maheksync/app/firestore_utills/dues_tracker_firestore_utils.dart';
import 'package:maheksync/app/firestore_utills/payment_method_firestore_utils.dart';
import 'package:maheksync/app/constant/show_toast.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';

class DuesTrackerController extends GetxController {
  final dues = <DuesTrackerModel>[].obs;
  final filteredDues = <DuesTrackerModel>[].obs;
  final isLoading = true.obs;
  final isActionLoading = false.obs;

  final searchQuery = ''.obs;
  final isGridView = true.obs;
  final selectedDueType = 'ALL'.obs;
  final selectedStatus = 'ALL'.obs;
  final selectedPaymentMethod = Rxn<PaymentMethodModel>();

  // Explicit filter state tracking variable to fix UI update issues
  final activeFilter = 'ALL'.obs;

  final sortField = 'createdAt'.obs;
  final sortAscending = false.obs;
  final dueTypeOptions = ['ALL', DueType.owe, DueType.take];
  final statusOptions = [
    'ALL',
    DueStatus.pending,
    DueStatus.partial,
    DueStatus.settled
  ];

  final paymentMethods = <PaymentMethodModel>[].obs;
  final customerNameController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final searchController = TextEditingController();
  final selectedDueTypeForm = DueType.owe.obs;

  // ── NEW: replaces selectedPaymentMethodForm + selectedPaymentMethodIconForm ──
  // Holds the full PaymentMethodModel selected in the Add/Edit form.
  // From this we derive paymentMethodId, paymentMethod (name), and
  // paymentMethodIcon when saving.
  final selectedPaymentMethodObj = Rxn<PaymentMethodModel>();

  final selectedGiveDate = Rxn<DateTime>();
  final selectedOweDate = Rxn<DateTime>();
  final selectedStatusForm = DueStatus.pending.obs;
  final editingDue = Rxn<DuesTrackerModel>();
  final isSaving = false.obs;

  Timer? _searchDebounce;
  static const _searchDebounceMs = 300;

  String? get ownerId => MahekConstant.ownerModel?.id;

  // Cached summary fields to improve dashboard performance
  final totalOweAmount = 0.0.obs;
  final totalTakeAmount = 0.0.obs;
  final netBalance = 0.0.obs;
  final oweCount = 0.obs;
  final takeCount = 0.obs;
  final overdueCount = 0.obs;
  final pendingCount = 0.obs;
  final settledCount = 0.obs;
  final totalActiveCount = 0.obs;

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
          activeFilter.value != 'ALL' ||
          selectedPaymentMethod.value != null;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    loadPaymentMethods();
    loadDues();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    customerNameController.dispose();
    amountController.dispose();
    noteController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: _searchDebounceMs),
          () {
        searchQuery.value = searchController.text;
        _applyFilters();
      },
    );
  }

  void loadPaymentMethods() {
    PaymentMethodFirestoreUtils.getPaymentMethods().listen((methods) {
      paymentMethods.value = methods;
    });
  }

  void loadDues() {
    if (ownerId == null) {
      isLoading.value = false;
      return;
    }
    DuesTrackerFirestoreUtils.getUserDues(ownerId!).listen((dueList) {
      for (var due in dueList) {
        // ── FIX: Match by paymentMethodId instead of pName ──
        final matchedMethod = paymentMethods.firstWhereOrNull(
              (m) => m.id == due.paymentMethodId,
        );
        if (matchedMethod != null) {
          // Always sync display fields from the master payment method record
          due.paymentMethod = matchedMethod.pName;
          due.paymentMethodIcon = matchedMethod.pIcon;
        }
      }
      dues.value = dueList;
      _recomputeSummary();
      _applyFilters();
      isLoading.value = false;
    }, onError: (error) {
      isLoading.value = false;
    });
  }

  // Pre-computes dashboard figures exactly once when the stream refreshes
  void _recomputeSummary() {
    double tempOwe = 0.0;
    double tempTake = 0.0;
    int tempOweCount = 0;
    int tempTakeCount = 0;
    int tempOverdueCount = 0;
    int tempPendingCount = 0;
    int tempSettledCount = 0;
    int tempActiveCount = 0;

    for (var d in dues) {
      final isOweType = DueType.isOwe(d.dueType);
      final isTakeType = DueType.isTake(d.dueType);
      final isSettledState = DueStatus.isSettled(d.status);
      final isPendingState = DueStatus.isPending(d.status);

      if (isOweType && !isSettledState) {
        tempOwe += (d.amount ?? 0.0);
        tempOweCount++;
      }
      if (isTakeType && !isSettledState) {
        tempTake += (d.amount ?? 0.0);
        tempTakeCount++;
      }
      if (d.isOverdue) {
        tempOverdueCount++;
      }
      if (isPendingState) {
        tempPendingCount++;
      }
      if (isSettledState) {
        tempSettledCount++;
      }
      if (!isSettledState) {
        tempActiveCount++;
      }
    }

    totalOweAmount.value = tempOwe;
    totalTakeAmount.value = tempTake;
    netBalance.value = tempTake - tempOwe;
    oweCount.value = tempOweCount;
    takeCount.value = tempTakeCount;
    overdueCount.value = tempOverdueCount;
    pendingCount.value = tempPendingCount;
    settledCount.value = tempSettledCount;
    totalActiveCount.value = tempActiveCount;
  }

  void _applyFilters() {
    var result = dues.toList();

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((d) {
        return (d.customerName ?? '').toLowerCase().contains(query) ||
            (d.note ?? '').toLowerCase().contains(query) ||
            (d.paymentMethod ?? '').toLowerCase().contains(query);
      }).toList();
    }

    // Comprehensive functional updates filtering logic
    switch (activeFilter.value) {
      case 'OWE':
        result = result.where((d) => d.dueType == DueType.owe).toList();
        break;
      case 'TAKE':
        result = result.where((d) => d.dueType == DueType.take).toList();
        break;
      case 'PENDING':
        result = result.where((d) => d.status == DueStatus.pending).toList();
        break;
      case 'SETTLED':
        result = result.where((d) => d.status == DueStatus.settled).toList();
        break;
      case 'OVERDUE':
        result = result.where((d) => d.isOverdue).toList();
        break;
      case 'ALL':
      default:
        break;
    }

    // ── FIX: Filter by paymentMethodId, not pName ──
    if (selectedPaymentMethod.value != null) {
      result = result.where(
            (d) => d.paymentMethodId == selectedPaymentMethod.value!.id,
      ).toList();
    }

    result = _applySorting(result);
    filteredDues.value = result;
  }

  List<DuesTrackerModel> _applySorting(List<DuesTrackerModel> items) {
    final sorted = items.toList();
    final ascending = sortAscending.value;
    switch (sortField.value) {
      case 'amount':
        sorted.sort((a, b) =>
        ascending
            ? (a.amount ?? 0).compareTo(b.amount ?? 0)
            : (b.amount ?? 0).compareTo(a.amount ?? 0));
        break;
      case 'customerName':
        sorted.sort((a, b) =>
        ascending
            ? (a.customerName ?? '').compareTo(b.customerName ?? '')
            : (b.customerName ?? '').compareTo(a.customerName ?? ''));
        break;
      case 'oweDate':
        sorted.sort((a, b) {
          final aDate = a.oweDate ?? DateTime(2000);
          final bDate = b.oweDate ?? DateTime(2000);
          return ascending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
        });
        break;
      case 'createdAt':
      default:
        sorted.sort((a, b) {
          final aTime = a.createdAt?.toDate() ?? DateTime(2000);
          final bTime = b.createdAt?.toDate() ?? DateTime(2000);
          return ascending ? aTime.compareTo(bTime) : bTime.compareTo(aTime);
        });
        break;
    }
    return sorted;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void filterByDueType(String type) {
    if (type == DueType.owe) {
      activeFilter.value = 'OWE';
    } else if (type == DueType.take) {
      activeFilter.value = 'TAKE';
    } else {
      activeFilter.value = 'ALL';
    }
    _applyFilters();
  }

  void filterByPaymentMethod(PaymentMethodModel? method) {
    selectedPaymentMethod.value = method;
    _applyFilters();
  }

  void filterByStatus(String status) {
    if (status == DueStatus.pending) {
      activeFilter.value = 'PENDING';
    } else if (status == DueStatus.settled) {
      activeFilter.value = 'SETTLED';
    } else if (status == 'OVERDUE') {
      activeFilter.value = 'OVERDUE';
    } else {
      activeFilter.value = 'ALL';
    }
    _applyFilters();
  }

  void setSortField(String field) {
    if (sortField.value == field) {
      sortAscending.value = !sortAscending.value;
    } else {
      sortField.value = field;
      sortAscending.value = false;
    }
    _applyFilters();
  }

  void clearFilters() {
    searchQuery.value = '';
    searchController.clear();
    selectedDueType.value = 'ALL';
    selectedPaymentMethod.value = null;
    selectedStatus.value = 'ALL';
    activeFilter.value = 'ALL';
    _applyFilters();
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  ADD / EDIT FORM STATE
  // ═══════════════════════════════════════════════════════════════════════

  void startAdding() {
    editingDue.value = null;
    customerNameController.clear();
    amountController.clear();
    noteController.clear();
    selectedDueTypeForm.value = DueType.owe;
    selectedPaymentMethodObj.value = null; // ← was selectedPaymentMethodForm
    selectedGiveDate.value = null;
    selectedOweDate.value = null;
    selectedStatusForm.value = DueStatus.pending;
  }

  void startEditing(DuesTrackerModel due) {
    editingDue.value = due;
    customerNameController.text = due.customerName ?? '';
    amountController.text = due.amount?.toStringAsFixed(2) ?? '';
    noteController.text = due.note ?? '';
    selectedDueTypeForm.value = due.dueType ?? DueType.owe;
    selectedGiveDate.value = due.giveDate;
    selectedOweDate.value = due.oweDate;
    selectedStatusForm.value = due.status ?? DueStatus.pending;

    // ── FIX: Resolve paymentMethodId → PaymentMethodModel ──
    if (due.paymentMethodId != null) {
      selectedPaymentMethodObj.value = paymentMethods.firstWhereOrNull(
            (m) => m.id == due.paymentMethodId,
      );
    } else {
      // Fallback: try matching by name for legacy data without paymentMethodId
      selectedPaymentMethodObj.value = paymentMethods.firstWhereOrNull(
            (m) => m.pName == due.paymentMethod,
      );
    }
  }

  void cancelEditing() {
    editingDue.value = null;
    customerNameController.clear();
    amountController.clear();
    noteController.clear();
    selectedDueTypeForm.value = DueType.owe;
    selectedPaymentMethodObj.value = null;
    selectedGiveDate.value = null;
    selectedOweDate.value = null;
    selectedStatusForm.value = DueStatus.pending;
  }

  // ── NEW: Takes the full PaymentMethodModel object ──
  void onPaymentMethodSelected(PaymentMethodModel? method) {
    selectedPaymentMethodObj.value = method;
  }

  // ── Helper: get the selected payment method ID ──
  String? get selectedPaymentMethodId => selectedPaymentMethodObj.value?.id;

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
    if (selectedPaymentMethodObj.value == null) {
      ShowToastDialog.showError('Please select a payment method');
      return;
    }

    isSaving.value = true;
    try {
      final pm = selectedPaymentMethodObj.value!;
      final due = DuesTrackerModel(
        id: editingDue.value?.id ?? MahekConstant.getUuid(),
        ownerId: ownerId,
        customerName: customerNameController.text.trim(),
        dueType: selectedDueTypeForm.value,
        amount: amount,
        paymentMethod: pm.pName,           // denormalized display name
        paymentMethodIcon: pm.pIcon,        // denormalized display icon
        paymentMethodId: pm.id,             // ← KEY: the stable FK
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
        Get.back();
      } else {
        ShowToastDialog.showError('Failed to save due');
      }
    } catch (e) {
      ShowToastDialog.showError('Error: ${e.toString()}');
    }
    finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteDue(DuesTrackerModel due) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade400),
            spaceW(width: 10),
            const Text('Delete Due'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete the due for "${due.customerName}"? This action cannot be undone.',
        ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (due.id == null) return;

    isActionLoading.value = true;
    try {
      final success = await DuesTrackerFirestoreUtils.deleteDue(due.id!);
      if (success) {
        ShowToastDialog.showSuccess('Due deleted successfully!');
      } else {
        ShowToastDialog.showError('Failed to delete due');
      }
    } catch (e) {
      ShowToastDialog.showError('Error: ${e.toString()}');
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> markAsSettled(DuesTrackerModel due) async {
    final updatedDue = DuesTrackerModel(
      id: due.id,
      ownerId: due.ownerId,
      customerName: due.customerName,
      dueType: due.dueType,
      amount: due.amount,
      paymentMethod: due.paymentMethod,
      paymentMethodIcon: due.paymentMethodIcon,
      paymentMethodId: due.paymentMethodId, // ← include paymentMethodId
      giveDate: due.giveDate,
      oweDate: due.oweDate,
      note: due.note,
      status: DueStatus.settled,
      createdAt: due.createdAt,
    );

    final success = await DuesTrackerFirestoreUtils.updateDue(updatedDue);
    if (success) {
      ShowToastDialog.showSuccess('Marked as settled!');
    } else {
      ShowToastDialog.showError('Failed to update status');
    }
  }

  Future<void> pickGiveDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedGiveDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
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
    await Future.delayed(const Duration(milliseconds: 300));
    loadDues();
  }
}
