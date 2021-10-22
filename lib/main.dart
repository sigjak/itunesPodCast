import 'package:flutter/material.dart';
import 'package:itunes_pod/episode_provider.dart';

import 'package:itunes_pod/screens/trend_screen.dart';
import 'package:provider/provider.dart';
import './trend_provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => Trends()),
    ChangeNotifierProvider(create: (_) => ItunesEpisodes()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TrendScreen(),
    );
  }
}
