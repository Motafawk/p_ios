import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import '../../funs.dart' as f;
import '../../vars.dart' as v;

String supplications = "supplications";

BaseOptions options = BaseOptions(
  baseUrl: "${v.link}",
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
);

Dio dio = Dio(options);
class Api2{
  int progress = 0;
  int size = 0;
  var controller;
  Future mysql({
    String? url,
    Map<String, dynamic>? params,
    required bool isGet,
    File? file,
    required String table,
    String? dt,
    String? dt_type,
    CancelToken? cancelToken,
    String condition = '1',
    var controller = null,
    bool showToast = true,
  }) async {
    Response? response = null;
    try {
      if ((isGet == true)) {
        print("${v.link}/select.php?table=$table&condition=$condition");
        if(dt_type == null) {
          response = await dio.get(
            url ?? "${v.link}/select.php?table=$table&condition=$condition",
            queryParameters: params, cancelToken: cancelToken,
          );
        }else if(dt_type == "c"){
          response = await dio.get(
            url ?? "${v.link}/select.php?table=$table&created_at=$dt&condition=$condition",
            queryParameters: params, cancelToken: cancelToken
          );
        }else{
          response = await dio.get(
            url ?? "${v.link}/select.php?table=$table&updated_at=$dt&condition=$condition",
            queryParameters: params, cancelToken: cancelToken
          );
        }
      }
      else{
        if(file != null) {
          params!.addAll({
            "file": MultipartFile.fromFileSync(
              file.path, filename: basename(file.path),
            ),
          });
        }
        var formData = FormData.fromMap(params!);
        response = await dio.post(
          url?? "${v.link}/exec.php?table=$table",
          data: formData,
          onSendProgress: (int sent, int total) {
            print('$sent $total');
            progress = sent;
            size = total;
            if(controller != null) {
              controller.progressRun(((sent / total) * 100).toInt());
            }
          },
          cancelToken: cancelToken
        );
      }
      print("response data ${table}: ${response.data}");
      print("showtoastsuccess: ${showToast}");
      return f.responseToast(response.data, showToast: showToast);
    } catch(err){
      print("err cache: ${err}");
      v.responseStatus = 400;
      if(err is DioException) {
        DioException dioError = err;
        print("err: ${dioError.message}");
        if (dioError.response == null) {
          print("خطا تم الغاء الرفع تاكد من اتصال الانترنت او قد يكون خلل في السرفر");
          if(isGet == false) {
            Fluttertoast.showToast(
              msg: "خطا تم الغاء الرفع تاكد من اتصال الانترنت او قد يكون خلل في السرفر",
              backgroundColor: Colors.red,
              textColor: Colors.black,
            );
          }
        }
        else {
          print("response status code: ${dioError.response!.statusCode}");
          if (dioError.response!.statusCode == 404) {
            print("خطا في السرفر قد يكون ملف php غير صحيح");
            Fluttertoast.showToast(
              msg: "خطا في السرفر قد يكون ملف php غير صحيح",
              backgroundColor: Colors.red,
              textColor: Colors.black,
            );
          }
          else if (dioError.response!.statusCode == 500) {
            print(
                "خطا تم الغاء الرفع او الرابط غير صحيح او الملف الذي اخترته غير موجود او معطوب");
            Fluttertoast.showToast(
              msg: "خطا تم الغاء الرفع او الرابط غير صحيح او الملف الذي اخترته غير موجود او معطوب",
              backgroundColor: Colors.red,
              textColor: Colors.black,
            );
          } else {
            print("خطا لم يتم الرفع خطا غير متوقع");
            Fluttertoast.showToast(
              msg: "خطا لم يتم الرفع خطا غير متوقع",
              backgroundColor: Colors.red,
              textColor: Colors.black,
            );
          }
        }
      }
      else if(err is FileSystemException){
        FileSystemException fileSystemException = err as FileSystemException;
        print("err: ${fileSystemException.message}");
        Fluttertoast.showToast(
          msg: "خطا الملف الذي اخترته غير موجود او معطوب او تم الغاء الرفع او الرابط غير صحيح",
          backgroundColor: Colors.red,
          textColor: Colors.black,
        );
      }
      else{
        Fluttertoast.showToast(
          msg: "خطا لم يتم الرفع خطا غير متوقع",
          backgroundColor: Colors.red,
          textColor: Colors.black,
        );
      }
    }
    return [];
  }
}




