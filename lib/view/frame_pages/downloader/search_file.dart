import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:motafawk/controller/download_files_controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../vars.dart' as v;
import '../../../funs.dart' as f;
import 'package:jiffy/jiffy.dart';

class SearchFile extends SearchDelegate {

  final String? downloadId;
  SearchFile({this.downloadId = ""});

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = f.themeSearch(context);
    assert(theme != null);
    return theme;
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () async {
        close(context, null);
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () async {
          if(query.isEmpty){
            close(context, null);
          }else {
            query = "";
          }
        },
      ),
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: Text("Result", style: TextStyle(color: Colors.black),),
    );
  }

  searchBody() {
    return GetBuilder<DownloadFilesController>(
        builder: (controller) {
          print("query: ${query}");
          return FutureBuilder(
            future: FlutterDownloader.loadTasksWithRawQuery(
              query: "select * from task where `file_name` like '%$query%' order by time_created desc;"
            ),
            builder: (context, AsyncSnapshot<List<DownloadTask>?> snapshot){
              if(snapshot.hasData){
                if(snapshot.data!.length == 0){
                  return Center(
                    child: Text(
                      "لا توجد ملفات تم تنزيلها",
                      style: TextStyle(
                          fontSize: v.lg
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, int i){
                    final item = snapshot.data![i];
                    File file = File("${item.savedDir}/${item.filename}");
                    String fileSizeStr = "0";
                    if(file.existsSync()) {
                      double fileSize = (file.lengthSync() / (1024 * 1024));
                      fileSizeStr = num.parse((fileSize).toStringAsFixed(2)).toString();
                      if (fileSizeStr.endsWith(".0")) {
                        fileSizeStr = fileSizeStr.replaceAll(".0", "");
                      }
                    }
                    return Material(
                      color: (item.taskId == downloadId)? Colors.blueGrey[200]: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          print("f.checkExistFile(item): ${f.checkExistFile(item)}");
                          if(f.checkExistFile(item) == false){return;}
                          FlutterDownloader.open(taskId: item.taskId);
                        },
                        child: Container(
                          width: Get.width,
                          padding: EdgeInsets.all(4),
                          child: Row(
                            children: [
                              SizedBox(width: 4,),
                              Column(
                                children: [
                                  SizedBox(height: 8,),
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: v.secondarycolor
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.fileLines,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  SizedBox(height: 4,),
                                  Text(
                                    "${fileSizeStr} MB",
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                      fontSize: v.sm - 1,
                                      // fontWeight: FontWeight.w600
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 8,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${item.filename}",
                                      style: TextStyle(
                                        fontFamily: v.fn,
                                        color: Colors.black,
                                        fontSize: v.normal,
                                      ),
                                    ),
                                    SizedBox(height: 8,),
                                    Text(
                                      "${Jiffy.parseFromMillisecondsSinceEpoch(item.timeCreated).fromNow()}" + ((item.progress != 100)? " . ${item.progress}%": ""),
                                      style: TextStyle(
                                          fontFamily: v.fn,
                                          color: v.tertiarycolor[700],
                                          fontSize: v.sm
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              if(item.status == DownloadTaskStatus.running || item.status == DownloadTaskStatus.paused)
                                Row(
                                  children: [
                                    if(item.status == DownloadTaskStatus.running)
                                      InkWell(
                                        child: Container(
                                          padding: EdgeInsets.all(6),
                                          child: CircularPercentIndicator(
                                              radius: 20.0,
                                              lineWidth: 5,
                                              progressColor: v.primarycolor,
                                              percent: item.progress/100,
                                              center: Icon(Icons.pause)
                                          ),
                                        ),
                                        onTap: () async {
                                          await FlutterDownloader.pause(taskId: item.taskId);
                                          await Future.delayed(Duration(milliseconds: 500));
                                          controller.update();
                                        },
                                      ),
                                    if(item.status == DownloadTaskStatus.paused)
                                      InkWell(
                                        child: Container(
                                          padding: EdgeInsets.all(6),
                                          child: CircularPercentIndicator(
                                              radius: 20.0,
                                              lineWidth: 5,
                                              progressColor: v.primarycolor,
                                              percent: item.progress/100,
                                              center: Icon(FontAwesomeIcons.caretLeft)
                                          ),
                                        ),
                                        onTap: () async {
                                          await FlutterDownloader.resume(taskId: item.taskId);
                                          await Future.delayed(Duration(milliseconds: 500));
                                          controller.update();
                                        },
                                      ),
                                    IconButton(
                                      icon: Icon(Icons.close, color: Colors.black,),
                                      onPressed: () async {
                                        if(File("${item.savedDir}/${item.filename}").existsSync()){
                                          File("${item.savedDir}/${item.filename}").deleteSync();
                                        }
                                        await Future.delayed(Duration(milliseconds: 500));
                                        FlutterDownloader.remove(taskId: item.taskId, shouldDeleteContent: true).then((value) {
                                          Fluttertoast.showToast(
                                              msg: "تم حذف: ${item.filename}",
                                              backgroundColor: Colors.amber,
                                              textColor: Colors.black,
                                              gravity: ToastGravity.CENTER
                                          );
                                          controller.update();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              if(item.status == DownloadTaskStatus.failed || item.status == DownloadTaskStatus.canceled)
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.black,),
                                  onPressed: () async {
                                    if(File("${item.savedDir}/${item.filename}").existsSync()){
                                      File("${item.savedDir}/${item.filename}").deleteSync();
                                    }
                                    await Future.delayed(Duration(milliseconds: 500));
                                    FlutterDownloader.remove(taskId: item.taskId, shouldDeleteContent: true).then((value) {
                                      Fluttertoast.showToast(
                                          msg: "تم حذف: ${item.filename}",
                                          backgroundColor: Colors.amber,
                                          textColor: Colors.black,
                                          gravity: ToastGravity.CENTER
                                      );
                                      controller.update();
                                    });
                                  },
                                ),
                              if(item.status == DownloadTaskStatus.complete)
                                PopupMenuButton<int>(
                                  padding: EdgeInsets.zero,
                                  elevation: 2,
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 0,
                                      padding: EdgeInsets.symmetric(horizontal: 4),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.share,
                                            color: v.secondarycolor,
                                            size: 24,
                                          ),
                                          SizedBox(width: 6,),
                                          Text(
                                            "مشاركة",
                                            style: TextStyle(
                                                fontSize: v.normal
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 1,
                                      padding: EdgeInsets.symmetric(horizontal: 4),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 24,
                                          ),
                                          SizedBox(width: 6,),
                                          Text(
                                            "حذف",
                                            style: TextStyle(
                                                fontSize: v.normal
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (int i) async {
                                    if(i == 0){
                                      if(f.checkExistFile(item) == false){return;}
                                      await Share.shareFiles(["${item.savedDir}/${item.filename}"]);
                                    }
                                    else if(i == 1){
                                      if(File("${item.savedDir}/${item.filename}").existsSync()){
                                        File("${item.savedDir}/${item.filename}").deleteSync();
                                      }
                                      FlutterDownloader.remove(taskId: item.taskId, shouldDeleteContent: true).then((value) {
                                        Fluttertoast.showToast(
                                            msg: "تم حذف: ${item.filename}",
                                            backgroundColor: Colors.amber,
                                            textColor: Colors.black,
                                            gravity: ToastGravity.CENTER
                                        );
                                        controller.update();
                                      });
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, int i){
                    return Divider(height: 1, color: v.tertiarycolor,);
                  },
                );
              }
              else if(snapshot.hasError){
                return Text(
                  "خطا",
                  style: TextStyle(
                      fontSize: v.lg
                  ),
                );
              }else{
                return Text(
                  "انتظر ...",
                  style: TextStyle(
                      fontSize: v.lg
                  ),
                );
              }
            },
          );
        }
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return searchBody();
  }

}
