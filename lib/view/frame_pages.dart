import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:badges/badges.dart' as badges;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:jiffy/jiffy.dart';
import 'package:motafawk/app_images.dart';
import 'package:motafawk/controller/badge_controller.dart';
import 'package:motafawk/controller/download_files_controller.dart';
import 'package:motafawk/controller/frame_pages_controller.dart';
import 'package:motafawk/data/classes_data.dart';
import 'package:motafawk/data/subsystems_data.dart';
import 'package:motafawk/data/systems_data.dart';
import 'package:motafawk/data/types_data.dart';
import 'package:motafawk/data/units_data.dart';
import 'package:motafawk/main.dart';
import 'package:motafawk/model/db/db_helper.dart';
import 'package:motafawk/model/subject_model.dart';
import 'package:motafawk/model/type_model.dart';
import 'package:motafawk/tmp/my_classes.dart';
import 'package:motafawk/tmp/my_sfpdf.dart';
import 'package:motafawk/view/frame_pages/downloader/download_files.dart';
import 'package:motafawk/view/frame_pages/home.dart';
import 'package:motafawk/view/frame_pages/settings.dart';
import 'package:motafawk/view/frame_pages/telegram.dart';

import 'package:path_provider/path_provider.dart';

import '../controller/ads_manager_controller.dart';
import '../controller/awesome_notification_controller_old.dart';
import '../controller/bottom_navigation_controller.dart';
import '../controller/notification_controller.dart';
import '../controller/subjects_controller.dart';
import '../controller/types_controller.dart';
import '../data/sections_data.dart';
import '../data/subjects_data.dart';
import '../vars.dart' as v;
import '../funs.dart' as f;
import 'frame_pages/notifications/notifications.dart';
import 'my_bottom_navigation.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';

@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
  send!.send([id, status, progress]);
}

class FramePages extends StatefulWidget {
  final bool doPrepareUnits;
  const FramePages({Key? key, this.doPrepareUnits = true}) : super(key: key);

  @override
  State<FramePages> createState() => _FramePagesState();
}

class _FramePagesState extends State<FramePages> {
  FramePagesController framePagesController = Get.put(FramePagesController());

  DownloadFilesController downloadFilesController = Get.put(DownloadFilesController());

  BadgeController badgeController = Get.put(BadgeController());

  ReceivePort _port = ReceivePort();

  prepare() async {
    await DbHelper().createDatabase();
    await Jiffy.setLocale("ar");
    try {
      await FirebaseMessaging.instance.subscribeToTopic(v.subscribe).then((value) {
        print("subscribe yes: ${v.subscribe}");
      }).catchError((err) {
        print("err subscribe: ${err}");
      });
    } catch (err) {
      print("err FirebaseMessaging.instance: ${err}");
    }

    try {
      print(v.subscribe + v.choiceClass!.id.toString());
      await FirebaseMessaging.instance.subscribeToTopic(v.subscribe + v.choiceClass!.id.toString()).then((value) {
        print("subscribe yes: ${v.subscribe + v.choiceClass!.id.toString()}");
      }).catchError((err) {
        print("err subscribe: ${err}");
      });
    } catch (err) {
      print("err FirebaseMessaging.instance: ${err}");
    }
  }

  getExternalStorage() async {
    Directory? dir = await getExternalStorageDirectory();
    v.downloadPath = dir!.path;
    print("getExternalStorageDirectory: ${v.downloadPath}");
  }

  ScrollDirection? direction;


  bool activescrollbody = false;
  listenScroll() {
    direction = framePagesController.scrollController.position.userScrollDirection;
    print("listenScroll: ${framePagesController.scrollController.offset}");
    if (framePagesController.scrollController.offset >= 53) {
      activescrollbody = true;
    } else {
      activescrollbody = false;
    }
    if (direction == ScrollDirection.forward) {
    } else {}
  }


