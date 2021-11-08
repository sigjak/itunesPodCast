// import 'package:flutter/material.dart';
// import 'package:itunes_pod/providers/episode_provider.dart';
// import 'package:itunes_pod/services/save_service.dart';
// import 'package:itunes_pod/sql/episode_favorite_model.dart';
// import 'package:itunes_pod/sql/podcasts_favorite_model.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:just_audio_background/just_audio_background.dart';
// import 'package:audio_session/audio_session.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:intl/intl.dart';
// import 'dart:io';
// import 'package:provider/provider.dart';
// import 'package:flutter/services.dart';
// import '../services/position_service.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import '../sql/podcast_sql_services.dart';
// import '../models/itunes_episodes.dart';
// import '../audio/player_buttons.dart';
// import '../audio/slider_bar.dart';

// class AudioScreen extends StatefulWidget {
//   const AudioScreen(
//       {required this.itunesId,
//       required this.podcastName,
//       required this.player,
//       required this.isSaved,
//       Key? key})
//       : super(key: key);
//   final String itunesId;
//   final String podcastName;
//   final AudioPlayer player;
//   final bool isSaved;
//   @override
//   _AudioScreenState createState() => _AudioScreenState();
// }

// class _AudioScreenState extends State<AudioScreen> with WidgetsBindingObserver {
//   List<Episode> episodes = [];
//   List<EpisFavorite> savedEpisodes = [];
//   bool isLoaded = false;
//   bool isSelected = false;
//   bool isFavorite = false;
//   int? tappedIndex;
//   String episodeName = '';

//   late String podcastImage;
//   late int itunesPodcastId;
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     WidgetsBinding.instance?.addObserver(this);
//     var dd = context.read<PodcastServices>();

//     context.read<ItunesEpisodes>().getEpisodes(widget.itunesId).then((value) {
//       if (!widget.isSaved) {
//         episodes = context.read<ItunesEpisodes>().episodeList;
//         podcastImage = episodes[0].artworkUrl600 ?? '';
//         itunesPodcastId = int.parse(widget.itunesId);
//         isLoaded = true;
//       } else {
//         getSavedData();
//       }

//       setState(() {
//         //podcastName = episodes[0].collectionName ?? '';
//         // podcastImage = episodes[0].artworkUrl600 ?? '';
//         // itunesPodcastId = int.parse(widget.itunesId);
//         // isLoaded = true;
//       });
//       dd.checkIfPodcastInDB(widget.podcastName).then((value) {
//         if (value) {
//           setState(() {
//             isFavorite = true;
//           });
//         }
//       });
//     });

//     super.initState();
//   }

//   List<Episode> transPose() {
//     List<Episode> tempEp = [];
//     for (int i = 0; i < savedEpisodes.length; i++) {
//       Episode episode = Episode(
//         collectionName: savedEpisodes[i].podcastName,
//         episodeUrl: savedEpisodes[i].dloadLocation,
//         artworkUrl600: savedEpisodes[i].podcastImage,
//         trackName: savedEpisodes[i].episodeName,
//         description: savedEpisodes[i].episodeDescription,
//         trackTimeMillis: savedEpisodes[i].episodeDuration,
//         releaseDate: DateTime.parse(savedEpisodes[i].episodeDate),
//       );
//       tempEp.add(episode);
//     }
//     Episode episodeZero = Episode(
//         collectionName: savedEpisodes[0].podcastName,
//         artworkUrl600: savedEpisodes[0].podcastImage);
//     tempEp.insert(0, episodeZero);

//     return tempEp;
//   }

//   Future<void> getSavedData() async {
//     var podservice = context.read<PodcastServices>();
//     await podservice.getEpisodesFromSinglePodcast(widget.podcastName);
//     setState(() {
//       savedEpisodes = [...podservice.favSinglePodEpisodes];
//       episodes = transPose();
//       podcastImage = episodes[0].artworkUrl600!;
//       isLoaded = true;
//     });
//   }

//   Future<void> _init(Episode episode) async {
//     final session = await AudioSession.instance;
//     await session.configure(const AudioSessionConfiguration.speech());
//     widget.player.playbackEventStream.listen((event) {},
//         onError: (Object e, StackTrace stackTrace) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(snack(Icons.error, 'Stream error!'));
//     });

//     try {
//       AudioSource audioSource = AudioSource.uri(Uri.parse(episode.episodeUrl!),
//           tag: MediaItem(
//               id: '1',
//               album: episode.collectionName,
//               title: episode.trackName!));
//       await widget.player.setAudioSource(audioSource);
//       Duration seeking = await posService.getSavedPosition(episodeName);

//       widget.player.seek(seeking);
//       widget.player.play();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         snack(Icons.error, 'Error loading audio'),
//       );
//     }
//   }

