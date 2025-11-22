import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movies_db/features/bookmarks/presentation/viewmodel/bookmarks_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/movie.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/deep_link_handler.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/movie_card.dart';
import '../viewmodel/movie_details_viewmodel.dart';
import '../widgets/cast_list.dart';
import '../widgets/movie_info_row.dart';

class MovieDetailsPage extends StatefulWidget {
  final int movieId;
  final Movie? movie;

  const MovieDetailsPage({
    super.key,
    required this.movieId,
    this.movie,
  });

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieDetailsViewModel>().loadMovieDetails(widget.movieId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MovieDetailsViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading || viewModel.movieDetails == null) {
            return _buildLoadingWithPlaceholder();
          }

          if (viewModel.isError && viewModel.movieDetails == null) {
            return Scaffold(
              appBar: AppBar(),
              body: AppErrorWidget(
                message: viewModel.errorMessage ?? AppStrings.errorLoading,
                onRetry: viewModel.refresh,
              ),
            );
          }

          return _buildContent(viewModel);
        },
      ),
    );
  }

  Widget _buildLoadingWithPlaceholder() {
    // Show placeholder with movie poster if available
    if (widget.movie != null) {
      return CustomScrollView(
        slivers: [
          _buildAppBar(null),
          const SliverFillRemaining(child: LoadingWidget()),
        ],
      );
    }
    return const LoadingWidget();
  }

  Widget _buildContent(MovieDetailsViewModel viewModel) {
    final details = viewModel.movieDetails!;

    return CustomScrollView(
      slivers: [
        _buildAppBar(viewModel),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(details, viewModel),
              _buildOverview(details),
              if (viewModel.hasCast) CastList(cast: viewModel.cast),
              if (viewModel.hasSimilarMovies)
                _buildSimilarMovies(viewModel.similarMovies),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(MovieDetailsViewModel? viewModel) {
    final backdropPath = viewModel?.movieDetails?.backdropPath ??
        widget.movie?.backdropPath;
    final posterPath = viewModel?.movieDetails?.posterPath ??
        widget.movie?.posterPath;

    final isBookmarked = context.watch<BookmarksViewModel>().isMovieBookmarked(widget.movieId);

    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (backdropPath != null)
              CachedNetworkImage(
                imageUrl: ApiConstants.getBackdropUrl(backdropPath),
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppTheme.cardColor),
                errorWidget: (_, __, ___) => posterPath != null
                    ? CachedNetworkImage(
                  imageUrl: ApiConstants.getPosterUrl(posterPath),
                  fit: BoxFit.cover,
                )
                    : Container(color: AppTheme.cardColor),
              )
            else
              Container(color: AppTheme.cardColor),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (viewModel != null) ...[
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: isBookmarked ? AppTheme.accentColor : null,
            ),
            onPressed: () {
              final movie = viewModel.createMovieFromDetails();
              if (movie != null) viewModel.toggleBookmark(context, movie);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareMovie(viewModel),
          ),
        ],
      ],
    );
  }

  Widget _buildHeader(details, MovieDetailsViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: ApiConstants.getPosterUrl(details.posterPath),
              width: 120,
              height: 180,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 120,
                height: 180,
                color: AppTheme.cardColor,
              ),
              errorWidget: (_, __, ___) => Container(
                width: 120,
                height: 180,
                color: AppTheme.cardColor,
                child: const Icon(Icons.movie, size: 40),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.displayTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (details.tagline != null && details.tagline!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    details.tagline!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                MovieInfoRow(
                  icon: Icons.star,
                  iconColor: Colors.amber,
                  text: '${details.formattedRating}/10',
                ),
                if (details.releaseDate != null) ...[
                  const SizedBox(height: 8),
                  MovieInfoRow(
                    icon: Icons.calendar_today,
                    text: details.year,
                  ),
                ],
                if (details.formattedRuntime.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  MovieInfoRow(
                    icon: Icons.access_time,
                    text: details.formattedRuntime,
                  ),
                ],
                if (details.genresString.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(details.genres.take(3).length, (index){
                      final genre = details.genres[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          genre.name,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(details) {
    if (details.overview == null || details.overview!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.overview,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            details.overview!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarMovies(List<Movie> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.similarMovies,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: movies.take(10).length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: MovieCard(
                  movie: movie,
                  width: 130,
                  onTap: () => AppRouter.navigateToMovieDetails(
                    movie.id,
                    movie: movie,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _shareMovie(MovieDetailsViewModel viewModel) {
    final details = viewModel.movieDetails;
    if (details == null) return;

    final deepLink = DeepLinkHandler.createMovieDeepLink(details.id);
    final shareText = 'Check out "${details.displayTitle}"!\n\n'
        '⭐ ${details.formattedRating}/10\n'
        '📅 ${details.year}\n\n'
        'Open in Movies DB: $deepLink';

    Share.share(shareText, subject: details.displayTitle);
  }
}