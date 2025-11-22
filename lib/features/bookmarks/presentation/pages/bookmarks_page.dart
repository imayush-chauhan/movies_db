import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/movie_list_item.dart';
import '../viewmodel/bookmarks_viewmodel.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookmarksViewModel>().loadBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.bookmarks),
        actions: [
          Consumer<BookmarksViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.hasBookmarks) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${viewModel.bookmarkCount}',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<BookmarksViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const LoadingWidget();
          }

          if (viewModel.isEmpty || !viewModel.hasBookmarks) {
            return EmptyStateWidget(
              icon: Icons.bookmark_outline,
              title: AppStrings.noBookmarks,
              subtitle: 'Start adding movies to your bookmarks',
            );
          }

          return RefreshIndicator(
            onRefresh: viewModel.refresh,
            color: AppTheme.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.bookmarkedMovies.length,
              itemBuilder: (context, index) {
                final movie = viewModel.bookmarkedMovies[index];
                return Dismissible(
                  key: Key(movie.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) => viewModel.removeBookmark(movie),
                  confirmDismiss: (_) => _confirmDelete(context),
                  child: MovieListItem(
                    movie: movie,
                    onTap: () => AppRouter.navigateToMovieDetails(
                      movie.id,
                      movie: movie,
                    ),
                    onBookmarkTap: () => viewModel.removeBookmark(movie),
                    showBookmarkIcon: false,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Remove Bookmark'),
        content: const Text(
          'Are you sure you want to remove this movie from bookmarks?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    ) ??
        false;
  }
}