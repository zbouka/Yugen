import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:yugen/assets/loading.dart';

/// Class in testing mode for now, and it will be like a download center for the app
class OfflineDownloads extends StatefulWidget with WidgetsBindingObserver {
  const OfflineDownloads({super.key});

  @override
  State<OfflineDownloads> createState() => _OfflineDownloadsState();
}

class _OfflineDownloadsState extends State<OfflineDownloads> {
  final ReceivePort _port = ReceivePort();
  List<Map> downloadsListMaps = [];
  String value = "";
  @override
  void initState() {
    super.initState();
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    FlutterDownloader.cancelAll();
    super.dispose();
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      String id = data[0];
      int status = data[1];
      int progress = data[2];
      var task = downloadsListMaps.where((element) => element['id'] == id);
      for (var element in task) {
        element['progress'] = progress;
        element['status'] = status;
        setState(() {});
      }
    });
  }

  Future<bool> _getAllDownloadTasks() async {
    final allDownloadTasks = await FlutterDownloader.loadTasks();

    var allCompleted = true;
    for (final downloadTask in allDownloadTasks!) {
      if (downloadTask.status == DownloadTaskStatus.complete) {
        print('this task is finished');
      } else {
        allCompleted = false;
      }
    }
    return allCompleted;
  }

  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  Future<List<Map<dynamic, dynamic>>> task() async {
    List<DownloadTask>? getTasks = await FlutterDownloader.loadTasks();
    getTasks?.forEach((task) {
      Map map = {};
      map['status'] = task.status is int
          ? DownloadTaskStatus.values[task.status as int]
          : task.status;
      map['progress'] = task.progress;
      map['id'] = task.taskId;
      map['filename'] = task.filename;
      map['savedDirectory'] = task.savedDir;
      value = task.filename!;
      downloadsListMaps.add(map);
    });
    return downloadsListMaps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Downloads'),
      ),
      body: FutureBuilder(
          future: task(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loading();
            } else if (snapshot.connectionState == ConnectionState.done &&
                snapshot.data == null) {
              return const Center(child: Text("No Downloads yet"));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!
                    .where((n) => n["filename"] == "1.jpg")
                    .toList()
                    .length,
                itemBuilder: (BuildContext context, int i) {
                  Map map = snapshot.data![i];
                  DownloadTaskStatus status = map['status'];
                  String id = map['id'];
                  String savedDirectory = map['savedDirectory'];
                  List<FileSystemEntity> directories =
                      Directory(savedDirectory).listSync(followLinks: true);
                  FileSystemEntity? file =
                      directories.isNotEmpty ? directories.first : null;
                  return GestureDetector(
                    onTap: () {
                      if (status == DownloadTaskStatus.complete) {
                        showDialogue(file! as File);
                      }
                    },
                    child: Card(
                      elevation: 10,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ListTile(
                            isThreeLine: false,
                            title: Text("${"chapter".tr} ${i + 1}"),
                            subtitle: downloadStatus(status),
                            trailing: SizedBox(
                              width: 60,
                              child: buttons(status, id, i, snapshot.data!),
                            ),
                          ),
                          /* ...snapshot.data!.map(
                                (e) => Expanded(child: Text(e["filename"]))),
                            ...snapshot.data!.map((e) => Expanded(
                                child: Text((e['progress']).toString()))),*/
                          Text(value),
                          const Row(
                            children: <Widget>[
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10)
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }),
    );
  }

  Widget downloadStatus(DownloadTaskStatus status) {
    return status == DownloadTaskStatus.canceled
        ? const Text('Download canceled')
        : status == DownloadTaskStatus.complete
            ? const Text('Download completed')
            : status == DownloadTaskStatus.failed
                ? const Text('Download failed')
                : status == DownloadTaskStatus.paused
                    ? const Text('Download paused')
                    : status == DownloadTaskStatus.running
                        ? const Text('Downloading..')
                        : const Text('Download waiting');
  }

  Widget buttons(
      DownloadTaskStatus status, String taskid, int index, List<Map> a) {
    void changeTaskID(String taskid, String newTaskID) {
      Map task = a.firstWhere(
        (element) => element['taskId'] == taskid,
      );
      task['taskId'] = newTaskID;
      setState(() {});
    }

    return status == DownloadTaskStatus.canceled
        ? GestureDetector(
            child: const Icon(Icons.cached, size: 20, color: Colors.green),
            onTap: () {
              FlutterDownloader.retry(taskId: taskid).then((newTaskID) {
                changeTaskID(taskid, newTaskID!);
              });
            },
          )
        : status == DownloadTaskStatus.failed
            ? GestureDetector(
                child: const Icon(Icons.cached, size: 20, color: Colors.green),
                onTap: () {
                  FlutterDownloader.retry(taskId: taskid).then((newTaskID) {
                    changeTaskID(taskid, newTaskID!);
                  });
                },
              )
            : status == DownloadTaskStatus.paused
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(
                        child: const Icon(Icons.play_arrow,
                            size: 20, color: Colors.blue),
                        onTap: () {
                          FlutterDownloader.resume(taskId: taskid).then(
                            (newTaskID) => changeTaskID(taskid, newTaskID!),
                          );
                        },
                      ),
                      GestureDetector(
                        child: const Icon(Icons.close,
                            size: 20, color: Colors.red),
                        onTap: () {
                          FlutterDownloader.cancel(taskId: taskid);
                        },
                      )
                    ],
                  )
                : status == DownloadTaskStatus.running
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            child: const Icon(Icons.pause,
                                size: 20, color: Colors.green),
                            onTap: () {
                              FlutterDownloader.pause(taskId: taskid);
                            },
                          ),
                          GestureDetector(
                            child: const Icon(Icons.close,
                                size: 20, color: Colors.red),
                            onTap: () {
                              FlutterDownloader.cancel(taskId: taskid);
                            },
                          )
                        ],
                      )
                    : status == DownloadTaskStatus.complete
                        ? GestureDetector(
                            child: const Icon(Icons.delete,
                                size: 20, color: Colors.red),
                            onTap: () {
                              a.removeAt(index);
                              FlutterDownloader.remove(
                                  taskId: taskid, shouldDeleteContent: true);
                              setState(() {});
                            },
                          )
                        : Container();
  }

  showDialogue(File file) {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                child: Image.file(
                  file,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        });
  }
}
