import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motafawk/controller/ads_manager_controller.dart';
import 'package:motafawk/view/frame_pages/downloader/download_files.dart';
import 'package:motafawk/view/setup/choose_class.dart';
import 'package:motafawk/view/setup/choose_term.dart';
import 'package:motafawk/view/once_splash.dart';
import '../../vars.dart' as v;

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  AdsManagerController adsManagerController = Get.put(AdsManagerController());

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    double textFieldRadius = 100;
    return Container(
      width: w,
      child: Column(
        children: [
          SizedBox(height: h * 0.05),
          SettingElement(
            label: "المرحلة الدراسية",
            name: "${v.choiceClass!.name}",
            btnName: "تغيير",
            onClick: () async {
              int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "home");
              if(watchFullRewardedAd == 1) return;

              Get.to(() => ChooseClass());
            },
          ),
          SizedBox(height: h * 0.03),
          if(v.choiceVSubsystem == null)
            SettingElement(
            label: "الفصل الدراسي",
            name: "${v.choiceTerm!.name}",
            btnName: "تغيير",
            onClick: () async {
              int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "home");
              if(watchFullRewardedAd == 1) return;

              Get.to(() => ChooseTerm());
            },
          ),
          if(v.choiceVSubsystem != null)
            SettingElement(
              label: "الفصل الدراسي",
              name: "${v.choiceTerm!.name}.${v.choiceVSubsystem!.systemName} - ${v.choiceVSubsystem!.name}",
              btnName: "تغيير",
              onClick: () async {
                int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "home");
                if(watchFullRewardedAd == 1) return;

                Get.to(() => ChooseTerm());
              },
            ),
          SizedBox(height: h * 0.03),
          SettingElement(
            label: "الملفات",
            name: "جميع الملفات التي تم تنزيلها",
            btnName: "التنزيلات",
            onClick: () async {
              int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "home");
              if(watchFullRewardedAd == 1) return;

              Get.to(() => DownloadFiles());
            },
          ),
          SizedBox(height: h * 0.03),
          SettingElement(
            label: "تحديث البيانات",
            name: "سيقوم بجلب البيانات من السيرفر",
            btnName: "تحديث",
            onClick: () async {
              int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "home");
              if(watchFullRewardedAd == 1) return;
              Get.offAll(() => OnceSplash());
            },
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}

class SettingElement extends StatelessWidget {
  final String label;
  final String name;
  final String btnName;
  final Function()? onClick;
  const SettingElement({super.key, required this.label, required this.name, required this.btnName, required this.onClick});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Container(
      child: Stack(
        children: [
          Container(
            width: w * 0.95,
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsetsDirectional.only(start: 20, end: 8, top: 6, bottom: 6),
            decoration: BoxDecoration(
              border: Border.all(color: v.primarycolor),
              borderRadius: BorderRadius.circular(100),
            ),
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${name}",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ),
                Container(
                  height: 43,
                  // width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      backgroundColor: v.secondarycolor,
                    ),
                    onPressed: onClick,
                    child: Text("${btnName}"),
                  ),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            start: 30,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6),
              color: v.tertiarycolor[100],
              child: Text(
                "${label}",
                style: TextStyle(fontSize: 12, color: v.primarycolor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
