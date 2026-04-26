import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:adnetwork/layers/presentation/controller/link/link_bloc.dart';
import 'package:adnetwork/layers/presentation/controller/profile/profile_bloc.dart';
import 'package:adnetwork/layers/presentation/widget/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
      final user = state.currentUser;
      final myLinks = context.watch<LinkBloc>().state.links;
      return SafeArea(
        child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
          SliverAppBar(
            floating: true, backgroundColor: cs.surface, surfaceTintColor: Colors.transparent,
            leading: IconButton(icon: Icon(Icons.menu_rounded, color: cs.onSurface), onPressed: () => Scaffold.of(context).openDrawer()),
            title: Text('Profile', style: getBoldStyle(fontSize: 20, color: cs.onSurface)), centerTitle: false,
          ),
          SliverToBoxAdapter(child: Column(children: [
            const SizedBox(height: 8),
            // ── Avatar with gradient ring ──
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [cs.primary, cs.secondary])),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(shape: BoxShape.circle, color: cs.surface),
                child: UserAvatar(username: user?.username ?? 'User', radius: 46),
              ),
            ),
            const SizedBox(height: 16),
            Text(user?.username ?? 'User', style: getBoldStyle(fontSize: 22, color: cs.onSurface)),
            if (user?.bio != null) ...[const SizedBox(height: 6), Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(user!.bio!, style: getRegularStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: .55)), textAlign: TextAlign.center),
            )],
            const SizedBox(height: 24),
      
            // ── Stats row ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: isDark ? cs.onSurface.withValues(alpha: .04) : cs.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cs.primary.withValues(alpha: isDark ? .1 : .05)),
                  boxShadow: [if (!isDark) BoxShadow(color: cs.primary.withValues(alpha: .04), blurRadius: 16, offset: const Offset(0, 4))],
                ),
                child: Row(children: [
                  _S(v: '${state.stats?.likesGiven ?? 0}', l: 'Likes Given', c: cs, onTap: () {}),
                  Container(width: 1, height: 36, color: cs.onSurface.withValues(alpha: .08)),
                  _S(
                    v: '${state.stats?.followers ?? user?.followersCount ?? 0}',
                    l: 'Followers',
                    c: cs,
                    onTap: () {
                      context.read<ProfileBloc>().add(const LoadFollowers());
                      Navigator.pushNamed(context, '/followers');
                    },
                  ),
                  Container(width: 1, height: 36, color: cs.onSurface.withValues(alpha: .08)),
                  _S(
                    v: '${state.stats?.following ?? user?.followingCount ?? 0}',
                    l: 'Following',
                    c: cs,
                    onTap: () {
                      context.read<ProfileBloc>().add(const LoadFollowing());
                      Navigator.pushNamed(context, '/following');
                    },
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 28),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(alignment: Alignment.centerLeft, child: Text('Published Links', style: getSemiBoldStyle(fontSize: 16, color: cs.onSurface)))),
            const SizedBox(height: 12),
          ])),
          // ── Link list ──
          if (myLinks.isEmpty)
            const SliverToBoxAdapter(child: SizedBox())
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                final link = myLinks[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? cs.onSurface.withValues(alpha: .04) : cs.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.primary.withValues(alpha: isDark ? .1 : .05)),
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: cs.primary.withValues(alpha: .1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.link_rounded, size: 18, color: cs.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(link.url ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: getMediumStyle(fontSize: 13, color: cs.primary)),
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.favorite_rounded, size: 13, color: cs.error.withValues(alpha: .6)), const SizedBox(width: 4),
                        Text('${link.likesCount}', style: getRegularStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: .45))),
                        const SizedBox(width: 14),
                        Icon(Icons.access_time_rounded, size: 12, color: cs.onSurface.withValues(alpha: .3)), const SizedBox(width: 4),
                        Text(DateFormat('dd MMM').format(link.publishedDate ?? DateTime.now()), style: getRegularStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: .4))),
                      ]),
                    ])),
                  ]),
                );
              }, childCount: myLinks.length)),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ]),
      );
    });
  }
}

class _S extends StatelessWidget {
  final String v, l; final ColorScheme c; final VoidCallback onTap;
  const _S({required this.v, required this.l, required this.c, required this.onTap});
  @override Widget build(BuildContext context) => Expanded(child: GestureDetector(onTap: onTap, child: Column(children: [
    Text(v, style: getBoldStyle(fontSize: 22, color: c.primary)),
    const SizedBox(height: 3),
    Text(l, style: getRegularStyle(fontSize: 12, color: c.onSurface.withValues(alpha: .55))),
  ])));
}
