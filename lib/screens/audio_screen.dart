import 'package:flutter/material.dart';
import '../models/itunes_episodes.dart';
import '../audio/player_buttons.dart';
import '../audio/slider_bar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({required this.episode, Key? key}) : super(key: key);
  final Episode episode;
  @override
  _AudioScreenState createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> with WidgetsBindingObserver {
  final AudioPlayer _player = AudioPlayer();

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
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error ocurred: $e');
    });

    try {
      var audioSource = AudioSource.uri(Uri.parse(audioUrl),
          tag: MediaItem(id: '1', album: 'ssome data', title: audioTitle));
      await _player.setAudioSource(audioSource);
      _player.play();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    // _player.dispose();
    super.dispose();
  }

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Title'),
      ),
      body: Container(
          child: Image(
        image: NetworkImage(widget.episode.artworkUrl600!),
      )),
    );
  }
}
