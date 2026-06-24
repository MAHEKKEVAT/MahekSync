import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/movie_model.dart';
import 'package:maheksync/app/firestore_utills/movie_firestore_utils.dart';

class MoviesController extends GetxController {
  final movies = <MovieModel>[].obs;
  final filteredMovies = <MovieModel>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final isGridView = true.obs;
  final selectedGenre = 'ALL'.obs;

  String? get ownerId => MahekConstant.ownerModel?.id;

  int get totalMovies => movies.length;
  int get watchingCount => movies.where((m) => m.status == 'WATCHING').length;
  int get completedCount => movies.where((m) => m.status == 'COMPLETED').length;
  int get notStartedCount => movies.where((m) => m.status == 'NOT_STARTED').length;

  List<MovieModel> get watchingMovies =>
      movies.where((m) => m.status == 'WATCHING').toList();

  List<MovieModel> get latestMovies {
    final sorted = movies.toList()
      ..sort((a, b) => (b.createdAt ?? Timestamp(0, 0)).compareTo(a.createdAt ?? Timestamp(0, 0)));
    return sorted.take(4).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadMovies();
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedGenre, (_) => _applyFilters());
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
            (m.year ?? '').toLowerCase().contains(query);
      }).toList();
    }

    if (selectedGenre.value != 'ALL') {
      final statusMap = {
        'NOT STARTED': 'NOT_STARTED',
        'WATCHING': 'WATCHING',
        'COMPLETED': 'COMPLETED',
      };
      final statusValue = statusMap[selectedGenre.value];
      if (statusValue != null) {
        result = result.where((m) => m.status == statusValue).toList();
      }
    }

    filteredMovies.value = result;
  }

  void toggleView() {
    isGridView.value = !isGridView.value;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void updateGenreFilter(String genre) {
    selectedGenre.value = genre;
  }
}
