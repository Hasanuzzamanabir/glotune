import 'package:get/get.dart';

class PerformanceData {
  final String videoTitle;
  final String views;
  final String watchTime;
  final String likes;
  final String comments;
  final String engagementRate;
  final String shares;
  final String earnings;

  PerformanceData({
    required this.videoTitle,
    required this.views,
    required this.watchTime,
    required this.likes,
    required this.comments,
    required this.engagementRate,
    required this.shares,
    required this.earnings,
  });
}

class PerformanceLogController extends GetxController {
  final performances = <PerformanceData>[
    PerformanceData(
      videoTitle: "My Skin Care",
      views: "32,000",
      watchTime: "12 hrs",
      likes: "800",
      comments: "120",
      engagementRate: "6.2%",
      shares: "150",
      earnings: "\$2000",
    ),
    PerformanceData(
      videoTitle: "Smart Earpiece",
      views: "18,000",
      watchTime: "85 hrs",
      likes: "650",
      comments: "90",
      engagementRate: "8.0%",
      shares: "75",
      earnings: "\$1000",
    ),
    PerformanceData(
      videoTitle: "Tekno 9D4",
      views: "24,000",
      watchTime: "99 hrs",
      likes: "740",
      comments: "104",
      engagementRate: "7.5%",
      shares: "84",
      earnings: "\$3000",
    ),
  ].obs;
}
