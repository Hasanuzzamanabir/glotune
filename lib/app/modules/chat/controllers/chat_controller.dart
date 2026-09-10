import 'package:get/get.dart';

class ChatController extends GetxController {
  late Map<String, dynamic> contactData;
  
  final messages = [
    {'text': 'Hello?', 'isMe': false, 'time': '11:50 AM'},
    {'text': 'How may I be of help Abena?', 'isMe': true, 'time': '11:52 AM'},
    {'text': 'I have booked your taxi, can you come pick me up right away?', 'isMe': false, 'time': '11:55 AM'},
    {'text': 'Yes, madam. I\'m currently rushing down to your location', 'isMe': true, 'time': '11:56 AM'},
    {'text': 'Can you take a photo of the location around you? so that I can find you easily', 'isMe': false, 'time': '11:58 AM'},
    {'text': 'Of course! I will send now.', 'isMe': true, 'time': '11:59 AM'},
  ].obs;

  @override
  void onInit() {
    super.onInit();
    contactData = Get.arguments ?? {'name': 'Abena Plait', 'status': 'Online'};
  }
}
