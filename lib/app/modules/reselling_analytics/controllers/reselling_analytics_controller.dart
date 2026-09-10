import 'package:get/get.dart';

class ResellingAnalyticsController extends GetxController {
  final analyticsData = [
    {
      'period': 'February\n2025',
      'records': [
        {'sn': '1', 'slots': '@jan728', 'plan': 'Enterprise Tier 2', 'status': 'Unpaid', 'date': '31-02-2025'},
        {'sn': '2', 'slots': '@ben841', 'plan': 'Pro Plan', 'status': 'Paid', 'date': '05-02-2025'},
        {'sn': '3', 'slots': '@ten639', 'plan': 'Enterprise Tier 3', 'status': 'Unpaid', 'date': '25-02-2025'},
        {'sn': '4', 'slots': '@kay227', 'plan': 'Enterprise Tier 1', 'status': 'Paid', 'date': '15-02-2025'},
      ]
    },
    {
      'period': 'January\n2025',
      'records': [
        {'sn': '1', 'slots': '@jan728', 'plan': 'Enterprise Tier 2', 'status': 'Unpaid', 'date': '31-01-2025'},
        {'sn': '2', 'slots': '@ben841', 'plan': 'Pro Plan', 'status': 'Paid', 'date': '05-01-2025'},
        {'sn': '3', 'slots': '@ten639', 'plan': 'Enterprise Tier 3', 'status': 'Unpaid', 'date': '25-01-2025'},
        {'sn': '4', 'slots': '@kay227', 'plan': 'Enterprise Tier 1', 'status': 'Paid', 'date': '15-01-2025'},
      ]
    }
  ].obs;

  void revokeAccess(String period, String username) {
    Get.snackbar(
      'Access Revoked',
      'Access for $username has been revoked.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
