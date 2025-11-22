import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import '../constants/api_constants.dart';
import 'app_router.dart';

class DeepLinkHandler {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  bool _initialHandled = false;

  Future<void> initDeepLinks() async {
    await _handleInitialUri();

    _linkSubscription = _appLinks.uriLinkStream.listen(
          (uri) => _handleDeepLink(uri),
      onError: (err) => debugPrint("Deep link error: $err"),
    );
  }

  Future<void> _handleInitialUri() async {
    if (_initialHandled) return;
    _initialHandled = true;

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleDeepLink(initialUri);
        });
      }
    } catch (e) {
      debugPrint("Initial deep link error: $e");
    }
  }

  void _handleDeepLink(Uri uri) {
    debugPrint("Handling deep link: $uri");

    final movieId = DeepLinkConstants.parseMovieId(uri);
    if (movieId != null) {
      AppRouter.navigateToMovieDetails(movieId);
    }
  }

  static String createMovieDeepLink(int movieId) {
    // If using HTTPS URL based deep linking
    return "https://moviesdb.com/movie/$movieId";

    // OR if using custom scheme (development)
    // return "moviesdb://movie/$movieId";
  }

  static int? parseMovieId(Uri uri) {
    if (uri.pathSegments.contains('movie')) {
      final idIndex = uri.pathSegments.indexOf('movie') + 1;
      if (idIndex < uri.pathSegments.length) {
        return int.tryParse(uri.pathSegments[idIndex]);
      }
    }
    return null;
  }


  void dispose() {
    _linkSubscription?.cancel();
  }
}
