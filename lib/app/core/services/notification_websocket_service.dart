import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../values/api_constants.dart';
import '../../routes/app_pages.dart';
import 'auth_service.dart';
import '../../modules/live_player/controllers/live_player_controller.dart';

class NotificationWebSocketService extends GetxService {
  WebSocket? _ws;
  Timer? _reconnectTimer;
  final RxBool isConnected = false.obs;
  final RxBool hasPendingAutoAccept = false.obs;

  @override
  void onInit() {
    super.onInit();
    final authService = Get.find<AuthService>();
    ever(authService.accessToken, (token) {
      if (token != null && token.isNotEmpty) {
        connect();
      } else {
        disconnect();
      }
    });
    if (authService.accessToken.value != null && authService.accessToken.value!.isNotEmpty) {
      connect();
    }
  }

  void connect() {
    disconnect();
    try {
      final authService = Get.find<AuthService>();
      final token = authService.accessToken.value;
      if (token == null || token.isEmpty) return;

      final parsed = Uri.parse(ApiConstants.baseUrl);
      final wsScheme = parsed.scheme == 'https' ? 'wss' : 'ws';
      final portStr = parsed.hasPort ? ':${parsed.port}' : '';
      final wsUrl = '$wsScheme://${parsed.host}$portStr/api/ws/notifications/?token=$token';

      print("[NotificationWS] Connecting to: $wsUrl");
      WebSocket.connect(wsUrl).then((ws) {
        _ws = ws;
        isConnected.value = true;
        print("[NotificationWS] Connected successfully!");

        ws.listen(
          (event) {
            try {
              final data = jsonDecode(event.toString());
              print("[NotificationWS] Received event: $data");
              if (data is Map<String, dynamic>) {
                _handleNotificationEvent(data);
              }
            } catch (e) {
              print("[NotificationWS] Error parsing message: $e");
            }
          },
          onError: (err) {
            print("[NotificationWS] Stream error: $err");
            _scheduleReconnect();
          },
          onDone: () {
            print("[NotificationWS] Stream closed");
            _scheduleReconnect();
          },
        );
      }).catchError((err) {
        print("[NotificationWS] Connection error: $err");
        _scheduleReconnect();
      });
    } catch (e) {
      print("[NotificationWS] Connect exception: $e");
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _ws = null;
    isConnected.value = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      final authService = Get.find<AuthService>();
      if (authService.accessToken.value != null) {
        connect();
      }
    });
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    try {
      _ws?.close();
    } catch (_) {}
    _ws = null;
    isConnected.value = false;
  }

  void _handleNotificationEvent(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    final notifType = data['notification_type']?.toString();

    if (notifType == 'live_invitation' ||
        type == 'live_invitation' ||
        (type == 'notification' && notifType == 'live_invitation')) {
      final hostName = data['sender_name'] ?? data['username'] ?? 'Host';
      final roomId = data['room_id']?.toString() ?? '';
      final message = data['message'] ?? "@$hostName invited you to join their live stream!";

      print("[NotificationWS] Handling live invitation for room $roomId from $hostName");

      // 1. If currently inside LivePlayerView for this room, trigger prompt directly
      if (Get.isRegistered<LivePlayerController>()) {
        try {
          final playerCtrl = Get.find<LivePlayerController>();
          if (roomId.isEmpty || playerCtrl.roomId == roomId) {
            playerCtrl.triggerCohostInvitationPrompt(hostName.toString());
            return;
          }
        } catch (_) {}
      }

      // 2. If viewer is on another screen, display the invitation dialog
      _showGlobalLiveInviteDialog(
        hostName: hostName.toString(),
        roomId: roomId,
        message: message.toString(),
      );
    }
  }

  void _showGlobalLiveInviteDialog({
    required String hostName,
    required String roomId,
    required String message,
  }) {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1E293B),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text("🎉", style: TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Live Stream Invitation!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text("Decline"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        if (roomId.isNotEmpty) {
                          hasPendingAutoAccept.value = true;
                          Get.toNamed(Routes.LIVE_PLAYER, arguments: roomId);
                        }
                      },
                      child: const Text("Accept & Go Live"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
