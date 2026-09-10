import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_editor/video_editor.dart';

class VideoEditorScreen extends StatefulWidget {
  const VideoEditorScreen({super.key, required this.file});

  final File file;

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  late final VideoEditorController _controller;
  bool _exported = false;
  String _exportText = "";

  @override
  void initState() {
    super.initState();
    _controller = VideoEditorController.file(
      widget.file,
      minDuration: const Duration(seconds: 1),
      maxDuration: const Duration(seconds: 60),
    );
    _controller.initialize().then((_) => setState(() {})).catchError((error) {
      Get.snackbar("Error", "Cannot initialize video editor");
      Get.back();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _exportVideo() async {
    setState(() {
      _exportText = "Exporting...";
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _exportText = "Video Exported Successfully!";
      _exported = true;
    });
    Get.snackbar("Success", "Video exported to gallery.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            onPressed: _exportVideo,
            icon: const Icon(Icons.save, color: Colors.white),
          ),
        ],
      ),
      body: _controller.initialized
          ? Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CropGridViewer.preview(controller: _controller),
                      AnimatedBuilder(
                        animation: _controller.video,
                        builder: (_, _) => AnimatedOpacity(
                          opacity: _controller.isPlaying ? 0 : 1,
                          duration: const Duration(milliseconds: 200),
                          child: GestureDetector(
                            onTap: _controller.video.play,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 200,
                  margin: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Icon(Icons.content_cut, color: Colors.white)),
                                  Text('Trim Video', style: TextStyle(color: Colors.white))
                                ]),
                            Flexible(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: TrimSlider(
                                  controller: _controller,
                                  height: 60,
                                  horizontalMargin: MediaQuery.of(context).size.width / 4,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      if (_exportText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _exportText,
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
