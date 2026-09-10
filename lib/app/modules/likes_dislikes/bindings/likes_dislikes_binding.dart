import 'package:get/get.dart';
import '../controllers/likes_dislikes_controller.dart';

class LikesDislikesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LikesDislikesController>(() => LikesDislikesController());
  }
}
