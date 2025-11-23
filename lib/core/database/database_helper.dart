import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie.dart';

class DatabaseHelper {
  static SharedPreferences? _prefs;

  // Keys for SharedPreferences
  static const String _moviesKey = 'movies_cache';
  static const String _trendingKey = 'trending_movies';
  static const String _nowPlayingKey = 'now_playing_movies';
  static const String _bookmarksKey = 'bookmarked_movies';

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ==================== Helper Methods ====================

  Future<Map<int, Movie>> _getAllMoviesMap() async {
    try {
      final prefs = await _preferences;
      final String? moviesJson = prefs.getString(_moviesKey);

      if (moviesJson == null || moviesJson.isEmpty) {
        return {};
      }

      final Map<String, dynamic> decoded = jsonDecode(moviesJson);
      final Map<int, Movie> movies = {};

      decoded.forEach((key, value) {
        final movie = Movie.fromJson(value as Map<String, dynamic>);
        movies[int.parse(key)] = movie;
      });

      return movies;
    } catch (e) {
      debugPrint('Error getting movies map: $e');
      return {};
    }
  }

  Future<void> _saveAllMoviesMap(Map<int, Movie> movies) async {
    try {
      final prefs = await _preferences;
      final Map<String, dynamic> toSave = {};

      movies.forEach((key, value) {
        toSave[key.toString()] = value.toJson();
      });

      await prefs.setString(_moviesKey, jsonEncode(toSave));
    } catch (e) {
      debugPrint('Error saving movies map: $e');
    }
  }

