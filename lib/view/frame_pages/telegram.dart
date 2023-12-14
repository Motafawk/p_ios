import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:motafawk/app_images.dart';
import 'package:motafawk/controller/ads_manager_controller.dart';
import 'package:motafawk/launch_link.dart';
import 'package:share/share.dart';
import '../../vars.dart' as v;

class Telegram extends StatefulWidget {
  const Telegram({super.key});

  @override
  State<Telegram> createState() => _TelegramState();
}

class _TelegramState extends State<Telegram> {

  AdsManagerController adsManagerController = Get.put(AdsManagerController());


  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Container(
      width: w,
      child: Column(
        children: [
          SizedBox(height: h * 0.1),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                Text(
                  "قم بمشاركة كل ما هو جديد مع زملائك الصف ",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                Text(
                  "${v.choiceClass!.name}",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.6, color: v.primarycolor, fontWeight: FontWeight.w600),
                ),
                Text(
                  " لتفيد وتستفيد",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ],
            ),
          ),
          SizedBox(height: h * 0.05),
          Container(
            width: w * 0.8,
            height: 60,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
              ),
              onPressed: () async {
                int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "home");
                if(watchFullRewardedAd == 1) return;

                if(v.choiceClass!.contact != null) {
                  await launchLink(url: "${v.choiceClass!.contact}");
                }
              },
              icon: SvgPicture.asset(AppImages.telegram_fill, color: Colors.white, height: 30, width: 30,),
              label: Padding(
                padding: const EdgeInsetsDirectional.only(start: 8),
                child: Text(
                  "شـــارك لتستفيد",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: h * 0.1),
          Container(
            width: w * 0.8,
            height: 60,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                backgroundColor: v.secondarycolor,
              ),
              onPressed: () async {
                int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "home");
                if(watchFullRewardedAd == 1) return;

                Share.share("""متفوق
رابط على جوجل بلاي:
https://play.google.com/store/apps/details?id=com.mhma.motafawk""");
              },
              icon: Icon(Icons.share_rounded, size: 32,),
              label: Padding(
                padding: const EdgeInsetsDirectional.only(start: 8),
                child: Text(
                  "مشاركة التطبيق",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 30,),
        ],
      ),
    );
  }
}
