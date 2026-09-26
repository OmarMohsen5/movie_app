enum ListType { favorite, watched, watching, wantToWatch }

extension ListTypeName on ListType {
  String get dbValue => toString().split('.').last;

  static ListType fromDb(String value) {
    return ListType.values.firstWhere((e) => e.dbValue == value);
  }
}

class MovieListItem {
  final int movieId;
  final String title;
  final String? posterPath;
  final ListType listType;
  final String userId;

  MovieListItem({
    required this.movieId,
    required this.title,
    required this.posterPath,
    required this.listType,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'movieId': movieId,
      'title': title,
      'posterPath': posterPath,
      'listType': listType.dbValue,
      'userId': userId,
    };
  }

  factory MovieListItem.fromMap(Map<String, dynamic> map) {
    return MovieListItem(
      movieId: map['movieId'],
      title: map['title'],
      posterPath: map['posterPath'],
      listType: ListTypeName.fromDb(map['listType']),
      userId: map['userId'],
    );
  }
}