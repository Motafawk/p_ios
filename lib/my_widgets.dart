import 'package:flutter/material.dart';
import 'vars.dart' as v;

class TheresNotData extends StatelessWidget {
  TheresNotData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 5),
      color: Colors.white,
      child: Center(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Text("لا توجد بيانات", style: TextStyle( fontSize: 16, color: Colors.black),),
          )
      ),
    );
  }
}

class ErrorInDb extends StatelessWidget {
  const ErrorInDb({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      color: Colors.white,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(8),
          child: Text("خطا في قاعدة البيانات", style: TextStyle(color: Colors.red, fontSize: 16),),
        ),
      ),
    );
  }
}

class LoadingData extends StatelessWidget {

  final double size;

  LoadingData({Key? key, this.size = 100}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(
            strokeWidth: 3,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(v.primarycolor),
          ),
        ),
      ],
    );
  }
}

