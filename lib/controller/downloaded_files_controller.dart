import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';

import '../data/units_data.dart';
import '../funs.dart' as f;

class DownloadedFilesController extends GetxController {
  UnitsData unitsData = Get.put(UnitsData());
  String condition = "";
  List<String> files = [];
  downloadedFiles() async {
    files.clear();
    List<DownloadTask>? tasks = await FlutterDownloader.loadTasksWithRawQuery(
      query: "select * from task WHERE status = 3;",
    );
    print("tasks: ${tasks}");
    for (DownloadTask element in tasks??[]) {
      files.add("${f.convertHexToArabic(element.url.toString().split("/").last)}");
    }
    print("files join: '${files.join("','")}'");
    condition = "file in ('${files.join("','")}')";
    unitsData.update();
  }
}