  SubjectsData subjectsData = Get.put(SubjectsData());
  SectionsData sectionsData = Get.put(SectionsData());
  UnitsData unitsData = Get.put(UnitsData());
  prepareUnits() async {
    await subjectsData.prepare();
    await sectionsData.prepare();
    await unitsData.prepare();
    int count = (await DbHelper().countRows(table: "units", condition: "1",))??0;
    if(count == 0) {
      Fluttertoast.showToast(
        msg: "يرجاء التاكد من اتصال الانترنت",
        backgroundColor: Colors.grey.withOpacity(0.6),
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  ClassesData classesData = Get.put(ClassesData());
  TypesData typesData = Get.put(TypesData());
  SystemsData systemsData = Get.put(SystemsData());
  SubsystemsData subsystemsData = Get.put(SubsystemsData());
  prepareBasicData() async {
    await Future.delayed(Duration(seconds: 2));
    classesData.prepare();
    await Future.delayed(Duration(seconds: 3));
    typesData.prepare();
    await Future.delayed(Duration(seconds: 3));
    systemsData.prepare();
    await Future.delayed(Duration(seconds: 3));
    subsystemsData.prepare();
  }

  prepareData() async {
    await prepareBasicData();
    if(widget.doPrepareUnits == true) {
      await prepareUnits();
    }
    setState(() {});
  }

  // ads _______________________________________________________________
  // BannerAd? _bannerAd;
  // int loadBannerAdFailedAttempts = 1;
  // bool isLoadedBannerAd = false;
  // void loadBannerAd() {
  //   _bannerAd = BannerAd(
  //     adUnitId: Platform.isAndroid
  //         ? 'ca-app-pub-6606559119948451/5051367343'
  //         : 'iosBannerAd',
  //     request: const AdRequest(),
  //     size: AdSize.banner,
  //     listener: BannerAdListener(
  //       // Called when an ad is successfully received.
  //       onAdLoaded: (ad) {
  //         debugPrint('$ad BannerAd is loaded.');
  //         setState(() {isLoadedBannerAd = true;});
  //       },
  //       // Called when an ad request failed.
  //       onAdFailedToLoad: (ad, err) async {
  //         debugPrint('BannerAd failed to load: $err');
  //         // Dispose the ad here to free resources.
  //         ad.dispose();
  //         loadBannerAdFailedAttempts = loadBannerAdFailedAttempts + 1;
  //         await Future.delayed(Duration(seconds: 3));
  //         if(loadBannerAdFailedAttempts <= 3) {
  //           loadBannerAd();
  //         }
  //       },
  //     ),
  //   )..load();
  // }
  // InterstitialAd? _interstitialAd;
  // int loadInterstitialAdFailedAttempts = 1;
  // void loadInterstitialAd() {
  //   InterstitialAd.load(
  //       adUnitId: Platform.isAndroid
  //           ? 'ca-app-pub-6606559119948451/9804220321'
  //           : 'iosInterstitialAd',
  //       request: const AdRequest(),
  //       adLoadCallback: InterstitialAdLoadCallback(
  //         // Called when an ad is successfully received.
  //         onAdLoaded: (ad) {
  //           debugPrint('$ad InterstitialAd is loaded.');
  //           // Keep a reference to the ad so you can show it later.
  //
  //           ad.fullScreenContentCallback = FullScreenContentCallback(
  //             // Called when the ad showed the full screen content.
  //             onAdShowedFullScreenContent: (ad) {},
  //             // Called when an impression occurs on the ad.
  //             onAdImpression: (ad) {},
  //             // Called when the ad failed to show full screen content.
  //             onAdFailedToShowFullScreenContent: (ad, err) {
  //               // Dispose the ad here to free resources.
  //               ad.dispose();
  //               loadInterstitialAd();
  //             },
  //             // Called when the ad dismissed full screen content.
  //             onAdDismissedFullScreenContent: (ad) {
  //               // Dispose the ad here to free resources.
  //               ad.dispose();
  //               loadInterstitialAd();
  //             },
  //             // Called when a click is recorded for an ad.
  //             onAdClicked: (ad) {},
  //           );
  //
  //           debugPrint('$ad InterstitialAd is loaded FullScreenContentCallback ready.');
  //           // Keep a reference to the ad so you can show it later.
  //           _interstitialAd = ad;
  //         },
  //         // Called when an ad request failed.
  //         onAdFailedToLoad: (LoadAdError err) async {
  //           debugPrint('InterstitialAd failed to load: $err');
  //           loadInterstitialAdFailedAttempts = loadInterstitialAdFailedAttempts + 1;
  //           await Future.delayed(Duration(seconds: 3));
  //           if(loadInterstitialAdFailedAttempts <= 3) {
  //             loadInterstitialAd();
  //           }
  //         },
  //       ));
  // }
  // end ads ___________________________________________________________

  AdsManagerController adsManagerController = Get.put(AdsManagerController());

  @override
  void initState() {
    super.initState();

    adsManagerController.fToast.init(MyApp.navigatorKey.currentContext!);

    prepareData();
    print("Start frame pages");
    framePagesController.scrollController.addListener(listenScroll);
    prepare();
    getExternalStorage();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("Show dialog");

      // AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      //   if (!isAllowed) {
      //     showDialog(
      //       context: context,
      //       builder: (context) {
      //         return AlertDialog(
      //           content: Text(
      //             "يرجى السماح بالوصول الى الاشعارات لمتابعة كل ما هو جديد",
      //             style: TextStyle(
      //               height: 1.5,
      //             ),
      //           ),
      //           actions: [
      //             TextButton(
      //               onPressed: () {
      //                 AwesomeNotifications().requestPermissionToSendNotifications().then((value) {
      //                   if (value == true) {
      //                     print("notification is allowed");
      //                     AwesomeNotificationController.createNotification(
      //                       title: "متفوق",
      //                       body: "مرحبا بك في تطبيق متفوق",
      //                     );
      //                   } else {
      //                     Fluttertoast.showToast(
      //                       msg: "لن تتمكن من الاطلاع على كل ما هو جديد يرجى تفعيل الاشعارات",
      //                     );
      //                   }
      //                 }).catchError((err) {
      //                   Fluttertoast.showToast(
      //                     msg: "خطأ لن تتمكن من الاطلاع على كل ما هو جديد يرجى تفعيل الاشعارات",
      //                   );
      //                 });
      //                 Get.back();
      //               },
      //               child: Text("السماح"),
      //             ),
      //             TextButton(
      //               onPressed: () {
      //                 Get.back();
      //               },
      //               child: Text("الغاء"),
      //             ),
      //           ],
      //         );
      //       },
      //     );
      //   } else {
      //     // AwesomeNotificationController.createNotification(
      //     //   title: "معلمك",
      //     //   body: "مرحبا بك في تطبيق معلمك",
      //     // );
      //   }
      // });

      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) isAllowed = await NotificationController.displayNotificationRationale();
      if (!isAllowed) {
        Fluttertoast.showToast(
          msg: "لن تتمكن من الاطلاع على كل ما هو جديد يرجى تفعيل الاشعارات",
        );
      }

    });

    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) async {
      String id = data[0];
      int status = data[1];
      int progress = data[2];
      print("my download update: ${data}");
      downloadFilesController.update();

      // Add This in order to Open file after downloaded _________________________________
      // if(status == 3 && progress == 100) {
      //   await Future.delayed(Duration(milliseconds: 500));
      //   print("Open file");
      //   FlutterDownloader.open(taskId: "${id}");
      // }
      // To Here ____________________________________________

    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    framePagesController.scrollController.dispose();
    framePagesController.scrollController.removeListener(listenScroll);

    v.audioPlayer.dispose();
    // adsManagerController.confettiController.dispose();

    super.dispose();
  }

