import 'package:adnetwork/layers/data/model/link_model.dart';

class UserModel {
  final String? id;
  final String? username;
  final String? email;
  final String? profilePhoto;
  final String? bio;
  final String? role;
  final int? isApproved;
  final int? isBlocked;
  int followersCount;
  int followingCount;
  int linkCount;
  int likesReceived;
  bool isFollowing;
  final DateTime? createdAt;
  final List<LinkModel>? links;

  UserModel({
    this.id,
    this.username,
    this.email,
    this.profilePhoto,
    this.bio,
    this.role,
    this.isApproved,
    this.isBlocked,
    this.followersCount = 0,
    this.followingCount = 0,
    this.linkCount = 0,
    this.likesReceived = 0,
    this.isFollowing = false,
    this.createdAt,
    this.links,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      username: json['username'] as String?,
      email: json['email'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      bio: json['bio'] as String?,
      role: json['role'] as String?,
      isApproved: json['is_approved'] as int?,
      isBlocked: json['is_blocked'] as int?,
      followersCount: (json['follower_count'] as int?) ?? (json['followers_count'] as int?) ?? 0,
      followingCount: (json['following_count'] as int?) ?? 0,
      linkCount: (json['link_count'] as int?) ?? 0,
      likesReceived: (json['likes_received'] as int?) ?? 0,
      isFollowing: (json['is_following'] as bool?) ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      links: json['links'] != null
          ? (json['links'] as List).map((l) => LinkModel.fromJson(l as Map<String, dynamic>)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'profile_photo': profilePhoto,
    'bio': bio,
    'role': role,
    'is_approved': isApproved,
    'is_blocked': isBlocked,
    'followers_count': followersCount,
    'following_count': followingCount,
    'link_count': linkCount,
    'likes_received': likesReceived,
    'is_following': isFollowing,
    'created_at': createdAt?.toIso8601String(),
  };

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? profilePhoto,
    String? bio,
    String? role,
    int? isApproved,
    int? isBlocked,
    int? followersCount,
    int? followingCount,
    int? linkCount,
    int? likesReceived,
    bool? isFollowing,
    DateTime? createdAt,
    List<LinkModel>? links,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      isApproved: isApproved ?? this.isApproved,
      isBlocked: isBlocked ?? this.isBlocked,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      linkCount: linkCount ?? this.linkCount,
      likesReceived: likesReceived ?? this.likesReceived,
      isFollowing: isFollowing ?? this.isFollowing,
      createdAt: createdAt ?? this.createdAt,
      links: links ?? this.links,
    );
  }
}
