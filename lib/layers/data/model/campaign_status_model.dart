class CampaignStatusModel {
  final bool campaignsAvailable;
  final int completedToday;
  final int timeRemaining;
  final String timeRemainingReadable;

  CampaignStatusModel({
    required this.campaignsAvailable,
    required this.completedToday,
    required this.timeRemaining,
    required this.timeRemainingReadable,
  });

  factory CampaignStatusModel.fromJson(Map<String, dynamic> json) {
    return CampaignStatusModel(
      campaignsAvailable: (json['campaignsAvailable'] ?? json['campaigns_available']) as bool? ?? false,
      completedToday: (json['completedToday'] ?? json['completed_today']) as int? ?? 0,
      timeRemaining: (json['timeRemaining'] ?? json['time_remaining']) as int? ?? 0,
      timeRemainingReadable: (json['timeRemainingReadable'] ?? json['time_remaining_readable'])?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'campaignsAvailable': campaignsAvailable,
        'completedToday': completedToday,
        'timeRemaining': timeRemaining,
        'timeRemainingReadable': timeRemainingReadable,
      };

  CampaignStatusModel copyWith({
    bool? campaignsAvailable,
    int? completedToday,
    int? timeRemaining,
    String? timeRemainingReadable,
  }) {
    return CampaignStatusModel(
      campaignsAvailable: campaignsAvailable ?? this.campaignsAvailable,
      completedToday: completedToday ?? this.completedToday,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      timeRemainingReadable: timeRemainingReadable ?? this.timeRemainingReadable,
    );
  }
}