//   SnackBar snack(IconData messIcon, String errorText) {
//     return SnackBar(
//       behavior: SnackBarBehavior.floating,
//       margin: const EdgeInsets.all(16),
//       content: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           Icon(
//             messIcon,
//             size: 50,
//             color: Colors.red,
//           ),
//           Text(
//             errorText,
//             style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance?.removeObserver(this);
//     _scrollController.dispose();
//     //widget.player.dispose();
//     super.dispose();
//   }

//   /// Collects the data useful for displaying in a seek bar, using a handy
//   /// feature of rx_dart to combine the 3 streams of interest into one.
//   Stream<PositionData> get _positionDataStream =>
//       Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
//           widget.player.positionStream,
//           widget.player.bufferedPositionStream,
//           widget.player.durationStream,
//           (position, bufferedPosition, duration) => PositionData(
//               position, bufferedPosition, duration ?? Duration.zero));
//   String dateToString(DateTime dt) {
//     DateFormat dateFormat = DateFormat('dd-MM-yyyy');
//     return 'Release date: ${dateFormat.format(dt)}';
//   }

//   String totime(int ms) {
//     Duration dur = Duration(milliseconds: ms);
//     String durString = dur.toString();
//     List<String> splDur = durString.split('.');
//     return 'Duration: ${splDur[0]}';
//   }

//   PositionService posService = PositionService();
//   @override
//   Widget build(BuildContext context) {
//     var podsql = context.read<PodcastServices>();
//     return Scaffold(
//         body: isLoaded
//             ? SafeArea(
//                 child: CustomScrollView(
//                   controller: _scrollController,
//                   slivers: [
//                     SliverAppBar(
//                       leading: BackButton(onPressed: () {
//                         if (widget.player.position >
//                             const Duration(minutes: 2)) {
//                           posService.savePosition(
//                               episodeName, widget.player.position);
//                         }
//                         Navigator.pop(context, widget.player.playing);
//                       }),
//                       actions: [
//                         // ElevatedButton(
//                         //     onPressed: () async {
//                         //       print(await context
//                         //           .read<PodcastServices>()
//                         //           .deleteDB());
//                         //     },
//                         //   child: Text('deleteDb')),
//                         !isFavorite
//                             ? Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: TextButton(
//                                   child: const Text('Add to favorites'),
//                                   onPressed: () async {
//                                     PodFavorite pod = PodFavorite(
//                                         podcastName: widget.podcastName,
//                                         podcastImage: podcastImage,
//                                         podcastFeed: itunesPodcastId);
//                                     await podsql.addPodcast(pod);
//                                     setState(() {
//                                       isFavorite = true;
//                                     });

