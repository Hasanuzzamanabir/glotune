import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PipService extends GetxService {
  OverlayEntry? _overlayEntry;
  Offset? _offset;
  
  bool get isPipActive => _overlayEntry != null;

  void showPip({
    required BuildContext context,
    required RtcEngine engine,
    required VoidCallback onTap,
  }) {
    if (_overlayEntry != null) return;

    _offset ??= Offset(20.w, 100.h);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: _offset!.dx,
          top: _offset!.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              _offset = _offset! + details.delta;
              _overlayEntry?.markNeedsBuild();
            },
            onTap: () {
              hidePip();
              onTap();
            },
            child: Material(
              color: Colors.transparent,
              elevation: 8,
              borderRadius: BorderRadius.circular(12.r),
              clipBehavior: Clip.antiAlias,
              child: Container(
                width: 120.w,
                height: 180.h,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Stack(
                  children: [
                    AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: engine,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "LIVE",
                          style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void hidePip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

extension LetExtension<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
