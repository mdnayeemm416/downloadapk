class ActivityStatsModel {
  final String day;
  final int likesGiven;
  final int likesReceived;

  ActivityStatsModel({
    required this.day,
    this.likesGiven = 0,
    this.likesReceived = 0,
  });

  factory ActivityStatsModel.fromJson(Map<String, dynamic> json) {
    return ActivityStatsModel(
      day: json['day'] ?? '',
      likesGiven: json['likes_given'] ?? 0,
      likesReceived: json['likes_received'] ?? 0,
    );
  }
}
