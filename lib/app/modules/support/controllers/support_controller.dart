import 'package:get/get.dart';

class SupportController extends GetxController {
  final faqs = [
    {
      'question': 'How do I change my password?',
      'answer': 'You can change your password by going to Settings > Security > Change Password. Enter your current password followed by your new password.',
    },
    {
      'question': 'How do I delete my account?',
      'answer': 'To delete your account, navigate to Settings > Account > Delete Account. Please note that this action is irreversible and all your data will be permanently removed.',
    },
    {
      'question': 'How does the competition process work?',
      'answer': 'When you register for a season competition, your profile will be reviewed by the talent managers. Once approved, you will receive a candidate badge and further instructions on submitting your entry.',
    },
    {
      'question': 'Who can I contact for payment issues?',
      'answer': 'For any payment-related issues, please contact our support team at billing@glotune.com with your transaction ID.',
    },
  ].obs;

  void contactSupport() {
    // In a real app, this might open an email client or a live chat.
    Get.snackbar(
      'Contact Support',
      'Opening email client to contact support@glotune.com',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
