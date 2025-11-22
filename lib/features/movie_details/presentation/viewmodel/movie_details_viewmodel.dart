import 'package:flutter/cupertino.dart';
import 'package:movies_db/features/bookmarks/presentation/viewmodel/bookmarks_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../../../core/base/base_viewmodel.dart';
import '../../../../core/models/cast.dart';
import '../../../../core/models/movie.dart';
import '../../../../core/models/movie_details.dart';
import '../../../../core/repository/movie_repository.dart';

class MovieDetailsViewModel extends BaseViewModel {
  final MovieRepository _repository;

  MovieDetails? _movieDetails;
  List<Cast> _cast = [];
  List<Movie> _similarMovies = [];
  bool _isBookmarked = false;
  int? _currentMovieId;

  MovieDetailsViewModel({required MovieRepository repository})
      : _repository = repository;

  // Getters
  MovieDetails? get movieDetails => _movieDetails;
  List<Cast> get cast => _cast;
  List<Movie> get similarMovies => _similarMovies;
  bool get isBookmarked => _isBookmarked;
  int? get currentMovieId => _currentMovieId;

  bool get hasCast => _cast.isNotEmpty;
  bool get hasSimilarMovies => _similarMovies.isNotEmpty;

  /// Load movie details
  Future<void> loadMovieDetails(int movieId) async {
    if (_currentMovieId == movieId && _movieDetails != null) {
      return; // Already loaded
    }

    _currentMovieId = movieId;
    setLoading();

    try {
      // Load bookmark status first
      _isBookmarked = await _repository.isBookmarked(movieId);

      // Load all data concurrently
      final results = await Future.wait([
        _repository.getMovieDetails(movieId),
        _repository.getMovieCredits(movieId),
        _repository.getSimilarMovies(movieId),
      ]);

      _movieDetails = results[0] as MovieDetails?;

      final credits = results[1] as CreditsResponse?;
      _cast = credits?.cast.take(20).toList() ?? [];

      _similarMovies = results[2] as List<Movie>? ?? [];

      if (_movieDetails == null) {
        setError('Movie not found');
      } else {
        setSuccess();
      }
    } catch (e) {
      setError(e.toString());
    }
  }

  /// Toggle bookmark status
  Future<void> toggleBookmark(BuildContext context, Movie movie) async {
    try {
      _isBookmarked = await _repository.toggleBookmark(movie);
      notifyListeners();

      Provider.of<BookmarksViewModel>(context, listen: false).loadBookmarks();
    } catch (e) {
      debugPrint('Error toggling bookmark: $e');
    }
  }

  /// Create a Movie object from MovieDetails for bookmarking
  Movie? createMovieFromDetails() {
    if (_movieDetails == null) return null;

    return Movie(
      id: _movieDetails!.id,
      title: _movieDetails!.title,
      originalTitle: _movieDetails!.originalTitle,
      overview: _movieDetails!.overview,
      posterPath: _movieDetails!.posterPath,
      backdropPath: _movieDetails!.backdropPath,
      releaseDate: _movieDetails!.releaseDate,
      voteAverage: _movieDetails!.voteAverage,
      voteCount: _movieDetails!.voteCount,
      popularity: _movieDetails!.popularity,
      isBookmarked: _isBookmarked,
    );
  }

  /// Clear current movie data
  void clear() {
    _currentMovieId = null;
    _movieDetails = null;
    _cast = [];
    _similarMovies = [];
    _isBookmarked = false;
    setIdle();
  }

  /// Refresh movie details
  Future<void> refresh() async {
    if (_currentMovieId != null) {
      _movieDetails = null;
      await loadMovieDetails(_currentMovieId!);
    }
  }
}