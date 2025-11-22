import '../database/database_helper.dart';
import '../models/cast.dart';
import '../models/movie.dart';
import '../models/movie_details.dart';
import '../network/api_service.dart';
import '../network/connectivity_service.dart';

/// Repository Pattern implementation for Movies
/// Handles data operations from both remote API and local database
class MovieRepository {
  final ApiService _apiService;
  final DatabaseHelper _databaseHelper;
  final ConnectivityService _connectivityService;

  MovieRepository({
    required ApiService apiService,
    required DatabaseHelper databaseHelper,
    required ConnectivityService connectivityService,
  })  : _apiService = apiService,
        _databaseHelper = databaseHelper,
        _connectivityService = connectivityService;

  // ==================== Trending Movies ====================

  /// Fetches trending movies
  /// Returns cached data if offline, otherwise fetches from API and caches
  Future<List<Movie>> getTrendingMovies({bool forceRefresh = false}) async {
    final isOnline = await _connectivityService.checkConnectivity();

    if (isOnline && forceRefresh) {
      return await _fetchAndCacheTrendingMovies();
    }

    // Try to get from cache first
    final cachedMovies = await _databaseHelper.getTrendingMovies();

    if (cachedMovies.isNotEmpty && !forceRefresh) {
      // Return cached data, but refresh in background if online
      if (isOnline) {
        _fetchAndCacheTrendingMovies(); // Fire and forget
      }
      return cachedMovies;
    }

    // If no cache and online, fetch from API
    if (isOnline) {
      return await _fetchAndCacheTrendingMovies();
    }

    // Return whatever we have (might be empty)
    return cachedMovies;
  }

  Future<List<Movie>> _fetchAndCacheTrendingMovies() async {
    try {
      final response = await _apiService.getTrendingMovies();
      final movies = await _updateBookmarkStatus(response.results);
      await _databaseHelper.saveTrendingMovies(movies);
      return movies;
    } catch (e) {
      // On error, return cached data
      return await _databaseHelper.getTrendingMovies();
    }
  }

  // ==================== Now Playing Movies ====================

  /// Fetches now playing movies
  Future<List<Movie>> getNowPlayingMovies({bool forceRefresh = false}) async {
    final isOnline = await _connectivityService.checkConnectivity();

    if (isOnline && forceRefresh) {
      return await _fetchAndCacheNowPlayingMovies();
    }

    final cachedMovies = await _databaseHelper.getNowPlayingMovies();

    if (cachedMovies.isNotEmpty && !forceRefresh) {
      if (isOnline) {
        _fetchAndCacheNowPlayingMovies();
      }
      return cachedMovies;
    }

    if (isOnline) {
      return await _fetchAndCacheNowPlayingMovies();
    }

    return cachedMovies;
  }

  Future<List<Movie>> _fetchAndCacheNowPlayingMovies() async {
    try {
      final response = await _apiService.getNowPlayingMovies();
      final movies = await _updateBookmarkStatus(response.results);
      await _databaseHelper.saveNowPlayingMovies(movies);
      return movies;
    } catch (e) {
      return await _databaseHelper.getNowPlayingMovies();
    }
  }

  // ==================== Movie Details ====================

  /// Fetches movie details
  Future<MovieDetails?> getMovieDetails(int movieId) async {
    final isOnline = await _connectivityService.checkConnectivity();

    if (!isOnline) {
      // Return basic info from cached movie if available
      final cachedMovie = await _databaseHelper.getMovie(movieId);
      if (cachedMovie != null) {
        return MovieDetails(
          id: cachedMovie.id,
          title: cachedMovie.title,
          overview: cachedMovie.overview,
          posterPath: cachedMovie.posterPath,
          backdropPath: cachedMovie.backdropPath,
          releaseDate: cachedMovie.releaseDate,
          voteAverage: cachedMovie.voteAverage,
        );
      }
      return null;
    }

    try {
      return await _apiService.getMovieDetails(movieId: movieId);
    } catch (e) {
      final cachedMovie = await _databaseHelper.getMovie(movieId);
      if (cachedMovie != null) {
        return MovieDetails(
          id: cachedMovie.id,
          title: cachedMovie.title,
          overview: cachedMovie.overview,
          posterPath: cachedMovie.posterPath,
          backdropPath: cachedMovie.backdropPath,
          releaseDate: cachedMovie.releaseDate,
          voteAverage: cachedMovie.voteAverage,
        );
      }
      rethrow;
    }
  }

