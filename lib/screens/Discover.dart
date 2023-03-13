import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_movie/models/Movie.dart';
import 'package:flutter_movie/screens/Home.dart';
import 'package:flutter_movie/screens/MovieDetail.dart';
import 'package:flutter_movie/screens/Search.dart';

import '../globals.dart';
import '../models/Genre.dart';

import 'package:http/http.dart' as http;

// A function that converts a response body into a List<Photo>.
List<Genre> parseGenres(String responseBody) {
  var results = jsonDecode(responseBody)["genres"];
  final parsed = results.cast<Map<String, dynamic>>();
  return parsed.map<Genre>((json) => Genre.fromJson(json)).toList();
}

Future<List<Genre>> fetchGenres() async {
  final response =
      await http.get(Uri.parse('${baseUrl}genre/movie/list?api_key=$apiKey'));
  return compute(parseGenres, response.body);
}

Future<List<Movie>> fetchMovies({int? genreId, int page = 1}) async {
  final response = await http.get(Uri.parse(
      '${baseUrl}discover/movie?api_key=$apiKey&sort_by=popularity.desc&include_adult=false&include_video=false&page=$page&with_genres=$genreId&with_watch_monetization_types=flatrate'));
  return compute(parseMovies, response.body);
}

class Discover extends StatefulWidget {
   int? genreId;

   Discover({Key? key, this.genreId}) : super(key: key);

  @override
  State<Discover> createState() => _DiscoverState(genreId);
}

class _DiscoverState extends State<Discover>
    with SingleTickerProviderStateMixin {
  int? genreId;

  List<Genre> genres = [];
  List<Movie> movies = [];

  bool movieLoading = true;

  int activeCategory = 0;

  _DiscoverState(this.genreId) {
    if (genreId != null) {
      activeCategory = genreId!;
    }
  }

  @override
  void initState() {
    super.initState();

    fetchGenres().then((value) {
      value.insert(0, Genre(id: 0, name: "All"));
      setState(() {
        genres = value;
      });
    });

    fetchMovies(genreId: genreId).then((value) {
      setState(() {
        movies = value;
        movieLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData localTheme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "DISCOVER",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            IconButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Search()));
            }, icon: const Icon(Icons.search))
          ],
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: genres.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          var newId = genres[index].id;
                          setState(() {
                            activeCategory = newId;
                            movieLoading = true;
                          });
                          fetchMovies(genreId: newId == 0 ? null : newId)
                              .then((value) {
                            setState(() {
                              movies = value;
                              movieLoading = false;
                            });
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              Text(
                                genres[index].name,
                                style: activeCategory == genres[index].id
                                    ? TextStyle(
                                        color: localTheme.primaryColor,
                                        fontWeight: FontWeight.bold)
                                    : TextStyle(color: Colors.grey.shade500),
                              ),
                              genres[index].id == activeCategory
                                  ? buildHorizontalBar(localTheme)
                                  : const SizedBox.shrink()
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                movieLoading
                    ? const SizedBox(
                        height: 300,
                        child: Center(
                          child: CupertinoActivityIndicator(
                            radius: 20,
                          ),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 0.6,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          crossAxisCount: 3,
                        ),
                        itemCount: movies.length,
                        physics: const ScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          var item = movies[index];
                          return GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return MovieDetail(movieId: item.id);
                                }));
                              },
                              child: MovieCard(item: item));
                        },
                      ),
              ],
            ),
          ),
        ));
  }

  Container buildHorizontalBar(ThemeData localTheme) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: localTheme.primaryColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  const MovieCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  final Movie item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage("$imageW500Url${item.posterPath}"),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      height: 200,
    );
  }
}
