import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:movies_db/features/bookmarks/presentation/viewmodel/bookmarks_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../../../core/base/base_viewmodel.dart';
import '../../../../core/models/movie.dart';
import '../../../../core/repository/movie_repository.dart';

class SearchViewModel extends BaseViewModel {
  final MovieRepository _repository;

  List<Movie> _searchResults = [];
  String _searchQuery = '';
  Timer? _debounceTimer;

  // Debounce duration for search-as-you-type
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  SearchViewModel({required MovieRepository repository})
      : _repository = repository;

  // Getters
  List<Movie> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;
  bool get hasResults => _searchResults.isNotEmpty;
  bool get hasQuery => _searchQuery.isNotEmpty;

  /// Handle search query changes with debouncing
  /// This implements the bonus task: search as user types
  void onSearchQueryChanged(String query) {
    _searchQuery = query;

    // Cancel previous timer
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      _searchResults = [];
      setIdle();
      return;
    }

    // Show loading immediately for better UX
    if (_searchResults.isEmpty) {
      setLoading();
    }

    // Debounce the actual search
    _debounceTimer = Timer(_debounceDuration, () {
      _performSearch(query);
    });
  }

  /// Perform immediate search (for submit button)
  Future<void> search(String query) async {
    _debounceTimer?.cancel();
    _searchQuery = query;

    if (query.isEmpty) {
      _searchResults = [];
      setIdle();
      return;
    }

    await _performSearch(query);
  }

  /// Internal search method
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setLoading();

    try {
      final results = await _repository.searchMovies(query);

      // Only update if the query hasn't changed
      if (query == _searchQuery) {
        _searchResults = results;

        if (results.isEmpty) {
          setEmpty();
        } else {
          setSuccess();
        }
      }
    } catch (e) {
      if (query == _searchQuery) {
        setError(e.toString());
      }
    }
  }

  /// Clear search
  void clearSearch() {
    _debounceTimer?.cancel();
    _searchQuery = '';
    _searchResults = [];
    setIdle();
  }

  /// Toggle bookmark for a movie
  Future<void> toggleBookmark(BuildContext context, Movie movie) async {
    try {
      final isNowBookmarked = await _repository.toggleBookmark(movie);

      final index = _searchResults.indexWhere((m) => m.id == movie.id);
      if (index != -1) {
        _searchResults[index] =
            _searchResults[index].copyWith(isBookmarked: isNowBookmarked);
        notifyListeners();

        Provider.of<BookmarksViewModel>(context, listen: false).loadBookmarks();
      }
    } catch (e) {
      debugPrint('Error toggling bookmark: $e');
    }
  }

  /// Update bookmark status for a specific movie
  void updateMovieBookmarkStatus(int movieId, bool isBookmarked) {
    final index = _searchResults.indexWhere((m) => m.id == movieId);
    if (index != -1) {
      _searchResults[index] =
          _searchResults[index].copyWith(isBookmarked: isBookmarked);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}