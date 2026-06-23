class CampaignLinkModel {
  final String id;
  final String userId;
  final String url;
  final String? title;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String username;
  final String role;
  final int globalLikes;
  final int likeCount;
  final bool isLiked;

  CampaignLinkModel({
    required this.id,
    required this.userId,
    required this.url,
    this.title,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.username,
    required this.role,
    this.globalLikes = 0,
    this.likeCount = 0,
    this.isLiked = false,
  });

  factory CampaignLinkModel.fromJson(Map<String, dynamic> json) {
    return CampaignLinkModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      title: json['title'] as String?,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      username: json['username']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      globalLikes: (json['global_likes'] as int?) ?? 0,
      likeCount: (json['like_count'] as int?) ?? 0,
      isLiked: (json['is_liked'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'url': url,
        'title': title,
        'description': description,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'username': username,
        'role': role,
        'global_likes': globalLikes,
        'like_count': likeCount,
        'is_liked': isLiked,
      };

  CampaignLinkModel copyWith({
    String? id,
    String? userId,
    String? url,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? username,
    String? role,
    int? globalLikes,
    int? likeCount,
    bool? isLiked,
  }) {
    return CampaignLinkModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      username: username ?? this.username,
      role: role ?? this.role,
      globalLikes: globalLikes ?? this.globalLikes,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
