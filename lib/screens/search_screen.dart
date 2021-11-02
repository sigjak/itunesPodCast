import 'package:flutter/material.dart';
import 'package:itunes_pod/models/itunes_search_by_name.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
//import '../models/itunes_search_by_name.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchText = 'fresh+air';
  bool startSearch = false;

  List<PodResult> dataSearch = [];

  @override
  void initState() {
    context.read<SearchByName>().nameSearch(searchText).then((_) {
      setState(() {
        dataSearch = context.read<SearchByName>().searches;
        startSearch = true;
      });
    });
    super.initState();
  }

  static String stripHtmlIfNeeded(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Title'),
      ),
      body: Column(children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              searchText = 'this+american+life';
              startSearch = true;
            });
          },
          child: const Text('Search'),
        ),
        startSearch
            ? Expanded(
                child: ListView.builder(
                    itemCount: dataSearch.length,
                    itemBuilder: (context, index) {
                      final searchData = dataSearch[index];

                      return ExpansionTile(
                        childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                        onExpansionChanged: (bool expanded) async {
                          if (searchData.description.isEmpty) {
                            String temp = await context
                                .read<SearchByName>()
                                .getDescription(searchData.feedUrl);

                            setState(() {
                              searchData.description = stripHtmlIfNeeded(temp);
                            });
                          }
                        },
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(searchData.artworkUrl30!),
                        ),
                        title: Text(searchData.trackName ?? ''),
                        children: [
                          Align(
                              alignment: Alignment.topRight,
                              child: Icon(Icons.podcasts)),
                          Container(
                              child: searchData.description.isNotEmpty
                                  ? Text(searchData.description)
                                  : CircularProgressIndicator()),
                        ],
                      );
                    }),
              )
            : SizedBox(),
      ]),
    );
  }
}
