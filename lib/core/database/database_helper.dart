import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/api_constants.dart';
import '../models/movie.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _dbName = DbConstants.databaseName;
  static const int _dbVersion = DbConstants.databaseVersion;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Movies table - stores all movie data
    await db.execute('''
      CREATE TABLE ${DbConstants.moviesTable} (
        id INTEGER PRIMARY KEY,
        title TEXT,
        original_title TEXT,
        overview TEXT,
        poster_path TEXT,
        backdrop_path TEXT,
        release_date TEXT,
        vote_average REAL,
        vote_count INTEGER,
        popularity REAL,
        original_language TEXT,
        adult INTEGER,
        video INTEGER,
        is_bookmarked INTEGER DEFAULT 0,
        updated_at INTEGER
      )
    ''');

    // Trending movies junction table
    await db.execute('''
      CREATE TABLE ${DbConstants.trendingTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        movie_id INTEGER,
        position INTEGER,
        FOREIGN KEY (movie_id) REFERENCES ${DbConstants.moviesTable}(id)
      )
    ''');

    // Now playing movies junction table
    await db.execute('''
      CREATE TABLE ${DbConstants.nowPlayingTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        movie_id INTEGER,
        position INTEGER,
        FOREIGN KEY (movie_id) REFERENCES ${DbConstants.moviesTable}(id)
      )
    ''');

    // Bookmarks table
    await db.execute('''
      CREATE TABLE ${DbConstants.bookmarksTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        movie_id INTEGER UNIQUE,
        bookmarked_at INTEGER,
        FOREIGN KEY (movie_id) REFERENCES ${DbConstants.moviesTable}(id)
      )
    ''');

    // Create indexes for better query performance
    await db.execute(
        'CREATE INDEX idx_movies_id ON ${DbConstants.moviesTable}(id)');
    await db.execute(
        'CREATE INDEX idx_trending_movie ON ${DbConstants.trendingTable}(movie_id)');
    await db.execute(
        'CREATE INDEX idx_nowplaying_movie ON ${DbConstants.nowPlayingTable}(movie_id)');
    await db.execute(
        'CREATE INDEX idx_bookmarks_movie ON ${DbConstants.bookmarksTable}(movie_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < newVersion) {
      // Drop and recreate tables for simplicity
      await db.execute('DROP TABLE IF EXISTS ${DbConstants.trendingTable}');
      await db.execute('DROP TABLE IF EXISTS ${DbConstants.nowPlayingTable}');
      await db.execute('DROP TABLE IF EXISTS ${DbConstants.bookmarksTable}');
      await db.execute('DROP TABLE IF EXISTS ${DbConstants.moviesTable}');
      await _onCreate(db, newVersion);
    }
  }

  // ==================== Movie Operations ====================

  Future<void> insertMovie(Movie movie) async {
    final db = await database;
    await db.insert(
      DbConstants.moviesTable,
      {...movie.toDb(), 'updated_at': DateTime.now().millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertMovies(List<Movie> movies) async {
    final db = await database;
    final batch = db.batch();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    for (final movie in movies) {
      batch.insert(
        DbConstants.moviesTable,
        {...movie.toDb(), 'updated_at': timestamp},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<Movie?> getMovie(int id) async {
    final db = await database;
    final maps = await db.query(
      DbConstants.moviesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Movie.fromDb(maps.first);
  }

  // ==================== Trending Movies ====================

  Future<void> saveTrendingMovies(List<Movie> movies) async {
    final db = await database;

    // Insert movies first
    await insertMovies(movies);

    // Clear old trending data
    await db.delete(DbConstants.trendingTable);

    // Insert trending references
    final batch = db.batch();
    for (var i = 0; i < movies.length; i++) {
      batch.insert(DbConstants.trendingTable, {
        'movie_id': movies[i].id,
        'position': i,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Movie>> getTrendingMovies() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT m.*, 
             CASE WHEN b.movie_id IS NOT NULL THEN 1 ELSE 0 END as is_bookmarked
      FROM ${DbConstants.moviesTable} m
      INNER JOIN ${DbConstants.trendingTable} t ON m.id = t.movie_id
      LEFT JOIN ${DbConstants.bookmarksTable} b ON m.id = b.movie_id
      ORDER BY t.position ASC
    ''');

    return result.map((map) => Movie.fromDb(map)).toList();
  }

  // ==================== Now Playing Movies ====================

  Future<void> saveNowPlayingMovies(List<Movie> movies) async {
    final db = await database;

    // Insert movies first
    await insertMovies(movies);

    // Clear old now playing data
    await db.delete(DbConstants.nowPlayingTable);

    // Insert now playing references
    final batch = db.batch();
    for (var i = 0; i < movies.length; i++) {
      batch.insert(DbConstants.nowPlayingTable, {
        'movie_id': movies[i].id,
        'position': i,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Movie>> getNowPlayingMovies() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT m.*, 
             CASE WHEN b.movie_id IS NOT NULL THEN 1 ELSE 0 END as is_bookmarked
      FROM ${DbConstants.moviesTable} m
      INNER JOIN ${DbConstants.nowPlayingTable} np ON m.id = np.movie_id
      LEFT JOIN ${DbConstants.bookmarksTable} b ON m.id = b.movie_id
      ORDER BY np.position ASC
    ''');

    return result.map((map) => Movie.fromDb(map)).toList();
  }

  // ==================== Bookmark Operations ====================

  Future<void> addBookmark(int movieId) async {
    final db = await database;
    await db.insert(
      DbConstants.bookmarksTable,
      {
        'movie_id': movieId,
        'bookmarked_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Update movie bookmark status
    await db.update(
      DbConstants.moviesTable,
      {'is_bookmarked': 1},
      where: 'id = ?',
      whereArgs: [movieId],
    );
  }

  Future<void> removeBookmark(int movieId) async {
    final db = await database;
    await db.delete(
      DbConstants.bookmarksTable,
      where: 'movie_id = ?',
      whereArgs: [movieId],
    );

    // Update movie bookmark status
    await db.update(
      DbConstants.moviesTable,
      {'is_bookmarked': 0},
      where: 'id = ?',
      whereArgs: [movieId],
    );
  }

  Future<bool> isBookmarked(int movieId) async {
    final db = await database;
    final result = await db.query(
      DbConstants.bookmarksTable,
      where: 'movie_id = ?',
      whereArgs: [movieId],
    );
    return result.isNotEmpty;
  }

  Future<List<Movie>> getBookmarkedMovies() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT m.*, 1 as is_bookmarked
      FROM ${DbConstants.moviesTable} m
      INNER JOIN ${DbConstants.bookmarksTable} b ON m.id = b.movie_id
      ORDER BY b.bookmarked_at DESC
    ''');

    return result.map((map) => Movie.fromDb(map)).toList();
  }

  // ==================== Search ====================

  Future<List<Movie>> searchMoviesLocally(String query) async {
    final db = await database;
    final searchTerm = '%$query%';
    final result = await db.rawQuery('''
      SELECT m.*, 
             CASE WHEN b.movie_id IS NOT NULL THEN 1 ELSE 0 END as is_bookmarked
      FROM ${DbConstants.moviesTable} m
      LEFT JOIN ${DbConstants.bookmarksTable} b ON m.id = b.movie_id
      WHERE m.title LIKE ? OR m.original_title LIKE ?
      ORDER BY m.popularity DESC
      LIMIT 50
    ''', [searchTerm, searchTerm]);

    return result.map((map) => Movie.fromDb(map)).toList();
  }

  // ==================== Utility ====================

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(DbConstants.trendingTable);
    await db.delete(DbConstants.nowPlayingTable);
    await db.delete(DbConstants.bookmarksTable);
    await db.delete(DbConstants.moviesTable);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}