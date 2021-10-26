import 'package:flutter/material.dart';
import 'package:itunes_pod/services/save_service.dart';
import 'package:itunes_pod/sql/episode_favorite_model.dart';
import 'package:itunes_pod/sql/podcasts_favorite_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../sql/podcast_sql_services.dart';
import '../models/itunes_episodes.dart';
import '../audio/player_buttons.dart';
import '../audio/slider_bar.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({required this.episode, required this.player, Key? key})
      : super(key: key);
  final Episode episode;
  final AudioPlayer player;
  @override
  _AudioScreenState createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> with WidgetsBindingObserver {
  List<Episode> episodes = [];
  bool isSelected = false;
  int? tappedIndex;
  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
    print('Init STTTAAAAAAAAAAAAATTTTE');
    // if coming from trend add one episode to episodes (List)

    episodes.add(widget.episode);

    // _init(widget.episode.episodeUrl!, widget.episode.trackName!);
  }

  Future<void> _init(String audioUrl, String audioTitle) async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    widget.player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(snack('Stream error!'));
    });

    try {
      AudioSource audioSource = AudioSource.uri(Uri.parse(audioUrl),
          tag: MediaItem(
              id: '1',
              album: widget.episode.collectionName,
              title: audioTitle));
      await widget.player.setAudioSource(audioSource);
      widget.player.play();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        snack('Error loading audio'),
      );
    }
  }

  SnackBar snack(String errorText) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Icon(
            Icons.error,
            size: 42,
            color: Colors.red,
          ),
          Text(
            errorText,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    return dateFormat.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    var podcastSql = context.read<PodcastServices>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Title'),
      ),
      body: Column(
        children: [
          Image(
            image: NetworkImage(widget.episode.artworkUrl600!, scale: 2),
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
          Expanded(
            child: ListView.builder(
                itemCount: episodes.length,
                itemBuilder: (context, index) {
                  final episode = episodes[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 150,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color:
                              tappedIndex == index ? Colors.red : Colors.grey,
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
                              // _init(episode.episodeUrl!, episode.trackName!);
                            },
                            child: Column(
                              children: [
                                Text(episode.trackName!),
                                Text(
                                  dateToString(
                                      episode.releaseDate ?? DateTime.now()),
                                  style: const TextStyle(fontSize: 9),
                                ),
                                Text(episode.description ?? ''),
                              ],
                            ),
                          ),
                          Align(
                              alignment: Alignment.bottomLeft,
                              child: TextButton(
                                  onPressed: () async {
                                    //Check if Podcast in favorites, if not save to favorites
                                    bool check =
                                        await podcastSql.checkIfPodcastInDB(
                                            episode.collectionName!);
                                    if (!check) {
                                      PodFavorite pod = PodFavorite(
                                        podcastName: episode.collectionName!,
                                        podcastImage: episode.artworkUrl600!,
                                        podcastFeed: episode.collectionId!,
                                      );
                                      await podcastSql.addPodcast(pod);
                                    }
                                    // now save episode to location

                                    String dloadLocation = await context
                                        .read<SaveService>()
                                        .saveEpisode(
                                            episode.episodeUrl!,
                                            episode.collectionName!,
                                            episode.trackName!);
                                    print('Saved in location: $dloadLocation');
                                    // EpisFavorite favToSave = EpisFavorite(
                                    //   podcastName: episode.collectionName!,
                                    //   episodeName: episode.trackName!,
                                    //   episodeUrl: episode.episodeUrl!,
                                    //   episodeDate: episode.releaseDate!
                                    //       .toIso8601String(),
                                    //   episodeDescription: episode.description!,
                                    //   timestamp:
                                    //       DateTime.now().microsecondsSinceEpoch,
                                    //   position: widget.player.position,
                                    //   dloadLocation: 'dloadlocation',
                                    // );
                                    // adding to sql databasse
                                  },
                                  child: const Text('Save Episode')))
                        ]),
                      ),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
}
