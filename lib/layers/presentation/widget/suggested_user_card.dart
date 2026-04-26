import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:adnetwork/layers/data/model/user_model.dart';
import 'package:adnetwork/layers/presentation/widget/user_avatar.dart';
import 'package:flutter/material.dart';

class SuggestedUserCard extends StatefulWidget {
  final UserModel user;
  final Future<bool> Function() onFollowToggle;
  final VoidCallback? onTap;

  const SuggestedUserCard({
    super.key,
    required this.user,
    required this.onFollowToggle,
    this.onTap,
  });

  @override
  State<SuggestedUserCard> createState() => _SuggestedUserCardState();
}

class _SuggestedUserCardState extends State<SuggestedUserCard> {
  bool _isLoading = false;
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.user.isFollowing;
  }

  @override
  void didUpdateWidget(SuggestedUserCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.id != widget.user.id || oldWidget.user.isFollowing != widget.user.isFollowing) {
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

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 130, // Compact width for horizontal scrolling
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? cs.onSurface.withValues(alpha: .04) : cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.primary.withValues(alpha: isDark ? .1 : .06),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UserAvatar(username: user.username ?? 'U', radius: 24),
            const SizedBox(height: 10),
            Text(
              user.username?.toUpperCase() ?? 'USER',
              style: getBoldStyle(fontSize: 13, color: cs.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '@${user.username?.toLowerCase().replaceAll(' ', '') ?? 'user'}',
              style: getRegularStyle(
                fontSize: 11,
                color: cs.onSurface.withValues(alpha: .5),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _handleFollow,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _isFollowing
                      ? cs.primary.withValues(alpha: .1)
                      : cs.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: _isFollowing ? cs.primary : cs.onPrimary,
                        ),
                      )
                    : Text(
                        _isFollowing ? 'Following' : 'Follow',
                        style: getSemiBoldStyle(
                          fontSize: 12,
                          color: _isFollowing ? cs.primary : cs.onPrimary,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
