import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'vars.dart' as v;
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'view/frame_pages/downloader/download_files.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

String convertArabicToHex(String url){
  String urlhex = url
      .replaceAll("ا", "%D8%A7")
      .replaceAll("ب", "%D8%A8")
      .replaceAll("ت", "%D8%AA")
      .replaceAll("ث", "%D8%AB")
      .replaceAll("ج", "%D8%AC")
      .replaceAll("ح", "%D8%AD")
      .replaceAll("خ", "%D8%AE")
      .replaceAll("د", "%D8%AF")
      .replaceAll("ذ", "%D8%B0")
      .replaceAll("ر", "%D8%B1")
      .replaceAll("ز", "%D8%B2")
      .replaceAll("س", "%D8%B3")
      .replaceAll("ش", "%D8%B4")
      .replaceAll("ص", "%D8%B5")
      .replaceAll("ض", "%D8%B6")
      .replaceAll("ط", "%D8%B7")
      .replaceAll("ظ", "%D8%B8")
      .replaceAll("ع", "%D8%B9")
      .replaceAll("غ", "%D8%BA")
      .replaceAll("ف", "%D9%81")
      .replaceAll("ق", "%D9%82")
      .replaceAll("ك", "%D9%83")
      .replaceAll("ل", "%D9%84")
      .replaceAll("م", "%D9%85")
      .replaceAll("ن", "%D9%86")
      .replaceAll("ه", "%D9%87")
      .replaceAll("ة", "%D8%A9")
      .replaceAll("و", "%D9%88")
      .replaceAll("ي", "%D9%8A")
      .replaceAll("ؤ", "%D8%A4")
      .replaceAll("ء", "%D8%A1")
      .replaceAll("ئ", "%D8%A6")
      .replaceAll("أ", "%D8%A3")
      .replaceAll("إ", "%D8%A5")
      .replaceAll("آ", "%D8%A2")
      .replaceAll(" ", "%20")
      .replaceAll("َ", "%D9%8E")
      .replaceAll("ً", "%D9%8B")
      .replaceAll("ُ", "%D9%8F")
      .replaceAll("ٌ", "%D9%8C")
      .replaceAll("ِ", "%D9%90")
      .replaceAll("ٍ", "%D9%8D");
  return urlhex;
}

String convertHexToArabic(String path) {
  String filterpath = path
      .replaceAll("%D8%A7", "ا",)
      .replaceAll("%D8%A8", "ب",)
      .replaceAll("%D8%AA", "ت",)
      .replaceAll("%D8%AB", "ث",)
      .replaceAll("%D8%AC", "ج",)
      .replaceAll("%D8%AD", "ح",)
      .replaceAll("%D8%AE", "خ",)
      .replaceAll("%D8%AF", "د",)
      .replaceAll("%D8%B0", "ذ",)
      .replaceAll("%D8%B1", "ر",)
      .replaceAll("%D8%B2", "ز",)
      .replaceAll("%D8%B3", "س",)
      .replaceAll("%D8%B4", "ش",)
      .replaceAll("%D8%B5", "ص",)
      .replaceAll("%D8%B6", "ض",)
      .replaceAll("%D8%B7", "ط",)
      .replaceAll("%D8%B8", "ظ",)
      .replaceAll("%D8%B9", "ع",)
      .replaceAll("%D8%BA", "غ",)
      .replaceAll("%D9%81", "ف",)
      .replaceAll("%D9%82", "ق",)
      .replaceAll("%D9%83", "ك",)
      .replaceAll("%D9%84", "ل",)
      .replaceAll("%D9%85", "م",)
      .replaceAll("%D9%86", "ن",)
      .replaceAll("%D9%87", "ه",)
      .replaceAll("%D8%A9", "ة",)
      .replaceAll("%D9%88", "و",)
      .replaceAll("%D9%8A", "ي",)
      .replaceAll("%D8%A4", "ؤ",)
      .replaceAll("%D8%A1", "ء",)
      .replaceAll("%D8%A6", "ئ",)
      .replaceAll("%D8%A3", "أ",)
      .replaceAll("%D8%A5", "إ",)
      .replaceAll("%D8%A2", "آ",)
      .replaceAll("%20", " ",)
      .replaceAll("%D9%8E", "َ",)
      .replaceAll("%D9%8B", "ً",)
      .replaceAll("%D9%8F", "ُ",)
      .replaceAll("%D9%8C", "ٌ",)
      .replaceAll("%D9%90", "ِ",)
      .replaceAll("%D9%8D", "ٍ",);
  return filterpath;
}

themeSearch(BuildContext context) {
  return Theme.of(context).copyWith(
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 0),
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
      textTheme: Theme.of(context).textTheme.apply(
          fontFamily: v.fn,
          bodyColor: Colors.black,
          displayColor: Colors.black,
          fontSizeFactor: 0.8
      ),
      appBarTheme: AppBarTheme(
        titleSpacing: -8,
        backgroundColor: v.secondarycolor,
      )
  );
}
// ______________________________________________