  Future<List<int>> _getIdList(String key) async {
    try {
      final prefs = await _preferences;
      final String? idsJson = prefs.getString(key);

      if (idsJson == null || idsJson.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(idsJson);
      return decoded.map((e) => e as int).toList();
    } catch (e) {
      debugPrint('Error getting id list for $key: $e');
      return [];
    }
  }

  Future<void> _saveIdList(String key, List<int> ids) async {
    try {
      final prefs = await _preferences;
      await prefs.setString(key, jsonEncode(ids));
    } catch (e) {
      debugPrint('Error saving id list for $key: $e');
    }
  }

  Future<Set<int>> _getBookmarkIds() async {
    final ids = await _getIdList(_bookmarksKey);
    return ids.toSet();
  }

  // ==================== Movie Operations ====================

  Future<void> insertMovie(Movie movie) async {
    try {
      final movies = await _getAllMoviesMap();
      movies[movie.id] = movie;
      await _saveAllMoviesMap(movies);
    } catch (e) {
      debugPrint('Error inserting movie: $e');
    }
  }

  Future<void> insertMovies(List<Movie> moviesList) async {
    try {
      final movies = await _getAllMoviesMap();

      for (final movie in moviesList) {
        movies[movie.id] = movie;
      }

      await _saveAllMoviesMap(movies);
    } catch (e) {
      debugPrint('Error inserting movies: $e');
    }
  }

  Future<Movie?> getMovie(int id) async {
    try {
      final movies = await _getAllMoviesMap();
      final movie = movies[id];

      if (movie != null) {
        final bookmarkIds = await _getBookmarkIds();
        return movie.copyWith(isBookmarked: bookmarkIds.contains(id));
      }

      return null;
    } catch (e) {
      debugPrint('Error getting movie: $e');
      return null;
    }
  }

  // ==================== Trending Movies ====================

  Future<void> saveTrendingMovies(List<Movie> movies) async {
    try {
      // Insert movies first
      await insertMovies(movies);

      // Save trending IDs in order
      final ids = movies.map((m) => m.id).toList();
      await _saveIdList(_trendingKey, ids);
    } catch (e) {
      debugPrint('Error saving trending movies: $e');
    }
  }

  Future<List<Movie>> getTrendingMovies() async {
    try {
      final trendingIds = await _getIdList(_trendingKey);

      if (trendingIds.isEmpty) {
        return [];
      }

      final allMovies = await _getAllMoviesMap();
      final bookmarkIds = await _getBookmarkIds();

      final List<Movie> result = [];

      for (final id in trendingIds) {
        final movie = allMovies[id];
        if (movie != null) {
          result.add(movie.copyWith(isBookmarked: bookmarkIds.contains(id)));
        }
      }

      return result;
    } catch (e) {
      debugPrint('Error getting trending movies: $e');
      return [];
    }
  }

  // ==================== Now Playing Movies ====================

  Future<void> saveNowPlayingMovies(List<Movie> movies) async {
    try {
      // Insert movies first
      await insertMovies(movies);

      // Save now playing IDs in order
      final ids = movies.map((m) => m.id).toList();
      await _saveIdList(_nowPlayingKey, ids);
    } catch (e) {
      debugPrint('Error saving now playing movies: $e');
    }
  }

  Future<List<Movie>> getNowPlayingMovies() async {
    try {
      final nowPlayingIds = await _getIdList(_nowPlayingKey);

      if (nowPlayingIds.isEmpty) {
        return [];
      }

      final allMovies = await _getAllMoviesMap();
      final bookmarkIds = await _getBookmarkIds();

      final List<Movie> result = [];

      for (final id in nowPlayingIds) {
        final movie = allMovies[id];
        if (movie != null) {
          result.add(movie.copyWith(isBookmarked: bookmarkIds.contains(id)));
        }
      }

      return result;
    } catch (e) {
      debugPrint('Error getting now playing movies: $e');
      return [];
    }
  }

  // ==================== Bookmark Operations ====================

  Future<void> addBookmark(int movieId) async {
    try {
      final bookmarkIds = (await _getIdList(_bookmarksKey)).toList();

      if (!bookmarkIds.contains(movieId)) {
        bookmarkIds.insert(0, movieId); // Add to beginning
        await _saveIdList(_bookmarksKey, bookmarkIds);
      }

      // Update movie's bookmark status
      final movies = await _getAllMoviesMap();
      if (movies.containsKey(movieId)) {
        movies[movieId] = movies[movieId]!.copyWith(isBookmarked: true);
        await _saveAllMoviesMap(movies);
      }
    } catch (e) {
      debugPrint('Error adding bookmark: $e');
    }
  }

  Future<void> removeBookmark(int movieId) async {
    try {
      final bookmarkIds = (await _getIdList(_bookmarksKey)).toList();
      bookmarkIds.remove(movieId);
      await _saveIdList(_bookmarksKey, bookmarkIds);

      // Update movie's bookmark status
      final movies = await _getAllMoviesMap();
      if (movies.containsKey(movieId)) {
        movies[movieId] = movies[movieId]!.copyWith(isBookmarked: false);
        await _saveAllMoviesMap(movies);
      }
    } catch (e) {
      debugPrint('Error removing bookmark: $e');
    }
  }

  Future<bool> isBookmarked(int movieId) async {
    try {
      final bookmarkIds = await _getBookmarkIds();
      return bookmarkIds.contains(movieId);
    } catch (e) {
      debugPrint('Error checking bookmark: $e');
      return false;
    }
  }

  Future<List<Movie>> getBookmarkedMovies() async {
    try {
      final bookmarkIds = await _getIdList(_bookmarksKey);

      if (bookmarkIds.isEmpty) {
        return [];
      }

      final allMovies = await _getAllMoviesMap();

      final List<Movie> result = [];

      for (final id in bookmarkIds) {
        final movie = allMovies[id];
        if (movie != null) {
          result.add(movie.copyWith(isBookmarked: true));
        }
      }

      return result;
    } catch (e) {
      debugPrint('Error getting bookmarked movies: $e');
      return [];
    }
  }

  // ==================== Search ====================

  Future<List<Movie>> searchMoviesLocally(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final allMovies = await _getAllMoviesMap();
      final bookmarkIds = await _getBookmarkIds();
      final queryLower = query.toLowerCase();

      final List<Movie> results = [];

      allMovies.forEach((id, movie) {
        final title = movie.title?.toLowerCase() ?? '';
        final originalTitle = movie.originalTitle?.toLowerCase() ?? '';

        if (title.contains(queryLower) || originalTitle.contains(queryLower)) {
          results.add(movie.copyWith(isBookmarked: bookmarkIds.contains(id)));
        }
      });

      // Sort by popularity
      results.sort((a, b) => (b.popularity ?? 0).compareTo(a.popularity ?? 0));

      // Limit to 50 results
      return results.take(50).toList();
    } catch (e) {
      debugPrint('Error searching movies locally: $e');
      return [];
    }
  }

  // ==================== Utility ====================

  Future<void> clearAllData() async {
    try {
      final prefs = await _preferences;
      await prefs.remove(_moviesKey);
      await prefs.remove(_trendingKey);
      await prefs.remove(_nowPlayingKey);
      await prefs.remove(_bookmarksKey);
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }

  Future<void> close() async {
    // SharedPreferences doesn't need to be closed
    // This method is kept for API compatibility
  }
}