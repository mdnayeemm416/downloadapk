class FinanceSummaryModel {
  final FinanceStats stats;
  final List<PayoutModel> payouts;

  FinanceSummaryModel({
    required this.stats,
    required this.payouts,
  });

  factory FinanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return FinanceSummaryModel(
      stats: FinanceStats.fromJson(json['stats'] as Map<String, dynamic>? ?? {}),
      payouts: json['payouts'] != null
          ? (json['payouts'] as List)
              .map((p) => PayoutModel.fromJson(p as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'stats': stats.toJson(),
        'payouts': payouts.map((p) => p.toJson()).toList(),
      };
}

class SubscriptionBreakdown {
  final int totalActive;
  final int paidUsers;
  final int freeUsers;
  final int staffSubscriptions;
  final int notSubscribed;
  final double subscriptionPrice;
  final int outstandingCount;
  final double actualAmount;

  SubscriptionBreakdown({
    required this.totalActive,
    required this.paidUsers,
    required this.freeUsers,
    required this.staffSubscriptions,
    required this.notSubscribed,
    required this.subscriptionPrice,
    required this.outstandingCount,
    required this.actualAmount,
  });

  factory SubscriptionBreakdown.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return SubscriptionBreakdown(
      totalActive: json['totalActive'] as int? ?? 0,
      paidUsers: json['paidUsers'] as int? ?? 0,
      freeUsers: json['freeUsers'] as int? ?? 0,
      staffSubscriptions: json['staffSubscriptions'] as int? ?? 0,
      notSubscribed: json['notSubscribed'] as int? ?? 0,
      subscriptionPrice: toDouble(json['subscriptionPrice']),
      outstandingCount: json['outstandingCount'] as int? ?? 0,
      actualAmount: toDouble(json['actualAmount']),
    );
  }

  Map<String, dynamic> toJson() => {
        'totalActive': totalActive,
        'paidUsers': paidUsers,
        'freeUsers': freeUsers,
        'staffSubscriptions': staffSubscriptions,
        'notSubscribed': notSubscribed,
        'subscriptionPrice': subscriptionPrice,
        'outstandingCount': outstandingCount,
        'actualAmount': actualAmount,
      };
}

class PaymentMethodBreakdown {
  final String method;
  final int count;
  final double totalAmount;
  final int outstandingCount;
  final double actualAmount;

  PaymentMethodBreakdown({
    required this.method,
    required this.count,
    required this.totalAmount,
    required this.outstandingCount,
    required this.actualAmount,
  });

  factory PaymentMethodBreakdown.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return PaymentMethodBreakdown(
      method: json['method'] as String? ?? 'Unspecified',
      count: json['count'] as int? ?? 0,
      totalAmount: toDouble(json['totalAmount']),
      outstandingCount: json['outstandingCount'] as int? ?? 0,
      actualAmount: toDouble(json['actualAmount']),
    );
  }

  Map<String, dynamic> toJson() => {
        'method': method,
        'count': count,
        'totalAmount': totalAmount,
        'outstandingCount': outstandingCount,
        'actualAmount': actualAmount,
      };
}

class FinanceStats {
  final String cycle;
  final String appname;
  final double subscriptionPrice;
  final int totalSubscribers;
  final int freeSubscribers;
  final int paidSubscribers;
  final double totalRevenue;
  final double actualRevenue;
  final double shakilShare;
  final double nayeemShare;
  final double rashedShare;
  final double totalPaid;
  final double totalPaidShakil;
  final double totalPaidNayeem;
  final double totalPaidRashed;
  final double unpaidBalance;
  final SubscriptionBreakdown? subscriptionBreakdown;
  final List<PaymentMethodBreakdown> paymentMethodBreakdown;
  final int outstandingUsers;

  FinanceStats({
    required this.cycle,
    required this.appname,
    required this.subscriptionPrice,
    required this.totalSubscribers,
    required this.freeSubscribers,
    required this.paidSubscribers,
    required this.totalRevenue,
    required this.actualRevenue,
    required this.shakilShare,
    required this.nayeemShare,
    required this.rashedShare,
    required this.totalPaid,
    required this.totalPaidShakil,
    required this.totalPaidNayeem,
    required this.totalPaidRashed,
    required this.unpaidBalance,
    this.subscriptionBreakdown,
    this.paymentMethodBreakdown = const [],
    this.outstandingUsers = 0,
  });

