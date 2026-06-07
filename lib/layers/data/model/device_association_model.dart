import 'package:adnetwork/layers/data/model/user_model.dart';

class DeviceAssociationModel {
  final String? id;
  final String? userId;
  final String? deviceId;
  final String? status;
  final DateTime? createdAt;
  final UserModel? user;

  DeviceAssociationModel({
    this.id,
    this.userId,
    this.deviceId,
    this.status,
    this.createdAt,
    this.user,
  });

  factory DeviceAssociationModel.fromJson(Map<String, dynamic> json) {
    return DeviceAssociationModel(
      id: json['id']?.toString(),
      userId: json['user_id'] as String?,
      deviceId: json['device_id'] as String?,
      status: json['is_approved'] == 1 ? 'approved' : 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      user: UserModel(
        id: json['user_id']?.toString(),
        username: json['username'] as String?,
        email: json['email'] as String?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'deviceId': deviceId,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'user': user?.toJson(),
    };
  }

  DeviceAssociationModel copyWith({
    String? id,
    String? userId,
    String? deviceId,
    String? status,
    DateTime? createdAt,
    UserModel? user,
  }) {
    return DeviceAssociationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
    );
  }
}
