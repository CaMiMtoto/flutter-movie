import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_movie/globals.dart';
import 'package:flutter_movie/models/Movie.dart';
import 'package:flutter_movie/screens/Home.dart';

import '../models/Cast.dart';
import 'package:http/http.dart' as http;

import '../models/Detail.dart';
import 'Discover.dart';

List<Cast> parseCasts(String responseBody) {
  var results = jsonDecode(responseBody)["cast"];
  final parsed = results.cast<Map<String, dynamic>>();
  return parsed.map<Cast>((json) => Cast.fromJson(json)).toList();
}

Future<List<Cast>> fetchCasts(int movieId) async {
  final response = await http
      .get(Uri.parse('${baseUrl}movie/$movieId/credits?api_key=$apiKey'));
  return compute(parseCasts, response.body);
}

Future<List<Movie>> fetchRecommendedMovies(int movieId) async {
  final response = await http.get(
      Uri.parse('${baseUrl}movie/$movieId/recommendations?api_key=$apiKey'));
  return compute(parseMovies, response.body);
}

Detail parseDetail(String responseBody) {
  var results = jsonDecode(responseBody);
  return Detail.fromJson(results);
}

Future<Detail> fetchMovieDetails(int movieId) async {
  final response =
      await http.get(Uri.parse('${baseUrl}movie/$movieId?api_key=$apiKey'));
  return compute(parseDetail, response.body);
}

class MovieDetail extends StatefulWidget {
  final int movieId;

  const MovieDetail({Key? key, required this.movieId}) : super(key: key);

  @override
  State<MovieDetail> createState() => _MovieDetailState(movieId: movieId);
}

class _MovieDetailState extends State<MovieDetail>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final int movieId;

  List<Cast> casts = [];
  bool castLoading = true;
  List<Movie> recommended = [];

  Detail? movie;

  _MovieDetailState({required this.movieId});

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    fetchCasts(movieId).then((value) {
      setState(() {
        casts = value;
        castLoading = false;
      });
    });

    fetchRecommendedMovies(movieId).then((value) {
      setState(() {
        recommended = value;
      });
    });

    fetchMovieDetails(movieId).then((value) {
      setState(() {
        movie = value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: movie == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  expandedHeight: 200,
                  flexibleSpace: FlexibleSpaceBar(
                    // title: const Text("Movie Detail"),
                    background: Image.network(
                      "$imageOriginalUrl${movie?.backdropPath ?? movie?.posterPath}",
                      fit: BoxFit.cover,
                    ),
                  ),
                  actions: const [
                    Icon(Icons.favorite_border),
                    SizedBox(
                      width: 16,
                    ),
                    Icon(Icons.more_vert),
                  ],
                ),
                SliverFillRemaining(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text("MOVIES",
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  const Text(
                                    '.',
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text("ACTION",
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    "${movie?.voteAverage.toStringAsFixed(1)}/10",
                                    style:
                                        TextStyle(color: Colors.grey.shade500),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Text(movie?.name ?? movie?.title ?? "",
                              style: const TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              movie?.releaseDate != ''
                                  ? Text(
                                      movie!.getReleaseDate().year.toString(),
                                      style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 16))
                                  : const SizedBox.shrink(),
                              movie!.adult
                                  ? Container(
                                      margin: const EdgeInsets.only(left: 16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(0),
                                        border: Border.all(
                                            color: Colors.grey.shade500),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Text(
                                        "18+",
                                        style: TextStyle(fontSize: 8),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              Container(
                                margin: const EdgeInsets.only(left: 16),
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  movie!.getDuration(),
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 16),
                                ),
                              ),
                              movie!.video
                                  ? Container(
                                      margin: const EdgeInsets.only(left: 16),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(0),
                                          color: Colors.grey.shade800),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      child: const Text(
                                        "HD",
                                        style: TextStyle(fontSize: 8),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          SizedBox(
                            height: 32,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: movie?.genres.length,
                              itemBuilder: (BuildContext context, int index) {
                                var genres = movie?.genres;
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return Discover(
                                        genreId: genres![index].id,
                                      );
                                    }));
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 16),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: Colors.grey.shade800),
                                    child: Text(genres![index].name),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(movie!.overview,
                              style: TextStyle(color: Colors.grey.shade500)),
                          const SizedBox(
                            height: 16,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: MaterialButton(
                              onPressed: () {},
                              color: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.play_arrow,
                                    size: 32,
                                  ),
                                  Text(
                                    "Play",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: MaterialButton(
                              onPressed: () {},
                              color: Colors.grey.shade800,
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.add,
                                    size: 32,
                                  ),
                                  Text(
                                    "Add to My List",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          const Text(
                            "Cast and Crew",
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          SizedBox(
                            height: 150,
                            child: castLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : ListView.builder(
                                    itemCount: casts.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return buildCastWidget(index);
                                    },
                                  ),
                          ),
                          const Text(
                            "MORE LIKE THIS",
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 18),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 160,
                              childAspectRatio: 0.6,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                            ),
                            itemCount: recommended.length,
                            physics: const ScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              var item = recommended[index];
                              return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return MovieDetail(movieId: item.id);
                                    }));
                                  },
                                  child: MovieCard(item: item));
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }

  SizedBox buildCastWidget(int index) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          SizedBox(
            height: 64,
            width: 64,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                "$imageW500Url${casts[index].profilePath}",
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            casts[index].name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
          Text(
            casts[index].character,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 10, letterSpacing: 1, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
