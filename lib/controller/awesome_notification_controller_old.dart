import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motafawk/view/frame_pages/pdf_reader.dart';
// import 'package:mnhaji/view/frame_pages/home.dart';
import 'package:share/share.dart';
import '../launch_link.dart';
import '../vars.dart' as v;

class AwesomeNotificationController {

//   static ReceivePort port = ReceivePort();
//   static bool initialized = true;
//   @pragma("vm:entry-point")
//   static Future <void> initTopNotification() async {
//     print("init notification");
//     IsolateNameServer.registerPortWithName(port.sendPort, 'notification_actions');
//     port.listen((var receivedAction) async {
//       print('Action running on main isolate');
//
//       Share.share(
//           """${receivedAction.title}
// ${receivedAction.body}
// رابط التطبيق للاندرويد
// ${v.androidLink}"""
//       );
//
//     });
//
//
//   }

  @pragma("vm:entry-point")
  static Future <void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    print("tracking onNotificationCreatedMethod: ${receivedNotification}");
  }

  @pragma("vm:entry-point")
  static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    print("tracking onNotificationDisplayedMethod: ${receivedNotification}");
  }

  @pragma("vm:entry-point")
  static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    print("tracking onDismissActionReceivedMethod: ${receivedAction}");
  }

  @pragma("vm:entry-point")
  static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    print("tracking onActionReceivedMethod: ${receivedAction}");

    // if (!initialized) {
    //   SendPort? uiSendPort = IsolateNameServer.lookupPortByName('notification_actions');
    //   if (uiSendPort != null) {
    //     print('Background action running on parallel isolate without valid context. Redirecting execution');
    //     uiSendPort.send(receivedAction);
    //     // return;
    //   }
    // }

    // Get.to(() => TmpHome());

    if(receivedAction.buttonKeyPressed == "share") {
      print("Share Notification");

      SendPort? uiSendPort = IsolateNameServer.lookupPortByName('notification_actions');
      if (uiSendPort != null) {
        print('Background action running on parallel isolate without valid context. Redirecting execution');
        uiSendPort.send(receivedAction);
        // return;
      }

//       Share.share(
//           """${receivedAction.title}
// ${receivedAction.body}
// رابط التطبيق للاندرويد
// ${v.androidLink}"""
//       );

      return;
    }

    if(receivedAction.payload!["url"]!.contains(".pdf")) {
      Get.to(() => PdfReader(
        fileUri: receivedAction.payload!["url"]!,
        indexes: null,
        fileName: receivedAction.payload!["file_name"]!,
      ), preventDuplicates: false);
    }
    else if(receivedAction.payload!["url"]!.contains("http")) {
      launchLink(url: receivedAction.payload!["url"]!);
    } else {

    }

  }


  static Future<void> createNotification({
    required String title,
    required String body,
    String? imageUrl,
    Map<String, String?>? payload,
  }) async {
    if(imageUrl == "") {
      imageUrl = null;
    }
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random().nextInt(1000),
        channelKey: "basic_channel",
        color: Color(0xff01577a),
        backgroundColor: Color(0xff01577a),

        title: title,
        body: body,

        bigPicture: imageUrl,
        largeIcon: imageUrl,
        hideLargeIconOnExpand: true,

        payload: payload?? {"url": ""},
        autoDismissible: true,
        wakeUpScreen: true,
        notificationLayout: (imageUrl == null || imageUrl == "")? NotificationLayout.BigText: NotificationLayout.BigPicture,
      ),
      actionButtons: [
        NotificationActionButton(
          key: "share",
          label: "مشاركة",
          actionType: ActionType.SilentBackgroundAction,
          autoDismissible: false,
        ),
        NotificationActionButton(
          key: "open",
          label: "فتح",
          autoDismissible: false, // true
        ),
        NotificationActionButton(
          key: "cancel",
          label: "الغاء",
          actionType: ActionType.DisabledAction,
          autoDismissible: true,
          color: Colors.red,
        ),
      ],
    );
  }

}
