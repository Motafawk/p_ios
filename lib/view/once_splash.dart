import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:motafawk/data/sections_data.dart';
import 'package:motafawk/data/subjects_data.dart';
import 'package:motafawk/data/units_data.dart';
import 'package:motafawk/model/db/db_helper.dart';
import 'package:motafawk/view/frame_pages.dart';

class OnceSplash extends StatefulWidget {
  const OnceSplash({super.key});

  @override
  State<OnceSplash> createState() => _OnceSplashState();
}

class _OnceSplashState extends State<OnceSplash> {

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
    Get.offAll(() => FramePages(doPrepareUnits: false));
  }

  @override
  void initState() {
    super.initState();
    prepareUnits();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(height: 0),
            Container(
              height: 250,
              width: 250,
              child: Image.asset("assets/images/logo.png"),
            ),
            Container(
              height: 40, width: 40,
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}

