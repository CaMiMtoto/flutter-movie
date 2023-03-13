import 'dart:convert';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_movie/globals.dart';
import 'package:flutter_movie/models/Movie.dart';
import 'package:flutter_movie/screens/MovieDetail.dart';
import 'package:flutter_movie/screens/Search.dart';
import 'package:http/http.dart' as http;

import '../colors.dart';

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

Future<List<Movie>> fetchUpcomingMovies() async {
  final response =
      await http.get(Uri.parse('${baseUrl}movie/upcoming?api_key=$apiKey'));
  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseMovies, response.body);
}

class _HomeState extends State<Home> {
  List<Movie> trendingMovies = [];
  List<Movie> popularMovies = [];
  List<Movie> upcomingMovies = [];

  @override
  void initState() {
    super.initState();
    fetchTrendingMovies().then((value) => {
          setState(() => {trendingMovies = value})
        });
    fetchPopularMovies().then((value) => {
          setState(() => {popularMovies = value})
        });
    fetchUpcomingMovies().then((value) {
      setState(() {
        upcomingMovies = value;
      });
    });
  }

  int _current = 0;

  @override
  Widget build(BuildContext context) {
    ThemeData localTheme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (builder) {
                    return const Search();
                  }));
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color:secondaryColor,
                    borderRadius: BorderRadius.circular(30),
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
              ),
              trendingMovies.isEmpty
                  ? const SizedBox.shrink()
                  : Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 16),
                      child: const Text(
                        "Trending Now",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
              trendingMovies.isEmpty
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()))
                  : CarouselSlider.builder(
                      itemCount: trendingMovies.length,
                      options: CarouselOptions(
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 3),
                          viewportFraction: 0.5,
                          enlargeCenterPage: true,
                          padEnds: true,
                          disableCenter: false,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                            });
                          }),
                      itemBuilder:
                          (BuildContext context, int index, int realIndex) {
                        var item = trendingMovies[index];
                        return buildCarouselCard(context, item);
                      },
                    ),
              popularMovies.isEmpty
                  ? const SizedBox.shrink()
                  : Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      child: const Text(
                        "Popular",
                        style: TextStyle(
                          fontSize: 16,
                        ),
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
              upcomingMovies.isEmpty
                  ? const SizedBox.shrink()
                  : Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      child: const Text(
                        "Upcoming",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: upcomingMovies
                      .map(
                        (item) => GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    MovieDetail(movieId: item.id)));
                          },
                          child: buildUpcomingCard(context, item),
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

  Container buildUpcomingCard(BuildContext context, Movie item) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: MediaQuery.of(context).size.width / 3,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage("$imageW500Url${item.posterPath}"),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10),
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
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: "$imageOriginalUrl${item.posterPath}",
              fit: BoxFit.cover,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  const Center(
                child: CupertinoActivityIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
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
                        borderRadius: BorderRadius.circular(50)),
                    child: CircularProgressIndicator(
                      value: item.voteAverage / 10,
                      backgroundColor: item.voteAverage > 6
                          ? secondaryColor
                          : Colors.indigo.shade300,
                      color: item.voteAverage > 6
                          ? primaryColor
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
