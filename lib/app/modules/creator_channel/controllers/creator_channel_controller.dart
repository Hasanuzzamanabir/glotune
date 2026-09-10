import 'package:get/get.dart';

class CreatorChannelController extends GetxController {
  final selectedFilter = "Home".obs;
  final filters = ["Home", "Shorts", "Videos", "Live"];
  
  late Map<String, dynamic> creatorData;

  @override
  void onInit() {
    super.onInit();
    creatorData = Get.arguments ?? {
      'name': 'The ENTERTAINER',
      'subs': '120k.5K',
      'videos': '100',
      'avatar': 'assets/images/user_avatar.png'
    };
  }

  void setFilter(String filter) => selectedFilter.value = filter;
}
