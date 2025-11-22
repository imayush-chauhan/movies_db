import 'package:flutter/material.dart';

import '../../features/home/presentation/pages/main_page.dart';
import '../../features/movie_details/presentation/pages/movie_details_page.dart';
import '../../features/movies_list/presentation/pages/movies_list_page.dart';
import '../models/movie.dart';

class AppRouter {
  AppRouter._();

  // Navigator key for accessing navigator from anywhere
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  // Route names
  static const String main = '/';
  static const String movieDetails = '/movie-details';
  static const String moviesList = '/movies-list';

  // Route generator
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case main:
        return _buildRoute(const MainPage(), settings);

      case movieDetails:
        final args = settings.arguments as MovieDetailsArguments;
        return _buildRoute(
          MovieDetailsPage(
            movieId: args.movieId,
            movie: args.movie,
          ),
          settings,
        );

      case moviesList:
        final args = settings.arguments as MoviesListArguments;
        return _buildRoute(
          MoviesListPage(
            title: args.title,
            movies: args.movies,
          ),
          settings,
        );

      default:
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
      Widget page,
      RouteSettings settings,
      ) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }

  // Navigation helpers
  static Future<T?> navigateTo<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  static void goBack<T>([T? result]) {
    navigatorKey.currentState!.pop<T>(result);
  }

  static Future<T?> navigateToMovieDetails<T>(int movieId, {Movie? movie}) {
    return navigateTo<T>(
      movieDetails,
      arguments: MovieDetailsArguments(movieId: movieId, movie: movie),
    );
  }

  static Future<T?> navigateToMoviesList<T>(String title, List<Movie> movies) {
    return navigateTo<T>(
      moviesList,
      arguments: MoviesListArguments(title: title, movies: movies),
    );
  }

  static void popUntilMain() {
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}

// Route arguments classes
class MovieDetailsArguments {
  final int movieId;
  final Movie? movie;

  MovieDetailsArguments({required this.movieId, this.movie});
}

class MoviesListArguments {
  final String title;
  final List<Movie> movies;

  MoviesListArguments({required this.title, required this.movies});
}