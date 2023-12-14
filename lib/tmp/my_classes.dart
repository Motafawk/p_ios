import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motafawk/data/classes_data.dart';
import '../vars.dart' as v;
import '../my_widgets.dart';
import '../model/class_model.dart';

class MyClasses extends StatefulWidget {
  const MyClasses({super.key});

  @override
  State<MyClasses> createState() => _MyClassesState();
}

class _MyClassesState extends State<MyClasses> {

  ClassesData classesData = Get.put(ClassesData());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Classes"),
        actions: [
          IconButton(
            onPressed: () async {
              await classesData.prepare();
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: GetBuilder<ClassesData>(
        builder: (controller) {
          return FutureBuilder(
            future: controller.getSqlite(),
            builder: (context, AsyncSnapshot<List> snapshot) {
              if(snapshot.hasData) {
                if(snapshot.data!.length == 0){
                  return TheresNotData();
                }
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, int i){
                    final item = ClassModel.fromJson(snapshot.data![i]);
                    return Text("${item.name}");
                  },
                  separatorBuilder: (context, int i){
                    return Divider(height: 1, color: v.tertiarycolor,);
                  },
                );
              }
              else if(snapshot.hasError){
                return ErrorInDb();
              }else{
                return LoadingData();
              }
            }
          );
        }
      ),
    );
  }
}

