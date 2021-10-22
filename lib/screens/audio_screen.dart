import 'package:flutter/material.dart';
import '../models/itunes_episodes.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({required this.episode, Key? key}) : super(key: key);
  final Episode episode;
  @override
  _AudioScreenState createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
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
