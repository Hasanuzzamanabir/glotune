import 'package:get/get.dart';
import '../controllers/search_controller.dart' as sc;

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<sc.SearchController>(() => sc.SearchController());
  }
}