  BottomNavigationController bottomNavigationController = Get.put(BottomNavigationController());

  TypesController typesController = Get.put(TypesController());
  SubjectController subjectController = Get.put(SubjectController());

  int subjectId = 0;
  int typeId = 0;

  Future<List> getSubjects() async {
    final List<Map<String, dynamic>> subjects = [];
    print("subjects 1: ${subjects}");
    subjects.add({"id": 0, "name": "الكل"});
    final List table = await DbHelper().select(
      column: "DISTINCT subject_id as id, subject_name as name",
      table: "vunits",
      condition: " display = 1 ",
    );
    for (var element in table) {
      subjects.add({"id": element['id'], "name": element['name']});
    }
    print("subjects 2: ${subjects}");
    return subjects;
  }

  Future<List> getTypes() async {
    List<Map<String, dynamic>> types = [];
    types.add({"id": 0, "name": "الكل"});
    (await DbHelper().select(
      column: "DISTINCT type_id as id, type_name as name",
      table: "vunits",
      condition: " display = 1 ",
    ))
        .toList()
        .forEach((element) {
      types.add({"id": element['id'], "name": element['name']});
    });
    return types;
  }

  ShowSearchBox showSearchBox = Get.put(ShowSearchBox());
  changeConditionVUnits({String nameCondition = "1"}) async {
    if (subjectId != 0 && typeId != 0) {
      print("($nameCondition) and display = 1 and subject_id = ${subjectId} and type_id = ${typeId}");
      unitsData.condition = "($nameCondition) and display = 1 and subject_id = ${subjectId} and type_id = ${typeId}";
    } else if (subjectId != 0 && typeId == 0) {
      print("($nameCondition) and display = 1 and subject_id = ${subjectId}");
      unitsData.condition = "($nameCondition) and display = 1 and subject_id = ${subjectId}";
    } else if (typeId != 0 && subjectId == 0) {
      print("($nameCondition) and display = 1 and type_id = ${typeId}");
      unitsData.condition = "($nameCondition) and display = 1 and type_id = ${typeId}";
    } else {
      print("($nameCondition) and display = 1");
      unitsData.condition = "($nameCondition) and display = 1";
    }
    unitsData.update();
  }

