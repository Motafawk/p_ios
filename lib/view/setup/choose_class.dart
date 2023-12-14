import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:motafawk/data/classes_data.dart';
import 'package:motafawk/data/types_data.dart';
import 'package:motafawk/model/class_model.dart';
import 'package:motafawk/model/db/db_helper.dart';
import 'package:motafawk/view/setup/choose_term.dart';
import '../../data/subsystems_data.dart';
import '../../data/systems_data.dart';
import '../../vars.dart' as v;

class ChooseClass extends StatefulWidget {
  const ChooseClass({super.key});

  @override
  State<ChooseClass> createState() => _ChooseClassState();
}

class _ChooseClassState extends State<ChooseClass> {

  ClassesData classesData = Get.put(ClassesData());
  TypesData typesData = Get.put(TypesData());
  SystemsData systemsData = Get.put(SystemsData());
  SubsystemsData subsystemsData = Get.put(SubsystemsData());


  ChooseClassController chooseClassController = Get.put(ChooseClassController());

  ClassModel? classItemSelected;

  prepareBasicData() async {
    await classesData.prepare();
    if((await DbHelper().countRows(table: "types", condition: "1")) == 0) {
      await typesData.prepare();
      await systemsData.prepare();
      await subsystemsData.prepare();
    }
  }
  @override
  void initState() {
    super.initState();
    classItemSelected = v.choiceClass;
    prepareBasicData();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: v.primarycolor,
      appBar: AppBar(
        backgroundColor: v.primarycolor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Builder(
            builder: (context) {
              bool isRefreshing = false;
              return StatefulBuilder(
                builder: (context, setStateInner) {
                  return IconButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    onPressed: (isRefreshing == true)? null: () async {
                      setStateInner(() {isRefreshing = true;});
                      await prepareBasicData();
                      setStateInner(() {isRefreshing = false;});
                    },
                    icon: (isRefreshing == true)? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      ): Icon(Icons.refresh),
                  );
                }
              );
            }
          ),
        ],
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  "اختر المرحلة الدراسية",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: h * 0.06),
              DropdownSearch<ClassModel>(
                validator: (ClassModel? item) {
                  if(item != null){
                    if(item.name == "" || item.name == null){
                      return "لا يمكن ترك هذا الحقل فارغ";
                    }
                  }else{
                    return "لا يمكن ترك هذا الحقل فارغ";
                  }
                  return null;
                },
                asyncItems: (String? filter) async {
                  List table = await classesData.getSqlite();
                  print("table: ${table}");
                  await Future.delayed(Duration(milliseconds: 1000));
                  final List<ClassModel> items = table.asMap().map((key, value) {
                    return MapEntry(key,
                        ClassModel(
                          id: value['id'],
                          name: value['name'],
                          contact: value['contact'],
                          display: value['display'],
                          createdAt: value['created_at'],
                          updatedAt: value['updated_at'],
                        ));
                  }).values.toList();
                  return items;
                },
                popupProps: PopupProps.menu(
                    itemBuilder: (context, item, isselected){
                      return Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                            textColor: (isselected == true)? v.primarycolor: Colors.black,
                            title: Text("${item.name}",),
                            // subtitle: Text("${item.detail}"),
                          ),
                          Divider(
                            height: 0,
                            color: isselected? v.primarycolor: v.tertiarycolor[400],
                            indent: 15,
                            endIndent: 15,
                          ),
                        ],
                      );
                    },
                    scrollbarProps: ScrollbarProps(
                        thumbVisibility: true
                    ),
                    showSelectedItems: true,
                    // disabledItemFn: (CountryItem item) {
                    //   return item.id == 1;
                    // },
                    constraints: BoxConstraints(
                        maxHeight: 250
                    ),
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      autofocus: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
                        hintText: "بحث".tr + " ...",
                      ),
                    ),
                    emptyBuilder: (context, str){
                      return Center(child: Text("لا توجد بيانات"));
                    },
                    loadingBuilder: (context, str) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    //labelText: "Menu mode",
                    hintText: "اختر المرحلة الدراسية ...",
                  ),
                ),
                clearButtonProps: ClearButtonProps(
                  isVisible: false,
                  // icon: Icon(Icons.close),
                ),
                onChanged: (ClassModel? item) {
                  print("item: ${item?.id}, ${item?.name}, ${item?.contact}");
                  classItemSelected = item;
                  chooseClassController.update();
                },
                selectedItem: classItemSelected,
                compareFn: (i, s) {
                  return (i.id == s.id)? true: false;
                },
                itemAsString: (ClassModel? item) {
                  return item!.name!;
                },
              ),
              GetBuilder<ChooseClassController>(
                builder: (context) {
                  return TextButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white60,
                    ),
                    onPressed: (classItemSelected != null)? () async {

                      try {
                        print(v.subscribe + v.choiceClass!.id.toString());
                        await FirebaseMessaging.instance.unsubscribeFromTopic(v.subscribe + v.choiceClass!.id.toString()).then((value) {
                          print("unsubscribe yes: ${v.subscribe + v.choiceClass!.id.toString()}");
                        }).catchError((err) {
                          print("err unsubscribe: ${err}");
                        });
                      } catch (err) {
                        print("err FirebaseMessaging.instance: ${err}");
                      }


                      print("classItemSelected!.toMap(): ${classItemSelected!.toMap()}");
                      GetStorage().write("choice_class", classItemSelected!.toMap());
                      v.choiceClass = classItemSelected;
                      Get.to(() => ChooseTerm());
                    }: null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "الــتــالــي",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Icon(Icons.arrow_forward_outlined, size: 22,),
                        ),
                      ],
                    ),
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChooseClassController extends GetxController {

}

