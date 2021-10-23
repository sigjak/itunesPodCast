// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;
import '../models/itunes_trend.dart';

class Trends with ChangeNotifier {
  List<Result> trendList = [];
  String baseUrl =
      'https://itunes.apple.com/search?term=podcast&limit=50&genreId=';

  Future getTrends(String trendId) async {
    String url = baseUrl + trendId;
    var result = await http.get(Uri.parse(url));
    var decoded = jsonDecode(result.body);
    var data = ItunesTrend.fromJson(decoded);

    trendList = [...data.results!];
    print(trendList[0].artistId);
    notifyListeners();
    // for (var data in trendList) {
    //   print(data.collectionName);
    //   print(data.artworkUrl30);
    //
    // }
  }
}
