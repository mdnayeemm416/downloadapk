import 'dart:async';
import 'dart:math';
import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:adnetwork/core/extensions/extension.dart';
import 'package:adnetwork/layers/data/model/campaign_link_model.dart';
import 'package:adnetwork/layers/presentation/controller/campaign/campaign_bloc.dart';
import 'package:adnetwork/layers/presentation/controller/profile/profile_bloc.dart';
import 'package:adnetwork/layers/presentation/widget/common_text_field.dart';
import 'package:adnetwork/layers/presentation/widget/gradient_button.dart';
import 'package:adnetwork/layers/presentation/widget/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tabs;
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

class CampaignScreen extends StatefulWidget {
  const CampaignScreen({super.key});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  bool _campaignStarted = false;

  // Background timer tracking state
  Timer? _adTimer;
  String? _activeAdId;
  DateTime? _activeAdStartTime;
  bool _isWatching = false;
  int _activeAdDuration = 15;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);

    // Fetch fresh list of campaigns and completions on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final campaignBloc = context.read<CampaignBloc>();
      campaignBloc.add(const LoadCampaignFeed());
      campaignBloc.add(const LoadMyCampaigns());
      campaignBloc.add(const LoadCampaignCompletions());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _adTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // App lifecycle changes listener
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_isWatching && _activeAdStartTime != null) {
        final elapsed = DateTime.now()
            .difference(_activeAdStartTime!)
            .inSeconds;
        if (elapsed < _activeAdDuration) {
          // Closed early!
          _adTimer?.cancel();
          setState(() {
            _activeAdId = null;
            _activeAdStartTime = null;
            _isWatching = false;
          });
          _showEarlyCloseDialog();
        } else {
          // Time met during background suspension or before resumption callback
          _adTimer?.cancel();
          _onAdCompleted();
        }
      }
    }
  }

  Future<void> _launchAd(CampaignLinkModel campaign) async {
    final random = Random();
    final adDuration =
        10 + random.nextInt(6); // random number between 10 and 15 inclusive

    setState(() {
      _activeAdId = campaign.id;
      _activeAdStartTime = DateTime.now();
      _isWatching = true;
      _activeAdDuration = adDuration;
    });

    // Start random countdown timer in background
    _adTimer = Timer(Duration(seconds: adDuration), () {
      _onAdCompleted();
    });

    final theme = Theme.of(context);
    try {
      await custom_tabs.launchUrl(
        Uri.parse(campaign.url),
        customTabsOptions: custom_tabs.CustomTabsOptions(
          colorSchemes: custom_tabs.CustomTabsColorSchemes.defaults(
            toolbarColor: theme.colorScheme.surface,
            navigationBarColor: theme.colorScheme.surface,
          ),
          shareState: custom_tabs.CustomTabsShareState.on,
          urlBarHidingEnabled: true,
          showTitle: true,
        ),
        safariVCOptions: custom_tabs.SafariViewControllerOptions(
          preferredBarTintColor: theme.colorScheme.surface,
          preferredControlTintColor: theme.colorScheme.primary,
          barCollapsingEnabled: true,
          dismissButtonStyle:
              custom_tabs.SafariViewControllerDismissButtonStyle.close,
        ),
      );
    } catch (e) {
      _adTimer?.cancel();
      setState(() {
        _activeAdId = null;
        _activeAdStartTime = null;
        _isWatching = false;
      });
      if (mounted) {
        showToast(
          context: context,
          message: 'Could not open ad link: $e',
          toastificationType: ToastificationType.error,
        );
      }
    }
  }

  void _onAdCompleted() {
    if (_activeAdId == null) return;

    final adId = _activeAdId!;
    // Automatically close the Custom Tab browser
    custom_tabs.closeCustomTabs();

    // Reward scoring
    context.read<CampaignBloc>().add(LikeCampaignLink(adId));

    setState(() {
      _activeAdId = null;
      _activeAdStartTime = null;
      _isWatching = false;
    });
  }

  void _showEarlyCloseDialog() {
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: cs.error.withValues(alpha: .2), width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.error.withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: cs.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'বিজ্ঞাপনটি সম্পূর্ণ দেখুন',
                  style: getBoldStyle(fontSize: 18, color: cs.onSurface),
                ),
              ),
            ],
          ),
          content: Text(
            'অনুগ্রহ করে বিজ্ঞাপনটি নিজে বন্ধ করবেন না, এটি ১৫ সেকেন্ড পর স্বয়ংক্রিয়ভাবে বন্ধ হয়ে যাবে। নিজে থেকে আগে বন্ধ করলে আপনার দেখার সময় গণনা করা হবে না এবং কোনো ক্রেডিট পাবেন না।',
            style: getRegularStyle(
              fontSize: 14,
              color: cs.onSurface.withValues(alpha: .8),
            ).copyWith(height: 1.5),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'ঠিক আছে',
                  style: getBoldStyle(fontSize: 14, color: cs.onPrimary),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showExitConfirmationDialog(int remainingAds) async {
    if (!mounted) return false;
    final cs = Theme.of(context).colorScheme;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: cs.error.withValues(alpha: .2), width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.error.withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: cs.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ক্যাম্পেইন অসম্পূর্ণ!',
                  style: getBoldStyle(fontSize: 18, color: cs.onSurface),
                ),
              ),
            ],
          ),
          content: Text(
            'আপনার এখনও $remainingAds টি বিজ্ঞাপন দেখা বাকি আছে। আপনি যদি এখন ফিরে যান, তবে পরবর্তীতে পয়েন্ট পেতে আপনাকে আবার শুরু থেকে ২০টি লিঙ্ক দেখতে হবে।',
            style: getRegularStyle(
              fontSize: 14,
              color: cs.onSurface.withValues(alpha: .8),
            ).copyWith(height: 1.5),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cs.error.withValues(alpha: .5)),
                        foregroundColor: cs.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'ফিরে যান',
                        style: getBoldStyle(fontSize: 14, color: cs.error),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'এখানেই থাকুন',
                        style: getBoldStyle(fontSize: 14, color: cs.onPrimary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = context.watch<CampaignBloc>().state;
    final unlikedLinks = state.feedLinks.where((l) => !l.isLiked).toList();
    final canPop = !_campaignStarted || unlikedLinks.isEmpty;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitConfirmationDialog(
          unlikedLinks.length,
        );
        if (shouldExit && context.mounted) {
          Navigator.of(context).pop(result);
        }
      },
      child: BlocListener<CampaignBloc, CampaignState>(
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == CampaignActionStatus.success) {
            showToast(
              context: context,
              message: state.actionMessage,
              toastificationType: ToastificationType.success,
            );
            context.read<CampaignBloc>().add(const ClearCampaignErrors());
          } else if (state.actionStatus == CampaignActionStatus.error) {
            showToast(
              context: context,
              message: state.actionMessage,
              toastificationType: ToastificationType.error,
            );
            context.read<CampaignBloc>().add(const ClearCampaignErrors());
          }
        },
        child: Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            backgroundColor: cs.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
              onPressed: () async {
                if (canPop) {
                  Navigator.pop(context);
                } else {
                  final shouldExit = await _showExitConfirmationDialog(
                    unlikedLinks.length,
                  );
                  if (shouldExit && context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
            title: Text(
              'Campaigns',
              style: getBoldStyle(fontSize: 20, color: cs.onSurface),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(66),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? cs.onSurface.withValues(alpha: .04)
                      : cs.primary.withValues(alpha: .04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cs.primary.withValues(alpha: isDark ? .1 : .05),
                    width: 1,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: cs.primary,
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: isDark ? .25 : .15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: cs.onPrimary,
                  unselectedLabelColor: cs.onSurface.withValues(alpha: .6),
                  labelStyle: getBoldStyle(fontSize: 13),
                  unselectedLabelStyle: getMediumStyle(fontSize: 13),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.campaign_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Campaign Feed'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_link_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('My Campaigns'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _CampaignFeedTab(
                isDark: isDark,
                campaignStarted: _campaignStarted,
                onStartCampaign: () {
                  setState(() {
                    _campaignStarted = true;
                  });
                },
                onLaunchAd: _launchAd,
                activeAdId: _activeAdId,
                activeAdDuration: _activeAdDuration,
              ),
              _MyCampaignsTab(isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CAMPAIGN FEED TAB
// ─────────────────────────────────────────────────────────────────────────────
class _CampaignFeedTab extends StatelessWidget {
  final bool isDark;
  final bool campaignStarted;
  final VoidCallback onStartCampaign;
  final Function(CampaignLinkModel) onLaunchAd;
  final String? activeAdId;
  final int activeAdDuration;

  const _CampaignFeedTab({
    required this.isDark,
    required this.campaignStarted,
    required this.onStartCampaign,
    required this.onLaunchAd,
    required this.activeAdId,
    required this.activeAdDuration,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return RefreshIndicator(
      color: cs.primary,
      onRefresh: () async {
        context.read<CampaignBloc>().add(const LoadCampaignFeed());
        context.read<CampaignBloc>().add(const LoadCampaignCompletions());
        await Future.delayed(const Duration(milliseconds: 600));
      },
      child: BlocBuilder<CampaignBloc, CampaignState>(
        builder: (context, state) {
          if (state.feedStatus == CampaignStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.feedStatus == CampaignStatus.error) {
            final errorMsg = state.feedErrorMessage.toLowerCase();
            final isLimitReached = errorMsg.contains('limit reached');
            final isUnderfilled =
                errorMsg.contains('not available') ||
                errorMsg.contains('underfilled');

            return Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? cs.onSurface.withValues(alpha: .04)
                          : cs.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isLimitReached
                            ? cs.primary.withValues(alpha: .2)
                            : cs.error.withValues(alpha: .15),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isLimitReached
                                ? cs.primary.withValues(alpha: .1)
                                : cs.error.withValues(alpha: .08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isLimitReached
                                ? Icons.timer_rounded
                                : (isUnderfilled
                                      ? Icons.campaign_rounded
                                      : Icons.error_outline_rounded),
                            size: 48,
                            color: isLimitReached ? cs.primary : cs.error,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isLimitReached
                              ? 'Limit Reached'
                              : (isUnderfilled
                                    ? 'No Campaigns Available'
                                    : 'Error Occurred'),
                          style: getBoldStyle(
                            fontSize: 18,
                            color: cs.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          state.feedErrorMessage,
                          style: getRegularStyle(
                            fontSize: 14,
                            color: cs.onSurface.withValues(alpha: .6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 160,
                          child: GradientButton(
                            buttonName: 'Retry Feed',
                            icon: Icons.refresh_rounded,
                            onPressed: () {
                              context.read<CampaignBloc>().add(
                                const LoadCampaignFeed(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          final unlikedLinks = state.feedLinks
              .where((l) => !l.isLiked)
              .toList();

          if (state.feedLinks.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: .05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.track_changes_rounded,
                        size: 48,
                        color: cs.primary.withValues(alpha: .4),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No Campaigns Available',
                      style: getSemiBoldStyle(
                        fontSize: 18,
                        color: cs.onSurface.withValues(alpha: .6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pull down to refresh and try again',
                      style: getRegularStyle(
                        fontSize: 13,
                        color: cs.onSurface.withValues(alpha: .35),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Initial "Start Campaign" state card
          if (!campaignStarted) {
            return Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 36,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                cs.primary.withValues(alpha: .12),
                                cs.secondary.withValues(alpha: .06),
                                cs.surface,
                              ]
                            : [
                                cs.primary.withValues(alpha: .06),
                                cs.secondary.withValues(alpha: .03),
                                cs.surface,
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: .15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(
                            alpha: isDark ? .15 : .05,
                          ),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tag Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [cs.primary, cs.secondary],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withValues(alpha: .25),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            'HIGH-YIELD OPTION',
                            style: getBoldStyle(
                              fontSize: 10,
                              color: cs.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Rocket Launch Stack
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: .08),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    cs.primary,
                                    Color.lerp(cs.primary, cs.secondary, 0.5)!,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: cs.primary.withValues(alpha: .35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.rocket_launch_rounded,
                                size: 36,
                                color: cs.onPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Start Campaign',
                          style: getBoldStyle(
                            fontSize: 24,
                            color: cs.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Unlock higher CPM and better revenue stream by viewing targeted sponsor campaigns.',
                          style: getRegularStyle(
                            fontSize: 14,
                            color: cs.onSurface.withValues(alpha: .6),
                          ).copyWith(height: 1.4),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        Divider(color: cs.onSurface.withValues(alpha: .06)),
                        const SizedBox(height: 20),
                        // Premium Stat Cards Row
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Ads Bundle',
                                value: '${state.feedLinks.length}',
                                icon: Icons.filter_none_rounded,
                                color: cs.primary,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: 'Yield Score',
                                value: '+${state.feedLinks.length}',
                                icon: Icons.stars_rounded,
                                color: cs.secondary,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: 'Completions',
                                value: '${state.completionsCount}',
                                icon: Icons.check_circle_outline_rounded,
                                color: Colors.green,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        GradientButton(
                          buttonName: 'Start Campaign',
                          icon: Icons.rocket_launch_rounded,
                          onPressed: onStartCampaign,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          if (unlikedLinks.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: .05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_outline_rounded,
                        size: 48,
                        color: cs.primary.withValues(alpha: .4),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'All Campaigns Completed!',
                      style: getSemiBoldStyle(
                        fontSize: 18,
                        color: cs.onSurface.withValues(alpha: .6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You have viewed all available sponsor ads.',
                      style: getRegularStyle(
                        fontSize: 13,
                        color: cs.onSurface.withValues(alpha: .35),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Active ad list
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: unlikedLinks.length,
            itemBuilder: (context, index) {
              final campaign = unlikedLinks[index];
              final originalIndex = state.feedLinks.indexWhere(
                (l) => l.id == campaign.id,
              );
              return _CampaignFeedCard(
                campaign: campaign,
                index: originalIndex != -1 ? originalIndex : index,
                isDark: isDark,
                onTap: () {
                  if (activeAdId == null) {
                    onLaunchAd(campaign);
                  }
                },
                isActiveWatch: activeAdId == campaign.id,
                activeAdDuration: activeAdDuration,
              );
            },
          );
        },
      ),
    );
  }
}

class _CampaignFeedCard extends StatelessWidget {
  final CampaignLinkModel campaign;
  final int index;
  final bool isDark;
  final VoidCallback onTap;
  final bool isActiveWatch;
  final int activeAdDuration;

  const _CampaignFeedCard({
    required this.campaign,
    required this.index,
    required this.isDark,
    required this.onTap,
    required this.isActiveWatch,
    required this.activeAdDuration,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    final Color cardBg = isDark
        ? cs.onSurface.withValues(alpha: .04)
        : cs.primaryContainer;
    final Color borderColor = cs.primary.withValues(alpha: isDark ? .12 : .06);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isActiveWatch ? cs.primary : borderColor,
          width: isActiveWatch ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: cs.primary.withValues(alpha: .04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Glowing Icon squircle
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.primary.withValues(alpha: .15),
                      cs.secondary.withValues(alpha: .1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.star_rounded, size: 24, color: cs.secondary),
              ),
              const SizedBox(width: 16),
              // Ad info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sponsor Ad Task #${index + 1}',
                      style: getBoldStyle(fontSize: 16, color: cs.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'High CPM Yield Campaign',
                      style: getBoldStyle(fontSize: 10, color: cs.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Yield explanation content
          Text(
            'Launch this campaign task and watch the sponsor ad for 8-15 seconds to receive your yield score credit. The tab will automatically close on completion.',
            style: getRegularStyle(
              fontSize: 12,
              color: cs.onSurface.withValues(alpha: .6),
            ).copyWith(height: 1.4),
          ),
          const SizedBox(height: 20),
          // View Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isActiveWatch ? Colors.grey : cs.primary,
                foregroundColor: cs.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActiveWatch
                        ? Icons.hourglass_top_rounded
                        : Icons.rocket_launch_rounded,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isActiveWatch
                        ? 'Watching (${activeAdDuration}s)...'
                        : 'Launch Campaign Ad',
                    style: getBoldStyle(fontSize: 13, color: cs.onPrimary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? cs.onSurface.withValues(alpha: .03) : cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: .15), width: 1),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: color.withValues(alpha: .04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: getBoldStyle(fontSize: 16, color: cs.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: getRegularStyle(
              fontSize: 10,
              color: cs.onSurface.withValues(alpha: .5),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MY CAMPAIGNS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _MyCampaignsTab extends StatelessWidget {
  final bool isDark;

  const _MyCampaignsTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final user = context.watch<ProfileBloc>().state.currentUser;
    final isHighRole = user?.role == 'admin' || user?.role == 'superadmin';
    final maxLinks = isHighRole ? 10 : 3;

    return BlocBuilder<CampaignBloc, CampaignState>(
      builder: (context, state) {
        final linksCount = state.myLinks.length;

        return RefreshIndicator(
          color: cs.primary,
          onRefresh: () async {
            context.read<CampaignBloc>().add(const LoadMyCampaigns());
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: Stack(
            children: [
              CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // Quota Progress Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? cs.onSurface.withValues(alpha: .03)
                              : cs.primary.withValues(alpha: .04),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: cs.primary.withValues(alpha: .1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Campaign Upload Quota',
                                  style: getSemiBoldStyle(
                                    fontSize: 14,
                                    color: cs.onSurface,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withValues(alpha: .1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$linksCount / $maxLinks Links',
                                    style: getBoldStyle(
                                      fontSize: 12,
                                      color: cs.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: maxLinks > 0
                                    ? (linksCount / maxLinks).clamp(0.0, 1.0)
                                    : 0,
                                minHeight: 8,
                                backgroundColor: cs.primary.withValues(
                                  alpha: .1,
                                ),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  cs.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              user?.role == 'admin' ||
                                      user?.role == 'superadmin'
                                  ? 'Admins/Superadmins can upload up to 10 active campaign links.'
                                  : 'Regular Users/Moderators can upload up to 3 active campaign links.',
                              style: getRegularStyle(
                                fontSize: 11,
                                color: cs.onSurface.withValues(alpha: .5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Links List
                  if (state.myLinksStatus == CampaignStatus.loading &&
                      state.myLinks.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.myLinks.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: .05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_link_rounded,
                                size: 48,
                                color: cs.primary.withValues(alpha: .4),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No campaigns uploaded',
                              style: getSemiBoldStyle(
                                fontSize: 18,
                                color: cs.onSurface.withValues(alpha: .6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + below to add your campaign link',
                              style: getRegularStyle(
                                fontSize: 13,
                                color: cs.onSurface.withValues(alpha: .35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final campaign = state.myLinks[index];
                          return _MyCampaignCard(
                            campaign: campaign,
                            isDark: isDark,
                          );
                        }, childCount: state.myLinks.length),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 90)),
                ],
              ),
              // Floating Action Button
              if (linksCount < maxLinks)
                Positioned(
                  right: 20,
                  bottom: 24,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          cs.primary,
                          Color.lerp(cs.primary, cs.secondary, 0.4)!,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: .35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () =>
                            _showAddCampaignDialog(context, state.myLinks),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                color: cs.onPrimary,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Add Campaign',
                                style: getMediumStyle(
                                  fontSize: 14,
                                  color: cs.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCampaignDialog(
    BuildContext context,
    List<CampaignLinkModel> currentLinks,
  ) {
    final urlCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final cs = context.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Add Campaign Link',
                style: getBoldStyle(fontSize: 20, color: cs.onSurface),
              ),
              const SizedBox(height: 6),
              Text(
                'Provide details of the promotional campaign. Title and Description are optional.',
                style: getRegularStyle(
                  fontSize: 13,
                  color: cs.onSurface.withValues(alpha: .5),
                ),
              ),
              const SizedBox(height: 20),
              CommonTextField(
                label: 'Campaign URL *',
                controller: urlCtrl,
                keyboardType: TextInputType.url,
                hintText: 'https://example.com/promo',
                prefixIcon: Icons.link_rounded,
              ),
              const SizedBox(height: 16),
              CommonTextField(
                label: 'Title (Optional)',
                controller: titleCtrl,
                hintText: 'Summer Sale',
                prefixIcon: Icons.title_rounded,
              ),
              const SizedBox(height: 16),
              CommonTextField(
                label: 'Description (Optional)',
                controller: descCtrl,
                hintText: '20% discount',
                prefixIcon: Icons.description_rounded,
              ),
              const SizedBox(height: 24),
              GradientButton(
                buttonName: 'Submit Campaign',
                icon: Icons.rocket_launch_rounded,
                onPressed: () {
                  final url = urlCtrl.text.trim();
                  final title = titleCtrl.text.trim();
                  final desc = descCtrl.text.trim();

                  if (url.isEmpty) {
                    showToast(
                      context: context,
                      message: 'URL field cannot be empty',
                      toastificationType: ToastificationType.error,
                    );
                    return;
                  }

                  if (!url.startsWith('http://') &&
                      !url.startsWith('https://')) {
                    showToast(
                      context: context,
                      message: 'URL must start with http:// or https://',
                      toastificationType: ToastificationType.error,
                    );
                    return;
                  }

                  // Submit
                  context.read<CampaignBloc>().add(
                    AddCampaignLink(
                      url: url,
                      title: title.isEmpty ? null : title,
                      description: desc.isEmpty ? null : desc,
                    ),
                  );

                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyCampaignCard extends StatelessWidget {
  final CampaignLinkModel campaign;
  final bool isDark;

  const _MyCampaignCard({required this.campaign, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? cs.onSurface.withValues(alpha: .04)
            : cs.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.primary.withValues(alpha: isDark ? .12 : .06),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primary.withValues(alpha: .15),
                  cs.secondary.withValues(alpha: .1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.track_changes_rounded,
              size: 22,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 14),
          // Text & Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.title ?? 'Promo Link',
                  style: getBoldStyle(fontSize: 14, color: cs.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  campaign.url,
                  style: getRegularStyle(fontSize: 12, color: cs.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 13,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${campaign.likeCount}',
                      style: getBoldStyle(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: .7),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: cs.onSurface.withValues(alpha: .35),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd MMM yyyy').format(campaign.createdAt),
                      style: getRegularStyle(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: .5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Delete Button
          IconButton(
            onPressed: () => _confirmDelete(context),
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: cs.error.withValues(alpha: .75),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final cs = context.colorScheme;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Delete Campaign',
            style: getBoldStyle(fontSize: 18, color: cs.onSurface),
          ),
          content: Text(
            'Are you sure you want to delete this campaign link? This action cannot be undone.',
            style: getRegularStyle(
              fontSize: 14,
              color: cs.onSurface.withValues(alpha: .7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: getMediumStyle(
                  fontSize: 14,
                  color: cs.onSurface.withValues(alpha: .6),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<CampaignBloc>().add(
                  DeleteCampaignLink(campaign.id),
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Delete',
                style: getBoldStyle(fontSize: 14, color: cs.onError),
              ),
            ),
          ],
        );
      },
    );
  }
}
