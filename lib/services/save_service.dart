import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class SaveService with ChangeNotifier {
  String? podcastName;
  String? episodeName;
  double? progress = 0.0;

  ////      get sd card
  //
  Future<String> getSdPath() async {
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      List<Directory>? extList = await getExternalStorageDirectories();
      List<String> splitList = extList![1].path.split('/');
      String sdPath = '';
      for (int i = 1; i < splitList.length; i++) {
        if (splitList[i] == 'Android') break;
        sdPath += '/${splitList[i]}';
      }
      return sdPath;
    } else {
      return 'denied';
    }
  }

  //
  //           Get directory and path
  //

  Future<String> getDirPath(String podcastName) async {
    String baseDirPath = await getSdPath();
    // print(baseDirPath);
    // print(baseDirPath + '/Podcasts/$podcastName');
    final Directory dir = Directory('$baseDirPath/Podcasts/$podcastName');
    if (await dir.exists()) {
      return dir.path;
    } else {
      await dir.create(recursive: true);
      return dir.path;
    }
  }

  Future<String> saveEpisode(
      String urlPath, String podcastName, String episodeTitle) async {
    Dio dio = Dio();

    String cleanTitle =
        episodeTitle.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ').trim();

    String cleanerTitle = cleanTitle.replaceAll(RegExp('\\s+'), '');
    String fileName = cleanerTitle.substring(0, min(cleanerTitle.length, 20));

    String dirPath = await getDirPath(podcastName);
    final savePath = dirPath + '/$fileName.mp3';

    try {
      await dio.download(urlPath, savePath,
          onReceiveProgress: (downloaded, totalsize) {
        progress = downloaded / totalsize;
        notifyListeners();
        print(progress);
      });
      progress = 0.0;
      notifyListeners();
      print('downloaded');
      return savePath;
    } catch (e) {
      print(e.toString());
      throw Exception('problems');
    }
  }
}