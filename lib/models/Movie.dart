import 'package:intl/intl.dart';

class Movie {
  final int id;
  String? title;
  String? originalTitle;
  String? name;
  String? originalName;
  String? mediaType;
  final bool adult;
  final bool? video;
  final String overview;
  final String posterPath;
  String? backdropPath;
  final double popularity;
  String? releaseDate;
  String? firstAirDate;
  final double voteAverage;
  final int voteCount;

  Movie(
      {required this.name,
      required this.firstAirDate,
      required this.originalName,
      required this.mediaType,
      required this.id,
      required this.title,
      required this.originalTitle,
      required this.adult,
      required this.video,
      required this.overview,
      required this.posterPath,
      required this.backdropPath,
      required this.popularity,
      required this.releaseDate,
      required this.voteAverage,
      required this.voteCount});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: json['title'],
      originalTitle: json['original_title'],
      adult: json['adult'],
      video: json['video'],
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      popularity: json['popularity'],
      releaseDate: json['release_date'],
      voteAverage: double.parse(json['vote_average'].toString()),
      voteCount: json['vote_count'] as int,
      name: json['name'],
      originalName: json['original_name'],
      mediaType: json['media_type'],
      firstAirDate: json['first_air_date'],
    );
  }

  String getFormattedDate() {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");

    DateTime dateTime = dateFormat
        .parse(releaseDate ?? firstAirDate ?? DateTime.now().toString());

    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  DateTime getReleaseDate() {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");

    DateTime dateTime = dateFormat
        .parse(releaseDate ?? firstAirDate ?? DateTime.now().toString());

    return dateTime;
  }
}
