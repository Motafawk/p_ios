

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
// import 'package:mnhaji/view/frame_pages/home.dart';
import 'package:url_launcher/url_launcher.dart';
import 'vars.dart' as v;

Future<void> launchLink({required String url}) async {
  print("launchLink url: ${url}");
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    Fluttertoast.showToast(
      msg: "الانترنت او الرابط غير صحيح",
      backgroundColor: Colors.red,
    );
  }
}

void launchWhatsApp({required String phone, required String message}) async {
  String url() {
    if (Platform.isAndroid) {
      // add the [https]
      return "https://wa.me/$phone/?text=${Uri.parse(message)}"; // new line
    } else {
      // add the [https]
      return "https://api.whatsapp.com/send?phone=$phone=${Uri.parse(message)}"; // new line
    }
  }

  if (await canLaunchUrl(Uri.parse(url()))) {
    bool b = await launchUrl(Uri.parse(url()), mode: LaunchMode.externalApplication);
    print("launchWhatsApp: ${b}");
  } else {
    throw 'Could not launch ${url()}';
  }
}

void launchSms({required String phone, required String message}) async {
  String url = "sms:$phone?body=$message";
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}

void launchCall({required String phone}) async {
  String url = "tel:$phone";
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}

void launchFacebook({required String url}) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}

void launchTelegram({required String url}) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}

void launchEmail({required String email, required String message, String body = ""}) async {
  String url = Uri(
    scheme: 'mailto',
    path: "${email}",
    query: encodeQueryParameters(<String, String>{
      'subject': "${message}",
      'body': "${body}"
    }),
  ).toString();
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}
String encodeQueryParameters(Map<String, String> params) {
  return params.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
}

