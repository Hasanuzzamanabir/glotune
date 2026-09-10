import 'package:get/get.dart';
import '../controllers/comments_made_controller.dart';

class CommentsMadeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommentsMadeController>(() => CommentsMadeController());
  }
}
