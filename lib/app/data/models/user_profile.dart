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

    return UserProfile(
      id: parseInt(json['id']),
      email: json['email']?.toString(),
      fullName: json['full_name']?.toString(),
      userType: json['user_type']?.toString(),
      country: json['country']?.toString(),
      city: json['city']?.toString(),
      profilePictureUrl: json['profile_picture_url']?.toString(),
      coverPhotoUrl: json['cover_photo_url']?.toString(),
      subscriberCount: parseInt(json['suscriber_count']),
      followerCount: parseInt(json['follower_count']),
      followingCount: parseInt(json['following_count']),
      yourCoins: parseInt(json['your_coins']),
    );
  }
}
