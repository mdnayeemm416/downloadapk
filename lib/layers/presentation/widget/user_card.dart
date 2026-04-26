import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:adnetwork/layers/data/model/user_model.dart';
import 'package:adnetwork/layers/presentation/widget/user_avatar.dart';
import 'package:flutter/material.dart';

class UserCard extends StatefulWidget {
  final UserModel user;
  final Future<bool> Function() onFollowToggle;
  final VoidCallback? onTap;

  const UserCard({
    super.key,
    required this.user,
    required this.onFollowToggle,
    this.onTap,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  bool _isLoading = false;
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.user.isFollowing;
  }

  @override
  void didUpdateWidget(UserCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.isFollowing != widget.user.isFollowing) {
      _isFollowing = widget.user.isFollowing;
    }
  }

  Future<void> _handleFollow() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final success = await widget.onFollowToggle();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (success) _isFollowing = !_isFollowing;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = widget.user;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? cs.onSurface.withValues(alpha: .04) : cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.primary.withValues(alpha: isDark ? .1 : .06),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: cs.onSurface.withValues(alpha: .03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
          // ── Row 1: Avatar and Name ──
          Row(
            children: [
              UserAvatar(username: user.username ?? 'U', radius: 26),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username?.toUpperCase() ?? 'USER',
                      style: getBoldStyle(fontSize: 15, color: cs.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${user.username?.toLowerCase().replaceAll(' ', '') ?? 'user'}',
                      style: getRegularStyle(
                        fontSize: 13,
                        color: cs.onSurface.withValues(alpha: .5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ── Row 2: Stats ──
          Row(
            children: [
              _buildStatBox(cs, '${user.linkCount}', 'Links'),
              const SizedBox(width: 8),
              _buildStatBox(cs, '${user.followersCount}', 'Followers'),
              const SizedBox(width: 8),
              _buildGateBox(cs, user.isApproved == 1),
            ],
          ),
          const SizedBox(height: 16),
          // ── Row 3: Action Buttons ──
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: .06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_rounded, size: 18, color: cs.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Profile',
                          style: getSemiBoldStyle(
                            fontSize: 14,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _handleFollow,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _isFollowing
                          ? cs.primary.withValues(alpha: .1)
                          : cs.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: _isFollowing ? cs.primary : cs.onPrimary,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isFollowing
                                    ? Icons.check_rounded
                                    : Icons.add_rounded,
                                size: 20,
                                color: _isFollowing ? cs.primary : cs.onPrimary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isFollowing ? 'Following' : 'Follow',
                                style: getSemiBoldStyle(
                                  fontSize: 14,
                                  color: _isFollowing
                                      ? cs.primary
                                      : cs.onPrimary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(ColorScheme cs, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: cs.onSurface.withValues(alpha: .08)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: getBoldStyle(fontSize: 16, color: cs.primary)),
            const SizedBox(height: 2),
            Text(
              label,
              style: getRegularStyle(
                fontSize: 11,
                color: cs.onSurface.withValues(alpha: .5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGateBox(ColorScheme cs, bool isApproved) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: cs.onSurface.withValues(alpha: .08)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isApproved ? Colors.green : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                isApproved ? Icons.check_rounded : Icons.close_rounded,
                size: 14,
                color: isApproved
                    ? Colors.white
                    : cs.onSurface.withValues(alpha: .3),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Gate',
              style: getRegularStyle(
                fontSize: 11,
                color: cs.onSurface.withValues(alpha: .5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
