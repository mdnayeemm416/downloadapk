class UserStatsModel {
  final int likesGiven;
  final int likesReceived;
  final int likesToday;
  final int followers;
  final int following;

  UserStatsModel({
    this.likesGiven = 0,
    this.likesReceived = 0,
    this.likesToday = 0,
    this.followers = 0,
    this.following = 0,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      likesGiven: json['likes_given'] ?? 0,
      likesReceived: json['likes_received'] ?? 0,
      likesToday: json['likes_today'] ?? 0,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
    );
  }
}
