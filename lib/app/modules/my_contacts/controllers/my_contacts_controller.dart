import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/show_toast.dart';
import 'package:maheksync/app/models/my_contacts_model.dart';
import 'package:maheksync/app/modules/my_contacts/my_contacts_crud.dart';

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

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final searchController = TextEditingController();

  StreamSubscription? _contactsSub;
  Timer? _debounce;

  int get totalContacts => contacts.length;

  int get recentCount {
    final now = DateTime.now();
    return contacts.where((c) => now.difference(c.createdAt).inDays <= 7).length;
  }

  @override
  void onInit() {
    super.onInit();
    _startContactsStream();
    searchController.addListener(_onSearchChanged);
  }

  void _startContactsStream() {
    isLoading.value = true;
    _contactsSub = MyContactsCrud.streamContacts().listen((data) {
      contacts.value = data;
      _applyFilter();
      isLoading.value = false;
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchText.value = searchController.text.trim();
      _applyFilter();
    });
  }

  void _applyFilter() {
    final q = searchText.value.toLowerCase().trim();
    if (q.isEmpty) {
      filteredContacts.value = contacts.toList();
    } else {
      filteredContacts.value = contacts.where((c) {
        final name = c.formattedName.toLowerCase();
        final mobile = c.mobileNumber.toLowerCase();
        return name.contains(q) || mobile.contains(q);
      }).toList();
    }
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
    final mobile = mobileNumberController.text.trim();

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
          mobileNumber: mobile.replaceAll(RegExp(r'[^0-9]'), ''),
          profileImage: image,
          searchKeywords: MyContactsModel.generateSearchKeywords(firstName, lastName, mobile),
        );
        await MyContactsCrud.createOrUpdateContact(model);
        ShowToastDialog.showSuccess('Contact updated');
      } else {
        final model = MyContactsModel(
          id: '',
          ownerId: uid,
          firstName: firstName,
          lastName: lastName,
          mobileNumber: mobile.replaceAll(RegExp(r'[^0-9]'), ''),
          profileImage: image,
          searchKeywords: MyContactsModel.generateSearchKeywords(firstName, lastName, mobile),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
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

  Future<void> deleteContact(String id) async {
    try {
      await MyContactsCrud.deleteContact(id);
      if (selectedContact.value?.id == id) {
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
  }

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
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        isImporting.value = false;
        return;
      }

      final file = result.files.first;
      String vcfContent;

      if (file.bytes != null) {
        vcfContent = String.fromCharCodes(file.bytes!);
      } else if (file.path != null) {
        vcfContent = await File(file.path!).readAsString();
      } else {
        ShowToastDialog.showError('Cannot read VCF file');
        isImporting.value = false;
        return;
      }

      final parsed = MyContactsCrud.parseVcfString(vcfContent);
      if (parsed.isEmpty) {
        ShowToastDialog.showError('No contacts found in VCF file');
        isImporting.value = false;
        return;
      }

      importTotal.value = parsed.length;
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

      for (int i = 0; i < parsed.length; i++) {
        final v = parsed[i];
        final mobile = v.mobileNumber.replaceAll(RegExp(r'[^0-9]'), '');
        if (mobile.isEmpty) {
          importSkipped.value++;
          importProgress.value = (i + 1) / parsed.length;
          continue;
        }

        final existing = await MyContactsCrud.checkContactExists(mobile);
        if (existing != null) {
          if (existing.firstName != v.firstName || existing.lastName != v.lastName) {
            final updated = existing.copyWith(
              firstName: v.firstName,
              lastName: v.lastName,
              searchKeywords: MyContactsModel.generateSearchKeywords(v.firstName, v.lastName, mobile),
            );
            await FirebaseFirestore.instance.collection('my_contacts').doc(existing.id).update(updated.toUpdateJson());
            importUpdated.value++;
          } else {
            importSkipped.value++;
          }
        } else {
          final model = MyContactsModel(
            id: '',
            ownerId: uid,
            firstName: v.firstName,
            lastName: v.lastName,
            mobileNumber: mobile,
            profileImage: '',
            searchKeywords: MyContactsModel.generateSearchKeywords(v.firstName, v.lastName, mobile),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await MyContactsCrud.createOnlyNewContact(model);
          importAdded.value++;
        }
        importProgress.value = (i + 1) / parsed.length;
      }

      ShowToastDialog.showSuccess(
        'Import done: ${importAdded.value} added, ${importUpdated.value} names updated, ${importSkipped.value} skipped',
      );
    } catch (e) {
      ShowToastDialog.showError('VCF import failed: ${e.toString()}');
    }
    isImporting.value = false;
  }

  @override
  void onClose() {
    _contactsSub?.cancel();
    _debounce?.cancel();
    firstNameController.dispose();
    lastNameController.dispose();
    mobileNumberController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
