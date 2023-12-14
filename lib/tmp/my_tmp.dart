import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motafawk/tmp/my_confetti.dart';

class MyTmp extends StatefulWidget {
  MyTmp({super.key});
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  State<MyTmp> createState() => _MyTmpState();
}

class _MyTmpState extends State<MyTmp> {

  ConfettiController confettiController =  ConfettiController(duration: Duration(milliseconds: 4500));

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("My Tmp"),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text("To My Confetti"),
          onPressed: () async {
            Get.to(() => MyConfetti(confettiController: confettiController,));
          },
        ),
      ),
    );
  }
}
