import 'package:flutter/material.dart';
import '../models/itunes_episodes.dart';
import '../audio/player_buttons.dart';
import '../audio/slider_bar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({required this.episode, required this.player, Key? key})
      : super(key: key);
  final Episode episode;
  final AudioPlayer player;
  @override
  _AudioScreenState createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> with WidgetsBindingObserver {
  //final AudioPlayer widget.player = AudioPlayer();

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
    print('Init STTTAAAAAAAAAAAAATTTTE');

    _init(widget.episode.episodeUrl!, widget.episode.trackName!);
  }

  Future<void> _init(String audioUrl, String audioTitle) async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    widget.player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(snack('Stream error!'));
    });

    try {
      print(widget.episode.collectionName);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Title'),
      ),
      body: Column(
        children: [
          Image(
            image: NetworkImage(widget.episode.artworkUrl600!, scale: 2),
          ),
          PlayerButtons(widget.player, true, context),
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
              }),
        ],
      ),
    );
  }
}
