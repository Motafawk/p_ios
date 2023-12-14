import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:motafawk/controller/download_files_controller.dart';
import 'package:motafawk/controller/downloaded_files_controller.dart';
import 'package:motafawk/data/sections_data.dart';
import 'package:motafawk/data/subjects_data.dart';
import 'package:motafawk/data/units_data.dart';
import 'package:motafawk/launch_link.dart';
import 'package:motafawk/model/db/db_helper.dart';
import 'package:motafawk/model/vunit_model.dart';
import 'package:motafawk/view/frame_pages/pdf_reader.dart';
import 'package:motafawk/view/setup/choose_class.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controller/ads_manager_controller.dart';
import '../../controller/bottom_navigation_controller.dart';
import '../../controller/frame_pages_controller.dart';
import '../../controller/subjects_controller.dart';
import '../../model/subject_model.dart';
import '../../my_widgets.dart';
import '../../tmp/my_classes.dart';
import '../../tmp/my_sfpdf.dart';
import '../../vars.dart' as v;
import '../../funs.dart' as f;

import 'package:flutter_animate/flutter_animate.dart';

class Home extends StatefulWidget {
  final String condition;
  final  String fromPage;
  const Home({Key? key, this.condition = " 1 ", required this.fromPage}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  AdsManagerController adsManagerController = Get.put(AdsManagerController());

  UnitsData unitsData = Get.put(UnitsData());

  DownloadedFilesController downloadedFilesController = Get.put(DownloadedFilesController());

  SubjectController subjectController = Get.put(SubjectController());

  DownloadFilesController downloadFilesController = Get.put(DownloadFilesController());

  final FramePagesController framePagesController = Get.put(FramePagesController());
  BottomNavigationController bottomNavigationController = Get.put(BottomNavigationController());

  scrollPosition() {
    if (bottomNavigationController.currentIndex == 0) {
      framePagesController.scrollController.jumpTo(framePagesController.scrollPositionDownload);
    }
    else if (bottomNavigationController.currentIndex == 1) {
      framePagesController.scrollController.jumpTo(framePagesController.scrollPositionFavorite);
    }
    else if (bottomNavigationController.currentIndex == 2) {
      framePagesController.scrollController.jumpTo(framePagesController.scrollPositionHome);
    }
    else if (bottomNavigationController.currentIndex == 3) {
      framePagesController.scrollController.jumpTo(framePagesController.scrollPositionContact);
    }
    else if (bottomNavigationController.currentIndex == 4) {
      framePagesController.scrollController.jumpTo(framePagesController.scrollPositionSetting);
    }
  }




  @override
  void initState() {
    super.initState();
    if(widget.fromPage == "downloads") {
      downloadedFilesController.downloadedFiles();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("Home initState");
      // scrollPosition();
      await Future.delayed(Duration(microseconds: 250), () {
        print("scrollPosition scrollPosition");
        scrollPosition();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    print("build Home");
    return GetBuilder<UnitsData>(
        builder: (controller) {
          return FutureBuilder(
            future: controller.getSqlite(
              condition: (widget.fromPage == "downloads")? downloadedFilesController.condition: " ${widget.condition} ",
            ),
            builder: (context, AsyncSnapshot<List> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.length == 0) {
                  return TheresNotData();
                }
                return Column(
                  children: [
                    if(widget.fromPage == "home")
                      Container(
                        padding: EdgeInsetsDirectional.only(top: 8),
                        width: w * 0.95,
                        child: Row(
                          children: [
                            if(v.choiceVSubsystem == null)
                              Expanded(
                              child: Text(
                                "${v.choiceClass!.name} (${v.choiceTerm!.name})",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if(v.choiceVSubsystem != null)
                              Expanded(
                                child: Text(
                                  "${v.choiceClass!.name}.${v.choiceVSubsystem!.systemName} - ${v.choiceVSubsystem!.name} (${v.choiceTerm!.name})",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: v.secondarycolor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                              ),
                              onPressed: () async {
                                Get.to(() => ChooseClass());
                              },
                              child: Text("تغيير"),
                            ),
                          ],
                        ),
                      ),
                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 30 + 60 + 60),
                      itemCount: snapshot.data!.length,
                      // itemCount: 20,
                      itemBuilder: (context, int i) {
                        final item = VUnitModel.fromJson(snapshot.data![i]);
                        String? extension;
                        if(item.file != null) {
                          extension = item.file!.toLowerCase().split(".").last;
                        }
                        String fileName = "";
                        String fileUri = item.file ?? "";
                        if (item.sectionName == item.subjectName) {
                          fileName =
                          "${item.typeNameSingle}.${item.name}.${item.sectionName!.split("&").first}.${item.systemName??''}.${item.subsystemName??''}.${v.choiceClass!.name}.${v
                              .choiceTerm!.name}";
                        } else {
                          fileName =
                          "${item.typeNameSingle}.${item.name}.${item.sectionName!.split("&").first}.${item.subjectName!.split(
                              "&").first}.${item.systemName??''}.${item.subsystemName??''}.${v.choiceClass!.name}.${v.choiceTerm!.name}";
                        }
                        print("fileName: ${fileName}");
                        fileName = fileName.replaceAll("....", ".").replaceAll("...", ".").replaceAll("..", ".");
                        print("fileName: ${fileName}");
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.white,
                            foregroundColor: v.primarycolor,
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                          ),
                          onPressed: () async {

                            int? i = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "home");
                            if(i == 1) return;


                            if(item.file != null) {
                              if (extension == "pdf") {
                                await Get.to(() =>
                                  PdfReader(
                                    fileUri: "${item.file}",
                                    fileName: "${fileName}",
                                    indexes: item.indexes,
                                  ));
                              } else if(extension == "docx" ||
                                extension == "xlsx" ||
                                extension == "zip" ||
                                extension == "rar") {
                                Fluttertoast.showToast(
                                  msg: "ملف من نوع ${extension} يمكنك تنزيله ",
                                  gravity: ToastGravity.CENTER,
                                  backgroundColor: v.tertiarycolor[800],
                                );
                              } else {
                                if(item.file!.contains("http") == true) {
                                  await launchLink(url: item.file!);
                                } else {
                                  await launchLink(url: "${v.link}/${item.file!}");
                                }
                              }
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    SizedBox(width: w, child: f.imageUrl(item.img, boxFit: BoxFit.cover)),
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: Container(color: Colors.black.withOpacity(0.1)),
                                    ),
                                    PositionedDirectional(
                                      end: -23,
                                      top: 12.5,
                                      child: RotationTransition(
                                        turns: AlwaysStoppedAnimation(-45 / 360),
                                        child: Container(
                                          alignment: Alignment.center,
                                          height: 25,
                                          width: 95,
                                          color: Color(int.parse("0xff" + "${item.typeBannerColor}")),
                                          child: Text(
                                            "${item.typeNameSingle}",
                                            style: TextStyle(color: Colors.white, height: 0.9, fontSize: 13),
                                          ),
                                        ),
                                      ),
                                    ),
                                    PositionedDirectional(
                                      bottom: 8,
                                      start: 8,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 30,
                                            height: 30,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: CircleBorder(),
                                                padding: EdgeInsets.zero,
                                                backgroundColor: Colors.white,
                                                foregroundColor: v.primarycolor,
                                              ),
                                              onPressed: () async {
                                                await DbHelper().update(
                                                  table: "units",
                                                  obj: {
                                                    "favorite": (item.favorite == 0) ? 1 : 0,
                                                  },
                                                  condition: " id = ${item.id} ",
                                                );
                                                controller.update();
                                              },
                                              child: Icon(
                                                (item.favorite == 0) ? Icons.favorite_outline : Icons.favorite,
                                                size: 22,
                                                color: (item.favorite == 0) ? v.tertiarycolor[700] : v.primarycolor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsetsDirectional.only(top: 4, bottom: 8, start: 6, end: 0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if(item.sectionName!.split("&").first != item.name)
                                            Container(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${item.sectionName!.split("&").first}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  "${item.name}",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: v.tertiarycolor[800],
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                          if(item.sectionName!.split("&").first == item.name)
                                            Container(
                                              child: Text(
                                                "${item.name}",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if(extension == "docx" ||
                                      extension == "xlsx" ||
                                      extension == "zip" ||
                                      extension == "rar" ||
                                      extension == "pdf")
                                    GetBuilder<DownloadFilesController>(
                                    builder: (controllerDownload) {
                                      final String fileUrlHex = f.convertArabicToHex("${v.filesLink}/${item.file}");
                                      print("item.file from DownloadFilesController: ${item.file}");
                                      return FutureBuilder(
                                        future: FlutterDownloader.loadTasksWithRawQuery(
                                          query: "select * from task where url = '${fileUrlHex}' order by time_created desc;",
                                        ),
                                        builder: (context, AsyncSnapshot<List<DownloadTask>?> snapshot) {
                                          if (snapshot.hasData) {
                                            File file = File("${v.downloadPath}/${fileName}.pdf");
                                            if (snapshot.data!.length == 0) {
                                              print("file path: ${v.downloadPath}/${fileName}.pdf");
                                              return InkWell(
                                                onTap: () async {
                                                  if (file.existsSync()) {
                                                    Get.defaultDialog(
                                                      titlePadding: EdgeInsets.zero,
                                                      title: "",
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                                      content: Column(
                                                        children: [
                                                          Text("الملف ${fileName} موجود بالفعل، هل تريد التنزيل على اية حال؟"),
                                                          SizedBox(height: 16),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                            children: [
                                                              ElevatedButton(
                                                                onPressed: () async {
                                                                  file.deleteSync();
                                                                  f.downloadFile(fileUri, "${fileName}");
                                                                  Get.back();
                                                                },
                                                                child: Text("نعم"),
                                                              ),
                                                              TextButton(
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor: Colors.red,
                                                                  foregroundColor: Colors.white,
                                                                ),
                                                                onPressed: () {
                                                                  Get.back();
                                                                },
                                                                child: Text("لا"),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                  else {
                                                    f.downloadFile(fileUri, "${fileName}");
                                                  }
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                  child: Icon(Icons.arrow_downward_sharp, color: Colors.black),
                                                ),
                                              );
                                            }
                                            else {
                                              final DownloadTask taskItem = snapshot.data![0];
                                              DownloadTaskStatus status = taskItem.status;

                                              if (status == DownloadTaskStatus.complete && file.existsSync()) {
                                                return Container(
                                                  width: 40,
                                                  child: PopupMenuButton(
                                                    iconSize: 24,
                                                    itemBuilder: (context) {
                                                      return [
                                                        PopupMenuItem(
                                                          value: 0,
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.open_in_new, size: 24,),
                                                              SizedBox(width: 8),
                                                              Text("فتح", style: TextStyle(fontSize: 14),),
                                                            ],
                                                          ),
                                                        ),
                                                        PopupMenuItem(
                                                          value: 1,
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.share, size: 24,),
                                                              SizedBox(width: 8),
                                                              Text("مشاركة", style: TextStyle(fontSize: 14),),
                                                            ],
                                                          ),
                                                        ),
                                                        PopupMenuItem(
                                                          value: 2,
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.delete_outline, size: 24, color: Colors.pink[800],),
                                                              SizedBox(width: 8),
                                                              Text("حذف", style: TextStyle(fontSize: 14, color: Colors.pink[800],),),
                                                            ],
                                                          ),
                                                        ),
                                                      ];
                                                    },
                                                    onSelected: (int val) async {
                                                      print("Val: ${val}");
                                                      int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "home");
                                                      if(watchFullRewardedAd == 1) return;
                                                      if(val == 0) {
                                                        if (status == DownloadTaskStatus.complete && !file.existsSync()) {
                                                          print("The file there is not exist in download folder!: ${taskItem}");
                                                          // await Fluttertoast.showToast(
                                                          //   msg: "The file there is not exist in download folder!",
                                                          //   backgroundColor: Colors.amber,
                                                          //   textColor: Colors.black,
                                                          // );
                                                          await FlutterDownloader.loadTasksWithRawQuery(
                                                            query: "delete from task where url = '${fileUrlHex}';",
                                                          );
                                                          print("deleted the '${fileUri}' from db");
                                                          // controller.update();
                                                          f.downloadFile(fileUri, "${fileName}");
                                                        } else {
                                                          await FlutterDownloader.open(taskId: taskItem.taskId);
                                                        }
                                                      }
                                                      else if(val == 1) {
                                                        if(f.checkExistFile(taskItem) == false){return;}
                                                        await Share.shareFiles(["${taskItem.savedDir}/${taskItem.filename}"]);
                                                      }
                                                      else if(val == 2) {
                                                        print("delete file");
                                                        if(File("${taskItem.savedDir}/${taskItem.filename}").existsSync()){
                                                          File("${taskItem.savedDir}/${taskItem.filename}").deleteSync();
                                                        }
                                                        FlutterDownloader.remove(
                                                          taskId: taskItem.taskId,
                                                          shouldDeleteContent: true,
                                                        ).then((value) {
                                                          Fluttertoast.showToast(
                                                              msg: "تم حذف: ${taskItem.filename}",
                                                              backgroundColor: Colors.amber,
                                                              textColor: Colors.black,
                                                              gravity: ToastGravity.CENTER
                                                          );
                                                          controllerDownload.update();
                                                        });
                                                      }
                                                    },
                                                  ),
                                                );
                                              }
                                              else if (status == DownloadTaskStatus.running) {
                                                return InkWell(
                                                  onTap: () async {
                                                    if(file.existsSync()){
                                                      file.deleteSync();
                                                    }
                                                    await Future.delayed(Duration(milliseconds: 500));
                                                    FlutterDownloader.remove(taskId: taskItem.taskId).then((value) {
                                                      Fluttertoast.showToast(
                                                          msg: "تم الغاء: ${taskItem.filename}",
                                                          backgroundColor: Colors.amber,
                                                          textColor: Colors.black,
                                                          gravity: ToastGravity.CENTER
                                                      );
                                                      controller.update();
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                    child: CircularPercentIndicator(
                                                        radius: 20.0,
                                                        lineWidth: 5,
                                                        progressColor: v.primarycolor,
                                                        percent: taskItem.progress/100,
                                                        center: Icon(Icons.close)
                                                    ),
                                                  ),
                                                );
                                              }
                                              else {
                                                if (status == DownloadTaskStatus.failed || status == DownloadTaskStatus.canceled) {
                                                  // Fluttertoast.showToast(
                                                  //   msg: "Failed or canceled download try again",
                                                  //   backgroundColor: Colors.red,
                                                  //   textColor: Colors.black,
                                                  // );
                                                  return InkWell(
                                                    onTap: () async {
                                                      await FlutterDownloader.loadTasksWithRawQuery(
                                                        query: "delete from task where url = '${fileUrlHex}';",
                                                      );
                                                      await file.delete().then((value) {
                                                        print("yes deleted file");
                                                      }).catchError((err) {
                                                        print("no deleted file");
                                                      });
                                                      f.downloadFile(fileUri, "${fileName}");
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                      child: Icon(Icons.arrow_downward_sharp, color: Colors.black),
                                                    ),
                                                  );
                                                }
                                                else {
                                                  if(file.path.split("/").last == taskItem.filename) {
                                                    print("taskItem.filename: ${taskItem.filename}, ${taskItem.status}, ${file.path.split("/").last}");
                                                    // Fluttertoast.showToast(
                                                    //   msg: "The file there is not exist in download folder",
                                                    //   backgroundColor: Colors.red,
                                                    //   textColor: Colors.black,
                                                    // );
                                                  }
                                                  return InkWell(
                                                    onTap: () async {
                                                      await FlutterDownloader.loadTasksWithRawQuery(
                                                        query: "delete from task where url = '${fileUrlHex}';",
                                                      );
                                                      f.downloadFile(fileUri, "${fileName}");
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                      child: Icon(Icons.arrow_downward_sharp, color: Colors.black),
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          }
                                          else if (snapshot.hasError) {
                                            return Text("خطا");
                                          } else {
                                            return Text("...");
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              }
              else if (snapshot.hasError) {
                return ErrorInDb();
              } else {
                return LoadingData();
              }
            },
          );
        }
    );
  }
}

/*
SingleChildScrollView(
        child: Container(
          width: w,
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  // Get.to(() => MyDown());
                },
                child: Text("تنزيلاتي"),
              ),
              ElevatedButton(
                onPressed: () async {
                  // File file = await DefaultCacheManager().getSingleFile("https://savingfood909.github.io/grade192/1-1-اسلامية-توحيد.pdf");
                  // print("path of file: ${file.path}");
                  Get.to(() => MySFPdf(
                    fileUrl: "https://savingfood909.github.io/grade192/1-1-اسلامية-توحيد.pdf",
                    fileName: "رياضيات اول ابتدائي ترم ثاني الوحدة الاولى",
                  ));
                },
                child: Text("My syncfusion pdf"),
              ),
              ElevatedButton(
                onPressed: () async {
                  File file = await DefaultCacheManager()
                      .getSingleFile("https://savingfood909.github.io/grade192/1-1-e-wecan-2.pdf");
                  print("path of file: ${file.path}");
                  Get.to(() => MyPdf(file: file));
                },
                child: Text("pdf viewer"),
              ),
              ElevatedButton(
                onPressed: () async {
                  List? tasks = await FlutterDownloader.loadTasksWithRawQuery(
                    query: "select * from task;",
                  );
                  print("tasks: ${tasks}");
                },
                child: Text("cmd flutter downloader"),
              ),
              ElevatedButton(
                onPressed: () async {
                  File file = File("/sdcard/Download/tmp.pdf");
                  await file.create().then((value) {
                    print("Yes Created: ${value}");
                  }).catchError((err) {
                    print("No Created: ${err}");
                  });
                  await Future.delayed(Duration(seconds: 8));
                  await file.delete().then((value) {
                    print("Yes Deleted: ${value}");
                  }).catchError((err) {
                    print("No Deleted: ${err}");
                  });
                },
                child: Text("Delete file"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Get.to(() => MyClasses());
                },
                child: Text("My Classes"),
              ),
              ElevatedButton(
                onPressed: () async {
                  print("id: ${v.choiceClass!.id}, name: ${v.choiceClass!.name}");
                  print("id: ${v.choiceTerm!.id}, name: ${v.choiceTerm!.name}");
                },
                child: Text("check choose class and term"),
              ),
              ElevatedButton(
                onPressed: () async {
                  List table = await DbHelper().select(column: "*", table: "subjects", condition: " 1 ");
                  print(table);
                },
                child: Text("get subjects"),
              ),
              Container(
                width: w * 0.8,
                child: TextFormField(
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      )
 */