CachedNetworkImage imageUrl(String? img, {double sizeCircleLoading = 30, BoxFit boxFit = BoxFit.fill}){
  String? imageUrl;
  if(img == null || img == "" || img == " ") {
    img = "";
  }
  if(img.contains("http")) {
    imageUrl = img;
  } else {
    imageUrl = "${v.imgsLink}/${img}";
  }
  return CachedNetworkImage(
    imageUrl: imageUrl,
    fit: boxFit,
    placeholder: (context, url) {
      return Container(
        padding: EdgeInsets.all(10),
        // height: sizeCircleLoading + 10.0,
        // width: sizeCircleLoading + 10.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: sizeCircleLoading,
              width: sizeCircleLoading,
              child: CircularProgressIndicator(strokeWidth: 2,),
            ),
          ],
        ),
      );
    },
    errorWidget: (context, url, error) {
      return Image.asset("assets/images/icon.png");
    },
  );
}
// _________________________________________________
bool checkExistFile(DownloadTask item) {
  if(!File("${item.savedDir}/${item.filename}").existsSync()){
    Fluttertoast.showToast(
        msg: "عذرا الملف غير موجود في الهاتف",
        backgroundColor: Colors.red,
        textColor: Colors.black,
        gravity: ToastGravity.CENTER
    );
    return false;
  }
  if(item.status != DownloadTaskStatus.complete){
    Fluttertoast.showToast(
        msg: "الملف قيد التنزيل",
        backgroundColor: Colors.red,
        textColor: Colors.black,
        gravity: ToastGravity.CENTER
    );
    return false;
  }
  return true;
}

downloadFile(String uri, String fileName) async {
  await getPermission();
  String url;
  if(uri.contains("http")) {
    url = uri;
  } else {
    url = "${v.filesLink}/${uri}";
  }
  print("url downloadFile: ${url}");
  List filename = url.split("/").last.split(".");
  List<DownloadTask>? table = await FlutterDownloader.loadTasksWithRawQuery(query: "select * from task where url = '${url}';");
  if(table != null){
    if(table.length > 0){
      String? id = table.last.taskId;
      if(table.last.status == DownloadTaskStatus.complete) {
        mySnackBar("الملف موجود بالفعل تاكد من التنزيلات", id);
        return;
      }
      else if(table.last.status == DownloadTaskStatus.running) {
        mySnackBar("الملف قيد التنزيل تاكد من التنزيلات", id);
        return;
      }
      else if(table.last.status == DownloadTaskStatus.paused) {
        mySnackBar("الملف متوقف عن التنزيل تاكد من التنزيلات", id);
        return;
      }else if(table.last.status == DownloadTaskStatus.failed || table.last.status == DownloadTaskStatus.canceled){
        if(File("${table.last.savedDir}/${table.last.filename}").existsSync()){
          File("${table.last.savedDir}/${table.last.filename}").deleteSync();
        }
        await Future.delayed(Duration(milliseconds: 500));
        FlutterDownloader.remove(taskId: table.last.taskId).then((value) {
          Fluttertoast.showToast(
              msg: "تم حذف الملف المعطوب اعادة تنزيل: ${table.last.filename}",
              backgroundColor: Colors.amber,
              textColor: Colors.black,
              gravity: ToastGravity.CENTER
          );
        });
      }
    }
  }
  if(filename.length > 1) {
    String name = filename[0];
    String extension = filename[1];
    final taskId = await FlutterDownloader.enqueue(
      url: convertArabicToHex(url),
      // fileName: convertHexToArabic("${name}.${extension}"),
      fileName: fileName + "." + extension,
      savedDir: "${v.downloadPath}",
      showNotification: true, // show download progress in status bar (for Android)
      openFileFromNotification: true, // click on notification to open downloaded file (for Android)
    ).then((value) {
      print("value: ${value}");
      mySnackBar("جاري تنزيل الملف: " + convertHexToArabic("${name}.${extension}"), "");
    }).catchError((err){
      print("err FlutterDownloader: ${err}");
    });
  } else {
    final taskId = await FlutterDownloader.enqueue(
      url: convertArabicToHex(url),
      // fileName: fileName,
      savedDir: "${v.downloadPath}",
      showNotification: true, // show download progress in status bar (for Android)
      openFileFromNotification: true, // click on notification to open downloaded file (for Android)
    );
    mySnackBar("جاري تنزيل الملف", "");
  }

}

