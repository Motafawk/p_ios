import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class MyDealFile extends StatefulWidget {
  const MyDealFile({Key? key}) : super(key: key);

  @override
  State<MyDealFile> createState() => _MyDealFileState();
}

class _MyDealFileState extends State<MyDealFile> {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("My Deal File"),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: w,
          height: h,
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  Directory? dir = await getExternalStorageDirectory();
                  print("path: ${dir!.path}");
                },
                child: Text(""),
              )
            ],
          ),
        ),
      ),
    );
  }
}

