import 'package:get_it/get_it.dart';

import '../database/database_helper.dart';
import '../navigation/deep_link_handler.dart';
import '../network/api_service.dart';
import '../network/connectivity_service.dart';
import '../network/dio_client.dart';
import '../repository/movie_repository.dart';
import '../../features/bookmarks/presentation/viewmodel/bookmarks_viewmodel.dart';
import '../../features/home/presentation/viewmodel/home_viewmodel.dart';
import '../../features/movie_details/presentation/viewmodel/movie_details_viewmodel.dart';
import '../../features/search/presentation/viewmodel/search_viewmodel.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==================== Core ====================

  // Database
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // Network
  sl.registerLazySingleton(() => DioClient.createDio());
  sl.registerLazySingleton<ApiService>(() => ApiService(sl()));
  sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  // ==================== Repository ====================

  sl.registerLazySingleton<MovieRepository>(
        () => MovieRepository(
      apiService: sl(),
      databaseHelper: sl(),
      connectivityService: sl(),
    ),
  );

  // ==================== Navigation ====================

  sl.registerLazySingleton<DeepLinkHandler>(() => DeepLinkHandler());

  // ==================== ViewModels ====================

  sl.registerFactory<HomeViewModel>(
        () => HomeViewModel(repository: sl(), connectivityService: sl()),
  );

  sl.registerFactory<SearchViewModel>(
        () => SearchViewModel(repository: sl()),
  );

  sl.registerFactory<BookmarksViewModel>(
        () => BookmarksViewModel(repository: sl()),
  );

  sl.registerFactory<MovieDetailsViewModel>(
        () => MovieDetailsViewModel(repository: sl()),
  );
}