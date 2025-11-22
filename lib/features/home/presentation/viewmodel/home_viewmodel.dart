import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:movies_db/features/bookmarks/presentation/viewmodel/bookmarks_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../../../core/base/base_viewmodel.dart';
import '../../../../core/models/movie.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/repository/movie_repository.dart';

class HomeViewModel extends BaseViewModel {
  final MovieRepository _repository;
  final ConnectivityService _connectivityService;

  List<Movie> _trendingMovies = [];
  List<Movie> _nowPlayingMovies = [];
  bool _isOffline = false;
  int forceLoad = 5;

  StreamSubscription? _connectivitySubscription;

  HomeViewModel({
    required MovieRepository repository,
    required ConnectivityService connectivityService,
  })  : _repository = repository,
        _connectivityService = connectivityService {
    _listenToConnectivity();
  }

  // Getters
  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get nowPlayingMovies => _nowPlayingMovies;
  bool get isOffline => _isOffline;

  bool get hasData =>
      _trendingMovies.isNotEmpty || _nowPlayingMovies.isNotEmpty;

  /// Listen to connectivity changes
  void _listenToConnectivity() {
    _connectivitySubscription = _connectivityService.connectionStatus.listen(
          (isConnected) {
        final wasOffline = _isOffline;
        _isOffline = !isConnected;
        notifyListeners();

        // Refresh data when coming back online
        if (wasOffline && isConnected) {
          loadMovies(forceRefresh: true);
        }
      },
    );
  }

  /// Load all movies data
  Future<void> loadMovies({bool forceRefresh = false}) async {
    if (isLoading && !forceRefresh) return;

    setLoading();
    _isOffline = !(await _repository.isOnline());

    try {

      // Load both lists concurrently
      final results = await Future.wait([
        _repository.getTrendingMovies(forceRefresh: forceRefresh),
        _repository.getNowPlayingMovies(forceRefresh: forceRefresh),
      ]);

      _trendingMovies = results[0];
      _nowPlayingMovies = results[1];

      print("_trendingMovies: $_trendingMovies");
      print("_nowPlayingMovies: $_nowPlayingMovies");

      notifyListeners();

      if (_trendingMovies.isEmpty || _nowPlayingMovies.isEmpty) {
        if(forceLoad > 0) {
          forceLoad = forceLoad - 1;
          await Future.delayed(const Duration(seconds: 1),(){
            return loadMovies(forceRefresh: true);
          });
        }
      } else {
        setSuccess();
      }
    } catch (e) {
      setError(e.toString());
    }
  }

  /// Refresh movies data
  Future<void> refresh() async {
    await loadMovies(forceRefresh: true);
  }

  /// Toggle bookmark for a movie
  Future<void> toggleBookmark(BuildContext context, Movie movie) async {
    try {
      final isNowBookmarked = await _repository.toggleBookmark(movie);

      // Update in trending list
      final trendingIndex = _trendingMovies.indexWhere((m) => m.id == movie.id);
      if (trendingIndex != -1) {
        _trendingMovies[trendingIndex] =
            _trendingMovies[trendingIndex].copyWith(isBookmarked: isNowBookmarked);
      }

      // Update in now playing list
      final nowPlayingIndex =
      _nowPlayingMovies.indexWhere((m) => m.id == movie.id);
      if (nowPlayingIndex != -1) {
        _nowPlayingMovies[nowPlayingIndex] =
            _nowPlayingMovies[nowPlayingIndex].copyWith(isBookmarked: isNowBookmarked);
      }

      notifyListeners();

      Provider.of<BookmarksViewModel>(context, listen: false).loadBookmarks();

    } catch (e) {
      debugPrint('Error toggling bookmark: $e');
    }
  }

  /// Update bookmark status for a specific movie ID
  void updateMovieBookmarkStatus(int movieId, bool isBookmarked) {
    final trendingIndex = _trendingMovies.indexWhere((m) => m.id == movieId);
    if (trendingIndex != -1) {
      _trendingMovies[trendingIndex] =
          _trendingMovies[trendingIndex].copyWith(isBookmarked: isBookmarked);
    }

    final nowPlayingIndex = _nowPlayingMovies.indexWhere((m) => m.id == movieId);
    if (nowPlayingIndex != -1) {
      _nowPlayingMovies[nowPlayingIndex] =
          _nowPlayingMovies[nowPlayingIndex].copyWith(isBookmarked: isBookmarked);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}