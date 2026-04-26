import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:adnetwork/layers/data/repo/remote/user_repository.dart';
import 'package:adnetwork/layers/presentation/controller/profile/profile_bloc.dart';
import 'package:adnetwork/layers/presentation/widget/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (ctx) =>
          ProfileBloc(userRepository: ctx.read<UserRepository>())
            ..add(LoadUserProfile(userId)),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final user = state.viewedUser;

          if (state.status == ProfileStatus.loading) {
            return Scaffold(
              backgroundColor: cs.surface,
              appBar: AppBar(
                backgroundColor: cs.surface,
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: const SafeArea(child: Center(child: CircularProgressIndicator())),
            );
          }

          final links = user?.links ?? [];

          return Scaffold(
            backgroundColor: cs.surface,
            body: SafeArea(
              child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  floating: true,
                  backgroundColor: cs.surface,
                  surfaceTintColor: Colors.transparent,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    user?.username ?? 'User Profile',
                    style: getBoldStyle(fontSize: 18, color: cs.onSurface),
                  ),
                  centerTitle: false,
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [cs.primary, cs.secondary],
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cs.surface,
                          ),
                          child: UserAvatar(
                            username: user?.username ?? 'U',
                            radius: 46,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user?.username ?? 'User',
                            style: getBoldStyle(
                              fontSize: 22,
                              color: cs.onSurface,
                            ),
                          ),
                          if (user?.isApproved == 1) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${user?.username?.toLowerCase().replaceAll(' ', '') ?? 'user'}',
                        style: getRegularStyle(
                          fontSize: 14,
                          color: cs.onSurface.withValues(alpha: .5),
                        ),
                      ),
                      if (user?.bio != null) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            user!.bio!,
                            style: getRegularStyle(
                              fontSize: 13,
                              color: cs.onSurface.withValues(alpha: .55),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      // ── Follow button ──
                      SizedBox(
                        width: 160,
                        child: Material(
                          color: (user?.isFollowing ?? false)
                              ? Colors.transparent
                              : cs.primary,
                          borderRadius: BorderRadius.circular(24),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => context.read<ProfileBloc>().add(
                              ToggleFollow(userId),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: cs.primary,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    (user?.isFollowing ?? false)
                                        ? Icons.check_rounded
                                        : Icons.add_rounded,
                                    size: 18,
                                    color: (user?.isFollowing ?? false)
                                        ? cs.primary
                                        : cs.onPrimary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    (user?.isFollowing ?? false)
                                        ? 'Following'
                                        : 'Follow',
                                    style: getSemiBoldStyle(
                                      fontSize: 14,
                                      color: (user?.isFollowing ?? false)
                                          ? cs.primary
                                          : cs.onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // ── Stats Row ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? cs.onSurface.withValues(alpha: .04)
                                : cs.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: cs.primary.withValues(
                                alpha: isDark ? .1 : .05,
                              ),
                            ),
                            boxShadow: [
                              if (!isDark)
                                BoxShadow(
                                  color: cs.primary.withValues(alpha: .04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Row(
                            children: [
                              _s('Links', '${user?.linkCount ?? 0}', cs),
                              Container(
                                width: 1,
                                height: 36,
                                color: cs.onSurface.withValues(alpha: .08),
                              ),
                              _s(
                                'Followers',
                                '${user?.followersCount ?? 0}',
                                cs,
                              ),
                              Container(
                                width: 1,
                                height: 36,
                                color: cs.onSurface.withValues(alpha: .08),
                              ),
                              _s(
                                'Following',
                                '${user?.followingCount ?? 0}',
                                cs,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (links.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Published Links',
                              style: getSemiBoldStyle(
                                fontSize: 16,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                // ── Published Links section ──
                if (links.isEmpty)
                  const SliverToBoxAdapter(child: SizedBox())
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final link = links[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? cs.onSurface.withValues(alpha: .04)
                                : cs.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: cs.primary.withValues(
                                alpha: isDark ? .1 : .05,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.link_rounded,
                                  size: 18,
                                  color: cs.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      link.title ?? link.url ?? 'Link',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: getMediumStyle(
                                        fontSize: 13,
                                        color: cs.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.favorite_rounded,
                                          size: 13,
                                          color: cs.error.withValues(alpha: .6),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${link.likesCount}',
                                          style: getRegularStyle(
                                            fontSize: 11,
                                            color: cs.onSurface.withValues(
                                              alpha: .45,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 12,
                                          color: cs.onSurface.withValues(
                                            alpha: .3,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateFormat('dd MMM').format(
                                            link.publishedDate ??
                                                DateTime.now(),
                                          ),
                                          style: getRegularStyle(
                                            fontSize: 11,
                                            color: cs.onSurface.withValues(
                                              alpha: .4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }, childCount: links.length),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ));
        },
      ),
    );
  }

  Widget _s(String l, String v, ColorScheme cs) => Expanded(
    child: Column(
      children: [
        Text(v, style: getBoldStyle(fontSize: 22, color: cs.primary)),
        const SizedBox(height: 3),
        Text(
          l,
          style: getRegularStyle(
            fontSize: 12,
            color: cs.onSurface.withValues(alpha: .55),
          ),
        ),
      ],
    ),
  );
}
