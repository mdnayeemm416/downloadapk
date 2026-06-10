class ClientOverrideModel {
  final String id;
  final String clientName;
  final String status;
  final String? appname;
  final String? subscriptionToggledBy;
  final DateTime? createdAt;

  ClientOverrideModel({
    required this.id,
    required this.clientName,
    required this.status,
    this.appname,
    this.subscriptionToggledBy,
    this.createdAt,
  });

  factory ClientOverrideModel.fromJson(Map<String, dynamic> json) {
    return ClientOverrideModel(
      id: json['id']?.toString() ?? '',
      clientName: json['client_name'] as String? ?? json['clientName'] as String? ?? '',
      status: json['status'] as String? ?? 'inactive',
      appname: json['appname'] as String? ?? json['namespace'] as String?,
      subscriptionToggledBy: json['subscription_toggled_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'client_name': clientName,
        'status': status,
        if (appname != null) 'appname': appname,
        if (subscriptionToggledBy != null)
          'subscription_toggled_by': subscriptionToggledBy,
        if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      };

  ClientOverrideModel copyWith({
    String? id,
    String? clientName,
    String? status,
    String? appname,
    String? subscriptionToggledBy,
    DateTime? createdAt,
  }) {
    return ClientOverrideModel(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      status: status ?? this.status,
      appname: appname ?? this.appname,
      subscriptionToggledBy: subscriptionToggledBy ?? this.subscriptionToggledBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
