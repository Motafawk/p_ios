import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'dart:math' as math;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:confetti/confetti.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:motafawk/controller/ads_manager_controller.dart';
import 'package:motafawk/tmp/my_tmp.dart';
import 'controller/notification_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:motafawk/model/vsubsystem_model.dart';
import 'package:motafawk/view/setup/choose_class.dart';
import 'package:motafawk/view/frame_pages.dart';
import 'package:motafawk/view/frame_pages/home.dart';
import 'package:motafawk/view/once_splash.dart';
import 'package:share/share.dart';
import 'data/classes_data.dart';
import 'data/sections_data.dart';
import 'data/subjects_data.dart';
import 'data/subsystems_data.dart';
import 'data/systems_data.dart';
import 'data/types_data.dart';
import 'data/units_data.dart';
import 'model/class_model.dart';
import 'model/db/db_helper.dart';
import 'model/term_model.dart';
import 'my_classes.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'vars.dart' as v;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Future<void> processNotification(RemoteMessage event) async {
  print("processNotification");
  Map<String, dynamic>? notification;
  notification = jsonDecode(event.data['notification']);
  if(notification != null) {
    if(notification.length > 0) {
      DbHelper dbHelper = DbHelper();
      await dbHelper.insert(
        table: "notifications",
        obj: {
          "id": event.data['id'],
          "title": notification['title'],
          "body": notification['body'],
          "img": notification['img'],
          "url": notification['url'],
          "file_name": event.data['file_name'],
          "created_at": DateTime.now().toIso8601String(),
        },
      );
    }
  }
  print("end processNotification");
}
execNotification(RemoteMessage event) {
  print("execNotification");
  Map? notification;
  print("notification: ${event.data['notification']}");
  print("notification type: ${event.data['notification'].runtimeType}");
  String id = event.data['id'].toString();
  notification = jsonDecode(event.data['notification']);
  String url = notification!['url'];
  if(notification['url'] == null || notification['url'] == "") {
    url = "";
  }
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      Fluttertoast.showToast(msg: "هناك اشعارات جديدة");
    } else {
      NotificationController.createNewNotification(
        title: notification!['title'],
        body: notification['body'],
        imageUrl: notification['img'],
        payload: {
          "url": url,
          "file_name": event.data['file_name'],
        },
      );
    }
  });

}

@pragma('vm:entry-point')
Future<void> onArriveBackgroundTerminatedfbm(RemoteMessage event) async {
  print("onArriveBackgroundTerminatedfbm");
  await Firebase.initializeApp().then((value) {
    print("initializeApp: ${value}");
  }).catchError((err){
    print("initializeApp err: ${err}");
  });
  if(event.data['notification'] != null && event.data['notification'] != "") {
    await processNotification(event).then((value) async {
      execNotification(event);
    }).catchError((err) {
      print("err processNotification: ${err}");
    });
  }
}
Future<void> onArriveForegroundfbm(RemoteMessage event) async {
  print("onArriveForegroundfbm listen");
  print("event: ${event.data}");

  SubjectsData subjectsData = Get.put(SubjectsData());
  SectionsData sectionsData = Get.put(SectionsData());
  UnitsData unitsData = Get.put(UnitsData());
  await subjectsData.prepare();
  await sectionsData.prepare();
  await unitsData.prepare();
  ClassesData classesData = Get.put(ClassesData());
  TypesData typesData = Get.put(TypesData());
  SystemsData systemsData = Get.put(SystemsData());
  SubsystemsData subsystemsData = Get.put(SubsystemsData());
  await Future.delayed(Duration(seconds: 2));
  classesData.prepare();
  await Future.delayed(Duration(seconds: 3));
  typesData.prepare();
  await Future.delayed(Duration(seconds: 3));
  systemsData.prepare();
  await Future.delayed(Duration(seconds: 3));
  subsystemsData.prepare();
  unitsData.update();

  if(event.data['notification'] != null && event.data['notification'] != "") {
    await processNotification(event).then((value) async {
      execNotification(event);
    }).catchError((err) {
      print("err processNotification: ${err}");
    });
  }
}


