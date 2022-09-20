import 'dart:convert';

import 'package:intl/intl.dart';

import 'Genre.dart';

class Detail {
  final int id;
  String? title;
  String? originalTitle;
  String? name;
  String? originalName;
  String? mediaType;
  final bool adult;
  final bool video;
  final String overview;
  final String posterPath;
  String? backdropPath;
  final double popularity;
  String? releaseDate;
  String? firstAirDate;
  final double voteAverage;
  final int voteCount;
  String? homepage;
  List<Genre> genres;
  final int runtime;

  Detail(
      {required this.name,
      required this.runtime,
      required this.homepage,
      required this.genres,
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

  factory Detail.fromJson(Map<String, dynamic> json) {
    print(json);
    var results = json["genres"];
    final parsed = results.cast<Map<String, dynamic>>();
    return Detail(
      id: json['id'] as int,
      title: json['title'],
      homepage: json['homepage'],
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
      runtime: json['runtime'],
      genres: parsed.map<Genre>((json) => Genre.fromJson(json)).toList(),
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

  String getDuration() {
    var d = Duration(minutes: runtime);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(1, '0')}h ${parts[1].padLeft(2, '0')}m';
  }
}
