class ScoreModel {
  final double? effectiveScore;

  ScoreModel({this.effectiveScore});

  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      effectiveScore: (json['effective_score'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'effective_score': effectiveScore,
      };
}
