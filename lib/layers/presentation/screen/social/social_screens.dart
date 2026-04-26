import 'package:adnetwork/config/theme/styles_manager.dart';

import 'package:adnetwork/layers/data/repo/remote/user_repository.dart';
import 'package:adnetwork/layers/presentation/controller/profile/profile_bloc.dart';
import 'package:adnetwork/layers/presentation/widget/user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowersScreen extends StatelessWidget {
  const FollowersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Followers',
          style: getBoldStyle(fontSize: 18, color: cs.onSurface),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state.status == ProfileStatus.loading &&
                state.followers.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            final followers = state.followers;
            if (followers.isEmpty) {
              return Center(
                child: Text(
                  'No followers yet',
                  style: getMediumStyle(
                    fontSize: 16,
                    color: cs.onSurface.withValues(alpha: .5),
                  ),
                ),
              );
            }
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => UserCard(
                      user: followers[index],
                      onFollowToggle: () async {
                        final repo = context.read<UserRepository>();
                        final res = await repo.toggleFollow(
                          followers[index].id ?? '',
                        );
                        return res.isSuccess;
                      },
                      onTap: () => Navigator.of(context).pushNamed(
                        '/user-profile',
                        arguments: followers[index].id ?? '',
                      ),
                    ),
                    childCount: followers.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: _buildFollowersPagination(context, state, cs),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFollowersPagination(
    BuildContext context,
    ProfileState state,
    ColorScheme cs,
  ) {
    int current = state.followersPage;
    bool hasMore = state.hasMoreFollowers;

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
              ? () => context.read<ProfileBloc>().add(
                  ChangeFollowersPage(current - 1),
                )
              : null,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        ...pages.map(
          (p) => InkWell(
            onTap: () {
              if (p != current) {
                context.read<ProfileBloc>().add(ChangeFollowersPage(p));
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
              ? () => context.read<ProfileBloc>().add(
                  ChangeFollowersPage(current + 1),
                )
              : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class FollowingScreen extends StatelessWidget {
  const FollowingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Following',
          style: getBoldStyle(fontSize: 18, color: cs.onSurface),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state.status == ProfileStatus.loading &&
                state.following.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            final following = state.following;
            if (following.isEmpty) {
              return Center(
                child: Text(
                  'Not following anyone',
                  style: getMediumStyle(
                    fontSize: 16,
                    color: cs.onSurface.withValues(alpha: .5),
                  ),
                ),
              );
            }
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => UserCard(
                      user: following[index],
                      onFollowToggle: () async {
                        final repo = context.read<UserRepository>();
                        final res = await repo.toggleFollow(
                          following[index].id ?? '',
                        );
                        return res.isSuccess;
                      },
                      onTap: () => Navigator.of(context).pushNamed(
                        '/user-profile',
                        arguments: following[index].id ?? '',
                      ),
                    ),
                    childCount: following.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: _buildFollowingPagination(context, state, cs),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFollowingPagination(
    BuildContext context,
    ProfileState state,
    ColorScheme cs,
  ) {
    int current = state.followingPage;
    bool hasMore = state.hasMoreFollowing;

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
              ? () => context.read<ProfileBloc>().add(
                  ChangeFollowingPage(current - 1),
                )
              : null,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        ...pages.map(
          (p) => InkWell(
            onTap: () {
              if (p != current) {
                context.read<ProfileBloc>().add(ChangeFollowingPage(p));
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
              ? () => context.read<ProfileBloc>().add(
                  ChangeFollowingPage(current + 1),
                )
              : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}
