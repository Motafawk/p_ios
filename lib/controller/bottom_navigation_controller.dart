import 'package:get/get.dart';

class BottomNavigationController extends GetxController{
  int currentIndex = 2;

  changeCurrentIndex(int currentIndex){
    this.currentIndex = currentIndex;
    update();
  }

}