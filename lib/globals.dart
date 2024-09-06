import 'package:flutter_dotenv/flutter_dotenv.dart';

String apiKey = dotenv.env['API_KEY'] ?? '';

const String baseUrl = 'https://api.themoviedb.org/3/';

const String imageW500Url = 'https://image.tmdb.org/t/p/w500';
const String imageOriginalUrl = 'https://image.tmdb.org/t/p/original';
