import 'dart:ui';

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
                child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ExpansionPanelList.radio(
                    expansionCallback: (int index, bool isExpanded) async {
                      if (dataSearch[index].description.isEmpty) {
                        String temp = await context
                            .read<SearchByName>()
                            .getDescription(dataSearch[index].feedUrl);

                        setState(() {
                          dataSearch[index].description =
                              stripHtmlIfNeeded(temp);
                        });
                      }
                    },
                    children: dataSearch.map<ExpansionPanelRadio>((podcast) {
                      return ExpansionPanelRadio(
                        value: podcast.trackName!,
                        headerBuilder: (context, isExpanded) {
                          return ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(podcast.artworkUrl30!),
                              ),
                              title: Text(podcast.trackName!));
                        },
                        body: podcast.description.isNotEmpty
                            ? ListTile(
                                title: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 4, 0, 10),
                                  child: Container(
                                    height: 100,
                                    child: SingleChildScrollView(
                                      child: Text(
                                        podcast.description,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    if (player.playing) player.stop();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AudioScreen(
                                            itunesId:
                                                podcast.collectionId.toString(),
                                            player: player),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.podcasts,
                                    color: Colors.amber,
                                    size: 32,
                                  ),
                                ),
                              )
                            : const CircularProgressIndicator(),
                      );
                    }).toList(),
                  ),
                ),
              ))
            : const SizedBox(),
      ]),
    );
  }
}