  factory FinanceStats.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final rawSubBreakdown = json['subscriptionBreakdown'];
    final rawPayBreakdown = json['paymentMethodBreakdown'];

    return FinanceStats(
      cycle: json['cycle'] as String? ?? '',
      appname: json['appname'] as String? ?? 'all',
      subscriptionPrice: toDouble(json['subscriptionPrice']),
      totalSubscribers: json['totalSubscribers'] as int? ?? 0,
      freeSubscribers: json['freeSubscribers'] as int? ?? 0,
      paidSubscribers: json['paidSubscribers'] as int? ?? 0,
      totalRevenue: toDouble(json['totalRevenue']),
      actualRevenue: toDouble(json['actualRevenue']),
      shakilShare: toDouble(json['shakilShare']),
      nayeemShare: toDouble(json['nayeemShare']),
      rashedShare: toDouble(json['rashedShare']),
      totalPaid: toDouble(json['totalPaid']),
      totalPaidShakil: toDouble(json['totalPaidShakil']),
      totalPaidNayeem: toDouble(json['totalPaidNayeem']),
      totalPaidRashed: toDouble(json['totalPaidRashed']),
      unpaidBalance: toDouble(json['unpaidBalance']),
      subscriptionBreakdown: rawSubBreakdown != null
          ? SubscriptionBreakdown.fromJson(rawSubBreakdown as Map<String, dynamic>)
          : null,
      paymentMethodBreakdown: rawPayBreakdown != null
          ? (rawPayBreakdown as List)
              .map((e) => PaymentMethodBreakdown.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
      outstandingUsers: json['outstandingUsers'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'cycle': cycle,
        'appname': appname,
        'subscriptionPrice': subscriptionPrice,
        'totalSubscribers': totalSubscribers,
        'freeSubscribers': freeSubscribers,
        'paidSubscribers': paidSubscribers,
        'totalRevenue': totalRevenue,
        'actualRevenue': actualRevenue,
        'shakilShare': shakilShare,
        'nayeemShare': nayeemShare,
        'rashedShare': rashedShare,
        'totalPaid': totalPaid,
        'totalPaidShakil': totalPaidShakil,
        'totalPaidNayeem': totalPaidNayeem,
        'totalPaidRashed': totalPaidRashed,
        'unpaidBalance': unpaidBalance,
        'subscriptionBreakdown': subscriptionBreakdown?.toJson(),
        'paymentMethodBreakdown': paymentMethodBreakdown.map((e) => e.toJson()).toList(),
        'outstandingUsers': outstandingUsers,
      };
}

class PayoutModel {
  final String id;
  final double shakilAmount;
  final double nayeemAmount;
  final double rashedAmount;
  final double amount;
  final String cycle;
  final String namespace;
  final String? notes;
  final String? createdBy;
  final String? creatorUsername;
  final DateTime? createdAt;

  PayoutModel({
    required this.id,
    required this.shakilAmount,
    required this.nayeemAmount,
    required this.rashedAmount,
    required this.amount,
    required this.cycle,
    required this.namespace,
    this.notes,
    this.createdBy,
    this.creatorUsername,
    this.createdAt,
  });

  factory PayoutModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    DateTime? parseDate(dynamic d) {
      if (d == null) return null;
      try {
        return DateTime.tryParse(d.toString());
      } catch (_) {
        return null;
      }
    }

    return PayoutModel(
      id: json['id']?.toString() ?? '',
      shakilAmount: toDouble(json['shakil_amount']),
      nayeemAmount: toDouble(json['nayeem_amount']),
      rashedAmount: toDouble(json['rashed_amount']),
      amount: toDouble(json['amount']),
      cycle: json['billing_cycle'] as String? ?? json['cycle'] as String? ?? '',
      namespace: json['appname'] as String? ?? json['namespace'] as String? ?? 'all',
      notes: json['notes'] as String?,
      createdBy: json['paid_by']?.toString() ?? json['created_by']?.toString(),
      creatorUsername: json['creator_username'] as String? ?? 'admin',
      createdAt: parseDate(json['payout_date'] ?? json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'shakil_amount': shakilAmount,
        'nayeem_amount': nayeemAmount,
        'rashed_amount': rashedAmount,
        'amount': amount,
        'cycle': cycle,
        'namespace': namespace,
        'notes': notes,
        'created_by': createdBy,
        'creator_username': creatorUsername,
        'created_at': createdAt?.toIso8601String(),
      };
}
