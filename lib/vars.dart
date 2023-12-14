import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:motafawk/data/terms_data.dart';
import 'package:motafawk/model/term_model.dart';
import 'package:motafawk/model/vsubsystem_model.dart';

import 'model/api/api2.dart';
import 'model/class_model.dart';

// import 'model/db/db_helper.dart';
Map<String, dynamic>? gSettings;

String androidLink = "https://play.google.com/store/apps/details?id=com.mhma.motafawk";

int lastInsertId = 0;
int responseStatus = 0;

String serverToken = "AAAAxI7JdhA:APA91bHwUcmS3U40QQ1ZHW1zabKEs0XZ4apekaN0vv6LLYjlMjje0zdIizJlfZxnPo2J-BQffRY_L3wvgxFnUwHKq1J3jjtmbOhlS6_5jsLZ9W3io1fG8GCT6SvJkoCFjhftPULsqi5l";
String subscribe = "subscribe";

// String ip = "http://172.16.5.87";
// String ip = "http://192.168.1.99";
// String ip = "http://192.168.43.99";
String ip = "https://motafawk.000webhostapp.com";
String link = "${ip}/motafawk";
String imgsLink = "${ip}/motafawk/imgs";
String filesLink = "${ip}/motafawk/files";

String fn = "Almaria";

Map user = {};

String downloadPath = "";

Color primarycolor = Color(0xff01577a);
Color secondarycolor = Color(0xffdda326);
MaterialColor tertiarycolor = Colors.grey;
Map<int, Color> primary_swatch_color =
{
  50: primarycolor.withOpacity(0.1),
  100:primarycolor.withOpacity(0.2),
  200:primarycolor.withOpacity(0.3),
  300:primarycolor.withOpacity(0.4),
  400:primarycolor.withOpacity(0.5),
  500:primarycolor.withOpacity(0.6),
  600:primarycolor.withOpacity(0.7),
  700:primarycolor.withOpacity(0.8),
  800:primarycolor.withOpacity(0.9),
  900:primarycolor.withOpacity(1.0),
};

double xxlg = 20;
double xlg = 18;
double lg = 16;
double normal = 14;
double sm = 12;
double xsm = 10;
double xxsm = 8;

// DbHelper dbHelper = DbHelper();
Api2 api2 = Api2();

// _________________________________
ClassModel? choiceClass;
TermModel? choiceTerm;
VSubsystemModel? choiceVSubsystem;

AudioPlayer audioPlayer = AudioPlayer();
