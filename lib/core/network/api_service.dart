import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../constants/api_constants.dart';
import '../models/cast.dart';
import '../models/movie.dart';
import '../models/movie_details.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @GET(ApiConstants.trendingMovies)
  Future<MoviesResponse> getTrendingMovies({
    @Query('page') int page = 1,
  });

  @GET(ApiConstants.nowPlayingMovies)
  Future<MoviesResponse> getNowPlayingMovies({
    @Query('page') int page = 1,
  });

  @GET('${ApiConstants.movieDetails}/{movie_id}')
  Future<MovieDetails> getMovieDetails({
    @Path('movie_id') required int movieId,
  });

  @GET('${ApiConstants.movieDetails}/{movie_id}/credits')
  Future<CreditsResponse> getMovieCredits({
    @Path('movie_id') required int movieId,
  });

  @GET('${ApiConstants.movieDetails}/{movie_id}/similar')
  Future<MoviesResponse> getSimilarMovies({
    @Path('movie_id') required int movieId,
    @Query('page') int page = 1,
  });

  @GET(ApiConstants.searchMovies)
  Future<MoviesResponse> searchMovies({
    @Query('query') required String query,
    @Query('page') int page = 1,
  });
}