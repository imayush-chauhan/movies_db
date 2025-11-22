import 'package:flutter/material.dart';

import '../../../../core/base/base_viewmodel.dart';
import '../../../../core/models/movie.dart';
import '../../../../core/repository/movie_repository.dart';

class BookmarksViewModel extends BaseViewModel {
  final MovieRepository _repository;

  List<Movie> _bookmarkedMovies = [];

  BookmarksViewModel({required MovieRepository repository})
      : _repository = repository;

  // Getters
  List<Movie> get bookmarkedMovies => _bookmarkedMovies;
  bool get hasBookmarks => _bookmarkedMovies.isNotEmpty;
  int get bookmarkCount => _bookmarkedMovies.length;

  /// Load all bookmarked movies
  Future<void> loadBookmarks() async {
    setLoading();

    try {
      _bookmarkedMovies = await _repository.getBookmarkedMovies();

      if (_bookmarkedMovies.isEmpty) {
        setEmpty();
      } else {
        setSuccess();
      }
    } catch (e) {
      setError(e.toString());
    }
  }



  /// Remove a movie from bookmarks
  Future<void> removeBookmark(Movie movie) async {
    try {
      await _repository.removeBookmark(movie.id);
      _bookmarkedMovies.removeWhere((m) => m.id == movie.id);

      if (_bookmarkedMovies.isEmpty) {
        setEmpty();
      } else {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error removing bookmark: $e');
    }
  }

  /// Toggle bookmark for a movie
  Future<void> toggleBookmark(Movie movie) async {
    try {
      final isNowBookmarked = await _repository.toggleBookmark(movie);

      if (isNowBookmarked) {
        // Add to list if not present
        if (!_bookmarkedMovies.any((m) => m.id == movie.id)) {
          _bookmarkedMovies.insert(
              0, movie.copyWith(isBookmarked: true));
        }
      } else {
        // Remove from list
        _bookmarkedMovies.removeWhere((m) => m.id == movie.id);
      }

      if (_bookmarkedMovies.isEmpty) {
        setEmpty();
      } else {
        setSuccess();
      }
    } catch (e) {
      debugPrint('Error toggling bookmark: $e');
    }
  }

  /// Check if a movie is bookmarked
  bool isMovieBookmarked(int movieId) {
    return _bookmarkedMovies.any((m) => m.id == movieId);
  }

  /// Refresh bookmarks
  Future<void> refresh() async {
    await loadBookmarks();
  }
}