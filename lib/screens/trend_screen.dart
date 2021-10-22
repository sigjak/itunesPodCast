// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/itunes_trend.dart';
import '../models/itunes_episodes.dart';
import '../trend_provider.dart';
import './audio_screen.dart';
import '../episode_provider.dart';

class TrendScreen extends StatefulWidget {
  const TrendScreen({Key? key}) : super(key: key);

  @override
  _TrendScreenState createState() => _TrendScreenState();
}

class _TrendScreenState extends State<TrendScreen> {
  List<Result> trendData = [];
  List<Episode> episodes = [];
  bool isLoading = true;
  bool isEpisodes = false;
  late ScrollController _scrollController;
  @override
  void initState() {
    _scrollController = ScrollController();
    getTrendData();
    super.initState();
  }

  getTrendData() {
    context.read<Trends>().getTrends().then((_) {
      setState(() {
        trendData = context.read<Trends>().trendList;
        isLoading = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    episodes = context.watch<ItunesEpisodes>().episodeList;
  }
  // getTrendData() async {
  //   await context.read<Trends>().getTrends();
  //   setState(() {
  //     trendData = context.read<Trends>().trendList;
  //     isLoading = false;
  //   });
  // }

  Trends trend = Trends();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Title'),
        ),
        body: isLoading
            ? const CircularProgressIndicator()
            : Column(
                children: [
                  SizedBox(
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: trendData.length,
                              itemBuilder: (context, index) {
                                final trend = trendData[index];
                                return SizedBox(
                                  width: 110,
                                  child: GestureDetector(
                                    onTap: () async {
                                      _scrollController.animateTo(0,
                                          duration: const Duration(seconds: 2),
                                          curve: Curves.easeInOutCubic);
                                      print(trend.collectionId);
                                      print(trend.artistId);
                                      await context
                                          .read<ItunesEpisodes>()
                                          .getEpisodes(
                                              trend.collectionId.toString());
                                      setState(() {
                                        isEpisodes = true;
                                      });
                                    },
                                    child: Image(
                                      image: NetworkImage(trend.artworkUrl100!),
                                    ),
                                  ),
                                );
                              }),
                        )
                      ],
                    ),
                  ),
                  isEpisodes
                      ? Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: episodes.length,
                            itemBuilder: (context, index) {
                              final episode = episodes[index];

                              return index == 0
                                  ? Text(
                                      episode.trackName ?? '',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 20),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 5, 20, 5),
                                      child: Container(
                                        height: 150,
                                        decoration: BoxDecoration(
                                            border: Border.all(width: 1)),
                                        child: GestureDetector(
                                          onTap: () {
                                            print(episode.episodeUrl);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AudioScreen(
                                                        episode: episode),
                                              ),
                                            );
                                          },
                                          child: Card(
                                            elevation: 5,
                                            child: SingleChildScrollView(
                                              child: ListTile(
                                                  title: Text(
                                                      episode.trackName ?? ''),
                                                  subtitle: Text(
                                                      episode.description ??
                                                          '')),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                            },
                          ),
                        )
                      : const Text('')
                ],
              ));
  }
}

// class NewWidget extends StatelessWidget {
//   const NewWidget({
//     Key? key,
//     required this.episodes,
//   }) : super(key: key);

//   final List<Episode> episodes;

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: episodes.length,
//       itemBuilder: (context, index) {
//         final episode = episodes[index];

//         return index == 0
//             ? Text(
//                 episode.trackName ?? '',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 20),
//               )
//             : Padding(
//                 padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
//                 child: Container(
//                   height: 150,
//                   decoration: BoxDecoration(border: Border.all(width: 1)),
//                   child: GestureDetector(
//                     onTap: () {
//                       print(episode.episodeUrl);
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AudioScreen(episode: episode),
//                         ),
//                       );
//                     },
//                     child: Card(
//                       elevation: 5,
//                       child: SingleChildScrollView(
//                         child: ListTile(
//                             title: Text(episode.trackName ?? ''),
//                             subtitle: Text(episode.description ?? '')),
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//       },
//     );
//   }
// }
