import 'package:flutter/material.dart';
import 'package:itunes_pod/sql/episode_favorite_model.dart';
import 'package:itunes_pod/sql/podcasts_favorite_model.dart';
import '../sql/podcast_sql_services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Favs extends StatefulWidget {
  const Favs({required this.itunesId, required this.podcastName, Key? key})
      : super(key: key);
  final String podcastName;
  final int itunesId;
  @override
  _FavsState createState() => _FavsState();
}

class _FavsState extends State<Favs> {
  List<PodFavorite> favoritePodcasts = [];
  List<EpisFavorite> singlePodcastSavedEpisodes = [];
  List<EpisFavorite> allFavorites = [];
  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> getData() async {
    var podservice = context.read<PodcastServices>();
    //await podservice.getAllFavoritePodcasts();
    await podservice.getEpisodesFromSinglePodcast(widget.podcastName);
    // print(podservice.favSinglePodEpisodes.length);
    await podservice.getAllFavoriteEpisodes();
    //print(podservice.allFavoriteEpisodes.length);

    setState(() {
      favoritePodcasts = [...podservice.favPodcasts];
      singlePodcastSavedEpisodes = [...podservice.favSinglePodEpisodes];
      allFavorites = [...podservice.allFavoriteEpisodes];
    });
    print(singlePodcastSavedEpisodes[0].toString());
  }

  String dateToString(DateTime dt) {
    DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    return 'Release date: ${dateFormat.format(dt)}';
  }

  String totime(int ms) {
    Duration dur = Duration(milliseconds: ms);
    String durString = dur.toString();
    List<String> splDur = durString.split('.');
    return 'Duration: ${splDur[0]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Title'),
      ),
      body: Center(
          child: Column(
        children: [
          // Expanded(
          //   child: ListView.builder(
          //       itemCount: favoritePodcasts.length,
          //       itemBuilder: (context, index) {
          //         final pod = favoritePodcasts[index];
          //         return Column(
          //           children: [
          //             Text(pod.podcastName),
          //             Text(pod.podcastFeed.toString()),
          //             // Text(pod.podcastImage),
          //           ],
          //         );
          //       }),
          // ),
          Expanded(
            child: ListView.builder(
                itemCount: singlePodcastSavedEpisodes.length,
                itemBuilder: (context, index) {
                  final episode = singlePodcastSavedEpisodes[index];

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(episode.episodeName),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Text(
                          //   dateToString(episode.episodeDate),
                          //   style: const TextStyle(fontSize: 9),
                          // ),
                          Text(
                            totime(episode.episodeDuration),
                            style: const TextStyle(fontSize: 9),
                          )
                        ],
                      ),
                      Text(episode.episodeDescription),
                    ],
                  );
                }),
          ),
        ],
      )),
    );
  }
}
