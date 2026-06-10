import 'package:flutter_test/flutter_test.dart';
import 'package:adnetwork/layers/data/model/client_override_model.dart';
import 'package:adnetwork/layers/data/model/finance_summary_model.dart';
import 'package:adnetwork/layers/data/model/user_model.dart';

void main() {
  test('ClientOverrideModel parsing test', () {
    final json = {
      'id': 'test-id',
      'client_name': 'Test Client',
      'status': 'active',
      'appname': 'adnetworkpro',
      'subscription_toggled_by': 'admin_user',
      'created_at': '2026-06-10T12:00:00.000Z',
    };
    final model = ClientOverrideModel.fromJson(json);
    expect(model.id, 'test-id');
    expect(model.clientName, 'Test Client');
    expect(model.status, 'active');
    expect(model.appname, 'adnetworkpro');
    expect(model.subscriptionToggledBy, 'admin_user');
  });

  test('FinanceSummaryModel parsing test with updated response fields', () {
    final json = {
      'stats': {
        'cycle': '2026-06',
        'appname': 'adnetworkpro',
        'subscriptionPrice': 50,
        'totalSubscribers': 151,
        'freeSubscribers': 1,
        'paidSubscribers': 150,
        'totalRevenue': 7500,
        'actualRevenue': 6900,
        'shakilShare': 2250,
        'nayeemShare': 2250,
        'rashedShare': 3000,
        'totalPaid': 5650,
        'totalPaidShakil': 1695,
        'totalPaidNayeem': 1695,
        'totalPaidRashed': 2260,
        'unpaidBalance': 1850,
        'subscriptionBreakdown': {
          'totalActive': 160,
          'paidUsers': 149,
          'freeUsers': 1,
          'staffSubscriptions': 10,
          'notSubscribed': 806,
          'subscriptionPrice': 50,
          'outstandingCount': 12,
          'actualAmount': 6900
        },
        'paymentMethodBreakdown': [
          {
            'method': 'Unspecified',
            'count': 149,
            'totalAmount': 7450,
            'outstandingCount': 12,
            'actualAmount': 6900
          },
          {
            'method': 'free',
            'count': 1,
            'totalAmount': 0,
            'outstandingCount': 0,
            'actualAmount': 0
          }
        ],
        'outstandingUsers': 12
      },
      'payouts': [
        {
          'id': 1,
          'appname': 'adnetworkpro',
          'amount': 5650,
          'billing_cycle': '2026-06',
          'payout_date': '2026-06-10 12:23:46',
          'notes': '1st',
          'paid_by': 'a09f7d31-cadb-4c45-a4e6-deeb04a30134',
          'shakil_amount': 1695,
          'nayeem_amount': 1695,
          'rashed_amount': 2260
        }
      ]
    };

    final model = FinanceSummaryModel.fromJson(json);
    
    // Validate stats
    expect(model.stats.cycle, '2026-06');
    expect(model.stats.subscriptionPrice, 50.0);
    expect(model.stats.totalSubscribers, 151);
    expect(model.stats.totalRevenue, 7500.0);
    expect(model.stats.actualRevenue, 6900.0);
    
    // Validate subscription breakdown
    expect(model.stats.subscriptionBreakdown?.totalActive, 160);
    expect(model.stats.subscriptionBreakdown?.staffSubscriptions, 10);
    expect(model.stats.subscriptionBreakdown?.notSubscribed, 806);
    expect(model.stats.subscriptionBreakdown?.subscriptionPrice, 50.0);
    expect(model.stats.subscriptionBreakdown?.outstandingCount, 12);
    expect(model.stats.subscriptionBreakdown?.actualAmount, 6900.0);

    // Validate payment method breakdown
    expect(model.stats.paymentMethodBreakdown.length, 2);
    expect(model.stats.paymentMethodBreakdown[0].method, 'Unspecified');
    expect(model.stats.paymentMethodBreakdown[0].totalAmount, 7450.0);
    expect(model.stats.paymentMethodBreakdown[0].outstandingCount, 12);
    expect(model.stats.paymentMethodBreakdown[0].actualAmount, 6900.0);
    expect(model.stats.outstandingUsers, 12);

    // Validate payouts
    expect(model.payouts.length, 1);
    expect(model.payouts[0].id, '1');
    expect(model.payouts[0].namespace, 'adnetworkpro');
    expect(model.payouts[0].cycle, '2026-06');
    expect(model.payouts[0].amount, 5650.0);
    expect(model.payouts[0].shakilAmount, 1695.0);
  });

  test('UserModel parsing test for subscription fields', () {
    final jsonFlat = {
      'id': 'u-id-1',
      'username': 'user1',
      'role': 'user',
      'is_free_subscription': 1,
      'autolike': 1,
    };
    final modelFlat = UserModel.fromJson(jsonFlat);
    expect(modelFlat.id, 'u-id-1');
    expect(modelFlat.role, 'user');
    expect(modelFlat.isFreeSubscription, 1);
    expect(modelFlat.autolike, 1);

    final jsonNested = {
      'id': 'u-id-2',
      'username': 'user2',
      'role': 'admin',
      'subscription': {
        'is_free_subscription': 1,
        'autolike': 1,
      }
    };
    final modelNested = UserModel.fromJson(jsonNested);
    expect(modelNested.id, 'u-id-2');
    expect(modelNested.role, 'admin');
    expect(modelNested.isFreeSubscription, 1);
    expect(modelNested.autolike, 1);
  });
}
