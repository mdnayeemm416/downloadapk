class NoticeModel {
  final String? id;
  final String? text;
  final String? bgColor;
  final String? textColor;
  final DateTime? createdAt;

  NoticeModel({
    this.id,
    this.text,
    this.bgColor,
    this.textColor,
    this.createdAt,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id']?.toString(),
      text: json['text'] as String?,
      bgColor: json['bg_color'] as String?,
      textColor: json['text_color'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'bg_color': bgColor,
        'text_color': textColor,
        'created_at': createdAt?.toIso8601String(),
      };
}
