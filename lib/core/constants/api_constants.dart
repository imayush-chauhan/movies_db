import 'package:flutter_dotenv/flutter_dotenv.dart';
/// API Constants for TMDB

class ApiConstants {
  ApiConstants._();

  // Base URLs
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';

  // TODO: Replace with your TMDB API Key
  // Get your API key from: https://www.themoviedb.org/settings/api
  static final String apiKey = dotenv.env['API_KEY'] ?? "";

  // Image Sizes
  static const String posterSizeSmall = '/w185';
  static const String posterSizeMedium = '/w342';
  static const String posterSizeLarge = '/w500';
  static const String backdropSize = '/w780';
  static const String originalSize = '/original';

  // Endpoints
  static const String trendingMovies = '/trending/movie/day';
  static const String nowPlayingMovies = '/movie/now_playing';
  static const String movieDetails = '/movie';
  static const String searchMovies = '/search/movie';
  static const String movieCredits = '/movie/{movie_id}/credits';
  static const String similarMovies = '/movie/{movie_id}/similar';

  // Helper methods for image URLs
  static String getPosterUrl(String? path, {String size = posterSizeMedium}) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl$size$path';
  }

  static String getBackdropUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl$backdropSize$path';
  }
}

/// App-wide string constants
class AppStrings {
  AppStrings._();

  static const String appName = 'Movies DB';
  static const String trending = 'Trending';
  static const String nowPlaying = 'Now Playing';
  static const String bookmarks = 'Bookmarks';
  static const String search = 'Search';
  static const String home = 'Home';
  static const String seeAll = 'See All';
  static const String noResults = 'No results found';
  static const String searchHint = 'Search for movies...';
  static const String noBookmarks = 'No bookmarked movies yet';
  static const String addToBookmarks = 'Add to Bookmarks';
  static const String removeFromBookmarks = 'Remove from Bookmarks';
  static const String share = 'Share';
  static const String overview = 'Overview';
  static const String cast = 'Cast';
  static const String similarMovies = 'Similar Movies';
  static const String offlineMode = 'You are offline. Showing cached data.';
  static const String errorLoading = 'Error loading data';
  static const String retry = 'Retry';
}

/// Database constants
class DbConstants {
  DbConstants._();

  static const String databaseName = 'movies_db.db';
  static const int databaseVersion = 1;

  // Table names
  static const String moviesTable = 'movies';
  static const String bookmarksTable = 'bookmarks';
  static const String trendingTable = 'trending_movies';
  static const String nowPlayingTable = 'now_playing_movies';
}

/// Deep link constants
class DeepLinkConstants {
  DeepLinkConstants._();

  static const String scheme = 'moviesdb';
  static const String host = 'movie';

  // Example: moviesdb://movie/123
  static String createMovieLink(int movieId) {
    return '$scheme://$host/$movieId';
  }

  static int? parseMovieId(Uri uri) {
    if (uri.scheme == scheme && uri.host == host && uri.pathSegments.isNotEmpty) {
      return int.tryParse(uri.pathSegments.first);
    }
    return null;
  }
}