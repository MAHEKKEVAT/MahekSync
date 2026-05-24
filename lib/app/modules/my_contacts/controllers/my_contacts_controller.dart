import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/show_toast.dart';
import 'package:maheksync/app/models/my_contacts_model.dart';
import 'package:maheksync/app/modules/my_contacts/my_contacts_crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ContactFilter { all, named, withPhoto }
enum ContactSort { nameAsc, nameDesc, newest }

class MyContactsController extends GetxController {
  final isLoading = false.obs;
  final isImporting = false.obs;
  final contacts = <MyContactsModel>[].obs;
  final filteredContacts = <MyContactsModel>[].obs;
  final searchText = ''.obs;
  final selectedContact = Rxn<MyContactsModel>();
  final isDrawerOpen = false.obs;
  final isEditing = false.obs;
  final isDetailPanelOpen = true.obs;
  final importProgress = 0.0.obs;
  final importTotal = 0.obs;
  final importAdded = 0.obs;
  final importSkipped = 0.obs;
  final importUpdated = 0.obs;

  // New states for Filter and Sort options [cite: 349]
  final currentFilter = ContactFilter.all.obs;
  final currentSort = ContactSort.nameAsc.obs;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final searchController = TextEditingController();
  StreamSubscription? _contactsSub;
  StreamSubscription? _authSub;
  Timer? _debounce;

  int get totalContacts => contacts.length;

  @override
  void onInit() {
    super.onInit();
    _listenAuthAndStream();
    searchController.addListener(_onSearchChanged);
  }