mySnackBar(String message, String id) {
  return Get.snackbar(
      snackPosition: SnackPosition.BOTTOM,
      "",
      "",
      margin: EdgeInsets.all(15),
      duration: Duration(seconds: 5),
      titleText: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "تنبية!",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: v.lg
                  ),
                ),
                SizedBox(height: 8,),
                Text(
                  "${message}",
                  style: TextStyle(
                      height: 1.3
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 4,),
          TextButton(
            style: ElevatedButton.styleFrom(
                onPrimary: v.secondarycolor
            ),
            child: Text("التنزيلات"),
            onPressed: (){
              Get.to(() => DownloadFiles(downloadId: id,));
            },
          ),
        ],
      ),
      messageText: SizedBox(height: 0, width: 0,),
      backgroundColor: Colors.white
  );
}

getPermission() async {
  var status = await Permission.storage.status;
  bool grant = false;
  if (status.isDenied) {
    grant = await Permission.storage.request().then((value) {
      print("value.isGranted: ${value.isGranted}");
      return value.isGranted;
    }).catchError((err) {
      return false;
    });
  }
  else {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      openAppSettings();
    }
  }
  print("grant: ${grant}");
  return grant;
}

List responseToast(response, {required bool showToast}) {
  if(response != null){
    print("response: ${response}");
    print("response runtimeType: ${response.runtimeType}");
    if(response is Map){
      int status = int.parse(response["status"].toString());
      v.lastInsertId = (response["id"] == null)? 0: int.parse(response["id"].toString());
      v.responseStatus = status;
      // _____________________________________________________
      if(status == 200){
        if(showToast == true) {
          Fluttertoast.showToast(
            msg: "تمت العملية بنجاح",
            backgroundColor: Colors.green,
            textColor: Colors.black,
          );
        }
      }
      else if(status == 201) {
        if(showToast == true) {
          Fluttertoast.showToast(
            msg: "تمت العملية بنجاح مع ملف",
            backgroundColor: Colors.green,
            textColor: Colors.black,
          );
        }
      }
      else if(status == 202) {
        if(showToast == true) {
          Fluttertoast.showToast(
            msg: "تمت العملية بنجاح #",
            backgroundColor: Colors.green,
            textColor: Colors.black,
          );
        }
      }
      else if(status == 300){
        Fluttertoast.showToast(
          msg: "فشلت العملية",
          backgroundColor: Colors.amber,
          textColor: Colors.black,
        );
      }
      else if(status == 301){
        Fluttertoast.showToast(
          msg: "المستخدم غير موجود قد تكون البيانات غير صحيحة",
          backgroundColor: Colors.amber,
          textColor: Colors.black,
        );
      }
      else if(status == 302){
        Fluttertoast.showToast(
          msg: "المستخدم مسجل بالفعل في جهاز اخر",
          backgroundColor: Colors.amber,
          textColor: Colors.black,
        );
      }
      else if(status == 400){
        Fluttertoast.showToast(
          msg: "فشل الاتصال بقاعدة البيانات او فشل في الاكواد php",
          backgroundColor: Colors.amber,
          textColor: Colors.black,
        );
      }
      else if(status == 500){
        Fluttertoast.showToast(
          msg: "فشل حجم الملف كبير تعدى 3MB",
          backgroundColor: Colors.amber,
          textColor: Colors.black,
        );
      }
      else if(status == 600){
        Fluttertoast.showToast(
          msg: "نوع الملف غير صحيح",
          backgroundColor: Colors.amber,
          textColor: Colors.black,
        );
      }
      else if(status == 0){
        print("nothing in api");
      }
      else{
        Fluttertoast.showToast(
          msg: "فشل غير متوقع",
          backgroundColor: Colors.amber,
          textColor: Colors.black,
        );
      }
    }
  }
  if(response == null){
    return [];
  }
  if(response is List) {
    return response;
  }else{
    return [];
  }

}

Future globalNotification({
  String id = "0",
  String table = "",

  String file_name = "", // interested here

  String notification_title = "",
  String notification_body = "",
  String notification_img = "",
  String notification_url = "",

  bool notification_isTopics = true,
  required String notification_toWho,
}) async {

  String notification = "";
  id = "${DateTime.now().toIso8601String().replaceAll("-", "").replaceAll(":", "").replaceAll(".", "")}";
  if(notification_title != "") {
    if(notification_url == "" || notification_url == "null") {
      notification_url = "";
    }
    notification = '{"title": "${notification_title}", "body": "${notification_body}", "img": "${notification_img}", "url": "${notification_url}"}';
  }
  if(notification_isTopics == true) {
    notification_toWho = "/topics/${notification_toWho}";
  }
  print("globalNotification to: ${notification_toWho}");
  await http.post(
    Uri.parse('https://fcm.googleapis.com/fcm/send'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'key=${v.serverToken}',
    },
    body: jsonEncode(
      {
        'priority': 'high',
        'data': <String, dynamic> {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': id,
          'table': table,
          'file_name': file_name,
          'notification': notification,
        },
        'to': notification_toWho,
      },
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



