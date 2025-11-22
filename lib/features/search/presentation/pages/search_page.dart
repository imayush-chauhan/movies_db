import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/movie_list_item.dart';
import '../viewmodel/search_viewmodel.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Consumer<SearchViewModel>(
        builder: (context, viewModel, _) {
          return TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: viewModel.onSearchQueryChanged,
            decoration: InputDecoration(
              hintText: AppStrings.searchHint,
              prefixIcon: const Icon(Icons.search, color: AppTheme.textHint),
              suffixIcon: viewModel.hasQuery
                  ? IconButton(
                icon: const Icon(Icons.clear, color: AppTheme.textHint),
                onPressed: () {
                  _searchController.clear();
                  viewModel.clearSearch();
                },
              )
                  : null,
            ),
            style: const TextStyle(color: AppTheme.textPrimary),
            textInputAction: TextInputAction.search,
            onSubmitted: viewModel.search,
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return Consumer<SearchViewModel>(
      builder: (context, viewModel, _) {
        if (!viewModel.hasQuery) {
          return _buildInitialState();
        }

        if (viewModel.isLoading && !viewModel.hasResults) {
          return _buildLoadingState();
        }

        if (viewModel.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.search_off,
            title: AppStrings.noResults,
            subtitle: 'Try searching with different keywords',
          );
        }

        if (viewModel.isError && !viewModel.hasResults) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: 'Search failed',
            subtitle: viewModel.errorMessage ?? 'Please try again',
          );
        }

        return _buildResultsList(viewModel);
      },
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_filter,
            size: 80,
            color: AppTheme.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Search for movies',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.textHint.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find your favorite movies',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textHint.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return const _ShimmerSearchItem();
      },
    );
  }

  Widget _buildResultsList(SearchViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: viewModel.searchResults.length,
      itemBuilder: (context, index) {
        final movie = viewModel.searchResults[index];
        return MovieListItem(
          movie: movie,
          onTap: () => AppRouter.navigateToMovieDetails(movie.id, movie: movie),
          onBookmarkTap: () => viewModel.toggleBookmark(context, movie),
        );
      },
    );
  }
}

class _ShimmerSearchItem extends StatelessWidget {
  const _ShimmerSearchItem();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}