import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../views/video_editor_view.dart';

class StudioController extends GetxController {
  final selectedTab = "Generate media".obs; // Generate media vs Merge media
  final tabs = ["Generate media", "Merge media"];
  
  final activeMergeStep = "Add video".obs;
  final mergeSteps = ["Add video", "Add audio", "Add music", "Add image"];

  final ImagePicker _picker = ImagePicker();

  void setTab(String tab) => selectedTab.value = tab;
  void setMergeStep(String step) => activeMergeStep.value = step;

  Future<void> pickVideoAndEdit() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      Get.to(() => VideoEditorScreen(file: File(file.path)));
    }
  }
}
