import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/movie.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/movie_card.dart';
import '../../../shared/widgets/movie_carousel.dart';
import '../../../shared/widgets/section_header.dart';
import '../viewmodel/home_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            onRefresh: viewModel.refresh,
            color: AppTheme.primaryColor,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(viewModel),
                if (viewModel.isOffline) _buildOfflineBanner(),
                if (viewModel.isLoading && !viewModel.hasData)
                  const SliverFillRemaining(child: LoadingWidget())
                else if (viewModel.isError && !viewModel.hasData)
                  SliverFillRemaining(
                    child: AppErrorWidget(
                      message: viewModel.errorMessage ?? AppStrings.errorLoading,
                      onRetry: viewModel.refresh,
                    ),
                  )
                else ...[
                    _buildTrendingSection(viewModel),
                    _buildNowPlayingSection(viewModel),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(HomeViewModel viewModel) {
    return SliverAppBar(
      floating: true,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.movie, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            AppStrings.appName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
      actions: [
        if (viewModel.isLoading && viewModel.hasData)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }

  Widget _buildOfflineBanner() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: AppTheme.accentColor.withOpacity(0.2),
        child: Row(
          children: [
            Icon(Icons.wifi_off,
                color: AppTheme.accentColor.withOpacity(0.8), size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                AppStrings.offlineMode,
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection(HomeViewModel viewModel) {
    if (viewModel.trendingMovies.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: AppStrings.trending,
            onSeeAll: () => AppRouter.navigateToMoviesList(
              AppStrings.trending,
              viewModel.trendingMovies,
            ),
          ),
          MovieCarousel(
            movies: viewModel.trendingMovies.take(10).toList(),
            onMovieTap: (movie) => _navigateToDetails(movie),
            onBookmarkTap: (movie) => viewModel.toggleBookmark(context, movie),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlayingSection(HomeViewModel viewModel) {
    if (viewModel.nowPlayingMovies.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          SectionHeader(
            title: AppStrings.nowPlaying,
            onSeeAll: () => AppRouter.navigateToMoviesList(
              AppStrings.nowPlaying,
              viewModel.nowPlayingMovies,
            ),
          ),
          _buildNowPlayingList(viewModel),
        ],
      ),
    );
  }

  Widget _buildNowPlayingList(HomeViewModel viewModel) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: viewModel.nowPlayingMovies.take(10).length,
        itemBuilder: (context, index) {
          final movie = viewModel.nowPlayingMovies[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: MovieCard(
              movie: movie,
              width: 130,
              onTap: () => _navigateToDetails(movie),
              onBookmarkTap: () => viewModel.toggleBookmark(context, movie),
            ),
          );
        },
      ),
    );
  }

  void _navigateToDetails(Movie movie) {
    AppRouter.navigateToMovieDetails(movie.id, movie: movie);
  }
}