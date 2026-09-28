import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:movie_app/Models/movie.dart';

class TmdbException implements Exception {
  final String message;
  TmdbException(this.message);
  @override
  String toString() => message;
}

class TmdbService {
  static final dotenv.DotEnv _dotenv = dotenv.DotEnv()..load(['.env']);
  static String get _apiKey => _dotenv['TMDB_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  void _checkKey() {
    if (_apiKey.isEmpty || _apiKey.contains('your_') || _apiKey.contains('paste_')) {
      throw TmdbException(
          'TMDB API key is missing. Open the .env file in the project root '
          'and set TMDB_API_KEY to your real key from '
          'themoviedb.org/settings/api');
    }
  }

  Future<List<Movie>> _getMovieList(String endpoint, {int page = 1}) async {
    _checkKey();
    final uri = Uri.parse(
        '$_baseUrl/$endpoint?api_key=$_apiKey&language=en-US&page=$page');

    late http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 15));
    } catch (_) {
      throw TmdbException('No internet connection. Please try again.');
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'] ?? [];
      return results.map((e) => Movie.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw TmdbException('Invalid TMDB API key.');
    } else {
      throw TmdbException('TMDB error (${response.statusCode}). Please try again.');
    }
  }

  Future<List<Movie>> getPopular({int page = 1}) =>
      _getMovieList('movie/popular', page: page);

  Future<List<Movie>> getTopRated({int page = 1}) =>
      _getMovieList('movie/top_rated', page: page);

  Future<List<Movie>> getNowPlaying({int page = 1}) =>
      _getMovieList('movie/now_playing', page: page);

  Future<List<Movie>> getUpcoming({int page = 1}) =>
      _getMovieList('movie/upcoming', page: page);

  Future<Movie> getMovieDetails(int id) async {
    _checkKey();
    final uri = Uri.parse('$_baseUrl/movie/$id?api_key=$_apiKey&language=en-US');
    late http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 15));
    } catch (_) {
      throw TmdbException('No internet connection. Please try again.');
    }
    if (response.statusCode == 200) {
      return Movie.fromJson(jsonDecode(response.body));
    }
    throw TmdbException('Could not load movie details.');
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];
    _checkKey();
    final uri = Uri.parse(
        '$_baseUrl/search/movie?api_key=$_apiKey&language=en-US&query=${Uri.encodeComponent(query)}&page=$page');
    late http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 15));
    } catch (_) {
      throw TmdbException('No internet connection. Please try again.');
    }
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'] ?? [];
      return results.map((e) => Movie.fromJson(e)).toList();
    }
    throw TmdbException('Search failed. Please try again.');
  }
}