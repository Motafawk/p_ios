import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';
import 'package:motafawk/main.dart';
import '../main.dart';
import '../funs.dart' as f;
import '../vars.dart' as v;

class MyConfetti extends StatefulWidget {
  final ConfettiController confettiController;
  const MyConfetti({super.key, required this.confettiController});

  @override
  State<MyConfetti> createState() => _MyConfettiState();
}

class _MyConfettiState extends State<MyConfetti> {

  FToast fToast = FToast();

  // ConfettiController confettiController =  ConfettiController(duration: Duration(milliseconds: 4500));

  @override
  void initState() {
    super.initState();
    fToast.init(MyApp.navigatorKey.currentContext!);
  }

  Future showToast() async {
    Widget toast = ConfettiWidget(
      confettiController: widget.confettiController,
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

    widget.confettiController.play();
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.CENTER,
      toastDuration: Duration(seconds: 10),
      fadeDuration: Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Confetti"),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text("Start Confetti"),
          onPressed: () async {
            print("---print context: ${MyApp.navigatorKey.currentContext}");
            await showToast();
            print("Finish toast");
          },
        ),
      ),
    );
  }
}


