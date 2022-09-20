import 'dart:convert';
import 'dart:math' as math;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_movie/globals.dart';
import 'package:flutter_movie/models/Movie.dart';
import 'package:flutter_movie/screens/MovieDetail.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

// A function that converts a response body into a List<Photo>.
List<Movie> parseMovies(String responseBody) {
  var results = jsonDecode(responseBody)["results"];
  final parsed = results.cast<Map<String, dynamic>>();
  return parsed.map<Movie>((json) => Movie.fromJson(json)).toList();
}

Future<List<Movie>> fetchTrendingMovies() async {
  final response =
      await http.get(Uri.parse('${baseUrl}trending/all/day?api_key=$apiKey'));
  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseMovies, response.body);
}

Future<List<Movie>> fetchPopularMovies() async {
  final response =
      await http.get(Uri.parse('${baseUrl}movie/popular?api_key=$apiKey'));
  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseMovies, response.body);
}

class _HomeState extends State<Home> {
  List<Movie> trendingMovies = [];
  List<Movie> popularMovies = [];

  @override
  void initState() {
    super.initState();
    fetchTrendingMovies().then((value) => {
          setState(() => {trendingMovies = value})
        });
    fetchPopularMovies().then((value) => {
          setState(() => {popularMovies = value})
        });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData localTheme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Hi CaMi !",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        "See What's next",
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundImage: const NetworkImage(
                        "https://cdn.dribbble.com/users/1040983/screenshots/5630845/media/e95768b82810699dfd54512ff570954a.png?compress=1&resize=400x300&vertical=top"),
                    backgroundColor: localTheme.backgroundColor,
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 32, bottom: 32),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(6),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.grey.shade600,
                        size: 32,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                          child: Text(
                        "Search Movies",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 16),
                      )),
                      VerticalDivider(
                        color: Colors.grey.shade700,
                        thickness: 2,
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.mic,
                          color: Colors.grey.shade600,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              trendingMovies.isEmpty
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()))
                  : CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 10),
                      ),
                      items: trendingMovies
                          .map(
                            (item) => buildCarouselCard(context, item),
                          )
                          .toList(),
                    ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 32),
                child: Row(
                  children: [
                    Text(
                      "Popular".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 250,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: popularMovies
                      .map(
                        (item) => buildPopularMovieCard(context, item),
                      )
                      .toList(),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 32),
                child: Row(
                  children: const [
                    Text(
                      "MY LIST",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: trendingMovies
                      .map(
                        (item) => GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    MovieDetail(movieId: item.id)));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 16),
                            width: MediaQuery.of(context).size.width / 3,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                    "$imageW500Url${item.posterPath}"),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector buildCarouselCard(BuildContext context, Movie item) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MovieDetail(movieId: item.id)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              "$imageW500Url${item.posterPath}",
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector buildPopularMovieCard(BuildContext context, Movie item) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MovieDetail(movieId: item.id)));
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        "$imageW500Url${item.posterPath}",
                      ),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 150,
                  width: 120,
                ),
                Positioned(
                  bottom: -20,
                  left: 10,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(50)),
                    child: CircularProgressIndicator(
                      value: item.voteAverage / 10,
                      backgroundColor: item.voteAverage > 6
                          ? Colors.green.shade900
                          : Colors.indigo.shade300,
                      color: item.voteAverage > 6
                          ? Colors.green
                          : Colors.indigo.shade600,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -12,
                  left: 16,
                  child: Text(
                    item.voteAverage.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: item.voteAverage > 6
                          ? Colors.green.shade600
                          : Colors.indigo.shade300,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 28,
            ),
            Text(
              item.name ?? item.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              item.releaseDate ?? item.firstAirDate ?? '',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Container buildContinueWatchingCard(BuildContext context, String item) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: MediaQuery.of(context).size.width / 3,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(item),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(children: <Widget>[
        Align(
          alignment: Alignment.center,
          child: InkWell(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(100)),
              child: const CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Icon(
                  Icons.info_outline,
                  color: Colors.white,
                ),
                Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
