import 'package:adnetwork/config/theme/styles_manager.dart';

import 'package:adnetwork/layers/data/model/user_model.dart';
import 'package:adnetwork/layers/data/repo/remote/user_repository.dart';
import 'package:adnetwork/layers/presentation/controller/explore/explore_bloc.dart';
import 'package:adnetwork/layers/presentation/widget/user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _q = '';

  List<UserModel> _getFiltered(List<UserModel> allUsers) {
    return _q.isEmpty
        ? allUsers
        : allUsers
              .where(
                (u) =>
                    (u.username ?? '').toLowerCase().contains(_q.toLowerCase()),
              )
              .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
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
            title: Text(
              'Explore',
              style: getBoldStyle(fontSize: 20, color: cs.onSurface),
            ),
            centerTitle: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? cs.onSurface.withValues(alpha: .05)
                        : cs.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: isDark ? .1 : .06),
                    ),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _q = v),
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      hintStyle: getRegularStyle(
                        fontSize: 14,
                        color: cs.onSurface.withValues(alpha: .35),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: cs.primary.withValues(alpha: .6),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 16,
                bottom: 8,
                top: 4,
              ),
              child: Text(
                'Follow Suggestions',
                style: getBoldStyle(
                  fontSize: 16,
                  color: cs.onSurface.withValues(alpha: .8),
                ),
              ),
            ),
          ),
          BlocBuilder<ExploreBloc, ExploreState>(
            builder: (context, state) {
              if (state.status == ExploreStatus.loading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final users = _getFiltered(state.users);
              if (users.isEmpty)
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: .06),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_search_rounded,
                            size: 48,
                            color: cs.primary.withValues(alpha: .4),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No users found',
                          style: getMediumStyle(
                            fontSize: 16,
                            color: cs.onSurface.withValues(alpha: .5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final u = users[i];
                  return TweenAnimationBuilder<double>(
                    key: ValueKey(u.id),
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 300 + (i * 50)),
                    curve: Curves.easeOutCubic,
                    builder: (ctx, v, child) => Opacity(
                      opacity: v,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - v)),
                        child: child,
                      ),
                    ),
                    child: UserCard(
                      user: u,
                      onFollowToggle: () async {
                        final repo = context.read<UserRepository>();
                        final res = await repo.toggleFollow(u.id ?? '');
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(res.message ?? 'Failed to follow user.'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Theme.of(context).colorScheme.error,
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
                    ),
                  );
                }, childCount: users.length),
              );
            },
          ),
          BlocBuilder<ExploreBloc, ExploreState>(
            builder: (context, state) {
              if (state.status == ExploreStatus.loading || state.users.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox(height: 24));
              }
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 40),
                  child: _buildPagination(context, state, cs),
                ),
              );
            },
          ),
        ],
      ),
    );;
  }

  Widget _buildPagination(
    BuildContext context,
    ExploreState state,
    ColorScheme cs,
  ) {
    int current = state.currentPage;
    bool hasMore = state.hasMore;

    List<int> pages = [];
    if (current > 2) pages.add(current - 2);
    if (current > 1) pages.add(current - 1);
    pages.add(current);
    if (hasMore) pages.add(current + 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: current > 1
              ? () => context.read<ExploreBloc>().add(
                  ChangeExplorePage(current - 1),
                )
              : null,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        ...pages.map(
          (p) => InkWell(
            onTap: () {
              if (p != current) {
                context.read<ExploreBloc>().add(ChangeExplorePage(p));
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p == current ? cs.primary : Colors.transparent,
                border: p != current
                    ? Border.all(color: cs.onSurface.withValues(alpha: 0.1))
                    : null,
              ),
              child: Text(
                '$p',
                style: getMediumStyle(
                  fontSize: 14,
                  color: p == current ? cs.onPrimary : cs.onSurface,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: hasMore
              ? () => context.read<ExploreBloc>().add(
                  ChangeExplorePage(current + 1),
                )
              : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}
