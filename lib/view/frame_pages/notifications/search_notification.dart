
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
import 'package:jiffy/jiffy.dart';
import '../home.dart';

class SearchFile extends SearchDelegate {

  AdsManagerController adsManagerController = Get.put(AdsManagerController());

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
            if(context.mounted) close(context, null);
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

  DbHelper dbHelper = DbHelper();
  BadgeController badgeController = Get.put(BadgeController());
  searchBody() {
    return GetBuilder<NotificationsController>(
        builder: (controller) {
          print("query: ${query}");
          return FutureBuilder(
            future: dbHelper.select(
              column: "*",
              table: "notifications",
              condition: " title like '%$query%' or body like '%$query%' order by created_at desc "
            ),
            builder: (context, AsyncSnapshot<List> snapshot){
              if(snapshot.hasData){
                if(snapshot.data!.length == 0){
                  return Center(
                    child: Text(
                      "لا توجد اشعارات",
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
                    return Material(
                      color: (item['done_visit'] == 1)? Colors.blueGrey[100]: Colors.transparent,
                      child: InkWell(
                        onTap: () async {

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
                          if(item['url'].contains("muealimuk.com")) {
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
                                            "${Jiffy.parse(item['created_at']).fromNow()}"
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
