class InformationCenterModel {
  final String? userName;
  final String? userUsername;
  final String? revenueSharing;
  final String? others;
  final String? duration;

  InformationCenterModel({
    this.userName,
    this.userUsername,
    this.revenueSharing,
    this.others,
    this.duration,
  });

  factory InformationCenterModel.fromJson(Map<String, dynamic> json) {
    return InformationCenterModel(
      userName: json['user_name'],
      userUsername: json['user_username'],
      revenueSharing: json['revenue_sharing'],
      others: json['others'],
      duration: json['duration'],
    );
  }
}
