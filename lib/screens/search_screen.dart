import 'package:flutter/material.dart';
import 'package:itunes_pod/screens/audio_screen.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../models/itunes_search_by_name.dart';
//import '../models/itunes_search_by_name.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  AudioPlayer player = AudioPlayer();
  bool startSearch = false;

  List<PodResult> dataSearch = [];

  Future initSearch(searchText) async {
    await context.read<SearchByName>().nameSearch(searchText).then((_) {
      setState(() {
        dataSearch = context.read<SearchByName>().searches;
        startSearch = true;
      });
    });
  }

  static String stripHtmlIfNeeded(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
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
            initSearch('wait+wait');
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
                        childrenPadding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                              child: IconButton(
                                onPressed: () {
                                  if (player.playing) player.stop();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AudioScreen(
                                              itunesId: searchData.collectionId
                                                  .toString(),
                                              player: player)));
                                  print(searchData.collectionId);
                                },
                                icon: const Icon(
                                  Icons.podcasts,
                                  color: Colors.amber,
                                  size: 32,
                                ),
                              )),
                          Container(
                              child: searchData.description.isNotEmpty
                                  ? Text(searchData.description)
                                  : const CircularProgressIndicator()),
                        ],
                      );
                    }),
              )
            : const SizedBox(),
      ]),
    );
  }
}
