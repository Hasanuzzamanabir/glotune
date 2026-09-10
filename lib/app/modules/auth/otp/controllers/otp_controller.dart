import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:glotune/app/core/network/api_client.dart';
import 'package:glotune/app/core/values/api_constants.dart';
import 'package:glotune/app/routes/app_pages.dart';
import 'package:glotune/app/core/services/auth_service.dart';

class OtpController extends GetxController {
  final countdown = 60.obs;
  Timer? _timer;

  final RxString otp = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  void startTimer() {
    countdown.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        _timer?.cancel();
      }
    });
  }

  String get timerText {
    final minutes = (countdown.value / 60).floor().toString().padLeft(2, '0');
    final seconds = (countdown.value % 60).toString().padLeft(2, '0');
    return '($minutes:$seconds)';
  }

  Future<void> verifyOtp() async {
    if (otp.value.length < 6) {
      Get.snackbar('Error', 'Please enter a valid 6-digit OTP', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final args = Get.arguments ?? {};
    final email = args['email'];
    final phoneNumber = args['phone_number'];
    final flow = args['flow'] ?? 'register';

    if (email == null && phoneNumber == null) {
      Get.snackbar('Error', 'Missing contact information to verify.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      if (email != null) {
        await _verifyEmailOtp(email, flow);
      } else if (phoneNumber != null) {
        await _verifyPhoneOtp(phoneNumber, flow);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _verifyEmailOtp(String email, String flow) async {
    final response = await apiClient.post(
      Uri.parse('${ApiConstants.baseUrl}auth/verify-email/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp.value}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Get.snackbar('Success', data['message'] ?? 'Verification successful', snackPosition: SnackPosition.BOTTOM);
      
      final token = data['token'] ?? data['access'] ?? data['access_token'];
      final refresh = data['refresh'];
      
      if (token != null) {
        Get.find<AuthService>().saveTokens(access: token, refresh: refresh);
      }

      final newArgs = Map<String, dynamic>.from(Get.arguments ?? {});
      newArgs['otp'] = otp.value;

      if (flow == 'register') {
        Get.toNamed(Routes.ONBOARDING, arguments: newArgs);
      } else {
        Get.toNamed(Routes.CREATE_PASSWORD, arguments: newArgs);
      }
    } else {
      Get.snackbar('Error', data['message'] ?? 'Verification failed', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _verifyPhoneOtp(String phoneNumber, String flow) async {
    final response = await apiClient.post(
      Uri.parse('${ApiConstants.baseUrl}auth/verify-phone-otp/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_number': phoneNumber, 'otp': otp.value}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Get.snackbar('Success', data['message'] ?? 'Verification successful', snackPosition: SnackPosition.BOTTOM);
      
      final token = data['token'] ?? data['access'] ?? data['access_token'];
      final refresh = data['refresh'];
      
      if (token != null) {
        Get.find<AuthService>().saveTokens(access: token, refresh: refresh);
      }

      final newArgs = Map<String, dynamic>.from(Get.arguments ?? {});
      newArgs['otp'] = otp.value;

      if (flow == 'register') {
        Get.toNamed(Routes.ONBOARDING, arguments: newArgs);
      } else {
        Get.toNamed(Routes.CREATE_PASSWORD, arguments: newArgs);
      }
    } else {
      Get.snackbar('Error', data['message'] ?? 'Verification failed', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
