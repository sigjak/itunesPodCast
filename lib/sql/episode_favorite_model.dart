// ignore_for_file: unnecessary_this, prefer_adjacent_string_concatenation

const String favoriteEpisodesTable = 'favoriteEpisodesTable';

class EpisodeFavFields {
  static const String id = 'id';
  static const String podcastName = 'podcastName';
  static const String episodeName = 'episodeName';
  static const String episodeUrl = 'episodeUrl';
  static const String episodeDate = 'episodeDate';
  static const String episodeDescription = 'episodeDescription';
  static const String timestamp = 'timestamp';
  static const String position = 'position';
  static const String isDownloaded = 'isDownloaded';
  static const String dloadLocation = 'dloadLocation';

  static final List<String> allFields = [
    id,
    podcastName,
    episodeName,
    episodeUrl,
    episodeDate,
    episodeDescription,
    timestamp,
    position,
    isDownloaded,
    dloadLocation
  ];
}

class EpisFavorite {
  int? id;
  String podcastName;
  String episodeName;
  String episodeDate;
  String episodeUrl;
  String episodeDescription;
  int timestamp;
  Duration? position;
  bool isDownloaded;
  String? dloadLocation;

  EpisFavorite(
      {this.id,
      required this.podcastName,
      required this.episodeName,
      required this.episodeUrl,
      required this.episodeDate,
      required this.episodeDescription,
      required this.timestamp,
      this.position,
      this.isDownloaded = false,
      this.dloadLocation});

  Map<String, dynamic> toJson() => {
        EpisodeFavFields.id: id,
        EpisodeFavFields.podcastName: podcastName,
        EpisodeFavFields.episodeName: episodeName,
        EpisodeFavFields.episodeUrl: episodeUrl,
        EpisodeFavFields.episodeDate: episodeDate,
        EpisodeFavFields.episodeDescription: episodeDescription,
        EpisodeFavFields.timestamp: timestamp,
        EpisodeFavFields.position:
            position != null ? position!.inMilliseconds : 0,
        EpisodeFavFields.isDownloaded: isDownloaded ? 1 : 0,
        EpisodeFavFields.dloadLocation: dloadLocation
      };

  static EpisFavorite fromJson(Map<String, dynamic> json) => EpisFavorite(
      id: json[EpisodeFavFields.id] as int?,
      podcastName: json[EpisodeFavFields.podcastName] as String,
      episodeName: json[EpisodeFavFields.episodeName] as String,
      episodeUrl: json[EpisodeFavFields.episodeUrl] as String,
      episodeDate: json[EpisodeFavFields.episodeDate] as String,
      episodeDescription: json[EpisodeFavFields.episodeDescription] as String,
      timestamp: json[EpisodeFavFields.timestamp] as int,
      position: Duration(milliseconds: json[EpisodeFavFields.position]),
      isDownloaded: json[EpisodeFavFields.isDownloaded] == 1 ? true : false,
      dloadLocation: json[EpisodeFavFields.dloadLocation] as String);

  @override
  // ignore: avoid_renaming_method_parameters
  bool operator ==(covariant EpisFavorite episode) {
    return (this.episodeName == episode.episodeName);
  }

  @override
  int get hashCode {
    return episodeName.hashCode;
  }

  @override
  String toString() {
    return '${EpisodeFavFields.id}: $id\n'
            '${EpisodeFavFields.podcastName} $podcastName\n'
            '${EpisodeFavFields.episodeName}: $episodeName\n'
            '${EpisodeFavFields.episodeUrl}: $episodeUrl\n'
            '${EpisodeFavFields.episodeDate}: $episodeDate\n' +
        '${EpisodeFavFields.episodeDescription}: $episodeDescription\n,' +
        '${EpisodeFavFields.timestamp}: $timestamp\n,' +
        '${EpisodeFavFields.isDownloaded}: $isDownloaded\n' +
        '${EpisodeFavFields.position}: $position' +
        '${EpisodeFavFields.dloadLocation}: $dloadLocation';
  }
}