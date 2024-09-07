import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import '../../apis/email.dart';

/// Extension to check if a Future has completed.
extension FutureExtension<T> on Future<T> {
  bool isCompleted() {
    final completer = Completer<T>();
    then(completer.complete).catchError(completer.completeError);
    return completer.isCompleted;
  }
}

Future<void> writeFiles(
  String collectionName,
  String title,
  String lang,
  bool isManga,
  bool isSingle, {
  int? chapter,
  required List<dynamic> chapters,
}) async {
  String? path = await FilePicker.platform.getDirectoryPath();

  if (path == null) {
    // Handle the case where the user cancels the directory selection
    sendErrorMail(false, "ERROR", "No directory selected.");
    return;
  }

  try {
    if (isSingle) {
      final selectedChapters = isManga ? [chapters[chapter!]] : [chapters[0]];
      await writeFilesChapter(
        title,
        lang,
        selectedChapters,
        chapter: chapter,
        isManga: isManga,
        pathDir: path,
      );
    } else {
      await writeFilesChapter(
        title,
        lang,
        chapters,
        isManga: isManga,
        pathDir: path,
      );
    }
  } catch (error) {
    sendErrorMail(false, "ERROR", error.toString());
  }
}

/// Downloads each chapter, verifying that the save path directory is free of forbidden characters
Future<void> writeFilesChapter(
  String title,
  String lang,
  List<dynamic> chapters, {
  String? pathDir,
  int? chapter,
  required bool isManga,
}) async {
  final path = pathDir ?? await FilePicker.platform.getDirectoryPath();
  if (path == null) {
    sendErrorMail(false, "ERROR", "No directory selected.");
    return;
  }

  Directory finalPath = Directory(
    '$path/$title ($lang)'.replaceAll(":", "-").replaceAll("|", "-") +
        (chapter != null && isManga ? '/${'chapter'.tr} ${chapter + 1}' : ''),
  );

  if (!await finalPath.exists()) {
    await finalPath.create(recursive: true);
  }

  if (isManga) {
    for (int i = 0; i < chapters.length; i++) {
      await downloadItem(
        url: chapters[i],
        savePath: finalPath.path,
        title: title,
        isManga: isManga,
        number: (i + 1).toString(),
      );
    }
  } else {
    if (chapter != null) {
      await downloadItem(
        url: chapters[0],
        savePath: finalPath.path,
        title: title,
        isManga: isManga,
        number: (chapter + 1).toString(),
      );
    } else {
      for (int i = 0; i < chapters.length; i++) {
        await downloadItem(
          url: chapters[i],
          savePath: finalPath.path,
          title: title,
          isManga: isManga,
          number: (i + 1).toString(),
        );
      }
    }
  }
}

/// Method used to download a single image or video
Future<void> downloadItem({
  required String url,
  required String savePath,
  required String title,
  required bool isManga,
  required String number,
}) async {
  try {
    await Future.delayed(
        const Duration(seconds: 1)); // Simulate delay if needed
    await FlutterDownloader.enqueue(
      url: url,
      savedDir: savePath,
      fileName: isManga ? "$number.jpg" : "$number.mp4",
      showNotification:
          true, // Show download progress in status bar (for Android)
      openFileFromNotification:
          true, // Click on notification to open downloaded file (for Android)
    );
  } catch (error) {
    sendErrorMail(
      true,
      isManga ? "ERROR DOWNLOAD MANGA" : "ERROR DOWNLOAD ANIME",
      error.toString(),
    );
    Get.back();
  }
}
