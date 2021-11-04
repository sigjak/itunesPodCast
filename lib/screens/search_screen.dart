import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:itunes_pod/screens/audio_screen.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../models/itunes_search_by_name.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  AudioPlayer player = AudioPlayer();
  bool startSearch = false;
  final textController = TextEditingController();
  List<PodResult> dataSearch = [];

  Future initSearch() async {
    String input = textController.text;
    String searchText = input.trim().replaceAll(" ", "+").toLowerCase();
    FocusManager.instance.primaryFocus!.unfocus();
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
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          toolbarHeight: 70,
          snap: true,
          floating: true,
          expandedHeight: 160,
          flexibleSpace: const FlexibleSpaceBar(
            centerTitle: true,
            background: Image(
              image: AssetImage('assets/images/p1.jpg'),
              fit: BoxFit.cover,
            ),
            title: Text('Podcast Search'),
          ),
          actions: [
            const SizedBox(width: 50),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) async {
                    await initSearch();
                  },
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  controller: textController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.black,
                    labelStyle: TextStyle(color: Colors.white),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.white,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    labelText: 'Search....',
                  ),
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  setState(() {
                    textController.text = '';
                  });
                },
                icon: const Icon(Icons.clear)),
          ],
        ),
        startSearch
            ? SliverToBoxAdapter(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 5, 16, 10),
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
                          value: podcast.collectionId!,
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
                                      constraints:
                                          const BoxConstraints(maxHeight: 120),
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
                                              itunesId: podcast.collectionId
                                                  .toString(),
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
                ),
              )
            : const SliverToBoxAdapter(child: SizedBox()),
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          dispose();
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        },
        child: const Icon(Icons.exit_to_app),
      ),
    );
  }
}
