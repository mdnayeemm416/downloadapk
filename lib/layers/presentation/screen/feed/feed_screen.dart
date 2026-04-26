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

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

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
                        child: RepaintBoundary(
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
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final link = state.links[index];
                        return RepaintBoundary(
                          child: LinkPostCard(
                            key: ValueKey(link.id),
                            link: link,
                            likeCooldownSeconds: state.likeCooldownSeconds,
                            onLike: () => context.read<FeedBloc>().add(
                              ToggleLike(link.id ?? ''),
                            ),
                            onUserTap: () => Navigator.of(context).pushNamed(
                              '/user-profile',
                              arguments: link.userId ?? '',
                            ),
                          ),
                        );
                      },
                      childCount: state.links.length,
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries:
                          false, // we add our own RepaintBoundary
                    ),
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
        return SafeArea(child: content);
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
