import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movies_db/features/bookmarks/presentation/viewmodel/bookmarks_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/movie.dart';
import '../../../core/theme/app_theme.dart';

class MovieListItem extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;
  final bool showBookmarkIcon;

  const MovieListItem({
    super.key,
    required this.movie,
    this.onTap,
    this.onBookmarkTap,
    this.showBookmarkIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final isBookmarked = context.watch<BookmarksViewModel>().isMovieBookmarked(movie.id);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: movie.posterPath != null
                  ? CachedNetworkImage(
                imageUrl: ApiConstants.getPosterUrl(
                  movie.posterPath,
                  size: ApiConstants.posterSizeSmall,
                ),
                width: 70,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (_, __) => _buildPlaceholder(),
                errorWidget: (_, __, ___) => _buildPlaceholder(),
              )
                  : _buildPlaceholder(),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.displayTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (movie.year.isNotEmpty) ...[
                    Text(
                      movie.year,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                  ],
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        movie.formattedRating,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (movie.overview != null && movie.overview!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      movie.overview!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textHint,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Bookmark button
            if (showBookmarkIcon)
              IconButton(
                onPressed: onBookmarkTap,
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  color: isBookmarked
                      ? AppTheme.accentColor
                      : AppTheme.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 70,
      height: 100,
      color: AppTheme.surfaceColor,
      child: const Icon(
        Icons.movie,
        color: AppTheme.textHint,
        size: 24,
      ),
    );
  }
}