import 'package:get/get.dart';

class MakeDonationController extends GetxController {
  final selectedTipAmount = ''.obs;
  final customTipCost = ''.obs;
  final tipComment = ''.obs;

  final selectedCoinsAmount = ''.obs;
  final customCoinsCost = ''.obs;
  final coinsComment = ''.obs;

  final selectedCreditAmount = ''.obs;
  final customCreditCost = ''.obs;
  final creditComment = ''.obs;

  final selectedGiftAmount = ''.obs;
  final customGiftCost = ''.obs;
  final giftComment = ''.obs;
  
  final tipOptions = ['\$2', '\$5', '\$10', '\$20', '\$50', '\$100', '\$200', '\$300', '\$400', '\$500'];
  final coinOptions = ['10', '50', '100', '200', '300', '1000', '2000', '5000', '10000', '20000'];
  final creditOptions = ['2', '10', '25', '35', '40', '55', '60', '75', '80', '90'];
  final giftOptions = ['3000', '50', '30', '80', '1000', '2000', '5000', '6000', '8000', '10000'];

  void selectTip(String amount) {
    selectedTipAmount.value = amount;
    customTipCost.value = '';
  }

  void selectCoins(String amount) {
    selectedCoinsAmount.value = amount;
    customCoinsCost.value = '';
  }

  void selectCredit(String amount) {
    selectedCreditAmount.value = amount;
    customCreditCost.value = '';
  }

  void selectGift(String amount) {
    selectedGiftAmount.value = amount;
    customGiftCost.value = '';
  }
}
