import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/movie_model.dart';
import 'package:maheksync/app/firestore_utills/movie_firestore_utils.dart';

class AllMoviesController extends GetxController {
  final movies = <MovieModel>[].obs;
  final filteredMovies = <MovieModel>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final isGridView = true.obs;
  final selectedStatus = 'ALL'.obs;

  String? get ownerId => MahekConstant.ownerModel?.id;

  int get totalMovies => movies.length;
  int get watchingCount => movies.where((m) => m.status == 'WATCHING').length;
  int get completedCount => movies.where((m) => m.status == 'COMPLETED').length;
  int get notStartedCount => movies.where((m) => m.status == 'NOT_STARTED').length;

  @override
  void onInit() {
    super.onInit();
    loadMovies();
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedStatus, (_) => _applyFilters());
  }

  void loadMovies() {
    if (ownerId == null) return;
    MovieFirestoreUtils.getUserMovies(ownerId!).listen((movieList) {
      movies.value = movieList;
      _applyFilters();
      isLoading.value = false;
    });
  }

  void _applyFilters() {
    var result = movies.toList();

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((m) {
        return (m.movieName ?? '').toLowerCase().contains(query) ||
            (m.year ?? '').toLowerCase().contains(query) ||
            (m.genre ?? '').toLowerCase().contains(query) ||
            (m.director ?? '').toLowerCase().contains(query);
      }).toList();
    }

    if (selectedStatus.value != 'ALL') {
      final statusMap = {
        'NOT STARTED': 'NOT_STARTED',
        'WATCHING': 'WATCHING',
        'COMPLETED': 'COMPLETED',
      };
      final statusValue = statusMap[selectedStatus.value];
      if (statusValue != null) {
        result = result.where((m) => m.status == statusValue).toList();
      }
    }

    filteredMovies.value = result;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void updateStatusFilter(String status) {
    selectedStatus.value = status;
  }

  void toggleView() {
    isGridView.value = !isGridView.value;
  }
}
