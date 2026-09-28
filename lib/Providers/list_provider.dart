import 'package:flutter/foundation.dart';
import 'package:movie_app/Models/movie.dart';
import 'package:movie_app/Models/movie_list_item.dart';
import 'package:movie_app/Services/db_helper.dart';

class ListProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper.instance;
  final String userId;

  ListProvider(this.userId);

  final Map<ListType, bool> currentMovieStatus = {};

  Future<void> refreshStatus(int movieId) async {
    for (final type in ListType.values) {
      currentMovieStatus[type] = await _db.isInList(movieId, type, userId);
    }
    notifyListeners();
  }

  Future<void> toggle(Movie movie, ListType type) async {
    final isCurrentlyIn = currentMovieStatus[type] ?? false;
    if (isCurrentlyIn) {
      await _db.removeFromList(movie.id, type, userId);
    } else {
      await _db.addToList(MovieListItem(
        movieId: movie.id,
        title: movie.title,
        posterPath: movie.posterPath,
        listType: type,
        userId: userId,
      ));
    }
    currentMovieStatus[type] = !isCurrentlyIn;
    notifyListeners();
  }

  Future<List<MovieListItem>> getList(ListType type) {
    return _db.getList(type, userId);
  }
}