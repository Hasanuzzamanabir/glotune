class SubscriberItem {
  final int id;
  final String? profilePicture;
  final String username;
  final String fullName;
  final String subscriberCount;
  final String subscribeTime;

  SubscriberItem({
    required this.id,
    this.profilePicture,
    required this.username,
    required this.fullName,
    required this.subscriberCount,
    required this.subscribeTime,
  });

  factory SubscriberItem.fromJson(Map<String, dynamic> json) {
    return SubscriberItem(
      id: json['id'] ?? 0,
      profilePicture: json['profile_picture'],
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      subscriberCount: json['subscriber_count'] ?? '0',
      subscribeTime: json['subscribe_time'] ?? '',
    );
  }
}