void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  MobileAds.instance.initialize();

  await NotificationController.initializeLocalNotifications();
  await NotificationController.initializeIsolateReceivePort();

  await FlutterDownloader.initialize(
    debug: true, // optional: set to false to disable printing logs to console (default: true)
    ignoreSsl: true, // option: set to false to disable working with http links (default: false)
  );
  await Firebase.initializeApp().then((value) {
    print("initializeApp: ${value}");
  }).catchError((err){
    print("initializeApp err: ${err}");
  });
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(onArriveBackgroundTerminatedfbm);
  FirebaseMessaging.onMessage.listen(onArriveForegroundfbm);
  await GetStorage.init();
  try {
    FirebaseMessaging.instance.getToken().then((value) {
      print("============================= token start ============================");
      print("${value}");
      print("============================= token ============================");
    }).catchError((err) {
      print("err get token fbm: ${err}");
      Fluttertoast.showToast(msg: "لا يمكنك تلقي الاشعارات تحقق من اتصال الانترنت");
    });
  }catch(err){
    print("err messaging: ${err}");
  }

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xff424242),
  ));

  // await SystemChrome.setEnabledSystemUIMode(
  //   SystemUiMode.immersiveSticky,
  //   overlays: [],
  // );

  // AwesomeNotifications().initialize(
  //     "resource://drawable/ic_notify",
  //     languageCode: "ar",
  //     [
  //       NotificationChannel(
  //         channelKey: "basic_channel",
  //         channelName: "Basic Notifications",
  //         channelDescription: "channel Description",
  //         defaultColor: Color(0xff01577a),
  //         soundSource: "resource://raw/sound",
  //         importance: NotificationImportance.High,
  //         ledColor: Colors.orangeAccent,
  //         enableLights: true,
  //         enableVibration: true
  //         // channelShowBadge: true,
  //       )
  //     ]
  // );
  //
  //
  // ReceivedAction? receivedAction = await AwesomeNotifications().getInitialNotificationAction(
  //   removeFromActionEvents: false,
  // );
  // if (receivedAction?.body != null){
  //   print(receivedAction!.body);
  // }


  runApp(MyApp());

  NotificationController.startListeningNotificationEvents();

  v.choiceClass = (GetStorage().read("choice_class") == null)? null: ClassModel.fromJson(GetStorage().read("choice_class"));
  v.choiceTerm = (GetStorage().read("choice_term") == null)? null: TermModel.fromJson(GetStorage().read("choice_term"));
  v.choiceVSubsystem = (GetStorage().read("choice_vsubsystem") == null)? null: VSubsystemModel.fromJson(GetStorage().read("choice_vsubsystem"));
}


class MyApp extends StatefulWidget {
  MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  AdsManagerController adsManagerController = Get.put(AdsManagerController());

  Future<int> unitsCountRows() async {
    await adsManagerController.loadAds();
    return (await DbHelper().countRows(table: "units", condition: "1",))??0;
  }

  @override
  void initState() {
    super.initState();
    adsManagerController.homeConfettiController = ConfettiController(duration: Duration(seconds: 5));
    adsManagerController.mainConfettiController = ConfettiController(duration: Duration(milliseconds: 4500));
    // adsManagerController.homeConfettiController.addListener(() {
    //   setState((){
    //     adsManagerController.isPlayingConfetti = adsManagerController.homeConfettiController.state == ConfettiControllerState.playing;
    //   });
    // });
  }

  @override
  void dispose() {
    adsManagerController.homeConfettiController.dispose();
    adsManagerController.mainConfettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'motafawk',
      debugShowCheckedModeBanner: false,
      builder: FToastBuilder(),
      navigatorKey: MyApp.navigatorKey,

      theme: ThemeData(
        fontFamily: v.fn,
        useMaterial3: true,
        // primaryColor: MaterialColor(v.primarycolor.value, v.primary_swatch_color),
        // canvasColor: Color(0xfff3f3f3),
        // canvasColor: v.tertiarycolor[600],
        scaffoldBackgroundColor: v.tertiarycolor[100],
        colorSchemeSeed: v.primarycolor,
        // primarySwatch: MaterialColor(v.primarycolor.value, v.primary_swatch_color),
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily: v.fn,
          bodyColor: v.tertiarycolor[800],
          displayColor: v.tertiarycolor[800],
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            gapPadding: 0,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: v.tertiarycolor[300]!,),
            borderRadius: BorderRadius.circular(4),
            gapPadding: 0,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: v.primarycolor,),
            borderRadius: BorderRadius.circular(4),
            gapPadding: 0,
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            gapPadding: 0,
            borderSide: BorderSide(color: v.tertiarycolor[500]!,),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            gapPadding: 0,
            borderSide: BorderSide(color: Colors.red,),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.red,),
            gapPadding: 0,
          ),
          labelStyle: TextStyle(height: 1,),
          hintStyle: TextStyle(height: 1.5, color: v.tertiarycolor[400],), // height: 2.5
          helperStyle: TextStyle(height: 1.4,),
          helperMaxLines: 3,
          fillColor: Colors.white,
          filled: true,
          errorStyle: TextStyle(height: 0.8, color: Colors.red),
        ),
        appBarTheme: AppBarTheme(
          titleSpacing: -5,
          titleTextStyle: TextStyle(
            fontSize: 17,
            fontFamily: v.fn,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: v.primarycolor,
          ),
        ),
      ),

      // arabic __________________________________________
      locale: Locale("ar"),
      fallbackLocale: Locale("ar"),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale("ar"),
        // const Locale('en'),
      ],
      // end arabic __________________________________________

      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          alignment: Alignment.center,
          children: [
            FutureBuilder(
              future: unitsCountRows(),
              builder: (context, AsyncSnapshot<int> snapshot) {
                print("Build main page");
                if(snapshot.hasData) {
                  if(snapshot.data == 0) {
                    return ChooseClass();
                  }
                  else {
                    return FramePages();
                  }
                }
                else if(snapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(height: 50, width: 50, child: Text("خطا غير متوقع في النظام")),
                        ],
                      ),
                    ),
                  );
                }
                else {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(height: 50, width: 50, child: CircularProgressIndicator()),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            ConfettiWidget(
              confettiController: adsManagerController.homeConfettiController,

              blastDirectionality: BlastDirectionality.explosive,

              emissionFrequency: 0.1,
              numberOfParticles: 60,

              minBlastForce: 10,
              maxBlastForce: 100,

              gravity: 0.1,

              createParticlePath: (size) {
                return drawStar(size);
              },
            ),
          ],
        ),
      ),

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

