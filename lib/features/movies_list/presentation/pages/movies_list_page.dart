import 'package:flutter/material.dart';

import '../../../../core/models/movie.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../shared/widgets/movie_grid_item.dart';

class MoviesListPage extends StatelessWidget {
  final String title;
  final List<Movie> movies;

  const MoviesListPage({
    super.key,
    required this.title,
    required this.movies,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: movies.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 64,
              color: AppTheme.textHint.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No movies available',
              style: TextStyle(
                color: AppTheme.textHint,
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return MovieGridItem(
            movie: movie,
            onTap: () => AppRouter.navigateToMovieDetails(
              movie.id,
              movie: movie,
            ),
          );
        },
      ),
    );
  }
}