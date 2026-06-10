import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:adnetwork/layers/data/model/finance_summary_model.dart';
import 'package:adnetwork/layers/data/repo/remote/admin_repository.dart';
import 'package:adnetwork/layers/presentation/controller/finance/finance_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FinanceBloc(adminRepository: AdminRepository())
        ..add(LoadFinanceSummary(
          cycle: DateFormat('yyyy-MM').format(DateTime.now()),
        )),
      child: const _FinanceScreenBody(),
    );
  }
}

class _FinanceScreenBody extends StatefulWidget {
  const _FinanceScreenBody();

  @override
  State<_FinanceScreenBody> createState() => _FinanceScreenBodyState();
}

class _FinanceScreenBodyState extends State<_FinanceScreenBody> {
  late String _selectedCycle;
  final List<String> _cycles = [];

  @override
  void initState() {
    super.initState();
    // Pre-populate cycles: last 12 months starting from current local time
    final now = DateTime.now();
    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i);
      _cycles.add(DateFormat('yyyy-MM').format(date));
    }
    _selectedCycle = _cycles.first;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary, cs.secondary],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 18,
                color: cs.onPrimary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Finance Summary',
              style: getBoldStyle(fontSize: 18, color: cs.onSurface),
            ),
          ],
        ),
        actions: [
          // Cycle Selector Dropdown
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? cs.onSurface.withValues(alpha: .05) : cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cs.primary.withValues(alpha: .15),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCycle,
                  dropdownColor: isDark ? const Color(0xFF2A2A3A) : cs.surface,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: cs.primary, size: 18),
                  items: _cycles.map((cycle) {
                    final date = DateFormat('yyyy-MM').parse(cycle);
                    final label = DateFormat('MMM yyyy').format(date);
                    return DropdownMenuItem<String>(
                      value: cycle,
                      child: Text(
                        label,
                        style: getBoldStyle(fontSize: 13, color: cs.onSurface),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCycle = val;
                      });
                      context.read<FinanceBloc>().add(LoadFinanceSummary(cycle: val));
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogPayoutDialog(context),
        backgroundColor: cs.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Log Payout',
          style: getBoldStyle(fontSize: 14, color: Colors.white),
        ),
      ),
      body: BlocConsumer<FinanceBloc, FinanceState>(
        listenWhen: (prev, curr) =>
            prev.successMessage != curr.successMessage ||
            prev.errorMessage != curr.errorMessage,
        listener: (context, state) {
          if (state.successMessage.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage),
                backgroundColor: cs.secondary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            context.read<FinanceBloc>().add(const ClearFinanceMessages());
          }
          if (state.errorMessage.isNotEmpty && state.status != FinanceStatus.loading) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: cs.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            context.read<FinanceBloc>().add(const ClearFinanceMessages());
          }
        },
        builder: (context, state) {
          if (state.status == FinanceStatus.loading && state.summary == null) {
            return Center(
              child: CircularProgressIndicator(color: cs.primary),
            );
          }

          if (state.status == FinanceStatus.error && state.summary == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load finance data',
                    style: getBoldStyle(fontSize: 16, color: cs.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage,
                    style: getRegularStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: .5)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context
                        .read<FinanceBloc>()
                        .add(LoadFinanceSummary(cycle: _selectedCycle)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final summary = state.summary;
          if (summary == null) {
            return Center(
              child: Text(
                'No finance details available.',
                style: getRegularStyle(fontSize: 14, color: cs.onSurface),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<FinanceBloc>().add(LoadFinanceSummary(cycle: _selectedCycle));
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Premium Key Metrics Dashboard ──
                  _buildRevenueHeaderCard(summary.stats, cs, isDark),
                  const SizedBox(height: 16),

                  _buildSubscriberSection(summary.stats, cs, isDark),
                  const SizedBox(height: 16),

                  _buildBreakdownSection(summary.stats, cs, isDark),
                  const SizedBox(height: 16),

                  // ── Stakeholder Split Shares section ──
                  _buildPartnerSplitSection(summary.stats, cs, isDark),
                  const SizedBox(height: 24),

                  // ── Logged payouts title ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payout Distribution History',
                        style: getBoldStyle(fontSize: 16, color: cs.onSurface),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${summary.payouts.length} Logs',
                          style: getBoldStyle(fontSize: 11, color: cs.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (summary.payouts.isEmpty)
                    _buildEmptyPayoutsPlaceholder(cs, isDark)
                  else
                    ...List.generate(
                      summary.payouts.length,
                      (i) => _PayoutCard(
                        payout: summary.payouts[i],
                        cs: cs,
                        isDark: isDark,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Revenue glassmorphic premium card ──
  Widget _buildRevenueHeaderCard(FinanceStats stats, ColorScheme cs, bool isDark) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary,
            cs.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: .3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REVENUE OVERVIEW',
                style: getBoldStyle(
                  fontSize: 11,
                  color: cs.onPrimary.withValues(alpha: .75),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  stats.appname.toUpperCase(),
                  style: getBoldStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTUAL REVENUE',
                      style: getMediumStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: .7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fmt.format(stats.actualRevenue),
                      style: getBoldStyle(fontSize: 26, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXPECTED REVENUE',
                      style: getMediumStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: .7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fmt.format(stats.totalRevenue),
                      style: getSemiBoldStyle(fontSize: 20, color: Colors.white.withValues(alpha: .85)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: .2), height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL PAID OUT',
                      style: getMediumStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: .7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fmt.format(stats.totalPaid),
                      style: getBoldStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UNPAID BALANCE',
                      style: getMediumStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: .7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fmt.format(stats.unpaidBalance),
                      style: getBoldStyle(
                        fontSize: 16,
                        color: stats.unpaidBalance > 0 ? Colors.orangeAccent : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Subscribers details stats row ──
  Widget _buildSubscriberSection(FinanceStats stats, ColorScheme cs, bool isDark) {
    Widget badge(String title, String count, IconData icon, Color color) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? cs.onSurface.withValues(alpha: .04) : cs.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.primary.withValues(alpha: .06),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: getMediumStyle(
                    fontSize: 11,
                    color: cs.onSurface.withValues(alpha: .5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count,
                  style: getBoldStyle(fontSize: 15, color: cs.onSurface),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: badge(
            'Paid Subs',
            '${stats.paidSubscribers}',
            Icons.check_circle_rounded,
            cs.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: badge(
            'Free Subs',
            '${stats.freeSubscribers}',
            Icons.card_membership_rounded,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  // ── Subscription Scope & Payment Methods breakdown ──
  Widget _buildBreakdownSection(FinanceStats stats, ColorScheme cs, bool isDark) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final breakdown = stats.subscriptionBreakdown;

    if (breakdown == null && stats.paymentMethodBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? cs.onSurface.withValues(alpha: .03) : cs.primaryContainer.withValues(alpha: .3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.primary.withValues(alpha: .06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded, color: cs.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Detailed Breakdowns',
                style: getBoldStyle(fontSize: 14, color: cs.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (breakdown != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Active Subscriptions:',
                  style: getMediumStyle(fontSize: 13, color: cs.onSurface),
                ),
                Text(
                  '${breakdown.totalActive}',
                  style: getBoldStyle(fontSize: 13, color: cs.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                children: [
                  _buildSubBreakdownRow('Paid Users', '${breakdown.paidUsers}', cs),
                  const SizedBox(height: 6),
                  _buildSubBreakdownRow('Free Users', '${breakdown.freeUsers}', cs),
                  const SizedBox(height: 6),
                  _buildSubBreakdownRow('Staff Subscriptions', '${breakdown.staffSubscriptions}', cs),
                  const SizedBox(height: 6),
                  _buildSubBreakdownRow('Not Subscribed Users', '${breakdown.notSubscribed}', cs),
                  const SizedBox(height: 6),
                  _buildSubBreakdownRow('Subscription Price', fmt.format(breakdown.subscriptionPrice), cs),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Outstanding Users:',
                  style: getMediumStyle(fontSize: 13, color: cs.onSurface),
                ),
                Text(
                  '${breakdown.outstandingCount}',
                  style: getBoldStyle(
                    fontSize: 13,
                    color: breakdown.outstandingCount > 0 ? cs.error : cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Collected Subscription Amount:',
                  style: getMediumStyle(fontSize: 13, color: cs.onSurface),
                ),
                Text(
                  fmt.format(breakdown.actualAmount),
                  style: getBoldStyle(fontSize: 13, color: cs.secondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          if (stats.paymentMethodBreakdown.isNotEmpty) ...[
            Text(
              'Payment Method Breakdown',
              style: getBoldStyle(fontSize: 13, color: cs.onSurface),
            ),
            const SizedBox(height: 12),
            ...stats.paymentMethodBreakdown.map((pm) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(color: cs.secondary, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                pm.method.toUpperCase(),
                                style: getBoldStyle(fontSize: 12, color: cs.onSurface),
                              ),
                              Text(
                                ' (x${pm.count} users)',
                                style: getRegularStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: .45)),
                              ),
                            ],
                          ),
                          Text(
                            'Actual: ${fmt.format(pm.actualAmount)}',
                            style: getBoldStyle(fontSize: 12, color: cs.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              pm.outstandingCount > 0
                                  ? '${pm.outstandingCount} outstanding'
                                  : 'Fully paid',
                              style: getRegularStyle(
                                fontSize: 11,
                                color: pm.outstandingCount > 0
                                    ? cs.error.withValues(alpha: .8)
                                    : cs.secondary,
                              ),
                            ),
                            Text(
                              'Expected: ${fmt.format(pm.totalAmount)}',
                              style: getRegularStyle(
                                fontSize: 11,
                                color: cs.onSurface.withValues(alpha: .5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildSubBreakdownRow(String label, String value, ColorScheme cs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: .3), shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: getRegularStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: .6)),
            ),
          ],
        ),
        Text(
          value,
          style: getMediumStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: .8)),
        ),
      ],
    );
  }

  // ── Partner split shares tracking panel ──
  Widget _buildPartnerSplitSection(FinanceStats stats, ColorScheme cs, bool isDark) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    Widget splitBar(
      String partner,
      double expected,
      double paid,
      double percent,
      Color color,
    ) {
      final ratio = expected > 0 ? (paid / expected).clamp(0.0, 1.0) : 0.0;
      final percentPaidStr = (ratio * 100).toStringAsFixed(1);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    partner,
                    style: getBoldStyle(fontSize: 13, color: cs.onSurface),
                  ),
                  Text(
                    ' (${percent.toStringAsFixed(0)}% share)',
                    style: getRegularStyle(
                      fontSize: 11,
                      color: cs.onSurface.withValues(alpha: .45),
                    ),
                  ),
                ],
              ),
              Text(
                '${fmt.format(paid)} / ${fmt.format(expected)}',
                style: getBoldStyle(fontSize: 13, color: cs.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  width: double.infinity,
                  color: isDark
                      ? cs.onSurface.withValues(alpha: .06)
                      : cs.primaryContainer,
                ),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: .7)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$percentPaidStr% payout complete',
                style: getMediumStyle(
                  fontSize: 10,
                  color: cs.onSurface.withValues(alpha: .35),
                ),
              ),
              Text(
                'Unpaid: ${fmt.format((expected - paid).clamp(0, double.infinity))}',
                style: getMediumStyle(
                  fontSize: 10,
                  color: (expected - paid) > 0 ? cs.error.withValues(alpha: .8) : cs.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? cs.onSurface.withValues(alpha: .03) : cs.primaryContainer.withValues(alpha: .3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.primary.withValues(alpha: .06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_rounded, color: cs.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Expected Shares & Splits',
                style: getBoldStyle(fontSize: 14, color: cs.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 20),
          splitBar('Shakil', stats.shakilShare, stats.totalPaidShakil, 30.0, cs.primary),
          splitBar('Nayeem', stats.nayeemShare, stats.totalPaidNayeem, 30.0, cs.secondary),
          splitBar('Rashed', stats.rashedShare, stats.totalPaidRashed, 40.0, Colors.teal),
        ],
      ),
    );
  }

  // ── Placeholder if there are no logged payouts ──
  Widget _buildEmptyPayoutsPlaceholder(ColorScheme cs, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? cs.onSurface.withValues(alpha: .02) : cs.primaryContainer.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.onSurface.withValues(alpha: .04),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: .05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 32,
              color: cs.primary.withValues(alpha: .6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No payouts logged for this cycle',
            style: getBoldStyle(fontSize: 14, color: cs.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            'Log new payouts for Shakil, Nayeem, and Rashed.',
            style: getRegularStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: .4)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Show dialog modal to log payouts ──
  void _showLogPayoutDialog(BuildContext context) {
    final bloc = context.read<FinanceBloc>();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: _LogPayoutDialog(cycle: _selectedCycle),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  PAYOUT CARD WIDGET
// ══════════════════════════════════════════════════════════
class _PayoutCard extends StatelessWidget {
  final PayoutModel payout;
  final ColorScheme cs;
  final bool isDark;

  const _PayoutCard({
    required this.payout,
    required this.cs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateStr = payout.createdAt != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(payout.createdAt!)
        : 'Unknown Date';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? cs.onSurface.withValues(alpha: .04) : cs.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.onSurface.withValues(alpha: .05),
        ),
      ),
      child: ExpansionTile(
        shape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.secondary.withValues(alpha: .1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.outbox_rounded, size: 20, color: cs.secondary),
        ),
        title: Text(
          fmt.format(payout.amount),
          style: getBoldStyle(fontSize: 15, color: cs.onSurface),
        ),
        subtitle: Text(
          payout.notes?.isNotEmpty == true ? payout.notes! : 'Partner Distribution',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: getRegularStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: .5)),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              payout.cycle,
              style: getBoldStyle(fontSize: 12, color: cs.primary),
            ),
            const SizedBox(height: 2),
            Text(
              'by ${payout.creatorUsername ?? 'admin'}',
              style: getRegularStyle(fontSize: 10, color: cs.onSurface.withValues(alpha: .35)),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: cs.onSurface.withValues(alpha: .06)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recorded Date:',
                      style: getRegularStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: .45)),
                    ),
                    Text(
                      dateStr,
                      style: getMediumStyle(fontSize: 12, color: cs.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Distribution Splits:',
                  style: getBoldStyle(fontSize: 12, color: cs.onSurface),
                ),
                const SizedBox(height: 8),
                _buildSplitRow('Shakil', payout.shakilAmount, cs.primary),
                const SizedBox(height: 6),
                _buildSplitRow('Nayeem', payout.nayeemAmount, cs.secondary),
                const SizedBox(height: 6),
                _buildSplitRow('Rashed', payout.rashedAmount, Colors.teal),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSplitRow(String name, double amount, Color dotColor) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: getMediumStyle(fontSize: 13, color: cs.onSurface),
        ),
        const Spacer(),
        Text(
          fmt.format(amount),
          style: getBoldStyle(fontSize: 13, color: cs.onSurface),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
//  LOG PAYOUT DIALOG
// ══════════════════════════════════════════════════════════
class _LogPayoutDialog extends StatefulWidget {
  final String cycle;
  const _LogPayoutDialog({required this.cycle});

  @override
  State<_LogPayoutDialog> createState() => _LogPayoutDialogState();
}

class _LogPayoutDialogState extends State<_LogPayoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _shakilCtrl = TextEditingController();
  final _nayeemCtrl = TextEditingController();
  final _rashedCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _shakilCtrl.dispose();
    _nayeemCtrl.dispose();
    _rashedCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<FinanceBloc, FinanceState>(
      listenWhen: (prev, curr) => prev.status == FinanceStatus.logging && curr.status != FinanceStatus.logging,
      listener: (context, state) {
        if (state.status == FinanceStatus.success) {
          Navigator.pop(context); // Close dialog on success
        }
      },
      builder: (context, state) {
        final isLogging = state.status == FinanceStatus.logging;

        return AlertDialog(
          backgroundColor: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.outbox_rounded, size: 20, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Text(
                'Log Partner Payout',
                style: getBoldStyle(fontSize: 18, color: cs.onSurface),
              ),
            ],
          ),
          content: SizedBox(
            width: 320,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Log splits for Cycle: ${widget.cycle}',
                      style: getMediumStyle(fontSize: 12, color: cs.primary),
                    ),
                    const SizedBox(height: 16),

                    // Shakil Amount
                    _buildAmountField(
                      controller: _shakilCtrl,
                      label: 'Shakil Payout Amount (\$)',
                      hint: '150.00',
                      cs: cs,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),

                    // Nayeem Amount
                    _buildAmountField(
                      controller: _nayeemCtrl,
                      label: 'Nayeem Payout Amount (\$)',
                      hint: '150.00',
                      cs: cs,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),

                    // Rashed Amount
                    _buildAmountField(
                      controller: _rashedCtrl,
                      label: 'Rashed Payout Amount (\$)',
                      hint: '200.00',
                      cs: cs,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),

                    // Notes
                    Text(
                      'Notes',
                      style: getBoldStyle(fontSize: 12, color: cs.onSurface),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? cs.onSurface.withValues(alpha: .04) : cs.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: cs.onSurface.withValues(alpha: .05),
                        ),
                      ),
                      child: TextFormField(
                        controller: _notesCtrl,
                        maxLines: 2,
                        style: getMediumStyle(fontSize: 13, color: cs.onSurface),
                        decoration: InputDecoration(
                          hintText: 'e.g. Weekly payout distribution',
                          hintStyle: getRegularStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: .35)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLogging ? null : () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: getBoldStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: .5)),
              ),
            ),
            ElevatedButton(
              onPressed: isLogging
                  ? null
                  : () {
                      if (_formKey.currentState?.validate() == true) {
                        final shakil = double.tryParse(_shakilCtrl.text) ?? 0.0;
                        final nayeem = double.tryParse(_nayeemCtrl.text) ?? 0.0;
                        final rashed = double.tryParse(_rashedCtrl.text) ?? 0.0;

                        context.read<FinanceBloc>().add(
                              LogPayout(
                                shakilAmount: shakil,
                                nayeemAmount: nayeem,
                                rashedAmount: rashed,
                                cycle: widget.cycle,
                                notes: _notesCtrl.text.trim(),
                              ),
                            );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLogging
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Log Payout',
                      style: getBoldStyle(fontSize: 14, color: Colors.white),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAmountField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ColorScheme cs,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getBoldStyle(fontSize: 12, color: cs.onSurface),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? cs.onSurface.withValues(alpha: .04) : cs.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cs.onSurface.withValues(alpha: .05),
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: getMediumStyle(fontSize: 13, color: cs.onSurface),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Amount is required';
              }
              if (double.tryParse(val) == null) {
                return 'Enter a valid number';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: getRegularStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: .35)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}
