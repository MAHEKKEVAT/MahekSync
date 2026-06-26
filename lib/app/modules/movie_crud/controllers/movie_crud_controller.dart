import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/movie_model.dart';
import 'package:maheksync/app/firestore_utills/movie_firestore_utils.dart';
import 'package:maheksync/app/constant/show_toast.dart';

class MovieCrudController extends GetxController {
  final movieNameController = TextEditingController();
  final yearController = TextEditingController();
  final descriptionController = TextEditingController();
  final directorController = TextEditingController();

  final totalHours = 0.obs;
  final totalMinutes = 0.obs;
  final watchedHours = 0.obs;
  final watchedMinutes = 0.obs;

  final selectedStatus = 'NOT_STARTED'.obs;
  final selectedGenre = 'ALL'.obs;
  final selectedRating = 0.0.obs;
  final posterUrl = ''.obs;
  final isEditMode = false.obs;
  final isSaving = false.obs;
  final posterFile = Rxn<XFile>();
  final posterBytes = Rxn<Uint8List>();

  String? get ownerId => MahekConstant.ownerModel?.id;
  MovieModel? _existingMovie;

  final statusOptions = ['NOT_STARTED', 'WATCHING', 'COMPLETED'];
  final genreOptions = [
    'ALL', 'ACTION', 'COMEDY', 'DRAMA', 'THRILLER', 'ROMANCE',
  ];
  final ImagePicker _picker = ImagePicker();

  void incTotalHours() { if (totalHours.value < 23) totalHours.value++; }
  void decTotalHours() { if (totalHours.value > 0) totalHours.value--; }
  void incTotalMinutes() { if (totalMinutes.value < 55) totalMinutes.value += 5; }
  void decTotalMinutes() { if (totalMinutes.value > 0) totalMinutes.value -= 5; }

  void incWatchedHours() { if (watchedHours.value < 23) watchedHours.value++; }
  void decWatchedHours() { if (watchedHours.value > 0) watchedHours.value--; }
  void incWatchedMinutes() { if (watchedMinutes.value < 55) watchedMinutes.value += 5; }
  void decWatchedMinutes() { if (watchedMinutes.value > 0) watchedMinutes.value -= 5; }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is MovieModel) {
      _existingMovie = args;
      isEditMode.value = true;
      _populateFields(args);
    }
  }

  void _populateFields(MovieModel movie) {
    movieNameController.text = movie.movieName ?? '';
    yearController.text = movie.year ?? '';
    descriptionController.text = movie.description ?? '';
    directorController.text = movie.director ?? '';
    selectedGenre.value = movie.genre ?? 'ALL';
    selectedRating.value = movie.rating ?? 0.0;
    selectedStatus.value = movie.status ?? 'NOT_STARTED';
    posterUrl.value = movie.posterUrl ?? '';

    totalHours.value = (movie.totalDuration ?? 0) ~/ 60;
    totalMinutes.value = (movie.totalDuration ?? 0) % 60;
    watchedHours.value = (movie.watchedDuration ?? 0) ~/ 60;
    watchedMinutes.value = (movie.watchedDuration ?? 0) % 60;
  }

  Future<void> pickPoster() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (image != null) {
      posterFile.value = image;
      posterBytes.value = await image.readAsBytes();
    }
  }

  Future<void> saveMovie() async {
    if (movieNameController.text.trim().isEmpty) {
      ShowToastDialog.showError('Please enter a movie name');
      return;
    }

    if (ownerId == null) {
      ShowToastDialog.showError('User not authenticated');
      return;
    }

    isSaving.value = true;

    String? imageUrl = posterUrl.value;
    if (posterFile.value != null) {
      imageUrl = await MovieFirestoreUtils.uploadPoster(
        imageFile: posterFile.value!,
        ownerId: ownerId!,
      );
    }

    final movie = MovieModel(
      id: _existingMovie?.id,
      ownerId: ownerId,
      movieName: movieNameController.text.trim(),
      year: yearController.text.trim(),
      totalDuration: (totalHours.value * 60) + totalMinutes.value,
      watchedDuration: (watchedHours.value * 60) + watchedMinutes.value,
      posterUrl: imageUrl,
      status: selectedStatus.value,
      genre: selectedGenre.value == 'ALL' ? '' : selectedGenre.value,
      description: descriptionController.text.trim(),
      director: directorController.text.trim(),
      rating: selectedRating.value == 0 ? null : selectedRating.value,
      createdAt: _existingMovie?.createdAt,
    );

    bool success;
    if (isEditMode.value) {
      success = await MovieFirestoreUtils.updateMovie(movie);
    } else {
      success = await MovieFirestoreUtils.addMovie(movie);
    }

    isSaving.value = false;

    if (success) {
      ShowToastDialog.showSuccess(isEditMode.value ? 'Movie updated' : 'Movie added');
      Get.back();
    } else {
      ShowToastDialog.showError('Failed to save movie');
    }
  }

  void clearForm() {
    movieNameController.clear();
    yearController.clear();
    descriptionController.clear();
    directorController.clear();
    totalHours.value = 0;
    totalMinutes.value = 0;
    watchedHours.value = 0;
    watchedMinutes.value = 0;
    selectedStatus.value = 'NOT_STARTED';
    selectedGenre.value = 'ALL';
    selectedRating.value = 0.0;
    posterUrl.value = '';
    posterFile.value = null;
    posterBytes.value = null;
  }

  @override
  void onClose() {
    movieNameController.dispose();
    yearController.dispose();
    descriptionController.dispose();
    directorController.dispose();
    super.onClose();
  }
}
