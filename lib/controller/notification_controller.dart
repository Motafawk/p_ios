

import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../launch_link.dart';
import '../vars.dart' as v;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share/share.dart';

import '../main.dart';

import '../view/frame_pages/pdf_reader.dart';

class NotificationController {
  static ReceivedAction? initialAction;

  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
      "resource://drawable/ic_notify",
      languageCode: "ar",
      [
        NotificationChannel(
          channelKey: 'alerts',
          channelName: 'Alerts',
          channelDescription: 'Notification tests as alerts',
          playSound: true,
          onlyAlertOnce: true,
          soundSource: "resource://raw/sound",
          groupAlertBehavior: GroupAlertBehavior.Children,
          importance: NotificationImportance.High,
          defaultPrivacy: NotificationPrivacy.Private,
          defaultColor: v.primarycolor,
          ledColor: v.primarycolor,
          enableVibration: true,
          enableLights: true,
          channelShowBadge: true,
        )
      ],
      debug: true,
    );

    initialAction = await AwesomeNotifications().getInitialNotificationAction(removeFromActionEvents: false);
  }

  static ReceivePort? receivePort;
  static Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort('notification_action_port')..listen(
      (silentData) => onActionReceivedImplementationMethod(silentData),
    );
    IsolateNameServer.registerPortWithName(receivePort!.sendPort, 'notification_action_port');
  }

  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod:         onActionReceivedMethod,
      onNotificationCreatedMethod:    onNotificationCreatedMethod,
      onNotificationDisplayedMethod:  onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:  onDismissActionReceivedMethod,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      print('Message sent via notification input: "${receivedAction.buttonKeyInput}"');
      await executeLongTaskInBackground(receivedAction);
    } else {
      if (receivePort == null) {
        print('onActionReceivedMethod was called inside a parallel dart isolate.');
        SendPort? sendPort = IsolateNameServer.lookupPortByName('notification_action_port');
        if (sendPort != null) {
          print('Redirecting the execution to main isolate process.');
          sendPort.send(receivedAction);
          return;
        }
      }
      return onActionReceivedImplementationMethod(receivedAction);
    }
  }

  static Future<void> onActionReceivedImplementationMethod(ReceivedAction receivedAction) async {
    print("onActionReceivedImplementationMethod");
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


  static Future<bool> displayNotificationRationale() async {
    bool userAuthorized = false;
    BuildContext context = MyApp.navigatorKey.currentContext!;
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            title: Container(
              width: MediaQuery.of(context).size.width,
              color: v.primarycolor,
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'الحصول على الاشعارات',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SvgPicture.asset(
                        'assets/images/icons/bell_fill.svg',
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.height * 0.1,
                        color: v.secondarycolor,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'يرجى السماح بالوصول الى الاشعارات لمتابعة كل ما هو جديد',
                  textAlign: TextAlign.center,
                  style: TextStyle(height: 1.5),
                ),
              ],
            ),
            actions: [
              TextButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text('رفض'),
              ),
              TextButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: v.primarycolor,
                ),
                onPressed: () async {
                  userAuthorized = true;
                  Navigator.of(ctx).pop();
                },
                child: Text('سماح'),
              ),
            ],
          );
        });
    return userAuthorized && await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  static Future<void> executeLongTaskInBackground(ReceivedAction receivedAction) async {
    print("starting long task");
      await Share.share(
          """${receivedAction.title}
${receivedAction.body}
رابط التطبيق للاندرويد
${v.androidLink}"""
      );
    print("long task done");
  }

  static Future<void> createNewNotification({
    required String title,
    required String body,
    String? imageUrl,
    Map<String, String?>? payload,
  }) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) {
      Fluttertoast.showToast(
        msg: "لن تتمكن من الاطلاع على كل ما هو جديد يرجى تفعيل الاشعارات",
      );
      return;
    }

    if(imageUrl == "") {
      imageUrl = null;
    }
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random().nextInt(1000),
        channelKey: "alerts",
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
          actionType: ActionType.SilentAction,
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


  static Future<void> resetBadgeCounter() async {
    await AwesomeNotifications().resetGlobalBadge();
  }

  static Future<void> cancelNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

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
}


