import 'package:get/get.dart';
import 'package:maheksync/app/models/movie_model.dart';
import 'package:maheksync/app/firestore_utills/movie_firestore_utils.dart';
import 'package:maheksync/app/constant/show_toast.dart';
import 'package:maheksync/app/routes/app_pages.dart';

class MovieDetailsController extends GetxController {
  final movie = Rxn<MovieModel>();
  final isLoading = true.obs;
  final isUpdating = false.obs;
  final currentSliderMinutes = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is MovieModel) {
      movie.value = args;
      currentSliderMinutes.value = args.watchedDuration ?? 0;
      isLoading.value = false;
    }
  }

  void initSlider() {
    if (movie.value != null) {
      currentSliderMinutes.value = movie.value!.watchedDuration ?? 0;
    }
  }

  Future<void> updateProgress(int newWatchedMinutes) async {
    if (movie.value == null) return;
    isUpdating.value = true;

    final updated = MovieModel(
      id: movie.value!.id,
      ownerId: movie.value!.ownerId,
      movieName: movie.value!.movieName,
      year: movie.value!.year,
      totalDuration: movie.value!.totalDuration,
      watchedDuration: newWatchedMinutes,
      posterUrl: movie.value!.posterUrl,
      status: newWatchedMinutes >= (movie.value!.totalDuration ?? 0)
          ? 'COMPLETED'
          : newWatchedMinutes > 0
              ? 'WATCHING'
              : 'NOT_STARTED',
      genre: movie.value!.genre,
      description: movie.value!.description,
      director: movie.value!.director,
      rating: movie.value!.rating,
      createdAt: movie.value!.createdAt,
    );

    final success = await MovieFirestoreUtils.updateMovie(updated);
    isUpdating.value = false;

    if (success) {
      movie.value = updated;
      currentSliderMinutes.value = newWatchedMinutes;
      ShowToastDialog.showSuccess('Progress updated');
    } else {
      ShowToastDialog.showError('Failed to update progress');
    }
  }

  Future<void> markComplete() async {
    if (movie.value == null) return;
    isUpdating.value = true;

    final updated = MovieModel(
      id: movie.value!.id,
      ownerId: movie.value!.ownerId,
      movieName: movie.value!.movieName,
      year: movie.value!.year,
      totalDuration: movie.value!.totalDuration,
      watchedDuration: movie.value!.totalDuration,
      posterUrl: movie.value!.posterUrl,
      status: 'COMPLETED',
      genre: movie.value!.genre,
      description: movie.value!.description,
      director: movie.value!.director,
      rating: movie.value!.rating,
      createdAt: movie.value!.createdAt,
    );

    final success = await MovieFirestoreUtils.updateMovie(updated);
    isUpdating.value = false;

    if (success) {
      movie.value = updated;
      currentSliderMinutes.value = movie.value!.totalDuration ?? 0;
      ShowToastDialog.showSuccess('Movie marked as completed');
    } else {
      ShowToastDialog.showError('Failed to update movie');
    }
  }

  Future<void> deleteMovie() async {
    if (movie.value?.id == null) return;
    isUpdating.value = true;

    final success = await MovieFirestoreUtils.deleteMovie(movie.value!.id!);
    isUpdating.value = false;

    if (success) {
      ShowToastDialog.showSuccess('Movie deleted');
      Get.back();
    } else {
      ShowToastDialog.showError('Failed to delete movie');
    }
  }

  void editMovie() {
    Get.toNamed(Routes.MOVIE_CRUD, arguments: movie.value);
  }
}
