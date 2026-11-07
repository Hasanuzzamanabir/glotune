class UserProfile {
  final int id;
  final String? email;
  final String? fullName;
  final String? userType;
  final String? country;
  final String? city;
  final String? profilePictureUrl;
  final String? coverPhotoUrl;
  final int subscriberCount;
  final int followerCount;
  final int followingCount;
  final int yourCoins;

  UserProfile({
    required this.id,
    this.email,
    this.fullName,
    this.userType,
    this.country,
    this.city,
    this.profilePictureUrl,
    this.coverPhotoUrl,
    this.subscriberCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.yourCoins = 0,
  });

  UserProfile copyWith({
    int? id,
    String? email,
    String? fullName,
    String? userType,
    String? country,
    String? city,
    String? profilePictureUrl,
    String? coverPhotoUrl,
    int? subscriberCount,
    int? followerCount,
    int? followingCount,
    int? yourCoins,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      userType: userType ?? this.userType,
      country: country ?? this.country,
      city: city ?? this.city,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      subscriberCount: subscriberCount ?? this.subscriberCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      yourCoins: yourCoins ?? this.yourCoins,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final Map<String, dynamic> p = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : (json['user'] is Map<String, dynamic>
            ? json['user'] as Map<String, dynamic>
            : (json['profile'] is Map<String, dynamic>
                ? json['profile'] as Map<String, dynamic>
                : json));

    int parsedCoins = 0;
    final coinCandidates = [
      p['your_coins'],
      p['coins'],
      p['coin_balance'],
      p['balance'],
      p['remaining_coins'],
      p['total_coins'],
      p['wallet_balance'],
      if (p['wallet'] is Map) (p['wallet']['coins'] ?? p['wallet']['balance']),
    ];

    for (final candidate in coinCandidates) {
      if (candidate != null) {
        final val = parseInt(candidate);
        if (val > 0) {
          parsedCoins = val;
          break;
        }
      }
    }

    print("[DEBUG UserProfile.fromJson] JSON keys: ${p.keys.toList()} | parsed yourCoins: $parsedCoins");

    return UserProfile(
      id: parseInt(p['id']),
      email: p['email']?.toString(),
      fullName: p['full_name']?.toString() ?? p['name']?.toString() ?? p['username']?.toString(),
      userType: p['user_type']?.toString(),
      country: p['country']?.toString(),
      city: p['city']?.toString(),
      profilePictureUrl: p['profile_picture_url']?.toString() ?? p['avatar']?.toString() ?? p['profile_picture']?.toString(),
      coverPhotoUrl: p['cover_photo_url']?.toString(),
      subscriberCount: parseInt(p['subscriber_count'] ?? p['suscriber_count']),
      followerCount: parseInt(p['follower_count']),
      followingCount: parseInt(p['following_count']),
      yourCoins: parsedCoins,
    );
  }
}
