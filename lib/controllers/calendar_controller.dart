import 'package:get/get.dart';

class CalendarController extends GetxController {
  static CalendarController get to => Get.put(CalendarController());

  RxString firstDay = "".obs;
  RxString secondDay = "".obs;
}