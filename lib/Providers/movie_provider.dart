import 'package:flutter/foundation.dart';
import 'package:movie_app/Models/movie.dart';
import 'package:movie_app/Services/tmdb_service.dart';

class MovieSection {
  List<Movie> movies = [];
  bool isLoading = false;
  String? error;
}

class MovieProvider extends ChangeNotifier {
  final TmdbService _tmdb = TmdbService();

  final MovieSection popular = MovieSection();
  final MovieSection topRated = MovieSection();
  final MovieSection nowPlaying = MovieSection();

  final MovieSection searchResults = MovieSection();

  Future<void> loadHome() async {
    await Future.wait([
      _load(popular, () => _tmdb.getPopular()),
      _load(topRated, () => _tmdb.getTopRated()),
      _load(nowPlaying, () => _tmdb.getNowPlaying()),
    ]);
  }

  Future<void> _load(
      MovieSection section, Future<List<Movie>> Function() fetch) async {
    section.isLoading = true;
    section.error = null;
    notifyListeners();
    try {
      section.movies = await fetch();
    } on TmdbException catch (e) {
      section.error = e.message;
    } catch (_) {
      section.error = 'Something went wrong. Please try again.';
    }
    section.isLoading = false;
    notifyListeners();
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      searchResults.movies = [];
      searchResults.error = null;
      notifyListeners();
      return;
    }
    await _load(searchResults, () => _tmdb.searchMovies(query));
  }

  Future<Movie> loadDetails(int id) => _tmdb.getMovieDetails(id);
}