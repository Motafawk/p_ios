import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:motafawk/app_images.dart';
import 'package:motafawk/controller/ads_manager_controller.dart';
import 'package:motafawk/controller/bottom_navigation_controller.dart';
import '../controller/frame_pages_controller.dart';
import '../vars.dart' as v;

class MyBottomNavigation extends StatelessWidget {
  MyBottomNavigation({super.key});

  final BottomNavigationController bottomNavigationController = Get.put(BottomNavigationController());

  final FramePagesController framePagesController = Get.put(FramePagesController());

  AdsManagerController adsManagerController = Get.put(AdsManagerController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BottomNavigationController>(
      builder: (controller) {
        return CurvedNavigationBar(
          index: controller.currentIndex,
          color: v.primarycolor,
          backgroundColor: Colors.transparent,
          buttonBackgroundColor: Colors.white,
          height: 60,
          items: [
            Container(
              width: 36, height: 36,
              padding: EdgeInsets.all(6),
              child: (controller.currentIndex == 0)? SvgPicture.asset(
                AppImages.download_fill,
                color: v.primarycolor,
              ): SvgPicture.asset(
                AppImages.download,
                color: Colors.white,
              ),
            ),
            Container(
              width: 36, height: 36,
              padding: EdgeInsets.all(6),
              child: (controller.currentIndex == 1)? SvgPicture.asset(
                AppImages.favorite_fill,
                color: v.primarycolor,
              ): SvgPicture.asset(
                AppImages.favorite,
                color: Colors.white,
              ),
            ),
            Container(
              width: 40,
              height: 40,
              padding: EdgeInsets.all((controller.currentIndex == 2)? 0: 4),
              child: (controller.currentIndex == 2)? Image.asset(
                AppImages.home,
              ): Image.asset(
                AppImages.home,
                color: Colors.white,
              ),
            ),
            Container(
              width: 36, height: 36,
              padding: EdgeInsets.all(6),
              child: (controller.currentIndex == 3)? SvgPicture.asset(
                AppImages.telegram_fill,
                color: v.primarycolor,
              ): SvgPicture.asset(
                AppImages.telegram,
                color: Colors.white,
              ),
            ),
            Container(
              width: 36, height: 36,
              padding: EdgeInsets.all(6),
              child: (controller.currentIndex == 4)? SvgPicture.asset(
                AppImages.settings_fill,
                color: v.primarycolor,
              ): SvgPicture.asset(
                AppImages.settings,
                color: Colors.white,
              ),
            ),
          ],
          onTap: (i) async {

            adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "home");
            // int? watchFullRewardedAd = await adsManagerController.showInterstitialAdOrRewardedAd(context, fromPage: "home");
            // if(watchFullRewardedAd == 1) return;

            print("before navigation: ${controller.currentIndex}");
            if(controller.currentIndex == 0) {
              framePagesController.scrollPositionDownload = framePagesController.scrollController.offset;
            }
            else if(controller.currentIndex == 1) {
              framePagesController.scrollPositionFavorite = framePagesController.scrollController.offset;
            }
            else if(controller.currentIndex == 2) {
              framePagesController.scrollPositionHome = framePagesController.scrollController.offset;
            }
            else if(controller.currentIndex == 3) {
              framePagesController.scrollPositionContact = framePagesController.scrollController.offset;
            }
            else if(controller.currentIndex == 4) {
              framePagesController.scrollPositionSetting = framePagesController.scrollController.offset;
            }
            controller.changeCurrentIndex(i);
            print("after navigation: ${controller.currentIndex}");

            // if(controller.currentIndex == 0) {
            //   framePagesController.scrollController.jumpTo(framePagesController.scrollPositionDownload);
            // }
            // else if(controller.currentIndex == 1) {
            //   framePagesController.scrollController.jumpTo(framePagesController.scrollPositionFavorite);
            // }
            // else if(controller.currentIndex == 2) {
            //   framePagesController.scrollController.jumpTo(framePagesController.scrollPositionHome);
            // }
            // else if(controller.currentIndex == 3) {
            //   framePagesController.scrollController.jumpTo(framePagesController.scrollPositionContact);
            // }
            // else if(controller.currentIndex == 4) {
            //   framePagesController.scrollController.jumpTo(framePagesController.scrollPositionSetting);
            // }

          },
        );
      }
    );
  }
}
