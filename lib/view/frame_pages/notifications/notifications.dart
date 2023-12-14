
import 'package:confetti/confetti.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:motafawk/controller/ads_manager_controller.dart';

import '../../../controller/badge_controller.dart';
import '../../../controller/notifications_controller.dart';
import '../../../launch_link.dart';
import '../../../model/db/db_helper.dart';

import '../../../view/mywidgets.dart';
import '../home.dart';
import '../pdf_reader.dart';
import 'search_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../vars.dart' as v;
import '../../../funs.dart' as f;
import 'package:jiffy/jiffy.dart';
import 'dart:math' as math;

class Notifications extends StatefulWidget {

  const Notifications({Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {

  NotificationsController notificationsController = Get.put(NotificationsController());
  DbHelper dbHelper = DbHelper();
  // HomeController homeController = Get.put(HomeController());
  BadgeController badgeController = Get.put(BadgeController());
  AdsManagerController adsManagerController = Get.put(AdsManagerController());

  @override
  void initState() {
    super.initState();
    adsManagerController.notificationsConfettiController = ConfettiController(duration: Duration(milliseconds: 4500));
  }

  @override
  void dispose() {
    adsManagerController.notificationsConfettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text("الاشعارات"),
            titleSpacing: -8,
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () async {

                  int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "notifications");
                  if(watchFullRewardedAd == 1) return;

                  if (mounted) {
                    showSearch(
                      context: context,
                      delegate: SearchFile(),
                    );
                  }

                },
              ),
            ],
          ),
          body: GetBuilder<NotificationsController>(
              builder: (controller) {
                return FutureBuilder(
                  future: dbHelper.select(
                    column: "*",
                    table: "notifications",
                    condition: " 1 order by created_at desc "
                  ),
                  builder: (context, AsyncSnapshot<List> snapshot){
                    if(snapshot.hasData){
                      if(snapshot.data!.length == 0){
                        return Center(child: Text("لا توجد اشعارات"),);
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, int i){
                          final item = snapshot.data![i];
                          return Material(
                            color: (item['done_visit'] == 1)? Colors.blueGrey[100]: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "notifications");
                                if(watchFullRewardedAd == 1) return;
                                // open url in web view
                                print("${item['url']}");
                                DbHelper dbHelper = DbHelper();
                                await dbHelper.update(
                                    table: "notifications",
                                    obj: {
                                      "done_visit": 1,
                                    },
                                    condition: " id = '${item['id']}' "
                                ).then((value) {
                                  print("update notifications: ${value}");
                                }).catchError((err){
                                  print("err update notification: ${err}");
                                });
                                await badgeController.countNotificationsBadges();
                                // Get.to(() => Home(url: item['url'],));
                                if(item['url'].contains("pdf")) {
                                  Get.to(() => PdfReader(
                                    fileUri: item["url"],
                                    indexes: null,
                                    fileName: item["file_name"],
                                  ));
                                }
                                else {
                                  launchLink(url: item['url']);
                                }
                                controller.update();
                              },
                              child: Container(
                                width: Get.width,
                                padding: EdgeInsets.all(8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            children: [
                                              Container(
                                                height: 70,
                                                width: 70,
                                                child: MyImageGalleryCache(
                                                  imageName: "${item['img']}",
                                                  boxFit: BoxFit.fill,
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
                                                  "${item['title']}",
                                                  style: TextStyle(
                                                    fontFamily: v.fn,
                                                    color: Colors.black,
                                                    fontSize: v.lg,
                                                    height: 1.2
                                                  ),
                                                ),
                                                SizedBox(height: 8,),
                                                Text(
                                                  "${item['body']}",
                                                  style: TextStyle(
                                                    fontFamily: v.fn,
                                                    color: Colors.grey[800],
                                                    fontSize: v.normal,
                                                    height: 1.3
                                                  ),
                                                ),
                                                SizedBox(height: 8,),
                                                Text(
                                                  Jiffy.parse(item['created_at']).fromNow()
                                                  + ((item['done_visit'] == 1)? " . تم الاطلاع على هذا الاشعار": " . لم تقم بالاطلاع على هذا الاشعار"),
                                                  style: TextStyle(
                                                      fontFamily: v.fn,
                                                      color: v.tertiarycolor[700],
                                                      fontSize: v.sm
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close, color: Colors.black,),
                                      onPressed: () async {
                                        // delete notification
                                        await dbHelper.delete(
                                          table: "notifications",
                                          condition: " id = '${item['id']}' ",
                                        );
                                        await badgeController.countNotificationsBadges();
                                        controller.update();
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
                      return Center(child: Text("خطا"));
                    }else{
                      return Center(child: Text("انتظر ..."));
                    }
                  },
                );
              }
          ),
          floatingActionButton: ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(16),
                elevation: 6
            ),
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    content: Text(
                      "هل انت متاكد من حذف جميع الاشعارات؟ ",
                      style: TextStyle(height: 1.6),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          await DbHelper().delete(table: "notifications", condition: " 1 ").then((value) {
                            Fluttertoast.showToast(
                              msg: "تم حذف جميع الاشعارات",
                              backgroundColor: Colors.green,
                            );
                          });
                          await badgeController.countNotificationsBadges();
                          notificationsController.update();
                          Get.back();
                        },
                        child: Text("نعم"),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text("لا"),
                      ),
                    ],
                  );
                },
              );

            },
            child: Icon(Icons.delete, size: 28,),
          ),
        ),

        ConfettiWidget(
          confettiController: adsManagerController.notificationsConfettiController,
          blastDirectionality: BlastDirectionality.explosive,
          emissionFrequency: 0.1,
          numberOfParticles: 60,
          minBlastForce: 10,
          maxBlastForce: 100,
          gravity: 0.1,
          createParticlePath: (size) {
            return f.drawStar(size);
          },
        ),

      ],
    );
  }

}

