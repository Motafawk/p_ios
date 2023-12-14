
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;



Future mysql({ required String url, Map<String, String>? params, bool isGet = true })async{
  var response = null;
  try {
    if (isGet == true) {
      response = await jsonDecode((await http.get(Uri.parse(url))).body);
    } else {
      response =
      await jsonDecode((await http.post(Uri.parse(url), body: params,)).body);
    }
  }catch(err){
    print("err: ${err}");
    if(err.toString().contains("Connection failed")){
      Fluttertoast.showToast(
        msg: "تاكد من اتصال الانترنت ثم اعد المحاولة",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.red,
      );
      return;
    }else {
      Fluttertoast.showToast(
        msg: "خطا في السرفر فشل الرفع لا يوجد ملف php",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.red,
      );
    }
  }

  return response;
}

