# Movies DB - Flutter Application

A comprehensive Movies Database application built with Flutter using TMDB API. This app showcases trending and now playing movies, allows users to search, bookmark movies, and share them via deep links.

## 📱 Features

### Core Features
- **Home Page**: Displays trending movies (carousel) and now playing movies (horizontal list)
- **Movie Details**: Detailed view with backdrop, poster, rating, runtime, genres, overview, cast, and similar movies
- **Bookmarks**: Save favorite movies locally for offline access
- **Search**: Search movies with debounced search-as-you-type functionality (Bonus Task)
- **Offline Support**: All data is cached locally using SQLite database
- **Share & Deep Links**: Share movies with custom deep links (Bonus Task)

### Technical Highlights
- **Architecture**: MVVM (Model-View-ViewModel) with Repository Pattern
- **Networking**: Retrofit (Dio) for API calls
- **Local Database**: SQLite (sqflite) for offline caching
- **State Management**: Provider with ChangeNotifier
- **Dependency Injection**: GetIt service locator

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── base/
│   │   └── base_viewmodel.dart        # Base ViewModel with common state management
│   ├── constants/
│   │   └── api_constants.dart         # API URLs, endpoints, and app strings
│   ├── database/
│   │   └── database_helper.dart       # SQLite database operations
│   ├── di/
│   │   └── injection_container.dart   # Dependency injection setup
│   ├── models/
│   │   ├── movie.dart                 # Movie model
│   │   ├── movie_details.dart         # Detailed movie model
│   │   └── cast.dart                  # Cast & Crew models
│   ├── navigation/
│   │   ├── app_router.dart            # Route management
│   │   └── deep_link_handler.dart     # Deep link handling
│   ├── network/
│   │   ├── api_service.dart           # Retrofit API service
│   │   ├── dio_client.dart            # Dio configuration
│   │   └── connectivity_service.dart  # Network status monitoring
│   ├── repository/
│   │   └── movie_repository.dart      # Data repository (API + Local DB)
│   └── theme/
│       └── app_theme.dart             # App theming
├── features/
│   ├── home/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── main_page.dart     # Bottom navigation container
│   │       │   └── home_page.dart     # Home screen
│   │       └── viewmodel/
│   │           └── home_viewmodel.dart
│   ├── search/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── search_page.dart   # Search screen
│   │       └── viewmodel/
│   │           └── search_viewmodel.dart
│   ├── bookmarks/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── bookmarks_page.dart
│   │       └── viewmodel/
│   │           └── bookmarks_viewmodel.dart
│   ├── movie_details/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── movie_details_page.dart
│   │       ├── widgets/
│   │       │   ├── cast_list.dart
│   │       │   └── movie_info_row.dart
│   │       └── viewmodel/
│   │           └── movie_details_viewmodel.dart
│   ├── movies_list/
│   │   └── presentation/
│   │       └── pages/
│   │           └── movies_list_page.dart
│   └── shared/
│       └── widgets/
│           ├── movie_card.dart
│           ├── movie_carousel.dart
│           ├── movie_list_item.dart
│           ├── movie_grid_item.dart
│           ├── section_header.dart
│           ├── loading_widget.dart
│           ├── error_widget.dart
│           └── empty_state_widget.dart
```

## 🚀 Setup Instructions

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- TMDB API Key

### Step 1: Get TMDB API Key
1. Go to [TMDB Website](https://www.themoviedb.org/)
2. Create an account or log in
3. Go to Settings > API
4. Request an API key (choose Developer option)
5. Copy your API key

### Step 2: Configure API Key
Open `lib/core/constants/api_constants.dart` and replace:
```dart
static const String apiKey = 'YOUR_TMDB_API_KEY_HERE';
```

### Step 3: Install Dependencies
```bash
flutter pub get
```

### Step 4: Generate Code (Retrofit & JSON Serializable)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 5: Create Assets Folder
```bash
mkdir -p assets/images
```

### Step 6: Run the App
```bash
# For Android
flutter run

# For iOS
cd ios && pod install && cd ..
flutter run
```

## 📋 Tasks Completed

| # | Task | Status |
|---|------|--------|
| 1 | Home page with trending and now playing movies | ✅ |
| 2 | Movie details page with navigation | ✅ |
| 3 | Bookmark movies with saved movies page | ✅ |
| 4 | Offline support with local database | ✅ |
| 5 | Search tab for movie search | ✅ |
| 6 | **BONUS**: Debounced search-as-you-type | ✅ |
| 7 | **BONUS**: Share movies with deep links | ✅ |

## 🔧 Specifications Met

| Specification | Implementation |
|--------------|----------------|
| Flutter Framework | ✅ Flutter 3.x |
| Retrofit for networking | ✅ Retrofit + Dio |
| Architecture (MVVM/MVP) | ✅ MVVM with Provider |
| Presentable UX | ✅ Dark theme, animations, smooth UI |
| Repository Pattern | ✅ MovieRepository |
| Local Database | ✅ SQLite (sqflite) |
| Android & iOS Compatible | ✅ Cross-platform |

## 🔗 Deep Link Testing

### Format
```
moviesdb://movie/{movieId}
```

### Testing on Android
```bash
adb shell am start -W -a android.intent.action.VIEW -d "moviesdb://movie/550" com.example.movies_db
```

### Testing on iOS
```bash
xcrun simctl openurl booted "moviesdb://movie/550"
```

## 📱 Screenshots

The app features:
- Dark theme with modern UI
- Animated movie carousel for trending movies
- Pull-to-refresh functionality
- Smooth page transitions
- Image caching for performance
- Offline indicator banner
- Swipe-to-delete for bookmarks

## 🛠️ Key Dependencies

```yaml
dependencies:
  provider: ^6.1.1          # State management
  dio: ^5.4.0               # HTTP client
  retrofit: ^4.0.3          # Type-safe REST client
  shared_preferences: ^2.5.3       # Local database
  get_it: ^7.6.4            # Dependency injection
  connectivity_plus: ^5.0.2 # Network monitoring
  cached_network_image: ^3.3.0 # Image caching
  share_plus: ^7.2.1        # Share functionality
  app_links: ^6.4.1         # Deep linking
```

## 📝 Notes

- The app automatically syncs data when coming back online
- Search implements 500ms debounce for optimal API usage
- All responses are cached in SQLite for offline access
- Bookmark data persists between app sessions
- The deep link format allows direct navigation to any movie

## 👨‍💻 Author

Built for Flutter Interview Assessment

---

**Good luck with your interview! 🎬**