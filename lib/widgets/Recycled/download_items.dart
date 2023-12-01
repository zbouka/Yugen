import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:get/route_manager.dart';
import '../../apis/email.dart';

/// For now its on testing mode

extension FutureExtension<T> on Future<T> {
  /// Checks if the future has returned a value, using a Completer.
  bool isCompleted() {
    final completer = Completer<T>();
    then(completer.complete).catchError(completer.completeError);
    return completer.isCompleted;
  }
}

writeFiles(String collectionName, String title, String lang, bool isManga,
    bool isSingle,
    {int? chapter, required List<dynamic> chapters}) async {
  String? path = await FilePicker.platform.getDirectoryPath();

  if (path != null) {
    if (isManga && !isSingle) {
      try {
        writeFilesChapter(title, lang, chapters, isManga: true, pathDir: path);
      } catch (error) {
        sendErrorMail(false, "ERROR", error);
      }
    } else if (!isManga && !isSingle) {
      try {
        writeFilesChapter(title, lang, chapters, isManga: false, pathDir: path);
      } catch (error) {
        sendErrorMail(false, "ERROR", error);
      }
    } else if (isManga && isSingle) {
      writeFilesChapter(title, lang, chapters,
          chapter: chapter, isManga: true, pathDir: path);
    } else if (!isManga && isSingle) {
      try {
        List<String> asd = [chapters[chapter!]];
        writeFilesChapter(title, lang, asd,
            isManga: false, pathDir: path, chapter: chapter);
      } catch (error) {
        sendErrorMail(false, "ERROR", error);
      }
    }
  }
}

/// Here we download each chapter, verifying that the save path directory is free of any forbidden characters
Future<void> writeFilesChapter(
    String title, String lang, List<dynamic> chapters,
    {String? pathDir, int? chapter, required bool isManga}) async {
  Directory? finalPath;
  int number = 0;
  if (pathDir == null) {
    var pathDir = await FilePicker.platform.getDirectoryPath();
    finalPath = Directory('$pathDir/$title ($lang)/${'chapter'.tr} $chapter'
        .replaceAll(":", "-")
        .replaceAll("|", "-"));
  } else {
    finalPath = Directory(
        '$pathDir/$title ($lang)'.replaceAll(":", "-").replaceAll("|", "-"));
    if (await finalPath.exists() == false) {
      await finalPath.create();
    }
  }
  if (chapter != null && isManga == true) {
    finalPath = Directory(
        '$pathDir/$title ($lang)/${'chapter'.tr} ${chapter + 1}'
            .replaceAll(":", "-")
            .replaceAll("|", "-"));
    if (await finalPath.exists() == false) {
      await finalPath.create();
    }
    for (var i = 0; i < chapters.length; i++) {
      number = i + 1;

      downloadItem(
        isManga: isManga,
        savePath: finalPath.path,
        title: title,
        number: (i + 1).toString(),
        url: chapters[i],
      );
    }
    return;
  } else if (chapter != null && isManga == false) {
    downloadItem(
        isManga: isManga,
        savePath: finalPath.path,
        title: title,
        number: (chapter + 1).toString(),
        url: chapters[0]);
    return;
  } else if (chapter == null && isManga == false) {
    for (int i = 0; i < chapters.length; i++) {
      downloadItem(
          isManga: isManga,
          savePath: finalPath.path,
          title: title,
          number: (i + 1).toString(),
          url: chapters[i]);
    }
    return;
  } else {
    if (await finalPath.exists() == false) {
      await finalPath.create(recursive: true);
    }

    for (int j = 0; j < chapters.length; j++) {
      finalPath = Directory('$pathDir/$title ($lang)/${'chapter'.tr} ${j + 1}'
          .replaceAll(":", "-")
          .replaceAll("|", "-"));
      if (await finalPath.exists() == false) {
        await finalPath.create(recursive: true);
      }
      for (int k = 0;
          k < (chapters[j]["images"] as List<dynamic>).length;
          k++) {
        number = k + 1;

        await downloadItem(
            isManga: isManga,
            savePath: finalPath.path,
            title: title,
            number: number.toString(),
            url: (chapters)[j]["images"][k]);
      }
    }
  }
}

/// Method used to download a single image or single video
Future<void> downloadItem(
    {required String url,
    required String savePath,
    required String title,
    required bool isManga,
    required String number}) async {
  try {
    //You can download a single file

    Future.delayed(const Duration(seconds: 1));
    //You can download a single file

    try {
      await FlutterDownloader.enqueue(
        url: url,
        savedDir: savePath,
        fileName: isManga ? "$number.jpg" : "$number.mp4",

        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );
    } catch (error) {
      print(error);
    }
  } on Exception catch (e) {
    sendErrorMail(true,
        isManga == true ? "ERROR DOWNLOAD MANGA" : "ERROR DOWNLOAD ANIME", e);
    Get.back();
  }
  return;
}
