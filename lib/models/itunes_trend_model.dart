// //https://itunes.apple.com/search?term=podcast&country=is&lang=is&genreId=1482&limit=2
// class ItunesTrend {
//   int resultCount;
//   List<Results> results;

//   ItunesTrend({this.resultCount, this.results});

//   ItunesTrend.fromJson(Map<String, dynamic> json) {
//     resultCount = json['resultCount'];
//     if (json['results'] != null) {
//       results = new List<Results>();
//       json['results'].forEach((v) {
//         results.add(new Results.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['resultCount'] = this.resultCount;
//     if (this.results != null) {
//       data['results'] = this.results.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class Results {
//   String wrapperType;
//   String kind;
//   int collectionId;
//   int trackId;
//   String artistName;
//   String collectionName;
//   String trackName;
//   String collectionCensoredName;
//   String trackCensoredName;
//   String collectionViewUrl;
//   String feedUrl;
//   String trackViewUrl;
//   String artworkUrl30;
//   String artworkUrl60;
//   String artworkUrl100;
//   int collectionPrice;
//   int trackPrice;
//   int trackRentalPrice;
//   int collectionHdPrice;
//   int trackHdPrice;
//   int trackHdRentalPrice;
//   String releaseDate;
//   String collectionExplicitness;
//   String trackExplicitness;
//   int trackCount;
//   String country;
//   String currency;
//   String primaryGenreName;
//   String contentAdvisoryRating;
//   String artworkUrl600;
//   List<String> genreIds;
//   List<String> genres;
//   int artistId;
//   String artistViewUrl;

//   Results(
//       {this.wrapperType,
//       this.kind,
//       this.collectionId,
//       this.trackId,
//       this.artistName,
//       this.collectionName,
//       this.trackName,
//       this.collectionCensoredName,
//       this.trackCensoredName,
//       this.collectionViewUrl,
//       this.feedUrl,
//       this.trackViewUrl,
//       this.artworkUrl30,
//       this.artworkUrl60,
//       this.artworkUrl100,
//       this.collectionPrice,
//       this.trackPrice,
//       this.trackRentalPrice,
//       this.collectionHdPrice,
//       this.trackHdPrice,
//       this.trackHdRentalPrice,
//       this.releaseDate,
//       this.collectionExplicitness,
//       this.trackExplicitness,
//       this.trackCount,
//       this.country,
//       this.currency,
//       this.primaryGenreName,
//       this.contentAdvisoryRating,
//       this.artworkUrl600,
//       this.genreIds,
//       this.genres,
//       this.artistId,
//       this.artistViewUrl});

//   Results.fromJson(Map<String, dynamic> json) {
//     wrapperType = json['wrapperType'];
//     kind = json['kind'];
//     collectionId = json['collectionId'];
//     trackId = json['trackId'];
//     artistName = json['artistName'];
//     collectionName = json['collectionName'];
//     trackName = json['trackName'];
//     collectionCensoredName = json['collectionCensoredName'];
//     trackCensoredName = json['trackCensoredName'];
//     collectionViewUrl = json['collectionViewUrl'];
//     feedUrl = json['feedUrl'];
//     trackViewUrl = json['trackViewUrl'];
//     artworkUrl30 = json['artworkUrl30'];
//     artworkUrl60 = json['artworkUrl60'];
//     artworkUrl100 = json['artworkUrl100'];
//     collectionPrice = json['collectionPrice'];
//     trackPrice = json['trackPrice'];
//     trackRentalPrice = json['trackRentalPrice'];
//     collectionHdPrice = json['collectionHdPrice'];
//     trackHdPrice = json['trackHdPrice'];
//     trackHdRentalPrice = json['trackHdRentalPrice'];
//     releaseDate = json['releaseDate'];
//     collectionExplicitness = json['collectionExplicitness'];
//     trackExplicitness = json['trackExplicitness'];
//     trackCount = json['trackCount'];
//     country = json['country'];
//     currency = json['currency'];
//     primaryGenreName = json['primaryGenreName'];
//     contentAdvisoryRating = json['contentAdvisoryRating'];
//     artworkUrl600 = json['artworkUrl600'];
//     genreIds = json['genreIds'].cast<String>();
//     genres = json['genres'].cast<String>();
//     artistId = json['artistId'];
//     artistViewUrl = json['artistViewUrl'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['wrapperType'] = this.wrapperType;
//     data['kind'] = this.kind;
//     data['collectionId'] = this.collectionId;
//     data['trackId'] = this.trackId;
//     data['artistName'] = this.artistName;
//     data['collectionName'] = this.collectionName;
//     data['trackName'] = this.trackName;
//     data['collectionCensoredName'] = this.collectionCensoredName;
//     data['trackCensoredName'] = this.trackCensoredName;
//     data['collectionViewUrl'] = this.collectionViewUrl;
//     data['feedUrl'] = this.feedUrl;
//     data['trackViewUrl'] = this.trackViewUrl;
//     data['artworkUrl30'] = this.artworkUrl30;
//     data['artworkUrl60'] = this.artworkUrl60;
//     data['artworkUrl100'] = this.artworkUrl100;
//     data['collectionPrice'] = this.collectionPrice;
//     data['trackPrice'] = this.trackPrice;
//     data['trackRentalPrice'] = this.trackRentalPrice;
//     data['collectionHdPrice'] = this.collectionHdPrice;
//     data['trackHdPrice'] = this.trackHdPrice;
//     data['trackHdRentalPrice'] = this.trackHdRentalPrice;
//     data['releaseDate'] = this.releaseDate;
//     data['collectionExplicitness'] = this.collectionExplicitness;
//     data['trackExplicitness'] = this.trackExplicitness;
//     data['trackCount'] = this.trackCount;
//     data['country'] = this.country;
//     data['currency'] = this.currency;
//     data['primaryGenreName'] = this.primaryGenreName;
//     data['contentAdvisoryRating'] = this.contentAdvisoryRating;
//     data['artworkUrl600'] = this.artworkUrl600;
//     data['genreIds'] = this.genreIds;
//     data['genres'] = this.genres;
//     data['artistId'] = this.artistId;
//     data['artistViewUrl'] = this.artistViewUrl;
//     return data;
//   }
// }
