import 'package:get/get.dart';
import '../controllers/favorite_videos_controller.dart';

class FavoriteVideosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoriteVideosController>(() => FavoriteVideosController());
  }
}