//                                     //show message
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                         snack(
//                                             Icons.check, 'Added to favorites'));
//                                   },
//                                 ),
//                               )
//                             : const SizedBox()
//                       ],
//                       backgroundColor: const Color(0x002e2e2e),
//                       shadowColor: const Color(0x002e2e2e),
//                       snap: true,
//                       floating: true,
//                       expandedHeight: 280,
//                       flexibleSpace: FlexibleSpaceBar(
//                         background: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 6.0),
//                           // add dummy image if error
//                           child: Column(
//                             children: [
//                               const SizedBox(height: 40),
//                               CachedNetworkImage(
//                                 imageUrl: podcastImage,
//                                 width: 200,
//                                 errorWidget: (context, url, error) =>
//                                     const Image(
//                                         image:
//                                             AssetImage('assets/images/dd.png')),
//                                 placeholder: (context, podcastImage) =>
//                                     const Center(
//                                         child: CircularProgressIndicator()),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     SliverToBoxAdapter(
//                       child: Center(
//                           child: PlayerButtons(
//                               widget.player, isSelected, context)),
//                     ),
//                     SliverToBoxAdapter(
//                       child: StreamBuilder<PositionData>(
//                         stream: _positionDataStream,
//                         builder: (context, snapshot) {
//                           final positionData = snapshot.data;
//                           return SliderBar(
//                               audioPlayer: widget.player,
//                               duration: positionData?.duration ?? Duration.zero,
//                               position: positionData?.position ?? Duration.zero,
//                               bufferedPosition:
//                                   positionData?.bufferedPosition ??
//                                       Duration.zero);
//                         },
//                       ),
//                     ),
//                     SliverFixedExtentList(
//                         delegate: SliverChildBuilderDelegate((context, index) {
//                           final episode = episodes[index + 1];
//                           return Padding(
//                             padding: const EdgeInsets.fromLTRB(20, 2, 20, 5),
//                             child: Container(
//                               height: 100,
//                               padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
//                               decoration: BoxDecoration(
//                                 border: Border.all(
//                                   width: 1,
//                                   color: tappedIndex == index
//                                       ? Colors.white
//                                       : Colors.grey,
//                                 ),
//                               ),
//                               child: SingleChildScrollView(
//                                 child: Column(children: [
//                                   GestureDetector(
//                                     onTap: () {
//                                       setState(() {
//                                         isSelected = true;
//                                         tappedIndex = index;
//                                         episodeName = episode.trackName!;
//                                       });
//                                       _scrollController.animateTo(0,
//                                           duration: const Duration(seconds: 2),
//                                           curve: Curves.easeInOutCirc);

//                                       _init(episode);
//                                     },
//                                     child: Column(
//                                       children: [
//                                         Padding(
//                                           padding:
//                                               const EdgeInsets.only(bottom: 12),
//                                           child: Text(episode.trackName!),
//                                         ),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text(
//                                               dateToString(
//                                                   episode.releaseDate ??
//                                                       DateTime.now()),
//                                               style:
//                                                   const TextStyle(fontSize: 9),
//                                             ),
//                                             Text(
//                                               totime(
//                                                   episode.trackTimeMillis ?? 0),
//                                               style:
//                                                   const TextStyle(fontSize: 9),
//                                             )
//                                           ],
//                                         ),
//                                         Text(episode.description ?? ''),
//                                       ],
//                                     ),
//                                   ),
//                                   Align(
//                                     alignment: Alignment.bottomLeft,
//                                     child: TextButton(
//                                         onPressed: () async {
//                                           showDloadIndicator(context, episode);
//                                           await saveEpisode(episode);
//                                           Navigator.pop(context);
//                                         },
//                                         child: const Text('Save Episode')),
//                                   ),
//                                 ]),
//                               ),
//                             ),
//                           );
//                         }, childCount: episodes.length - 1),
//                         itemExtent: 100)
//                   ],
//                 ),
//               )
//             : const Center(child: CircularProgressIndicator()),
//         floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
//         floatingActionButton: FloatingActionButton.small(
//           onPressed: () {
//             widget.player.dispose();
//             SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//           },
//           child: const Icon(Icons.exit_to_app),
//         ));
//   }

//   Future<dynamic> showDloadIndicator(BuildContext context, Episode episode) {
//     return showDialog(
//         barrierDismissible: false,
//         context: context,
//         builder: (BuildContext context) {
//           //dialogContext = context;
//           return AlertDialog(
//             title: const Text('Downloading...'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 LinearProgressIndicator(
//                     value: context.watch<SaveService>().progress),
//                 const Padding(
//                   padding: EdgeInsets.all(8.0),
//                   child: Text('please wait...'),
//                 ),
//                 TextButton(
//                     onPressed: () async {
//                       context.read<SaveService>().token.cancel('cancelled');
//                       String dloadLocation = await context
//                           .read<SaveService>()
//                           .downloadLocation(
//                               episode.collectionName!, episode.trackName);

//                       //clean sql of episode
//                       await context
//                           .read<PodcastServices>()
//                           .deleteSavedEpisode('dummy');
//                       File fileToDelete = File(dloadLocation);
//                       if (fileToDelete.existsSync()) {
//                         fileToDelete.deleteSync();
//                       }
//                       context.read<SaveService>().progress = 0.0;
//                       Navigator.of(context, rootNavigator: true).pop();
//                     },
//                     child: const Text('Cancel'))
//               ],
//             ),
//           );
//         });
//   }

//   Future<void> saveEpisode(episode) async {
//     context.read<SaveService>().refreshToken();
//     var podcastSql = context.read<PodcastServices>();
//     bool check = await podcastSql.checkIfPodcastInDB(episode.collectionName!);
//     if (!check) {
//       PodFavorite pod = PodFavorite(
//         podcastName: episode.collectionName!,
//         podcastImage: episode.artworkUrl600!,
//         podcastFeed: episode.collectionId!,
//       );
//       await podcastSql.addPodcast(pod);
//     }
//     // now save episode to location

//     EpisFavorite favToSave = EpisFavorite(
//       podcastName: episode.collectionName!,
//       podcastImage: episode.artworkUrl600!,
//       episodeName: episode.trackName!,
//       episodeUrl: episode.episodeUrl!,
//       episodeDuration: episode.trackTimeMillis ?? 0,
//       episodeDate: episode.releaseDate!.toIso8601String(),
//       episodeDescription: episode.description!,
//       timestamp: DateTime.now().microsecondsSinceEpoch,
//       position: widget.player.position,
//       dloadLocation: 'dummy',
//     );
//     // print(favToSave.toString());
//     String result = await podcastSql.addFavoriteEpisode(favToSave);

//     if (result == 'Episode added') {
//       String dloadlocation = await context.read<SaveService>().saveEpisode(
//           episode.episodeUrl, episode.collectionName, episode.trackName);
//       await podcastSql.updateSaveLocation(dloadlocation, episode.trackName);
//     } else {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(snack(Icons.check, 'Already in database'));
//     }
//   }
// }
