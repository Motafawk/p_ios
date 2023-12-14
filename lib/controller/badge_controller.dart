
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get/get.dart';

import 'package:motafawk/model/db/db_helper.dart';



class BadgeController extends GetxController{
  DbHelper dbHelper = DbHelper();
  int countnotificationsbadges = 0;
  int countfavoritesbadges = 0;
  int countalarmsbadges = 0;

  Future countNotificationsBadges() async {
    List table = await dbHelper.select(
      column: "*",
      table: "notifications",
      condition: " done_visit = 0 "
    );
    countnotificationsbadges = table.length;
    print("countbadges: ${countnotificationsbadges}");
    update();
  }
  Future countFavoritesBadges() async {
    List table = await dbHelper.select(
      column: "*",
      table: "units",
      condition: " favorite = 1 "
    );
    countfavoritesbadges = table.length;
    print("countfavoritesbadges: ${countfavoritesbadges}");
    update();
  }
  Future countAlarmsBadges() async {
    List table = await dbHelper.select(
      column: "*",
      table: "alarms",
      condition: " 1 "
    );
    countalarmsbadges = table.length;
    print("countfavoritesbadges: ${countfavoritesbadges}");
    update();
  }

  @override
  void onInit() {
    super.onInit();
    countNotificationsBadges();
    countFavoritesBadges();
  }
}
