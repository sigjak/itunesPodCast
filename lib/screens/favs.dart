import 'package:flutter/material.dart';
import '../models/itunes_episodes.dart';
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
  List<EpisFavorite> savedEpisodes = [];
  List<EpisFavorite> allFavorites = [];
  List<Episode> newEp = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> getData() async {
    var podservice = context.read<PodcastServices>();
    await podservice.getEpisodesFromSinglePodcast(widget.podcastName);
    setState(() {
      savedEpisodes = [...podservice.favSinglePodEpisodes];
      newEp = transPose();
    });
  }

  List<Episode> transPose() {
    List<Episode> tempEp = [];
    for (int i = 0; i < savedEpisodes.length; i++) {
      Episode episode = Episode(
        collectionName: savedEpisodes[i].podcastName,
        artworkUrl600: savedEpisodes[i].podcastImage,
        trackName: savedEpisodes[i].episodeName,
        description: savedEpisodes[i].episodeDescription,
        trackTimeMillis: savedEpisodes[i].episodeDuration,
        releaseDate: DateTime.parse(savedEpisodes[i].episodeDate),
      );
      tempEp.add(episode);
    }
    return tempEp;
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
          //       itemCount: newEp.length,
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
          newEp.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                      itemCount: newEp.length,
                      itemBuilder: (context, index) {
                        final episode = newEp[index];

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(episode.trackName!),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dateToString(episode.releaseDate!),
                                  style: const TextStyle(fontSize: 9),
                                ),
                                Text(
                                  totime(episode.trackTimeMillis!),
                                  style: const TextStyle(fontSize: 9),
                                )
                              ],
                            ),
                            Text(episode.description!),
                          ],
                        );
                      }),
                )
              : CircularProgressIndicator(),
        ],
      )),
    );
  }
}
