// ignore_for_file: avoid_print
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:itunes_pod/providers/search_provider.dart';
import 'package:itunes_pod/screens/audio_screen.dart';
import 'package:provider/provider.dart';
//import 'package:intl/intl.dart';
// import 'package:just_audio/just_audio.dart';
import '../models/itunes_trend.dart';
//import '../models/itunes_episodes.dart';
import '../providers/trend_provider.dart';
//import './audio_screen.dart';
//import '../providers/episode_provider.dart';

class TrendScreen extends StatefulWidget {
  const TrendScreen({Key? key}) : super(key: key);

  @override
  _TrendScreenState createState() => _TrendScreenState();
}

class _TrendScreenState extends State<TrendScreen> {
  List<Result> trendData = [];

  List<String> categoryList = [
    'Arts',
    'Books',
    'News',
    'Comedy',
    'Daily',
    'FilmReviews',
    'Food',
    'History',
    'Music',
    'Science',
    'Philosophy',
    'Politics',
    'True Crime',
    'TV&Film',
    'Society&Culture',
    'EarthSciences'
  ];
  List<String> categoryNumbers = [
    '1301',
    '1482',
    '1489',
    '1303',
    '1526',
    '1565',
    '1306',
    '1487',
    '1310',
    '1533',
    '1443',
    '1527',
    '1488',
    '1309',
    '1324',
    '1540'
  ];
  List<bool> selectionList = [
    true,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];
  String trendName = '';
  String currentItunesId = '';
  bool isLoading = true;
  int isSelected = 0;

  bool isFirstTime = true;
  bool isDescription = true;
  String description = '';

  late ScrollController _trendScrollController;
  @override
  void initState() {
    _trendScrollController = ScrollController();
    getTrendData('1301', 'Arts');
    super.initState();
  }

  getTrendData(String trendId, String name) {
    context.read<Trends>().getTrends(trendId).then((_) {
      setState(() {
        trendData = context.read<Trends>().trendList;
        isLoading = false;
        isSelected = 0;
        getDescription(trendData[0]);
        trendName = name;
      });
    });
  }

  static String stripHtmlIfNeeded(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
  }

  @override
  void dispose() {
    _trendScrollController.dispose();
    super.dispose();
  }

  Future<void> getDescription(trend) async {
    if (trend.description.isEmpty) {
      String descr =
          await context.read<SearchByName>().getDescription(trend.feedUrl);
      trend.description = stripHtmlIfNeeded(descr);
    }
    setState(() {
      description = trend.description;
      isDescription = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Trending',
                    style: TextStyle(fontSize: 32, fontFamily: 'MonteCarlo'),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      toggleButtons(),
                    ],
                  ),
                ),
                Text(
                  trendName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 100,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ListView.builder(
                              controller: _trendScrollController,
                              scrollDirection: Axis.horizontal,
                              itemCount: trendData.length,
                              itemBuilder: (context, index) {
                                final trend = trendData[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: SizedBox(
                                    width: 100,
                                    child: GestureDetector(
                                      onTap: () async {
                                        print(trend.collectionId);
                                        setState(() {
                                          isDescription = false;
                                          isSelected = index;
                                          currentItunesId =
                                              trend.collectionId.toString();
                                        });
                                        getDescription(trend);
                                      },
                                      child: Stack(children: [
                                        CachedNetworkImage(
                                          width: 100,
                                          imageUrl: trend.artworkUrl100!,
                                        ),
                                        isSelected == index
                                            ? const Positioned(
                                                bottom: 25,
                                                right: 15,
                                                child: Icon(
                                                  Icons.check_circle_outline,
                                                  size: 50,
                                                  color: Colors.amberAccent,
                                                ))
                                            : const SizedBox()
                                      ]),
                                    ),
                                  ),
                                );
                              }),
                        )
                      ],
                    ),
                  ),
                ),
                Center(
                  child: isDescription
                      ? Container(
                          padding: const EdgeInsets.only(left: 20),
                          constraints: const BoxConstraints(maxHeight: 150),
                          child: SingleChildScrollView(
                            child: ListTile(
                              title: Text(description),
                              trailing: IconButton(
                                onPressed: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AudioScreen(
                                              itunesId: currentItunesId)));
                                  ;
                                },
                                icon: const Icon(Icons.podcasts,
                                    size: 32, color: Colors.amberAccent),
                              ),
                            ),
                          ),
                        )
                      : const CircularProgressIndicator(),
                )
              ],
            ),
    );
  }

  ToggleButtons toggleButtons() {
    return ToggleButtons(
      color: Colors.white,
      splashColor: Colors.white,
      selectedColor: Colors.white,
      selectedBorderColor: Colors.grey.shade300,
      children: categoryList
          .map((item) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(item),
              ))
          .toList(),
      isSelected: selectionList,
      onPressed: (int index) {
        setState(() {
          for (int buttonIndex = 0;
              buttonIndex < selectionList.length;
              buttonIndex++) {
            if (buttonIndex == index) {
              selectionList[buttonIndex] = true;
              getTrendData(
                  categoryNumbers[buttonIndex], categoryList[buttonIndex]);
              _trendScrollController.animateTo(0,
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOutCubic);
              //isEpisodes = false;
            } else {
              selectionList[buttonIndex] = false;
            }
          }
        });
      },
    );
  }
}
