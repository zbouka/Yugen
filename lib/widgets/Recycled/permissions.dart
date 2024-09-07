import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yugen/widgets/Recycled/download_items.dart';

/// Checks if the [permission] is granted in the device
Future<bool> getPermissionStatus(int permission) async {
  bool isStoragePermission = true;
  bool isPermission = true;
  bool isNotificationPermission = true;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  if (androidInfo.version.sdkInt >= 33) {
    if (permission == 1) {
      isPermission = await Permission.photos.status.isGranted;
    } else if (permission == 2) {
      isPermission = await Permission.videos.status.isGranted;
    } else if (permission == 3) {
      isNotificationPermission = await Permission.notification.status.isGranted;
    }
  } else {
    isStoragePermission = await Permission.storage.status.isGranted;
    isNotificationPermission = await Permission.notification.status.isGranted;
  }
  if (isStoragePermission && isPermission && isNotificationPermission) {
    return true;
  } else {
    return false;
  }
}

/// Checks if permission is granted, if so it downloads the chapter
Future<void> getChapters(String collectionName, String title, String lang,
    bool isManga, bool isSingle,
    {int? chapter, String? path, required List<dynamic> chapters}) async {
  if (await getPermissionStatus(2) && await getPermissionStatus(3)) {
    chapter != null
        ? await writeFiles(collectionName, title, lang, isManga, isSingle,
            chapter: chapter, chapters: chapters)
        : await writeFiles(collectionName, title, lang, isManga, isSingle,
            chapters: chapters);
  } else {
    if (await requestPermission(2) && await requestPermission(3)) {
      chapter != null
          ? await writeFiles(collectionName, title, lang, isManga, isSingle,
              chapter: chapter, chapters: chapters)
          : await writeFiles(collectionName, title, lang, isManga, isSingle,
              chapters: chapters);
    }
  }
}

/// Request the [permission] and returns a bool depending on the result
Future<bool> requestPermission(int permission) async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  PermissionStatus? storage;
  PermissionStatus? perm;
  PermissionStatus? notification;
  if (androidInfo.version.sdkInt >= 33) {
    if (permission == 1) {
      perm = await Permission.photos.request();
      if (perm.isGranted) {
        return true;
      } else {
        return false;
      }
    } else if (permission == 2) {
      perm = await Permission.videos.request();
      if (perm.isGranted) {
        return true;
      } else {
        return false;
      }
    } else if (permission == 3) {
      notification = await Permission.notification.request();
      if (notification.isGranted) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  } else {
    if (permission == 1 || permission == 2) {
      storage = await Permission.storage.request();

      if (storage.isGranted) {
        return true;
      } else {
        return false;
      }
    } else if (permission == 3) {
      notification = await Permission.notification.request();
      if (notification.isGranted) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }
}