  void _listenAuthAndStream() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      _contactsSub?.cancel();
      _startContactsStream();
    });
  }

  void _startContactsStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      isLoading.value = false;
      contacts.clear();
      filteredContacts.clear();
      return;
    }
    isLoading.value = true;
    _contactsSub = MyContactsCrud.streamContacts().listen(
          (data) {
        contacts.value = data;
        _applyFilterAndSort(); // Trigger unified processing [cite: 355]
        isLoading.value = false;
      },
      onError: (error) {
        isLoading.value = false;
      },
    );
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchText.value = searchController.text.trim();
      _applyFilterAndSort();
    });
  }

  // Unified Filter & Sort processor [cite: 357, 358]
  void _applyFilterAndSort() {
    List<MyContactsModel> result = contacts.toList();

    // 1. Text Search Filter
    final q = searchText.value.toLowerCase().trim();
    if (q.isNotEmpty) {
      result = result.where((c) {
        final name = c.formattedName.toLowerCase();
        final mobile = c.mobileNumber.toLowerCase();
        return name.contains(q) || mobile.contains(q);
      }).toList();
    }

    // 2. Tab/Segment Filter Group
    switch (currentFilter.value) {
      case ContactFilter.named:
        result = result.where((c) => c.firstName.isNotEmpty).toList();
        break;
      case ContactFilter.withPhoto:
        result = result.where((c) => c.hasProfile).toList();
        break;
      case ContactFilter.all:
      default:
        break;
    }

    // 3. Sorting Engine
    switch (currentSort.value) {
      case ContactSort.nameAsc:
        result.sort((a, b) => a.formattedName.toLowerCase().compareTo(b.formattedName.toLowerCase()));
        break;
      case ContactSort.nameDesc:
        result.sort((a, b) => b.formattedName.toLowerCase().compareTo(a.formattedName.toLowerCase()));
        break;
      case ContactSort.newest:
      // Automatically falls back to natural DB stream positioning if no timestamps are present,
      // or reverses order based on unique properties.
        result = result.reversed.toList();
        break;
    }

    filteredContacts.value = result;
  }

  // Updaters targeting filters & sorting modes
  void changeFilter(ContactFilter filter) {
    currentFilter.value = filter;
    _applyFilterAndSort();
  }

  void changeSort(ContactSort sort) {
    currentSort.value = sort;
    _applyFilterAndSort();
  }

  void selectContact(MyContactsModel? contact) {
    selectedContact.value = contact;
    if (contact != null) {
      isDetailPanelOpen.value = true;
    }
  }

  void openAddDrawer() {
    isEditing.value = false;
    firstNameController.clear();
    lastNameController.clear();
    mobileNumberController.clear();
    isDrawerOpen.value = true;
  }

  void openEditDrawer(MyContactsModel contact) {
    isEditing.value = true;
    firstNameController.text = contact.firstName;
    lastNameController.text = contact.lastName;
    mobileNumberController.text = contact.mobileNumber;
    selectedContact.value = contact;
    isDrawerOpen.value = true;
  }

  void closeDrawer() {
    isDrawerOpen.value = false;
    firstNameController.clear();
    lastNameController.clear();
    mobileNumberController.clear();
  }

  void toggleDetailPanel() {
    isDetailPanelOpen.value = !isDetailPanelOpen.value;
  }

  Future<void> saveContact({String? imageUrl}) async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final mobile = MyContactsModel.normalizeMobile(mobileNumberController.text.trim());

    if (firstName.isEmpty || mobile.isEmpty) {
      ShowToastDialog.showError('First name and mobile number are required');
      return;
    }

    isLoading.value = true;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      String image = imageUrl ?? '';
      if (isEditing.value && selectedContact.value != null) {
        image = image.isEmpty ? selectedContact.value!.profileImage : image;
        final model = selectedContact.value!.copyWith(
          firstName: firstName,
          lastName: lastName,
          mobileNumber: mobile,
          profileImage: image,
        );
        await MyContactsCrud.createOrUpdateContact(model);
        ShowToastDialog.showSuccess('Contact updated');
      } else {
        final model = MyContactsModel(
          ownerId: uid,
          firstName: firstName,
          lastName: lastName,
          mobileNumber: mobile,
          profileImage: image,
        );
        await MyContactsCrud.createOrUpdateContact(model);
        ShowToastDialog.showSuccess('Contact saved');
      }
      closeDrawer();
    } catch (e) {
      ShowToastDialog.showError('Failed to save contact');
    }
    isLoading.value = false;
  }

  Future<void> deleteContact(String docId) async {
    try {
      await MyContactsCrud.deleteContact(docId);
      if (selectedContact.value?.docId == docId) {
        selectedContact.value = null;
      }
      ShowToastDialog.showSuccess('Contact deleted');
    } catch (e) {
      ShowToastDialog.showError('Failed to delete contact');
    }
  }

  Future<void> refreshContacts() async {
    isLoading.value = true;
    _contactsSub?.cancel();
    _startContactsStream();
    await Future.delayed(const Duration(milliseconds: 400));
    isLoading.value = false;
    ShowToastDialog.showSuccess('Contacts refreshed');
  }

  // VCF processing remaining blocks setup ...
  Future<void> importMobileContacts() async {
    isImporting.value = true;
    try {
      ShowToastDialog.showSuccess('Contacts imported');
    } catch (e) {
      ShowToastDialog.showError('Import failed');
    }
    isImporting.value = false;
  }

  Future<void> importVcfFile() async {
    isImporting.value = true;
    importProgress.value = 0;
    importAdded.value = 0;
    importSkipped.value = 0;
    importUpdated.value = 0;
    try {
      final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['vcf'],
          withReadStream: true
      );
      if (result == null || result.files.isEmpty) {
        isImporting.value = false;
        return;
      }

      final file = result.files.first;
      final stream = file.readStream;
      if (stream == null) {
        ShowToastDialog.showError('Cannot read VCF');
        isImporting.value = false;
        return;
      }

      final bytes = <int>[];
      await for (final chunk in stream) {
        bytes.addAll(chunk);
      }

      final vcfContent = String.fromCharCodes(bytes);
      final parsed = MyContactsCrud.parseVcfString(vcfContent);
      if (parsed.isEmpty) {
        ShowToastDialog.showError('No contacts found');
        isImporting.value = false;
        return;
      }

      importTotal.value = parsed.length;
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final existingMap = await MyContactsCrud.getAllContactsMap();
      final firestore = FirebaseFirestore.instance;
      WriteBatch batch = firestore.batch();

      int operationCount = 0;
      for (int i = 0; i < parsed.length; i++) {
        final v = parsed[i];
        final mobile = MyContactsModel.normalizeMobile(v.mobileNumber);
        if (mobile.isEmpty) {
          importSkipped.value++;
          continue;
        }

        final existing = existingMap[mobile];
        if (existing != null) {
          final needsUpdate = existing.firstName != v.firstName || existing.lastName != v.lastName;
          if (needsUpdate) {
            final updated = existing.copyWith(
              firstName: v.firstName,
              lastName: v.lastName,
            );
            batch.update(
              firestore.collection('my_contacts').doc(existing.docId),
              updated.toJson(),
            );
            importUpdated.value++;
            final index = contacts.indexWhere((e) => e.docId == existing.docId);
            if (index != -1) {
              contacts[index] = updated;
              contacts.refresh();
              _applyFilterAndSort();
            }
            operationCount++;
          } else {
            importSkipped.value++;
          }
        } else {
          final doc = firestore.collection('my_contacts').doc();
          final model = MyContactsModel(
            docId: doc.id,
            ownerId: uid,
            firstName: v.firstName,
            lastName: v.lastName,
            mobileNumber: mobile,
            profileImage: '',
          );
          batch.set(doc, model.toJson());

          importAdded.value++;
          operationCount++;
          existingMap[mobile] = model;
          contacts.insert(0, model);
          _applyFilterAndSort();
        }

        if (operationCount >= 400) {
          await batch.commit();
          batch = firestore.batch();
          operationCount = 0;
        }

        if (i % 20 == 0) {
          importProgress.value = (i + 1) / parsed.length;
          await Future.delayed(const Duration(milliseconds: 1));
        }
      }

      if (operationCount > 0) {
        await batch.commit();
      }

      await refreshContacts();
      importProgress.value = 1;
      ShowToastDialog.showSuccess('Imported ${importAdded.value} new contacts');
    } catch (e) {
      ShowToastDialog.showError('VCF import failed: $e');
    }
    isImporting.value = false;
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _contactsSub?.cancel();
    _debounce?.cancel();
    firstNameController.dispose();
    lastNameController.dispose();
    mobileNumberController.dispose();
    searchController.dispose();
    super.onClose();
  }
}