  /// Fetches movie credits (cast & crew)
  Future<CreditsResponse?> getMovieCredits(int movieId) async {
    final isOnline = await _connectivityService.checkConnectivity();
    if (!isOnline) return null;

    try {
      return await _apiService.getMovieCredits(movieId: movieId);
    } catch (e) {
      return null;
    }
  }

  /// Fetches similar movies
  Future<List<Movie>> getSimilarMovies(int movieId) async {
    final isOnline = await _connectivityService.checkConnectivity();
    if (!isOnline) return [];

    try {
      final response = await _apiService.getSimilarMovies(movieId: movieId);
      return await _updateBookmarkStatus(response.results);
    } catch (e) {
      return [];
    }
  }

  // ==================== Search ====================

  /// Searches for movies
  /// Uses API when online, local search when offline
  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];

    final isOnline = await _connectivityService.checkConnectivity();

    if (isOnline) {
      try {
        final response = await _apiService.searchMovies(query: query);
        final movies = await _updateBookmarkStatus(response.results);
        // Cache search results
        await _databaseHelper.insertMovies(movies);
        return movies;
      } catch (e) {
        // Fall back to local search
        return await _databaseHelper.searchMoviesLocally(query);
      }
    }

    // Offline - search locally
    return await _databaseHelper.searchMoviesLocally(query);
  }

  // ==================== Bookmarks ====================

  /// Toggles bookmark status for a movie
  Future<bool> toggleBookmark(Movie movie) async {
    final isCurrentlyBookmarked = await _databaseHelper.isBookmarked(movie.id);

    if (isCurrentlyBookmarked) {
      await _databaseHelper.removeBookmark(movie.id);
      return false;
    } else {
      // Ensure movie is in database before bookmarking
      await _databaseHelper.insertMovie(movie);
      await _databaseHelper.addBookmark(movie.id);
      return true;
    }
  }

  /// Adds a movie to bookmarks
  Future<void> addBookmark(Movie movie) async {
    await _databaseHelper.insertMovie(movie);
    await _databaseHelper.addBookmark(movie.id);
  }

  /// Removes a movie from bookmarks
  Future<void> removeBookmark(int movieId) async {
    await _databaseHelper.removeBookmark(movieId);
  }

  /// Gets all bookmarked movies
  Future<List<Movie>> getBookmarkedMovies() async {
    return await _databaseHelper.getBookmarkedMovies();
  }

  /// Checks if a movie is bookmarked
  Future<bool> isBookmarked(int movieId) async {
    return await _databaseHelper.isBookmarked(movieId);
  }

  // ==================== Helpers ====================

  /// Updates bookmark status for a list of movies
  Future<List<Movie>> _updateBookmarkStatus(List<Movie> movies) async {
    final updatedMovies = <Movie>[];
    for (final movie in movies) {
      final isBookmarked = await _databaseHelper.isBookmarked(movie.id);
      updatedMovies.add(movie.copyWith(isBookmarked: isBookmarked));
    }
    return updatedMovies;
  }

  /// Gets a single movie by ID
  Future<Movie?> getMovie(int movieId) async {
    return await _databaseHelper.getMovie(movieId);
  }

  /// Checks if the device is online
  Future<bool> isOnline() async {
    return await _connectivityService.checkConnectivity();
  }
}