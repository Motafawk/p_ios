import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../launch_link.dart';
import '../funs.dart' as f;

class StopApp extends StatefulWidget {
  final Map<String, dynamic> data;
  StopApp({super.key, required this.data});

  @override
  State<StopApp> createState() => _StopAppState();
}

class _StopAppState extends State<StopApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${widget.data['alarmTitle']}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 18),
              Text(
                "${widget.data['alarmBody']}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 8),
              if(widget.data['img'] != "")
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: Get.width,
                    height: 250,
                    child: f.imageUrl("${widget.data['img']}", boxFit: BoxFit.cover),
                  ),
                ),
              SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        padding: EdgeInsets.symmetric(vertical: 20),
                      ),
                      onPressed: () async {
                        await launchLink(url: "${widget.data['url']}");
                      },
                      child: Text("${widget.data['okBut']}"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

