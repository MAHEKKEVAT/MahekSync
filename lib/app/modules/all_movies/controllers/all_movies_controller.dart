import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/movie_model.dart';
import 'package:maheksync/app/firestore_utills/movie_firestore_utils.dart';

class AllMoviesController extends GetxController {
  final movies = <MovieModel>[].obs;
  final filteredMovies = <MovieModel>[].obs;
  final displayedMovies = <MovieModel>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final searchQuery = ''.obs;
  final isGridView = true.obs;
  final selectedStatus = 'ALL'.obs;
  final selectedGenre = 'ALL'.obs;

  int _displayCount = 12;
  static const int _pageSize = 12;

  String? get ownerId => MahekConstant.ownerModel?.id;

  int get totalMovies => movies.length;
  int get watchingCount => movies.where((m) => m.status == 'WATCHING').length;
  int get completedCount => movies.where((m) => m.status == 'COMPLETED').length;
  int get notStartedCount => movies.where((m) => m.status == 'NOT_STARTED').length;

  List<String> get availableGenres {
    final genres = <String>{};
    for (final m in movies) {
      for (final g in m.genreTags) {
        genres.add(g.toUpperCase());
      }
    }
    final sorted = genres.toList()..sort();
    return ['ALL', ...sorted];
  }

  bool get hasMore => displayedMovies.length < filteredMovies.length;

  @override
  void onInit() {
    super.onInit();
    loadMovies();
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedStatus, (_) => _applyFilters());
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

    if (selectedGenre.value != 'ALL') {
      final genre = selectedGenre.value.toLowerCase();
      result = result
          .where((m) => m.genreTags.any((g) => g.toLowerCase() == genre))
          .toList();
    }

    filteredMovies.value = result;
    _displayCount = _pageSize;
    _updateDisplayed();
  }

  void _updateDisplayed() {
    final end = _displayCount.clamp(0, filteredMovies.length);
    displayedMovies.value = filteredMovies.sublist(0, end);
  }

  void loadMore() {
    if (isLoadingMore.value || !hasMore) return;
    isLoadingMore.value = true;
    Future.delayed(const Duration(milliseconds: 300), () {
      _displayCount += _pageSize;
      _updateDisplayed();
      isLoadingMore.value = false;
    });
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void updateStatusFilter(String status) {
    selectedStatus.value = status;
  }

  void updateGenreFilter(String genre) {
    selectedGenre.value = genre;
  }

  void toggleView() {
    isGridView.value = !isGridView.value;
  }
}
