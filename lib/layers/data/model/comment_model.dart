class CommentModel {
  final String? id;
  final String? userId;
  final String? username;
  final String? text;
  final DateTime? createdAt;

  CommentModel({
    this.id,
    this.userId,
    this.username,
    this.text,
    this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      username: json['username'] as String?,
      text: json['text'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'username': username,
        'text': text,
        'created_at': createdAt?.toIso8601String(),
      };
}
