import 'package:get/get.dart';
import '../vars.dart' as v;
import '../model/db/db_helper.dart';

class TermsData extends GetxController {
  DbHelper dbHelper = DbHelper();

  String apiName = "terms";
  List tableApi = [];

  String condition = "display = 1";

  Future<List> getSqlite({String condition = ""}) async {
    print("fetch from sqlite ${apiName}");
    return dbHelper.select(
      column: "*",
      table: apiName,
      condition: this.condition + " and " + condition,
    );
  }

  getApi({bool iscreated = true}) async {
    String max_dt = await dbHelper.maxDate(
      created_at: iscreated,
      table: apiName,
    );
    print("max_dt: ${max_dt}");

    final dt_type = (iscreated)? "c": "u";
    print("dt_type: ${dt_type}");
    tableApi = await v.api2.mysql(
      isGet: true,
      table: apiName,
      dt: max_dt,
      dt_type: dt_type,
    ).then((value) {
      return value??[];
    }).catchError((err){
      return [];
    });

    print("api ${apiName}: ${tableApi}");

    if(tableApi.length > 0){
      for (int i = 0; i < tableApi.length; i++){
        print("obj: ${tableApi[i]}");
        Map<String, dynamic> obj = tableApi[i];
        if(iscreated == true) {
          await dbHelper.insert(
            table: apiName,
            obj: obj,
          ).then((value) {
            print("insert to ${apiName} table id: ${value}");
            return value;
          }).catchError((err) {
            print("error add to ${apiName}: ${err}");
            return -1;
          });
        }else{
          await dbHelper.update(
              table: apiName,
              obj: obj,
              condition: " id = ${tableApi[i]['id']} "
          ).then((value) {
            print("update to ${apiName} table id: ${value}");
            return value;
          }).catchError((err) {
            print("error update to ${apiName}: ${err}");
            return -1;
          });
        }
      }
    }else{
      print("There is not data from mysql ${tableApi}");
    }
    print("api ${apiName} done: ${tableApi}");
    tableApi.clear();
  }

  Future prepare() async {
    await getApi(
      iscreated: true,
    );
    // await Future.delayed(Duration(milliseconds: 500));
    await getApi(
      iscreated: false,
    );
    await Future.delayed(Duration(milliseconds: 500));
    update();
  }

  @override
  void onInit() {
    super.onInit();
    print("init ${apiName}");
  }
}
