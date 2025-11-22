import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/injection_container.dart' as di;
import 'core/navigation/app_router.dart';
import 'core/navigation/deep_link_handler.dart';
import 'core/theme/app_theme.dart';
import 'features/bookmarks/presentation/viewmodel/bookmarks_viewmodel.dart';
import 'features/home/presentation/viewmodel/home_viewmodel.dart';
import 'features/movie_details/presentation/viewmodel/movie_details_viewmodel.dart';
import 'features/search/presentation/viewmodel/search_viewmodel.dart';

final deepLinkHandler = DeepLinkHandler();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await deepLinkHandler.initDeepLinks();
  await dotenv.load();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize dependency injection
  await di.init();

  runApp(const MoviesApp());
}

class MoviesApp extends StatefulWidget {
  const MoviesApp({super.key});

  @override
  State<MoviesApp> createState() => _MoviesAppState();
}

class _MoviesAppState extends State<MoviesApp> {
  final DeepLinkHandler _deepLinkHandler = di.sl<DeepLinkHandler>();

  @override
  void initState() {
    super.initState();
    _deepLinkHandler.initDeepLinks();
  }

  @override
  void dispose() {
    _deepLinkHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<HomeViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<SearchViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<BookmarksViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<MovieDetailsViewModel>()),
      ],
      child: MaterialApp(
        title: 'Movies DB',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        navigatorKey: AppRouter.navigatorKey,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRouter.main,
      ),
    );
  }
}