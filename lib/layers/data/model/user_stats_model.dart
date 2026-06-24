class UserStatsModel {
  final int likesGiven;
  final int likesReceived;
  final int likesToday;
  final int followers;
  final int following;
  final int likesGivenToday;
  final int likesReceivedToday;

  UserStatsModel({
    this.likesGiven = 0,
    this.likesReceived = 0,
    this.likesToday = 0,
    this.followers = 0,
    this.following = 0,
    this.likesGivenToday = 0,
    this.likesReceivedToday = 0,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      likesGiven: json['likes_given'] ?? 0,
      likesReceived: json['likes_received'] ?? 0,
      likesToday: json['likes_today'] ?? 0,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      likesGivenToday: json['likes_given_today'] ?? 0,
      likesReceivedToday: json['likes_received_today'] ?? 0,
    );
  }
}
