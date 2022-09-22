
import 'package:flutter/material.dart';
import 'package:flutter_movie/screens/Discover.dart';

import 'screens/Home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie',
      theme: ThemeData(
        fontFamily: 'Mulish',
        primarySwatch: Colors.green,
        textTheme: const TextTheme(
          bodyText1: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      home: const MyHomePage(title: 'Movies'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int pageIndex = 0;

  final pages = [
    const Home(),
     Discover(),
    const Home(),
    const Home(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: pages[pageIndex],
      bottomNavigationBar: buildMyNavBar(context),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _selectScreen(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 0;
              });
            },
            icon: Icon(
              Icons.home_filled,
              color: pageIndex == 0
                  ? Theme.of(context).primaryColor
                  : Colors.white,
              size: 35,
              semanticLabel: "Home",
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 1;
              });
            },
            icon: Icon(
              Icons.explore_outlined,
              color: pageIndex == 1
                  ? Theme.of(context).primaryColor
                  : Colors.white,
              size: 35,
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 2;
              });
            },
            icon: Icon(
              Icons.bookmark,
              color: pageIndex == 2
                  ? Theme.of(context).primaryColor
                  : Colors.white,
              size: 35,
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 3;
              });
            },
            icon: Icon(
              Icons.settings_outlined,
              color: pageIndex == 3
                  ? Theme.of(context).primaryColor
                  : Colors.white,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }
}
