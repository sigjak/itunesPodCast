import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/itunes_episodes.dart';

class ItunesEpisodes with ChangeNotifier {
  List<Episode> episodeList = [];

  // 'https://itunes.apple.com/lookup?id=1251196416&country=US&media=podcast&entity=podcastEpisode&limit=100';

  Future getEpisodes(String id) async {
    String baseUrl = 'https://itunes.apple.com/lookup?id=$id';
    String addUrl = '&country=US&media=podcast&entity=podcastEpisode&limit=20';
    String url = baseUrl + addUrl;
    final result = await http.get(Uri.parse(url));
    final decoded = jsonDecode(result.body);
    var res = Episodes.fromJson(decoded);
    print(res.results![1].releaseDate ?? 'error');
    // print(res.results![1].episodeUrl);
    // print(res.results![1].description);
    // print('ResultCount: ${res.resultCount}');
    episodeList = [...res.results!];
    notifyListeners();
  }
}