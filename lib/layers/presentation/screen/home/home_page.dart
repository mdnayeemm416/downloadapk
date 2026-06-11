import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:adnetwork/core/services/token_storage.dart';
import 'package:adnetwork/layers/data/repo/remote/link_repository.dart';
import 'package:adnetwork/layers/data/repo/remote/user_repository.dart';
import 'package:adnetwork/layers/presentation/controller/feed/feed_bloc.dart';
import 'package:adnetwork/layers/presentation/controller/link/link_bloc.dart';
import 'package:adnetwork/layers/presentation/controller/notice/notice_bloc.dart';
import 'package:adnetwork/layers/data/repo/remote/notice_repository.dart';
import 'package:adnetwork/layers/presentation/controller/explore/explore_bloc.dart';
import 'package:adnetwork/layers/presentation/controller/profile/profile_bloc.dart';
import 'package:adnetwork/layers/presentation/screen/explore/explore_screen.dart';
import 'package:adnetwork/layers/presentation/screen/feed/feed_screen.dart';
import 'package:adnetwork/layers/presentation/screen/links/my_links_screen.dart';
import 'package:adnetwork/layers/presentation/screen/profile/profile_screen.dart';
import 'package:adnetwork/layers/presentation/widget/link_queue_overlay.dart';
import 'package:adnetwork/layers/presentation/widget/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _idx = 0;
  static const _labels = ['Feed', 'My Links', 'Explore', 'Profile'];
  static const _icons = [
    Icons.dynamic_feed_rounded,
    Icons.link_rounded,
    Icons.explore_rounded,
    Icons.person_rounded,
  ];
  final _pages = const [
    FeedScreen(),
    MyLinksScreen(),
    ExploreScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load stats once on initial feed load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileBloc>().add(const LoadProfileStats());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileState = context.watch<ProfileBloc>().state;
    final user = profileState.currentUser;

    final linkRepo = context.read<LinkRepository>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              FeedBloc(linkRepository: linkRepo)..add(const LoadFeed()),
        ),
        BlocProvider(
          create: (_) =>
              LinkBloc(linkRepository: linkRepo)..add(const LoadMyLinks()),
        ),
        BlocProvider(
          create: (_) =>
              ExploreBloc(userRepository: context.read<UserRepository>())
                ..add(const LoadExplore()),
        ),
        BlocProvider(
          create: (_) =>
              NoticeBloc(noticeRepository: NoticeRepository())
                ..add(const LoadNotices()),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: cs.surface,
            drawer: Drawer(
              backgroundColor: cs.surface,
              child: SafeArea(
                child: Column(
                  children: [
                    // ── Premium gradient header ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [cs.primary.withValues(alpha: .2), cs.surface]
                              : [cs.primary.withValues(alpha: .08), cs.surface],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [cs.primary, cs.secondary],
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cs.surface,
                              ),
                              child: UserAvatar(
                                username: user?.username ?? 'User',
                                radius: 32,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user?.username ?? 'User',
                            style: getBoldStyle(
                              fontSize: 18,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (user?.bio != null)
                            Text(
                              user!.bio!,
                              style: getRegularStyle(
                                fontSize: 12,
                                color: cs.onSurface.withValues(alpha: .5),
                              ),
                            ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                '${user?.followersCount ?? 0}',
                                style: getBoldStyle(
                                  fontSize: 14,
                                  color: cs.onSurface,
                                ),
                              ),
                              Text(
                                ' Followers',
                                style: getRegularStyle(
                                  fontSize: 12,
                                  color: cs.onSurface.withValues(alpha: .5),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '${user?.followingCount ?? 0}',
                                style: getBoldStyle(
                                  fontSize: 14,
                                  color: cs.onSurface,
                                ),
                              ),
                              Text(
                                ' Following',
                                style: getRegularStyle(
                                  fontSize: 12,
                                  color: cs.onSurface.withValues(alpha: .5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // ── Scrollable Menu Items ──
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            ...List.generate(
                              4,
                              (i) => _Item(
                                icon: _icons[i],
                                label: _labels[i],
                                active: _idx == i,
                                onTap: () {
                                  if (i == 0) {
                                    context.read<FeedBloc>().add(
                                      const RefreshFeed(),
                                    );
                                    context.read<NoticeBloc>().add(
                                      const LoadNotices(),
                                    );
                                  } else if (i == 1) {
                                    context.read<LinkBloc>().add(
                                      const LoadMyLinks(),
                                    );
                                  } else if (i == 2) {
                                    context.read<ExploreBloc>().add(
                                      const RefreshExplore(),
                                    );
                                  } else if (i == 3) {
                                    context.read<ProfileBloc>().add(
                                      const LoadProfileStats(),
                                    );
                                  }
                                  setState(() => _idx = i);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              child: Divider(
                                color: cs.onSurface.withValues(alpha: .06),
                              ),
                            ),
                            _Item(
                              icon: Icons.query_stats_rounded,
                              label: 'Stats',
                              active: false,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/stats');
                              },
                            ),
                            _Item(
                              icon: Icons.settings_rounded,
                              label: 'Settings',
                              active: false,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/settings');
                              },
                            ),
                            // Admin panel — visible for admin and moderator users
                            if (user?.role == 'admin' ||
                                user?.role == 'moderator') ...[
                              _Item(
                                icon: Icons.admin_panel_settings_rounded,
                                label: 'Admin Panel',
                                active: false,
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, '/admin');
                                },
                              ),
                              _Item(
                                icon: Icons.subscriptions_rounded,
                                label: 'Manage Subscriptions',
                                active: false,
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    '/admin/subscriptions',
                                  );
                                },
                              ),
                              if (user?.role == 'admin')
                                _Item(
                                  icon: Icons.account_balance_wallet_rounded,
                                  label: 'Finance',
                                  active: false,
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(
                                      context,
                                      '/admin/finance',
                                    );
                                  },
                                ),
                              _Item(
                                icon: Icons.campaign_rounded,
                                label: 'Manage Notices',
                                active: false,
                                onTap: () async {
                                  Navigator.pop(context);
                                  await Navigator.pushNamed(
                                    context,
                                    '/admin/notices',
                                  );
                                  if (context.mounted) {
                                    context.read<NoticeBloc>().add(
                                      const LoadNotices(),
                                    );
                                  }
                                },
                              ),
                            ],
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    // Logout
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                        bottom: 12,
                      ),
                      child: Material(
                        color: cs.error.withValues(alpha: isDark ? .1 : .06),
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () async {
                            await TokenStorage.instance.setManualLogout(true);
                            await TokenStorage.instance.clearAll();
                            if (context.mounted) {
                              context.read<ProfileBloc>().add(
                                const ClearProfile(),
                              );
                              Navigator.pop(context);
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (_) => false,
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  size: 22,
                                  color: cs.error,
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  'Log Out',
                                  style: getMediumStyle(
                                    fontSize: 14,
                                    color: cs.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Text(
                        'Ad Network v1.0.5',
                        style: getRegularStyle(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: .25),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: SafeArea(
              child: ValueListenableBuilder<bool>(
                valueListenable: isPipModeNotifier,
                builder: (context, isPip, child) {
                  return Stack(
                    children: [
                      Column(
                        children: [
                          // Main content
                          Expanded(
                            child: OverflowBox(
                              minWidth: isPip ? 400 : null,
                              maxWidth: isPip ? 400 : null,
                              minHeight: isPip ? 800 : null,
                              maxHeight: isPip ? 800 : null,
                              alignment: Alignment.topCenter,
                              child: IndexedStack(
                                index: _idx,
                                children: _pages,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!isPip)
                        const Positioned(
                          left: 16,
                          bottom: 16,
                          child: LinkQueueOverlay(isPipMode: false),
                        ),
                      if (isPip)
                        Positioned.fill(
                          child: Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: const LinkQueueOverlay(isPipMode: true),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Item({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: active ? cs.primary.withValues(alpha: .1) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: active
                      ? cs.primary
                      : cs.onSurface.withValues(alpha: .55),
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: getMediumStyle(
                    fontSize: 14,
                    color: active
                        ? cs.primary
                        : cs.onSurface.withValues(alpha: .75),
                  ),
                ),
                if (active) ...[
                  const Spacer(),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
