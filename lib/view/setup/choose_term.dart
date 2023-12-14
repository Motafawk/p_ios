import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:motafawk/data/subsystems_data.dart';
import 'package:motafawk/data/terms_data.dart';
import 'package:motafawk/model/term_model.dart';
import 'package:motafawk/model/vsubsystem_model.dart';
import 'package:motafawk/view/frame_pages.dart';
import '../../model/db/db_helper.dart';
import '../../vars.dart' as v;
import '../once_splash.dart';

class ChooseTerm extends StatefulWidget {
  const ChooseTerm({super.key});

  @override
  State<ChooseTerm> createState() => _ChooseTermState();
}

class _ChooseTermState extends State<ChooseTerm> {

  TermsData termsData = Get.put(TermsData());
  SubsystemsData subsystemsData = Get.put(SubsystemsData());

  ChooseTermController chooseTermController = Get.put(ChooseTermController());

  TermModel? termItemSelected;
  VSubsystemModel? vSubsystemItemSelected;

  @override
  void initState() {
    super.initState();
    termItemSelected = v.choiceTerm;
    vSubsystemItemSelected = v.choiceVSubsystem;
    termsData.prepare();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: v.primarycolor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: v.primarycolor,
        foregroundColor: Colors.white,
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
                          await termsData.prepare();
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
                  "اختر الفصل الدراسي",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: h * 0.06),
              DropdownSearch<TermModel>(
                validator: (TermModel? item) {
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
                  List table = await termsData.getSqlite();
                  print("table: ${table}");
                  await Future.delayed(Duration(milliseconds: 1000));
                  final List<TermModel> items = table.asMap().map((key, value) {
                    return MapEntry(key,
                        TermModel(
                          id: value['id'],
                          name: value['name'],
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
                      maxHeight: 250,
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
                onChanged: (TermModel? item) {
                  print("item: ${item?.id}, ${item?.name}");
                  termItemSelected = item;
                  chooseTermController.update();
                },
                selectedItem: termItemSelected,
                compareFn: (i, s) {
                  return (i.id == s.id)? true: false;
                },
                itemAsString: (TermModel? item) {
                  return item!.name!;
                },
              ),
              if(v.choiceClass!.id >= 10) SizedBox(height: h * 0.04),
              if(v.choiceClass!.id >= 10)
                DropdownSearch<VSubsystemModel>(
                validator: (VSubsystemModel? item) {
                  if(item != null) {
                    if(item.name == "" || item.name == null) {
                      return "لا يمكن ترك هذا الحقل فارغ";
                    }
                  }else{
                    return "لا يمكن ترك هذا الحقل فارغ";
                  }
                  return null;
                },
                asyncItems: (String? filter) async {
                  List table = await subsystemsData.getSqlite();
                  print("table: ${table}");
                  await Future.delayed(Duration(milliseconds: 1000));
                  final List<VSubsystemModel> items = table.asMap().map((key, value) {
                    return MapEntry(key,
                        VSubsystemModel(
                          id: value['id'],
                          name: value['name'],
                          display: value['display'],
                          createdAt: value['created_at'],
                          updatedAt: value['updated_at'],
                          systemId: value['system_id'],
                          systemName: value['system_name'],
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
                            title: Text("${item.systemName} - ${item.name}",),
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
                      maxHeight: 250,
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
                onChanged: (VSubsystemModel? item) {
                  print("item: ${item?.id}, ${item?.name}");
                  vSubsystemItemSelected = item;
                  chooseTermController.update();
                },
                selectedItem: vSubsystemItemSelected,
                compareFn: (i, s) {
                  return (i.id == s.id)? true: false;
                },
                itemAsString: (VSubsystemModel? item) {
                  return item!.name!;
                },
              ),
              // button ok ________________________________
              if(v.choiceClass!.id < 10)
                GetBuilder<ChooseTermController>(
                  builder: (context) {
                    return TextButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white60,
                      ),
                      onPressed: (termItemSelected != null)? () async {
                        GetStorage().write("choice_term", termItemSelected!.toMap());
                        v.choiceTerm = termItemSelected;
                        await DbHelper().delete(table: "units", condition: "1");
                        Get.offAll(() => OnceSplash());
                      }: null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "مــوافــق",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                        ],
                      ),
                    );
                  }
              ),
              if(v.choiceClass!.id >= 10)
                GetBuilder<ChooseTermController>(
                  builder: (context) {
                    return TextButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white60,
                      ),
                      onPressed: (termItemSelected != null && vSubsystemItemSelected != null)? () async {
                        GetStorage().write("choice_term", termItemSelected!.toMap());
                        GetStorage().write("choice_vsubsystem", vSubsystemItemSelected!.toMap());
                        v.choiceTerm = termItemSelected;
                        await DbHelper().delete(table: "units", condition: "1");
                        Get.offAll(() => OnceSplash());
                      }: null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "مــوافــق",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 8),
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

class ChooseTermController extends GetxController {

}

