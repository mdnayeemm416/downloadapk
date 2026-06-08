import 'package:adnetwork/config/asset_manager.dart';
import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:adnetwork/layers/presentation/controller/feed/feed_bloc.dart';
import 'package:adnetwork/layers/presentation/controller/notice/notice_bloc.dart';
import 'package:adnetwork/layers/presentation/controller/profile/profile_bloc.dart';
import 'package:adnetwork/layers/presentation/controller/explore/explore_bloc.dart';
import 'package:adnetwork/layers/data/repo/remote/user_repository.dart';
import 'package:adnetwork/layers/presentation/widget/link_post_card.dart';
import 'package:adnetwork/layers/presentation/widget/suggested_user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:adnetwork/core/services/token_storage.dart';
import 'package:flutter/services.dart';
import 'package:adnetwork/core/services/api_client.dart';
import 'package:adnetwork/layers/dto/api_response.dart';

import 'dart:async';
import 'dart:io' show Platform;

import 'package:pip/pip.dart';

final ValueNotifier<bool> isPipModeNotifier = ValueNotifier(false);

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late ScrollController _scrollController;
  Timer? _botTimer;
  bool _isAutoScrolling = false;
  int _currentTargetIndex = 0;
  bool _isProcessingTarget = false;
  final Map<int, GlobalKey> _cardKeys = {};
  final _pip = Pip();
  bool _isPipActive = false;
  bool _isAutoLikeEnabled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initPip();
    _loadAutoLikeStatus();
  }

  Future<void> _loadAutoLikeStatus() async {
    final enabled = await TokenStorage.instance.isAutoLikeEnabled();
    debugPrint('feed_screen.dart: _loadAutoLikeStatus - enabled: $enabled');
    if (mounted) {
      setState(() {
        _isAutoLikeEnabled = enabled;
      });
    }
  }

  Future<void> _initPip() async {
    try {
      final isSupported = await _pip.isSupported();
      if (isSupported) {
        PipOptions options = PipOptions(autoEnterEnabled: false);
        if (Platform.isAndroid) {
          options = PipOptions(
            autoEnterEnabled: false,
            aspectRatioX: 9,
            aspectRatioY: 16,
          );
        } else if (Platform.isIOS) {
          options = PipOptions(
            autoEnterEnabled: false,
            preferredContentWidth: 300,
            preferredContentHeight: 533,
            controlStyle: 0,
          );
        }
        await _pip.setup(options);
        await _pip.registerStateChangedObserver(
          PipStateChangedObserver(
            onPipStateChanged: (state, error) {
              if (mounted) {
                final isActive = state == PipState.pipStateStarted;
                setState(() {
                  _isPipActive = isActive;
                });
                isPipModeNotifier.value = isActive;
              }
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to init PIP: $e');
    }
  }

  @override
  void dispose() {
    _botTimer?.cancel();
    _scrollController.dispose();
    _pip.dispose();
    super.dispose();
  }

  void _toggleAutoPlay(FeedState state) {
    setState(() {
      _isAutoScrolling = !_isAutoScrolling;
      _isProcessingTarget = false;
      _cardKeys.clear();
      if (_isAutoScrolling) {
        _currentTargetIndex = 0;
        _scrollToIndex(0);
        _isProcessingTarget = true;
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted && _isAutoScrolling) {
            setState(() {
              _isProcessingTarget = false;
            });
            _startBotTimer();
          }
        });
      } else {
        _botTimer?.cancel();
        _botTimer = null;
      }
    });
  }

  void _startBotTimer() {
    _botTimer?.cancel();
    _botTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted || !_isAutoScrolling) {
        timer.cancel();
        return;
      }

      if (_isProcessingTarget) return;

      final feedBloc = context.read<FeedBloc>();
      final state = feedBloc.state;

      // Wait if loading or in page wait cooldown
      if (state.pageWaitSeconds > 0 ||
          state.nextCooldownSeconds > 0 ||
          state.status == FeedStatus.loading) {
        return;
      }

      if (state.links.isEmpty) return;

      // Boundary safety check
      if (_currentTargetIndex >= state.links.length) {
        _currentTargetIndex = 0;
      }

      final link = state.links[_currentTargetIndex];

      if (link.isLiked) {
        _currentTargetIndex++;
        if (_currentTargetIndex >= state.links.length) {
          _cardKeys.clear();
          _currentTargetIndex = 0;
          feedBloc.add(ChangeFeedPage(state.currentPage + 1));
          context.read<ExploreBloc>().add(const RefreshExplore());
        } else {
          _isProcessingTarget = true;
          _scrollToIndex(_currentTargetIndex);
          Future.delayed(const Duration(milliseconds: 900), () {
            if (mounted) {
              setState(() {
                _isProcessingTarget = false;
              });
            }
          });
        }
      } else {
        // wait for the likeCooldownSeconds
        if (state.likeCooldownSeconds > 0) {
          return;
        }

        _isProcessingTarget = true;

        // Human-like delay before liking (1000ms)
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted || !_isAutoScrolling) {
            _isProcessingTarget = false;
            return;
          }

          // do the action onLike
          feedBloc.add(ToggleLike(link.id ?? ''));

          // Human-like delay after liking before scrolling (1500ms)
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (!mounted || !_isAutoScrolling) {
              _isProcessingTarget = false;
              return;
            }

            if (context.mounted) {
              // when index end then call next page
              if (_currentTargetIndex == state.links.length - 1) {
                _cardKeys.clear();
                feedBloc.add(ChangeFeedPage(state.currentPage + 1));
                context.read<ExploreBloc>().add(const RefreshExplore());
                setState(() {
                  _currentTargetIndex = 0;
                  _isProcessingTarget = false;
                });
              } else {
                final int nextIndex = _currentTargetIndex + 1;
                _scrollToIndex(nextIndex);

                // Wait for scroll animation to complete, then update index
                Future.delayed(const Duration(milliseconds: 900), () {
                  if (!mounted || !_isAutoScrolling) {
                    _isProcessingTarget = false;
                    return;
                  }
                  setState(() {
                    _currentTargetIndex = nextIndex;
                    _isProcessingTarget = false;
                  });
                });
              }
            } else {
              _isProcessingTarget = false;
            }
          });
        });
      }
    });
  }

  void _scrollToIndex(int index) {
    if (_scrollController.hasClients) {
      final key = _cardKeys[index];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 800),
          alignment: 0.1, // Align near the top of the viewport
          curve: Curves.easeInOut,
        );
      } else {
        // Fallback to offset-based scroll with human-like height per card
        final double targetOffset = 50.0 + (index * 320.0);
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        Widget content;
        // ── Next Button Cooldown Card (5m countdown) ──
        if (state.nextCooldownSeconds > 0) {
          final mins = state.nextCooldownSeconds ~/ 60;
          final secs = state.nextCooldownSeconds % 60;
          final timeStr =
              '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

          content = Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.timer_outlined,
                      color: cs.primary,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    timeStr,
                    style: getBoldStyle(fontSize: 40, color: cs.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '৫ মিনিট পর আবার চেষ্টা করুন',
                    style: getBoldStyle(fontSize: 18, color: cs.onSurface),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'নতুন বিজ্ঞাপন লোড হচ্ছে',
                    style: getMediumStyle(
                      fontSize: 14,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        } else if (state.pageWaitSeconds > 0) {
          content = Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated countdown circle
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: state.pageWaitSeconds / 4.0,
                          strokeWidth: 6,
                          backgroundColor: cs.primary.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text(
                        '${state.pageWaitSeconds}',
                        style: getBoldStyle(fontSize: 32, color: cs.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'অপেক্ষা করুন...',
                    style: getBoldStyle(fontSize: 20, color: cs.onSurface),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${state.pageWaitSeconds} সেকেন্ডে নতুন বিজ্ঞাপন লোড হচ্ছে',
                    style: getMediumStyle(
                      fontSize: 14,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'দয়া করে একটু ধৈর্য ধরুন 🙏',
                    style: getRegularStyle(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.45),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        } else if (state.status == FeedStatus.loading) {
          content = const Center(child: CircularProgressIndicator());
        } else {
          content = RefreshIndicator(
            color: cs.primary,
            onRefresh: () async {
              context.read<FeedBloc>().add(const RefreshFeed());
              context.read<NoticeBloc>().add(const LoadNotices());
              context.read<ProfileBloc>().add(const LoadProfileStats());
              context.read<ExploreBloc>().add(const RefreshExplore());
              await Future.delayed(const Duration(milliseconds: 600));
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: cs.surface,
                  surfaceTintColor: Colors.transparent,
                  leading: IconButton(
                    icon: Icon(Icons.menu_rounded, color: cs.onSurface),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          ImageAssets.adNetworkLogo,
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AdNetwork',
                        style: getBoldStyle(fontSize: 18, color: cs.primary),
                      ),
                    ],
                  ),
                  centerTitle: false,
                  actions: [
                    IconButton(
                      onPressed: () async {
                        final Uri url = Uri.parse(
                          "https://beta.publishers.adsterra.com/referral/kRdPCzuf8a",
                        );

                        try {
                          if (!await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          )) {
                            debugPrint('Could not launch $url');
                          }
                        } catch (e) {
                          debugPrint('Error launching URL: $e');
                        }
                      },
                      icon: Text(
                        'Adsterra',
                        style: getBoldStyle(fontSize: 18, color: cs.primary),
                      ),
                    ),
                  ],
                ),
                // ── Stats Card ──
                SliverToBoxAdapter(
                  child: BlocBuilder<ProfileBloc, ProfileState>(
                    buildWhen: (prev, curr) => prev.stats != curr.stats,
                    builder: (context, profileState) {
                      final stats = profileState.stats;
                      if (stats == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: cs.primary.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Row(
                            children: [
                              _StatItem(
                                icon: Icons.thumb_up_alt_rounded,
                                label: 'Given',
                                value: '${stats.likesGiven}',
                                color: cs.primary,
                                cs: cs,
                              ),
                              _verticalDivider(cs),
                              _StatItem(
                                icon: Icons.favorite_rounded,
                                label: 'Received',
                                value: '${stats.likesReceived}',
                                color: cs.error,
                                cs: cs,
                              ),
                              _verticalDivider(cs),
                              _StatItem(
                                icon: Icons.today_rounded,
                                label: 'Today',
                                value: '${stats.likesToday}',
                                color: cs.secondary,
                                cs: cs,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (state.links.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.dynamic_feed_rounded,
                              size: 64,
                              color: cs.onSurface.withValues(alpha: .3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No posts yet',
                              style: getMediumStyle(
                                fontSize: 16,
                                color: cs.onSurface.withValues(alpha: .5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (state.links.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final link = state.links[index];
                      final cardKey = _cardKeys.putIfAbsent(
                        index,
                        () => GlobalKey(),
                      );
                      return LinkPostCard(
                        key: cardKey,
                        link: link,
                        likeCooldownSeconds: state.likeCooldownSeconds,
                        onLike: () {
                          Future.microtask(() {
                            if (context.mounted) {
                              context.read<FeedBloc>().add(
                                ToggleLike(link.id ?? ''),
                              );
                            }
                          });
                        },
                        onUserTap: () => Navigator.of(context).pushNamed(
                          '/user-profile',
                          arguments: link.userId ?? '',
                        ),
                      );
                    }, childCount: state.links.length),
                  ),

                // ── Notices Section ──
                SliverToBoxAdapter(
                  child: BlocBuilder<NoticeBloc, NoticeState>(
                    builder: (context, noticeState) {
                      if (noticeState.status == NoticeStatus.loading &&
                          noticeState.notices.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      if (noticeState.notices.isEmpty) return const SizedBox();

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: noticeState.notices.map((notice) {
                            Color bg = _parseColor(
                              notice.bgColor,
                              cs.primaryContainer,
                            );
                            Color text = _parseColor(
                              notice.textColor,
                              cs.onSurface,
                            );
                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: text.withValues(alpha: .25),
                                ),
                              ),
                              child: SelectableText(
                                notice.text ?? '',
                                textAlign: TextAlign.center,
                                style: getSemiBoldStyle(
                                  fontSize: 14,
                                  color: text,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
                if (state.links.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      child: state.links.length >= 4
                          ? Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: 16,
                                  bottom: 20,
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3B82F6),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: () {
                                    context.read<FeedBloc>().add(
                                      ChangeFeedPage(state.currentPage + 1),
                                    );
                                    context.read<ExploreBloc>().add(
                                      const RefreshExplore(),
                                    );
                                  },
                                  child: Text(
                                    'NEXT',
                                    style: getBoldStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer.withValues(
                                  alpha: 0.3,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: cs.primary.withValues(alpha: 0.1),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: cs.primary.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.timer_outlined,
                                      color: cs.primary,
                                      size: 36,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'আর কোনো বিজ্ঞাপন নেই',
                                    style: getBoldStyle(
                                      fontSize: 18,
                                      color: cs.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'পাঁচ মিনিট পর আবার চেষ্টা করুন',
                                    style: getMediumStyle(
                                      fontSize: 14,
                                      color: cs.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 16,
                                      bottom: 20,
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF3B82F6,
                                        ),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 05,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        context.read<FeedBloc>().add(
                                          ChangeFeedPage(state.currentPage + 1),
                                        );
                                        context.read<ExploreBloc>().add(
                                          const RefreshExplore(),
                                        );
                                      },
                                      child: Text(
                                        'Refresh',
                                        style: getBoldStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                // ── Follow Suggestions Section ──
                SliverToBoxAdapter(
                  child: BlocBuilder<ExploreBloc, ExploreState>(
                    builder: (context, exploreState) {
                      if (exploreState.status == ExploreStatus.loading &&
                          exploreState.users.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final unfollowedUsers = exploreState.users
                          .where((u) => !u.isFollowing)
                          .toList();
                      if (unfollowedUsers.isEmpty)
                        return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
                            child: Text(
                              'Suggested for you',
                              style: getBoldStyle(
                                fontSize: 15,
                                color: cs.onSurface.withValues(alpha: .7),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 180,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: unfollowedUsers.length,
                              itemBuilder: (context, index) {
                                final u = unfollowedUsers[index];
                                return SuggestedUserCard(
                                  key: ValueKey(u.id),
                                  user: u,
                                  onFollowToggle: () async {
                                    final repo = context.read<UserRepository>();
                                    final res = await repo.toggleFollow(
                                      u.id ?? '',
                                    );
                                    if (res.isSuccess) {
                                      context.read<ExploreBloc>().add(
                                        ToggleExploreFollowState(
                                          u.id ?? '',
                                          !u.isFollowing,
                                        ),
                                      );
                                      return true;
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              res.message ??
                                                  'Failed to follow user.',
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                          ),
                                        );
                                      }
                                      return false;
                                    }
                                  },
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    '/user-profile',
                                    arguments: u.id ?? '',
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 48)),
              ],
            ),
          );
        }
        final showFab =
            state.nextCooldownSeconds <= 0 &&
            state.pageWaitSeconds <= 0 &&
            state.status != FeedStatus.loading &&
            state.links.isNotEmpty;

        return SafeArea(
          child: Stack(
            children: [
              content,
              if (showFab)
                Positioned(
                  right: 16,
                  bottom: 24,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (_isAutoScrolling) ...[
                        FloatingActionButton(
                          heroTag: 'pipBtn',
                          onPressed: () async {
                            try {
                              final isSupported = await _pip.isSupported();
                              if (isSupported) {
                                await _pip.start();
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'PIP is not supported on this device',
                                      ),
                                      backgroundColor: cs.error,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              debugPrint('Failed to start PIP: $e');
                            }
                          },
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          mini: true,
                          child: const Icon(
                            Icons.picture_in_picture_alt_rounded,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      FloatingActionButton.extended(
                        heroTag: 'autoPlayBtn',
                        onPressed: () {
                          if (_isAutoLikeEnabled) {
                            _toggleAutoPlay(state);
                          } else {
                            _showSubscriptionDialog(context);
                          }
                        },
                        backgroundColor: _isAutoScrolling
                            ? Colors.orange.shade700
                            : cs.primary,
                        foregroundColor: Colors.white,
                        icon: Icon(
                          _isAutoScrolling
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 24,
                        ),
                        label: Text(
                          _isAutoScrolling ? 'PAUSE' : 'AUTO PLAY',
                          style: getBoldStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showSubscriptionDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.transparent,
          child: FutureBuilder<ApiResponse<dynamic>>(
            future: ApiClient.instance.get<dynamic>(
              '/api/getprice',
              queryParams: {'appname': 'adnetworkpro'},
              auth: true,
            ),
            builder: (context, snapshot) {
              String priceText = 'লোড হচ্ছে...';
              double? price;

              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data!.isSuccess && snapshot.data!.data is Map) {
                  final priceVal = snapshot.data!.data['price'];
                  if (priceVal != null) {
                    price = double.tryParse(priceVal.toString());
                    if (price != null) {
                      priceText = '$price ৳';
                    } else {
                      priceText = 'ফ্রি';
                    }
                  } else {
                    priceText = 'ফ্রি';
                  }
                } else {
                  priceText = 'মূল্য জানতে যোগাযোগ করুন';
                }
              }

              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Premium Icon with Gold Gradient
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.amber.shade700, width: 2),
                      ),
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.amber.shade800,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dialog Title
                    Text(
                      'অটো প্লে সাবস্ক্রিপশন',
                      style: getBoldStyle(
                        fontSize: 22,
                        color: isDark ? Colors.white : cs.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      'বিজ্ঞাপন অটো প্লে করার মাধ্যমে খুব সহজেই কাজ সম্পন্ন করুন। এই প্রিমিয়াম ফিচারটি আনলক করতে নিচের নম্বরে সাবস্ক্রিপশন পেমেন্ট করুন।',
                      style: getMediumStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : cs.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Dynamic Price Section
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.monetization_on_outlined,
                            color: Colors.amber.shade800,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'সাবস্ক্রিপশন ফি: ',
                            style: getMediumStyle(
                              fontSize: 15,
                              color: isDark ? Colors.white : cs.onSurface,
                            ),
                          ),
                          if (snapshot.connectionState == ConnectionState.waiting)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                              ),
                            )
                          else
                            Text(
                              priceText,
                              style: getBoldStyle(
                                fontSize: 18,
                                color: Colors.amber.shade800,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Payment Methods Label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'বিকাশ • নগদ • রকেট • উপায়',
                            style: getBoldStyle(fontSize: 12, color: cs.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Number Field with Copy Button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? cs.onSurface.withValues(alpha: 0.05)
                            : cs.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: cs.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'পার্সোনাল নম্বর',
                                style: getRegularStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.5)
                                      : cs.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '01401011049',
                                style: getBoldStyle(
                                  fontSize: 18,
                                  color: isDark ? Colors.white : cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                const ClipboardData(text: '01401011049'),
                              );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('নম্বরটি কপি করা হয়েছে!'),
                                  backgroundColor: cs.primary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.copy_rounded, color: cs.primary),
                            tooltip: 'কপি করুন',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Instructions
                    Text(
                      'টাকা পাঠানোর পর ট্রানজেকশন আইডি এবং আপনার ইউজারনেম সহ এডমিনের সাথে যোগাযোগ করুন।',
                      style: getRegularStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : cs.onSurface.withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'বন্ধ করুন',
                          style: getBoldStyle(fontSize: 15, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _parseColor(String? hexCode, Color fallback) {
    if (hexCode == null || hexCode.isEmpty) return fallback;
    try {
      final code = hexCode.replaceAll('#', '');
      return Color(int.parse('FF$code', radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  Widget _verticalDivider(ColorScheme cs) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: cs.onSurface.withValues(alpha: 0.08),
    );
  }

  Widget _StatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ColorScheme cs,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: getBoldStyle(fontSize: 16, color: cs.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: getRegularStyle(
              fontSize: 11,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
