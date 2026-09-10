import 'package:get/get.dart';

class CustomizeMembershipController extends GetxController {
  final selectedPlan = 'Starter Plan'.obs;
  
  final plans = [
    'Starter Plan',
    'Pro Plan',
    'Enterprise Plan',
  ];

  final perks = [
    {'name': 'Exclusive content access', 'selected': true},
    {'name': 'Behind the scenes videos', 'selected': false},
    {'name': 'Member only polls', 'selected': true},
    {'name': 'Collaboration opportunities', 'selected': false},
  ].obs;

  final isPublic = true.obs;

  void togglePerk(int index) {
    perks[index]['selected'] = !(perks[index]['selected'] as bool);
    perks.refresh();
  }

  void setAvailability(bool public) {
    isPublic.value = public;
  }
}