  TextEditingController _searchTxt = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Stack(
      alignment: Alignment.center,
      children: [
        SafeArea(
          top: false,
          child: GetBuilder<FramePagesController>(builder: (framePagesController) {
            return Scaffold(
              extendBody: true,
              body: GetBuilder<BottomNavigationController>(
                builder: (controller) {
                  return CustomScrollView(
                    // floatHeaderSlivers: true,
                    shrinkWrap: true,
                    controller: framePagesController.scrollController,
                    // physics: PageScrollPhysics(),
                    slivers: [

                      GetBuilder<ShowSearchBox>(
                        builder: (controllerShowSearch) {
                          return SliverAppBar(
                            floating: true,
                            snap: true,
                            pinned: true,
                            expandedHeight: 50,
                            leading: (controllerShowSearch.showSearchBox == true)? IconButton(
                              onPressed: () {
                                changeConditionVUnits(
                                  nameCondition: "1",
                                );
                                controllerShowSearch.changeShowSearchBox();
                              },
                              icon: Icon(Icons.arrow_back_outlined, color: v.tertiarycolor[700],),
                            ): null,
                            title: (controllerShowSearch.showSearchBox == true)? Container(
                              width: w,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      child: TextFormField(
                                        controller: _searchTxt,
                                        autofocus: true,
                                        onChanged: (String? val) {
                                          if( val == "" || val == " " || val == null){
                                            changeConditionVUnits(
                                              nameCondition: "1",
                                            );
                                          } else {
                                            changeConditionVUnits(
                                              nameCondition: "name like '%${val}%' or section_name like '%${val}%' or subsystem_name like '%${val}%' or system_name like '%${val}%'",
                                            );
                                          }
                                        },
                                        decoration: InputDecoration(
                                          hintText: "بحث ...",
                                          suffixIcon: InkWell(
                                            onTap: () {
                                              _searchTxt.text = "";
                                              changeConditionVUnits(
                                                nameCondition: "1",
                                              );
                                            },
                                            child: Icon(Icons.close),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                ],
                              ),
                            ): Text(
                              "متفوق",
                              style: TextStyle(color: v.tertiarycolor[800], fontSize: 18),
                            ),
                            titleSpacing: (controllerShowSearch.showSearchBox == true)? -5: 16,
                            elevation: 0,
                            backgroundColor: v.tertiarycolor[200],
                            actions: (controllerShowSearch.showSearchBox == true)? null: [
                              if(controller.currentIndex < 3)
                                IconButton(
                                onPressed: () async {

                                  int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "home");
                                  if(watchFullRewardedAd == 1) return;

                                  changeConditionVUnits(
                                    nameCondition: "name like '%${_searchTxt.text}%' or section_name like '%${_searchTxt.text}%' or subsystem_name like '%${_searchTxt.text}%' or system_name like '%${_searchTxt.text}%' ",
                                  );
                                  controllerShowSearch.changeShowSearchBox();
                                },
                                icon: SizedBox(
                                  width: 26, height: 26,
                                  child: SvgPicture.asset(AppImages.search_fill, color: v.tertiarycolor[700])
                                ),
                              ),
                              GetBuilder<BadgeController>(
                                builder: (controller) {
                                  int count = controller.countnotificationsbadges;
                                  return IconButton(
                                    onPressed: () async {
                                      int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "home");
                                      if(watchFullRewardedAd == 1) return;

                                      NotificationController.resetBadgeCounter();
                                      Get.to(() => Notifications());

                                      // NotificationController.createNewNotification(
                                      //   title: "Meg New",
                                      //   body: "NotificationController",
                                      // );
                                      // f.globalNotification(
                                      //   notification_toWho: v.subscribe + v.choiceClass!.id.toString(),
                                      //   notification_isTopics: true,
                                      //   file_name: "كتاب.الرياضيات.الصف.الاول.الابتدائي",
                                      //   notification_title: "كتاب الرياضيات",
                                      //   notification_body: "كتاب الرياضيات الصف الاول الابتدائي",
                                      //   notification_img: "https://smaller-pictures.appspot.com/images/dreamstime_xxl_65780868_small.jpg",
                                      //   notification_url: "http://192.168.1.99/pdfs/file.pdf",
                                      // );

                                      controller.update();
                                    },
                                    icon: badges.Badge(
                                      showBadge: (count <= 0)? false: true,
                                      badgeContent: Text(
                                        "${(count > 99)? '+99': count}",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      position: badges.BadgePosition.bottomStart(start: -6),
                                      badgeStyle: badges.BadgeStyle(badgeColor: v.secondarycolor, padding: EdgeInsets.all(4)),
                                      child: SizedBox(
                                        width: 26, height: 26,
                                        child: SvgPicture.asset(AppImages.bell_fill, color: v.tertiarycolor[700]),
                                      ),
                                    ),
                                  );
                                }
                              ),
                            ],
                            bottom: PreferredSize(
                              preferredSize: Size.fromHeight(1.0),
                              child: Container(
                                height: 1,
                                width: w,
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: v.tertiarycolor, width: 0.3)),
                                ),
                              ),
                            ),
                          );
                        }
                      ),

                      if(controller.currentIndex < 3)
                        SliverPersistentHeader(
                        // floating: true,
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          Container(
                            height: 65,
                            decoration: BoxDecoration(
                              color: v.tertiarycolor[100],
                              border: Border(bottom: BorderSide(color: v.tertiarycolor.withOpacity(0.5), width: 1)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 0),
                                Container(
                                  height: 24,
                                  child: GetBuilder<SubjectController>(builder: (controller) {
                                    return FutureBuilder(
                                      future: getSubjects(),
                                      builder: (context, AsyncSnapshot<List> snapshot) {
                                        print("snapshot.data: ${snapshot.data}");
                                        if (snapshot.hasData) {
                                          if (snapshot.data!.length == 0) {
                                            return Text("none");
                                          }
                                          return ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            padding: EdgeInsets.symmetric(horizontal: 6),
                                            shrinkWrap: true,
                                            itemCount: snapshot.data!.length,
                                            itemBuilder: (context, int i) {
                                              final item = SubjectModel.fromJson(snapshot.data![i]);
                                              return TextButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                      color: v.primarycolor,
                                                    ),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                                  backgroundColor: (item.id == subjectId) ? v.primarycolor : Colors.white,
                                                  foregroundColor: (item.id == subjectId) ? Colors.white : v.primarycolor,
                                                ),
                                                onPressed: () async {
                                                  int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "home");
                                                  if(watchFullRewardedAd == 1) return;

                                                  subjectId = item.id;
                                                  controller.update();
                                                  changeConditionVUnits();
                                                  if (activescrollbody == true) {
                                                    framePagesController.scrollController.jumpTo(53);
                                                  }
                                                },
                                                child: Text("${item.name.split("&").first}"),
                                              );
                                            },
                                            separatorBuilder: (context, int i) {
                                              return SizedBox(width: 8);
                                            },
                                          );
                                        } else if (snapshot.hasError) {
                                          return Text("err");
                                        } else {
                                          return Text("...");
                                        }
                                      },
                                    );
                                  }),
                                ),
                                Container(
                                  height: 28,
                                  child: GetBuilder<TypesController>(
                                    builder: (controller) {
                                      return FutureBuilder(
                                        future: getTypes(),
                                        builder: (context, AsyncSnapshot<List> snapshot) {
                                          print("snapshot.data: ${snapshot.data}");
                                          if (snapshot.hasData) {
                                            if (snapshot.data!.length == 0) {
                                              return Text("none");
                                            }
                                            return ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              padding: EdgeInsets.symmetric(horizontal: 0),
                                              shrinkWrap: true,
                                              itemCount: snapshot.data!.length,
                                              itemBuilder: (context, int i) {
                                                final item = TypeModel.fromJson(snapshot.data![i]);
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        width: 1.5,
                                                        color: (item.id == typeId) ? v.primarycolor : Colors.transparent,
                                                      ),
                                                    ),
                                                  ),
                                                  child: TextButton(
                                                    style: ElevatedButton.styleFrom(
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          color: Colors.transparent,
                                                        ),
                                                        borderRadius: BorderRadius.circular(0),
                                                      ),
                                                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                                                      backgroundColor: (item.id == typeId) ? v.primarycolor.withOpacity(0.1) : Colors.transparent,
                                                      // foregroundColor: (item.id == typeId) ? Colors.white : v.primarycolor,
                                                      foregroundColor: v.primarycolor,
                                                    ),
                                                    onPressed: () async {

                                                      int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "home");
                                                      if(watchFullRewardedAd == 1) return;

                                                      typeId = item.id;
                                                      controller.update();
                                                      changeConditionVUnits();
                                                      if (activescrollbody == true) {
                                                        framePagesController.scrollController.jumpTo(53);
                                                      }
                                                    },
                                                    child: Text("${item.name.split("&").first}"),
                                                  ),
                                                );
                                              },
                                              separatorBuilder: (context, int i) {
                                                return SizedBox(width: 0);
                                              },
                                            );
                                          } else if (snapshot.hasError) {
                                            return Text("err");
                                          } else {
                                            return Text("...");
                                          }
                                        },
                                      );
                                    }
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: IndexedStack(
                          index: controller.currentIndex,
                          children: [
                            Visibility(
                              visible: (controller.currentIndex == 0)? true: false,
                              child: const Home(fromPage: "downloads"),
                            ),
                            Visibility(
                              visible: (controller.currentIndex == 1)? true: false,
                              child: const Home(fromPage: "favorite", condition: " favorite = 1 "),
                            ),
                            Visibility(
                              visible: (controller.currentIndex == 2)? true: false,
                              child: const Home(fromPage: 'home',),
                            ),
                            Visibility(
                              visible: (controller.currentIndex == 3)? true: false,
                              child: const Telegram(),
                            ),
                            Visibility(
                              visible: (controller.currentIndex == 4)? true: false,
                              child: const Settings(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              ),
              resizeToAvoidBottomInset: false,
              bottomNavigationBar: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyBottomNavigation(),
                  // if (isLoadedBannerAd == true)
                  GetBuilder<AdsManagerController>(
                    builder: (controller) {
                      if(controller.bannerAd == null) {
                        return Visibility(visible: false, child: Text(""));
                      }
                      return Visibility(
                        visible: controller.isLoadedBannerAd,
                        child: Container(
                          height: controller.bannerAd!.size.height.toDouble(),
                          // width: controller.bannerAd!.size.width.toDouble(),
                          // height: 60,
                          width: w,
                          color: Colors.grey,
                          alignment: Alignment.center,
                          child: AdWidget(ad: controller.bannerAd!),
                        ),
                      );
                    }
                  ),
                ],
              ),
            );
          }),
        ),

        // ConfettiWidget(
        //   confettiController: adsManagerController.confettiController,
        //
        //   blastDirectionality: BlastDirectionality.explosive,
        //
        //   emissionFrequency: 0.1,
        //   numberOfParticles: 60,
        //
        //   minBlastForce: 10,
        //   maxBlastForce: 100,
        //
        //   gravity: 0.1,
        //
        //   createParticlePath: (size) {
        //     return drawStar(size);
        //   },
        // ),

      ],
    );
  }

  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (math.pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * math.cos(step),
          halfWidth + externalRadius * math.sin(step));
      path.lineTo(halfWidth + internalRadius * math.cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * math.sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget widget;
  _SliverAppBarDelegate(this.widget);

  @override
  double get minExtent => 65;
  @override
  double get maxExtent => 65;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      child: widget,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class ShowSearchBox extends GetxController {
  bool showSearchBox = false;
  changeShowSearchBox() {
    showSearchBox = !showSearchBox;
    update();
  }
}
