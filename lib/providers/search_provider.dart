import 'package:flutter/cupertino.dart';

import '../models/itunes_search_by_name.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//String baseUrl = 'https://itunes.apple.com/search?term=fresh+air&entity=podcast&country=us&limit=20';
List<PodResult> searches = [];

class SearchByName with ChangeNotifier {
  Future nameSarch(String searchTerm) async {
    String url =
        'https://itunes.apple.com/search?term=$searchTerm&entity=podcast&country=us&limit=20';
    var result = await http.get(Uri.parse(url));
    if (result.statusCode == 200) {
      var decoded = json.decode(result.body);
      var data = Podcasts.fromJson(decoded);

      searches = [...data.results!];
      notifyListeners();
    }
  }
}
