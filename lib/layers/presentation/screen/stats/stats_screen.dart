import 'dart:math';

import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:adnetwork/layers/data/model/activity_stats_model.dart';
import 'package:adnetwork/layers/data/repo/remote/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  final UserRepository _repo = UserRepository();
  List<ActivityStatsModel> _activities = [];
  bool _loading = true;
  String? _error;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fetchStats();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _repo.getActivityStats();
      if (res.isSuccess && res.dataList != null) {
        _activities = res.dataList!
            .where((a) => a.likesGiven > 0 || a.likesReceived > 0)
            .toList();
        _activities.sort((a, b) => b.day.compareTo(a.day));
      } else {
        _activities = [];
        _error = res.message ?? 'Failed to load stats';
      }
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) {
      setState(() => _loading = false);
      _animController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          'Activity Stats',
          style: getBoldStyle(fontSize: 20, color: cs.onSurface),
        ),
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _activities.isEmpty
          ? _buildError(cs)
          : RefreshIndicator(
              onRefresh: _fetchStats,
              color: cs.primary,
              child: _buildContent(cs, isDark),
            ),
    );
  }

  Widget _buildError(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: cs.onSurface.withValues(alpha: .3),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: getBoldStyle(fontSize: 18, color: cs.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              style: getRegularStyle(
                fontSize: 13,
                color: cs.onSurface.withValues(alpha: .5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _fetchStats,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ColorScheme cs, bool isDark) {
    // Compute totals
    int totalGiven = 0;
    int totalReceived = 0;
    int maxGiven = 0;
    int maxReceived = 0;
    for (final a in _activities) {
      totalGiven += a.likesGiven;
      totalReceived += a.likesReceived;
      if (a.likesGiven > maxGiven) maxGiven = a.likesGiven;
      if (a.likesReceived > maxReceived) maxReceived = a.likesReceived;
    }
    final maxBar = max(maxGiven, maxReceived).clamp(1, 999999);

    // Today
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    ActivityStatsModel? today;
    for (final a in _activities) {
      if (a.day == todayStr) {
        today = a;
        break;
      }
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        // ── Summary Cards ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Today highlight
                if (today != null) ...[
                  _buildTodayCard(cs, today, isDark),
                  const SizedBox(height: 20),
                ],
                // Totals row
                // Row(
                //   children: [
                //     Expanded(
                //       child: _SummaryTile(
                //         icon: Icons.thumb_up_alt_rounded,
                //         label: 'Total Given',
                //         value: '$totalGiven',
                //         gradient: [
                //           cs.primary,
                //           cs.primary.withValues(alpha: .7),
                //         ],
                //       ),
                //     ),
                //     const SizedBox(width: 14),
                //     Expanded(
                //       child: _SummaryTile(
                //         icon: Icons.favorite_rounded,
                //         label: 'Total Received',
                //         value: '$totalReceived',
                //         gradient: [
                //           cs.error,
                //           cs.error.withValues(alpha: .7),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 28),
                // Chart title
                Text(
                  'Daily Activity',
                  style: getBoldStyle(fontSize: 18, color: cs.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_activities.length} days tracked',
                  style: getRegularStyle(
                    fontSize: 13,
                    color: cs.onSurface.withValues(alpha: .5),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // ── Daily bars ──
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final a = _activities[index];
              final isToday = a.day == todayStr;
              return AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  final delay = index / (_activities.length.clamp(1, 20));
                  final t = Curves.easeOutCubic.transform(
                    ((_animController.value - delay * 0.3) / 0.7)
                        .clamp(0, 1)
                        .toDouble(),
                  );
                  return Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - t)),
                      child: _DayRow(
                        activity: a,
                        maxValue: maxBar,
                        isToday: isToday,
                        cs: cs,
                        animProgress: t,
                      ),
                    ),
                  );
                },
              );
            }, childCount: _activities.length),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildTodayCard(
    ColorScheme cs,
    ActivityStatsModel today,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary.withValues(alpha: isDark ? .2 : .12),
            cs.primary.withValues(alpha: isDark ? .08 : .04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.primary.withValues(alpha: .15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.today_rounded, color: cs.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                "Today's Activity",
                style: getBoldStyle(fontSize: 17, color: cs.onSurface),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  today.day,
                  style: getMediumStyle(fontSize: 11, color: cs.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _todayStat(
                  cs,
                  icon: Icons.thumb_up_alt_rounded,
                  label: 'Given',
                  value: today.likesGiven,
                  color: cs.primary,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: cs.onSurface.withValues(alpha: .08),
              ),
              Expanded(
                child: _todayStat(
                  cs,
                  icon: Icons.favorite_rounded,
                  label: 'Received',
                  value: today.likesReceived,
                  color: cs.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _todayStat(
    ColorScheme cs, {
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              '$value',
              style: getBoldStyle(fontSize: 26, color: cs.onSurface),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: getMediumStyle(
            fontSize: 12,
            color: cs.onSurface.withValues(alpha: .55),
          ),
        ),
      ],
    );
  }
}

/// ── Summary Tile (gradient icon card) ──
class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;

  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradient[0].withValues(alpha: .12),
            gradient[1].withValues(alpha: .06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gradient[0].withValues(alpha: .15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: gradient[0], size: 24),
          const SizedBox(height: 14),
          Text(value, style: getBoldStyle(fontSize: 28, color: cs.onSurface)),
          const SizedBox(height: 2),
          Text(
            label,
            style: getMediumStyle(
              fontSize: 12,
              color: cs.onSurface.withValues(alpha: .6),
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Single day row with animated bars ──
class _DayRow extends StatelessWidget {
  final ActivityStatsModel activity;
  final int maxValue;
  final bool isToday;
  final ColorScheme cs;
  final double animProgress;

  const _DayRow({
    required this.activity,
    required this.maxValue,
    required this.isToday,
    required this.cs,
    required this.animProgress,
  });

  @override
  Widget build(BuildContext context) {
    // Parse readable date
    String dateLabel = activity.day;
    try {
      final dt = DateTime.parse(activity.day);
      dateLabel = DateFormat('MMM d').format(dt);
    } catch (_) {}

    String weekDay = '';
    try {
      final dt = DateTime.parse(activity.day);
      weekDay = DateFormat('EEE').format(dt);
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isToday
            ? cs.primary.withValues(alpha: .08)
            : cs.primaryContainer.withValues(alpha: .25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday
              ? cs.primary.withValues(alpha: .2)
              : cs.onSurface.withValues(alpha: .04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                dateLabel,
                style: getSemiBoldStyle(fontSize: 14, color: cs.onSurface),
              ),
              const SizedBox(width: 6),
              Text(
                weekDay,
                style: getRegularStyle(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: .4),
                ),
              ),
              if (isToday) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Today',
                    style: getBoldStyle(fontSize: 10, color: cs.primary),
                  ),
                ),
              ],
              const Spacer(),
              // Counts
              Icon(Icons.thumb_up_alt_rounded, size: 13, color: cs.primary),
              const SizedBox(width: 3),
              Text(
                '${activity.likesGiven}',
                style: getBoldStyle(fontSize: 13, color: cs.onSurface),
              ),
              const SizedBox(width: 12),
              Icon(Icons.favorite_rounded, size: 13, color: cs.error),
              const SizedBox(width: 3),
              Text(
                '${activity.likesReceived}',
                style: getBoldStyle(fontSize: 13, color: cs.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Bars
          _AnimatedBar(
            label: 'Given',
            value: activity.likesGiven,
            maxValue: maxValue,
            color: cs.primary,
            progress: animProgress,
          ),
          const SizedBox(height: 6),
          _AnimatedBar(
            label: 'Received',
            value: activity.likesReceived,
            maxValue: maxValue,
            color: cs.error,
            progress: animProgress,
          ),
        ],
      ),
    );
  }
}

class _AnimatedBar extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final Color color;
  final double progress;

  const _AnimatedBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fraction = (value / maxValue).clamp(0.0, 1.0) * progress;

    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: getRegularStyle(
              fontSize: 11,
              color: cs.onSurface.withValues(alpha: .45),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraction,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: .6)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
