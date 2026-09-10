import 'package:get/get.dart';

class MyChannelController extends GetxController {
  final selectedFilter = "Shorts".obs; // Shorts, Videos, Posts
  final filters = ["Shorts", "Videos", "Posts"];
  
  void setFilter(String filter) => selectedFilter.value = filter;
}
