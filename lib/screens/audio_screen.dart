import 'package:flutter/material.dart';
import 'package:itunes_pod/providers/episode_provider.dart';
import 'package:itunes_pod/services/save_service.dart';
import 'package:itunes_pod/sql/episode_favorite_model.dart';
import 'package:itunes_pod/sql/podcasts_favorite_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../sql/podcast_sql_services.dart';
import '../models/itunes_episodes.dart';
import '../audio/player_buttons.dart';
import '../audio/slider_bar.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({required this.itunesId, required this.player, Key? key})
      : super(key: key);
  final String itunesId;
  final AudioPlayer player;
  @override
  _AudioScreenState createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> with WidgetsBindingObserver {
  List<Episode> episodes = [];
  bool isLoaded = false;
  bool isSelected = false;
  int? tappedIndex;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    context.read<ItunesEpisodes>().getEpisodes(widget.itunesId).then((value) {
      episodes = context.read<ItunesEpisodes>().episodeList;
      setState(() {
        isLoaded = true;
      });
    });
    super.initState();
    print('Init STTTAAAAAAAAAAAAATTTTE');
    // if coming from trend add one episode to episodes (List)

    //episodes.add(widget.episode);

    // _init(widget.episode.episodeUrl!, widget.episode.trackName!);
  }

  Future<void> _init(Episode episode) async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    widget.player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      ScaffoldMessenger.of(context)
          .showSnackBar(snack(Icons.error, 'Stream error!'));
    });

    try {
      AudioSource audioSource = AudioSource.uri(Uri.parse(episode.episodeUrl!),
          tag: MediaItem(
              id: '1',
              album: episode.collectionName,
              title: episode.trackName!));
      await widget.player.setAudioSource(audioSource);
      widget.player.play();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        snack(Icons.error, 'Error loading audio'),
      );
    }
  }

  SnackBar snack(IconData messIcon, String errorText) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            messIcon,
            size: 50,
            color: Colors.red,
          ),
          Text(
            errorText,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    //widget.player.dispose();
    super.dispose();
  }

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          widget.player.positionStream,
          widget.player.bufferedPositionStream,
          widget.player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));
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
      body: isLoaded
          ? Column(
              children: [
                Image(
                  image: NetworkImage(episodes[0].artworkUrl600!, scale: 2),
                ),
                PlayerButtons(widget.player, isSelected, context),
                StreamBuilder<PositionData>(
                  stream: _positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data;
                    return SliderBar(
                        audioPlayer: widget.player,
                        duration: positionData?.duration ?? Duration.zero,
                        position: positionData?.position ?? Duration.zero,
                        bufferedPosition:
                            positionData?.bufferedPosition ?? Duration.zero);
                  },
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                      itemCount: episodes.length - 1,
                      itemBuilder: (context, index) {
                        final episode = episodes[index + 1];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 2, 20, 5),
                          child: Container(
                            height: 100,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: tappedIndex == index
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: Column(children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isSelected = false;
                                      tappedIndex = index;
                                    });
                                    _init(episode);
                                  },
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: Text(episode.trackName!),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            dateToString(episode.releaseDate ??
                                                DateTime.now()),
                                            style: const TextStyle(fontSize: 9),
                                          ),
                                          Text(
                                            totime(
                                                episode.trackTimeMillis ?? 0),
                                            style: const TextStyle(fontSize: 9),
                                          )
                                        ],
                                      ),
                                      Text(episode.description ?? ''),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: TextButton(
                                      onPressed: () async {
                                        showDloadIndicator(context, episode);
                                        await saveEpisode(episode);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Save Episode')),
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      await context
                                          .read<SaveService>()
                                          .getEpisodesInDirectory(
                                              episode.collectionName!);
                                      var rr = await context
                                          .read<PodcastServices>()
                                          .getSingleEpisode(episode.trackName!);
                                      print(rr.episodeDuration);
                                      // File fileToDelete = File(rr.dloadLocation!);
                                      // if (fileToDelete.existsSync()) {
                                      //   fileToDelete.delete();
                                      //   print('file deleted');
                                      // } else {
                                      //   print('no such file');
                                      // }
                                      // await context
                                      //     .read<PodcastServices>()
                                      //     .deleteSavedEpisode(rr.dloadLocation!);
                                    },
                                    child: Text('dededed'))
                              ]),
                            ),
                          ),
                        );
                      }),
                )
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Future<dynamic> showDloadIndicator(BuildContext context, Episode episode) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          //dialogContext = context;
          return AlertDialog(
            title: const Text('Downloading...'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                    value: context.watch<SaveService>().progress),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('please wait...'),
                ),
                TextButton(
                    onPressed: () async {
                      context.read<SaveService>().token.cancel('cancelled');
                      String dloadLocation = await context
                          .read<SaveService>()
                          .downloadLocation(
                              episode.collectionName!, episode.trackName);

                      //clean sql of episode
                      await context
                          .read<PodcastServices>()
                          .deleteSavedEpisode('dummy');
                      File fileToDelete = File(dloadLocation);
                      if (fileToDelete.existsSync()) {
                        fileToDelete.deleteSync();
                      }
                      context.read<SaveService>().progress = 0.0;
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: const Text('Cancel'))
              ],
            ),
          );
        });
  }

  Future<void> saveEpisode(episode) async {
    context.read<SaveService>().refreshToken();
    var podcastSql = context.read<PodcastServices>();
    bool check = await podcastSql.checkIfPodcastInDB(episode.collectionName!);
    if (!check) {
      PodFavorite pod = PodFavorite(
        podcastName: episode.collectionName!,
        podcastImage: episode.artworkUrl600!,
        podcastFeed: episode.collectionId!,
      );
      await podcastSql.addPodcast(pod);
    }
    // now save episode to location

    EpisFavorite favToSave = EpisFavorite(
      podcastName: episode.collectionName!,
      episodeName: episode.trackName!,
      episodeUrl: episode.episodeUrl!,
      episodeDuration: episode.trackTimeMillis!,
      episodeDate: episode.releaseDate!.toIso8601String(),
      episodeDescription: episode.description!,
      timestamp: DateTime.now().microsecondsSinceEpoch,
      position: widget.player.position,
      dloadLocation: 'dummy',
    );
    String result = await podcastSql.addFavoriteEpisode(favToSave);
    if (result == 'Episode added') {
      String dloadlocation = await context.read<SaveService>().saveEpisode(
          episode.episodeUrl, episode.collectionName, episode.trackName);
      await podcastSql.updateSaveLocation(dloadlocation, episode.trackName);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(snack(Icons.check, 'Already in database'));
    }
  }
}
