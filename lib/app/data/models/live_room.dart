class HostUser {
  final int id;
  final String? username;
  final String? profilePicture;

  HostUser({
    required this.id,
    this.username,
    this.profilePicture,
  });

  factory HostUser.fromJson(Map<String, dynamic> json) {
    return HostUser(
      id: json['id'],
      username: json['username'],
      profilePicture: json['profile_picture'],
    );
  }
}

class LiveRoom {
  final int id;
  final String roomId;
  final String title;
  final HostUser host;
  final String status;
  final String availability;
  final int memberCount;
  final bool isHost;
  final String? agoraToken;
  final String? startedAt;
  final String? createdAt;

  LiveRoom({
    required this.id,
    required this.roomId,
    required this.title,
    required this.host,
    required this.status,
    required this.availability,
    required this.memberCount,
    required this.isHost,
    this.agoraToken,
    this.startedAt,
    this.createdAt,
  });

  factory LiveRoom.fromJson(Map<String, dynamic> json) {
    return LiveRoom(
      id: json['id'] ?? 0,
      roomId: json['room_id'] ?? '',
      title: json['title'] ?? '',
      host: HostUser.fromJson(json['host'] ?? {}),
      status: json['status'] ?? '',
      availability: json['availability'] ?? '',
      memberCount: json['member_count'] ?? 0,
      isHost: json['is_host'] ?? false,
      agoraToken: json['agora_token'],
      startedAt: json['started_at'],
      createdAt: json['created_at'],
    );
  }
}
