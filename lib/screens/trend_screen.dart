// ignore_for_file: avoid_print
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:itunes_pod/providers/search_provider.dart';
import 'package:provider/provider.dart';
//import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import '../models/itunes_trend.dart';
import '../models/itunes_episodes.dart';
import '../providers/trend_provider.dart';
//import './audio_screen.dart';
import '../providers/episode_provider.dart';

class TrendScreen extends StatefulWidget {
  const TrendScreen({Key? key}) : super(key: key);

  @override
  _TrendScreenState createState() => _TrendScreenState();
}

class _TrendScreenState extends State<TrendScreen> {
  AudioPlayer player = AudioPlayer();
  List<Result> trendData = [];
//  List<Episode> episodes = [];
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
  bool isLoading = true;
  // bool isEpisodes = false;
  //bool isPlayer = false;
  bool isDescription = false;
  String descr = '';

  // late ScrollController _scrollController;
  late ScrollController _trendScrollController;
  @override
  void initState() {
    //_scrollController = ScrollController();
    _trendScrollController = ScrollController();
    getTrendData('1301', 'Arts');
    super.initState();
    print('ho');
  }

  getTrendData(String trendId, String name) {
    context.read<Trends>().getTrends(trendId).then((_) {
      setState(() {
        trendData = context.read<Trends>().trendList;
        isLoading = false;
        //     isPlayer = false;
        trendName = name;
      });
    });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   episodes = context.watch<ItunesEpisodes>().episodeList;
  // }

  @override
  void dispose() {
    // _scrollController.dispose();
    _trendScrollController.dispose();
    super.dispose();
    player.dispose();
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
                    height: 120,
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
                                return SizedBox(
                                  width: 110,
                                  child: GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        isDescription = false;
                                      });
                                      String d = await context
                                          .read<SearchByName>()
                                          .getDescription(trend.feedUrl);

                                      setState(() {
                                        descr = d;
                                        isDescription = true;
                                      });
                                    },
                                    child: CachedNetworkImage(
                                      imageUrl: trend.artworkUrl100!,
                                    ),
                                  ),
                                );
                              }),
                        )
                      ],
                    ),
                  ),
                ),
                isDescription
                    ? Container(
                        child: Text(descr),
                      )
                    : CircularProgressIndicator()
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
