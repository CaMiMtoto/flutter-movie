import 'package:cached_network_image/cached_network_image.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_movie/screens/MovieDetail.dart';
import 'package:http/http.dart' as http;

import '../globals.dart';
import '../models/Movie.dart';
import 'Home.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

Future<List<Movie>> fetchMovies({required String query, int page = 1}) async {
  final response = await http.get(Uri.parse(
      '${baseUrl}search/movie?api_key=$apiKey&language=en-US&query=$query&page=$page&include_adult=true'));
  return compute(parseMovies, response.body);
}

class _SearchState extends State<Search> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  TextEditingController searchController = TextEditingController();

  List<Movie> movies = [];
  var isLoading = false;

  final debouncer =
      Debouncer<String>(const Duration(milliseconds: 500), initialValue: "");

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    searchController.addListener(() => debouncer.value = searchController.text);
    debouncer.values.listen((value) {
      if (value.isEmpty) return;
      setState(() {
        isLoading = true;
      });
      fetchMovies(query: value).then((results) {
        setState(() {
          movies = results;
          isLoading = false;
        });
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          color: Colors.grey.shade300,
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: TextField(
          onChanged: (value) {},
          controller: searchController,
          decoration: InputDecoration.collapsed(
              hintText: 'Search Movie...',
              hintStyle: TextStyle(color: Colors.grey.shade300)),
          style: TextStyle(color: Colors.grey.shade300),
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  searchController.text = "";
                });
              },
              icon: const Icon(Icons.clear))
        ],
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CupertinoActivityIndicator(
              radius: 20,
            ))
          : movies.isEmpty && searchController.text.isNotEmpty
              ? Center(
                  child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Oops",
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
                        ),
                        Text(
                          "No results found",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ))
              : ListView.builder(
                  itemCount: movies.length,
                  itemBuilder: (BuildContext context, int index) {
                    var movie = movies[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return MovieDetail(movieId: movie.id);
                        }));
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: SizedBox(
                            height: 64,
                            width: 64,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl:
                                    "$imageW500Url${movie.posterPath ?? movie.backdropPath}",
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                progressIndicatorBuilder: (context, url,
                                        downloadProgress) =>
                                    const Center(
                                        child: CupertinoActivityIndicator()),
                                errorWidget: (context, url, error) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor),
                                    child: Center(
                                      child: Text(movie
                                          .getName()
                                          .substring(0, 2)
                                          .toUpperCase()),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          title: Text(
                            movie.title ?? movie.name ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                            ),
                          ),
                          subtitle: Container(
                            margin: const EdgeInsets.only(top: 16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.thumb_up_alt_outlined,
                                  color: Colors.yellow,
                                  size: 16,
                                ),
                                Text(movie.voteAverage.toString(),
                                    style:
                                        TextStyle(color: Colors.grey.shade500)),
                                const SizedBox(
                                  width: 32,
                                ),
                                Text(movie.getFormattedDate(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style:
                                        TextStyle(color: Colors.grey.shade500)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
