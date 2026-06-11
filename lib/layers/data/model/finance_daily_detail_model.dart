import 'package:adnetwork/layers/data/model/finance_summary_model.dart';

class DailyDetailModel {
  final String? date;
  final String? startDate;
  final String? endDate;
  final int registrationsCount;
  final double payoutsTotal;
  final int disbursedSubscribersCount;
  final List<SessionSubscriber> subscribers;
  final List<PayoutModel> payouts;

  DailyDetailModel({
    this.date,
    this.startDate,
    this.endDate,
    required this.registrationsCount,
    required this.payoutsTotal,
    required this.disbursedSubscribersCount,
    required this.subscribers,
    required this.payouts,
  });

  factory DailyDetailModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return DailyDetailModel(
      date: json['date'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      registrationsCount: json['registrationsCount'] as int? ?? json['registrations_count'] as int? ?? 0,
      payoutsTotal: toDouble(json['payoutsTotal'] ?? json['payouts_total']),
      disbursedSubscribersCount: json['disbursedSubscribersCount'] as int? ?? json['disbursed_subscribers_count'] as int? ?? 0,
      subscribers: json['users'] != null
          ? (json['users'] as List)
              .map((s) => SessionSubscriber.fromJson(s as Map<String, dynamic>))
              .toList()
          : [],
      payouts: json['payouts'] != null
          ? (json['payouts'] as List)
              .map((p) => PayoutModel.fromJson(p as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'startDate': startDate,
        'endDate': endDate,
        'registrationsCount': registrationsCount,
        'payoutsTotal': payoutsTotal,
        'disbursedSubscribersCount': disbursedSubscribersCount,
        'subscribers': subscribers.map((s) => s.toJson()).toList(),
        'payouts': payouts.map((p) => p.toJson()).toList(),
      };
}

class SessionSubscriber {
  final String id;
  final String username;
  final String? email;
  final String? namespace;
  final int autolike;
  final String? paymentMethod;
  final String? toggler;
  final String? createdAt;
  final String? subscriptionStartedAt;

  SessionSubscriber({
    required this.id,
    required this.username,
    this.email,
    this.namespace,
    required this.autolike,
    this.paymentMethod,
    this.toggler,
    this.createdAt,
    this.subscriptionStartedAt,
  });

  factory SessionSubscriber.fromJson(Map<String, dynamic> json) {
    return SessionSubscriber(
      id: json['id']?.toString() ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String?,
      namespace: json['namespace'] as String? ?? json['appname'] as String? ?? '',
      autolike: json['autolike'] as int? ?? json['is_approved'] as int? ?? 0,
      paymentMethod: json['paymentMethod'] as String? ?? json['payment_method'] as String?,
      toggler: json['toggler'] as String? ?? json['subscription_toggled_by'] as String? ?? json['toggled_by'] as String?,
      createdAt: json['created_at'] as String?,
      subscriptionStartedAt: json['subscription_started_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'namespace': namespace,
        'autolike': autolike,
        'paymentMethod': paymentMethod,
        'toggler': toggler,
        'created_at': createdAt,
        'subscription_started_at': subscriptionStartedAt,
      };
}
