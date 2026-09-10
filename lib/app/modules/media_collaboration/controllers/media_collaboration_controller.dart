import 'package:get/get.dart';

class CollaborationData {
  final String username;
  final String userType;
  final String agreementType;
  final String cost;
  final String startDate;
  final String endDate;
  final String status;

  CollaborationData({
    required this.username,
    required this.userType,
    required this.agreementType,
    required this.cost,
    required this.startDate,
    required this.endDate,
    required this.status,
  });
}

class MediaCollaborationController extends GetxController {
  final collaborations = <CollaborationData>[
    CollaborationData(
      username: "@ben345",
      userType: "Creator",
      agreementType: "Media Training",
      cost: "\$0.00",
      startDate: "8 June 2025",
      endDate: "7 June 2026",
      status: "Active",
    ),
    CollaborationData(
      username: "@sam612",
      userType: "Talent Manager",
      agreementType: "Contracted",
      cost: "\$800",
      startDate: "8 June 2025",
      endDate: "7 June 2026",
      status: "Pending",
    ),
    CollaborationData(
      username: "@kay475",
      userType: "Merchant",
      agreementType: "Product Interview",
      cost: "\$1400",
      startDate: "8 June 2025",
      endDate: "7 June 2026",
      status: "Completed",
    ),
  ].obs;
}
