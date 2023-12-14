import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:confetti/confetti.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:motafawk/view/stop_app.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../app_images.dart';
import '../launch_link.dart';
import '../main.dart';
import '../vars.dart' as v;
import '../funs.dart' as f;

class AdsManagerController extends GetxController {

  late ConfettiController mainConfettiController;
  FToast fToast = FToast();
  late ConfettiController homeConfettiController;
  late ConfettiController notificationsConfettiController;
  late ConfettiController pdfReaderConfettiController;
  // bool isPlayingConfetti = false;


  appInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
  }

  final dio = Dio();
  late PackageInfo packageInfo;
  Future<Map<String, dynamic>?>? generalSettings() async {
    packageInfo = await PackageInfo.fromPlatform();
    print("version name: ${packageInfo.version}");
    print("version number: ${packageInfo.buildNumber}");
    try {
      final response = await dio.get('https://motafawk.github.io/motafawk/motafawk.json');
      Map<String, dynamic> data = response.data;
      print(data);
      print(data.runtimeType);
      await GetStorage().write("general_settings", data);
      print("data['appVersion']: ${data['appVersion']}, packageInfo.version: ${packageInfo.version}");
      if(data['appVersion'] != packageInfo.version || data['stopApp'] == "1") {
        Get.defaultDialog(
          barrierDismissible: false,
          title: "${data['alarmTitle']}",
          titleStyle:TextStyle(
            fontWeight: FontWeight.w600,
          ),
          content: Column(
            children: [
              Text(
                "${data['alarmBody']}",
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.4, fontSize: 14),
              ),
              SizedBox(height: 8),
              if(data['img'] != "")
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: Get.width,
                    height: 200,
                    child: f.imageUrl("${data['img']}", boxFit: BoxFit.cover),
                  ),
                ),
            ],
          ),
          confirm: Column(
            children: [
              Container(
                width: Get.width,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(),
                  ),
                  onPressed: () async {
                    await launchLink(url: "${data['url']}");
                  },
                  child: Text("${data['okBut']}"),
                ),
              ),
              SizedBox(height: 8),
              Container(
                child: (data['stopApp'] == "1")? null: Container(
                  width: Get.width,
                  height: 50,
                  child: TextButton(
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(side: BorderSide(color: v.secondarycolor, width: 2)),
                      foregroundColor: v.secondarycolor,
                      padding: EdgeInsets.symmetric(horizontal: 33),
                    ),
                    onPressed: () {
                      Get.back();
                    },
                    child: Text("${data['cancelBut']}", style: TextStyle(fontWeight: FontWeight.w600),),
                  ),
                ),
              ),
            ],
          ),

        ).then((value) {
          if(data['stopApp'] == "1") {
            Get.offAll(() => StopApp(data: data));
          }
        });
      }
    } catch(err) {
      print("err general settings: ${err}");
    }
    return await GetStorage().read("general_settings");
  }

  BannerAd? bannerAd;
  int loadBannerAdFailedAttempts = 1;
  bool isLoadedBannerAd = false;
  Future<void> loadBannerAd() async {
    bannerAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-6606559119948451/5051367343'
          : 'iosBannerAd',
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          print('$ad BannerAd is loaded.');
          // setState(() {isLoadedBannerAd = true;});
          isLoadedBannerAd = true;
          update();
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) async {
          print('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
          ad.dispose();
          loadBannerAdFailedAttempts = loadBannerAdFailedAttempts + 1;
          await Future.delayed(Duration(seconds: 3));
          if(loadBannerAdFailedAttempts <= 3) {
            print("loadBannerAdFailedAttempts: ${loadBannerAdFailedAttempts}");
            loadBannerAd();
          }
          if(isLoadedBannerAd == true) {
            isLoadedBannerAd = false;
            update();
          }
        },
      ),
    )..load();
  }

  InterstitialAd? interstitialAd;
  int loadInterstitialAdFailedAttempts = 1;
  int numDisplayInterstitialAd = 1;
  bool isLoadedInterstitialAd = false;
  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-6606559119948451/9804220321'
          : 'iosInterstitialAd',
      request: const AdRequest(),

      adLoadCallback: InterstitialAdLoadCallback(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          print('$ad InterstitialAd is loaded.');
          isLoadedInterstitialAd = true;
          // Keep a reference to the ad so you can show it later.

          ad.fullScreenContentCallback = FullScreenContentCallback(
            // Called when the ad showed the full screen content.
            onAdShowedFullScreenContent: (ad) {},
            // Called when an impression occurs on the ad.
            onAdImpression: (ad) {},
            // Called when the ad failed to show full screen content.
            onAdFailedToShowFullScreenContent: (ad, err) {
              // Dispose the ad here to free resources.
              ad.dispose();
              loadInterstitialAd();
            },
            // Called when the ad dismissed full screen content.
            onAdDismissedFullScreenContent: (ad) {
              // Dispose the ad here to free resources.
              ad.dispose();
              print("Finish show interstitial Ad");
              loadInterstitialAd();
            },
            // Called when a click is recorded for an ad.
            onAdClicked: (ad) {},
          );

          print('$ad InterstitialAd is loaded FullScreenContentCallback ready.');
          // Keep a reference to the ad so you can show it later.
          interstitialAd = ad;
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (LoadAdError err) async {
          print('InterstitialAd failed to load: $err');
          isLoadedInterstitialAd = false;
          loadInterstitialAdFailedAttempts = loadInterstitialAdFailedAttempts + 1;
          await Future.delayed(Duration(seconds: 3));
          if(loadInterstitialAdFailedAttempts <= 3) {
            loadInterstitialAd();
          }
        },
      ),
    );
  }

  RewardedAd? rewardedAd;
  int loadRewardedAdFailedAttempts = 1;
  int numDisplayRewardedAd = 1;
  int rewardedCore = 0;
  bool isLoadedRewardedAd = false;
  Future<void> loadRewardedAd() async {
     await RewardedAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-6606559119948451/6437203845'
          : 'iosRewardedAd',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          print('$ad RewardedAd is loaded.');
          isLoadedRewardedAd = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            // Called when the ad showed the full screen content.
              onAdShowedFullScreenContent: (ad) {},
              // Called when an impression occurs on the ad.
              onAdImpression: (ad) {},
              // Called when the ad failed to show full screen content.
              onAdFailedToShowFullScreenContent: (ad, err) {
                // Dispose the ad here to free resources.
                rewardedCore = 0;
                ad.dispose();
                loadRewardedAd();
              },
              // Called when the ad dismissed full screen content.
              onAdDismissedFullScreenContent: (ad) {
                print("onAdDismissed RewardedAd");
                if(rewardedCore == 1) {
                  giveReward();
                }else{
                  Fluttertoast.showToast(
                      msg: "Must watch the ad completely",
                      backgroundColor: Colors.black45,
                      textColor: Colors.white,
                      gravity: ToastGravity.CENTER,
                      toastLength: Toast.LENGTH_LONG
                  );
                }
                rewardedCore = 0;
                ad.dispose();
                print("Finish show rewarded Ad");
                loadRewardedAd();
              },
              // Called when a click is recorded for an ad.
              onAdClicked: (ad) {});

          print('$ad RewardedAd is loaded FullScreenContentCallback ready.');
          // Keep a reference to the ad so you can show it later.
          rewardedAd = ad;
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (LoadAdError err) async {
          print('RewardedAd failed to load: $err');
          isLoadedRewardedAd = false;
          loadRewardedAdFailedAttempts = loadRewardedAdFailedAttempts + 1;
          await Future.delayed(Duration(seconds: 3));
          if(loadRewardedAdFailedAttempts <= 3) {
            loadRewardedAd();
          }
        },
      ),
    );
  }

  showInterstitialAd() async {
    int rand = Random().nextInt(3) + 1;
    numDisplayInterstitialAd = numDisplayInterstitialAd + 1;
    print("rand: ${rand}, numDisplayInterstitialAd: ${numDisplayInterstitialAd}, isLoadedInterstitialAd: ${isLoadedInterstitialAd}");
    if(numDisplayInterstitialAd % 2 == 0 && rand == 2 && isLoadedInterstitialAd == true) {
      interstitialAd!.show();
    }
  }
  showRewardedAd() async {
    rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
        print("The user rewarded: ${ad.adUnitId}, ${rewardItem.amount}");
        rewardedCore = 1;
        print("rewardedCore: ${rewardedCore}");
        update();
      },
    );
  }

  giveReward() async {
    try{
      v.audioPlayer.play(AssetSource("confetti.ogg"));
      Fluttertoast.showToast(
          msg: "🥳 Stars Confetti! 🥳",
          backgroundColor: Colors.purple[400]!.withOpacity(0.9),
          textColor: Colors.white,
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_LONG
      );
      showConfetti();
      // if(fromPage == "home") {
      //   homeConfettiController.play();
      // }
      // else if(fromPage == "notifications") {
      //   notificationsConfettiController.play();
      // }
      // else if(fromPage == "pdf_reader") {
      //   pdfReaderConfettiController.play();
      // }
    }catch(err){
      print("err in giveReward: ${err}");
    }
  }

  Future showConfetti() async {
    Widget toast = ConfettiWidget(
      confettiController: mainConfettiController,
      blastDirectionality: BlastDirectionality.explosive,
      emissionFrequency: 0.1,
      numberOfParticles: 60,
      minBlastForce: 10,
      maxBlastForce: 100,
      gravity: 0.1,
      createParticlePath: (size) {
        return f.drawStar(size);
      },
    );

    mainConfettiController.play();
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.CENTER,
      toastDuration: Duration(seconds: 10),
      fadeDuration: Duration(seconds: 1),
    );
  }

  rewardedDialog(BuildContext context) async {
    int rand = Random().nextInt(5) + 1;
    numDisplayRewardedAd = numDisplayRewardedAd + 1;
    print("rand: ${rand}, numDisplayRewardedAd: ${numDisplayRewardedAd}, isLoadedRewardedAd: ${isLoadedRewardedAd}");
    if(numDisplayRewardedAd % 2 == 1 && rand == 1 && isLoadedRewardedAd == true) {
      return await AwesomeDialog(
        context: context,
        animType: AnimType.bottomSlide,
        dialogType: DialogType.noHeader,
        customHeader: RotationTransition(
          turns: AlwaysStoppedAnimation(-15 / 360),
          child: Container(
            width: 100,
            height: 100,
            margin: EdgeInsets.all(12),
            color: Colors.transparent,
            child: Image.asset(AppImages.gift),
          ),
        ).animate(
            onPlay: (controller) {
              controller.repeat();
            }
        )
            .shimmer(duration: 2400.ms)
            .shake(hz: 4, curve: Curves.easeInOutCubic, duration: 2000.ms)
            .scaleXY(end: 1.2, duration: 1200.ms)
            .then(delay: 600.ms)
            .scaleXY(end: 1 / 1.2, duration: 1000.ms),
        title: "احتفال النجوم",
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
        desc: "شاهد الإعلان كاملاً لتحصل على المكافئة",
        btnOk: Container(
          height: 45,
          child: ElevatedButton.icon(
            icon: Icon(Icons.live_tv),
            label: Text("مشاهدة"),
            onPressed: () async {
              showRewardedAd();
              Navigator.of(context).pop(1);
            },
          ),
        ),
        descTextStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey[800],
          height: 1.3,
        ),
        showCloseIcon: true,
        dismissOnTouchOutside: false,
      ).show().then((value) {
        print("AwesomeDialog value: ${value}");
        return value;
      });
    }
  }

  String fromPage = "home";
  showInterstitialAdOrRewardedAd(BuildContext context, {required String fromPage}) async {
    this.fromPage = fromPage;
    if(loadBannerAdFailedAttempts == 4) {
      loadBannerAdFailedAttempts = 1;
      loadBannerAd();
    }
    if(loadInterstitialAdFailedAttempts == 4) {
      loadInterstitialAdFailedAttempts = 1;
      loadInterstitialAd();
    }
    if(loadRewardedAdFailedAttempts == 4) {
      loadRewardedAdFailedAttempts = 1;
      loadRewardedAd();
    }
    if(isLoadedInterstitialAd == true) showInterstitialAd();
    if(isLoadedRewardedAd == true) return await rewardedDialog(context);
  }

  loadAds() async {
    v.gSettings = await generalSettings();
    print("v.ip: ${v.gSettings!['ip']}");
    if(v.gSettings == null) return;
    if(v.gSettings!['ip'] != "") {
      v.ip = v.gSettings!['ip'];
    }
    if(v.gSettings!['activeAds'] != "1") return;
    loadBannerAd();
    loadInterstitialAd();
    loadRewardedAd();
  }


}
