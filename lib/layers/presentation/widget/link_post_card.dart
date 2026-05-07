import 'package:adnetwork/config/asset_manager.dart';
import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:adnetwork/layers/data/model/link_model.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Redesigned link post card matching the app's feed style.
class LinkPostCard extends StatelessWidget {
  final LinkModel link;
  final VoidCallback onLike;
  final VoidCallback? onUserTap;

  /// Seconds remaining on the like cooldown (0 = ready to like).
  final double likeCooldownSeconds;

  const LinkPostCard({
    super.key,
    required this.link,
    required this.onLike,
    this.onUserTap,
    this.likeCooldownSeconds = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bool isCoolingDown = !link.isLiked && likeCooldownSeconds > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: .4)),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: .03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── User Row ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 0),
            child: GestureDetector(
              onTap: onUserTap,
              child: Row(
                children: [
                  // Avatar with online indicator
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: cs.primary.withValues(alpha: .2),
                            ),
                          ),
                          padding: const EdgeInsets.all(5.0),
                          child: Image.asset(ImageAssets.adNetworkLogo),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: cs.secondary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: cs.primaryContainer,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "AdNetwork",
                          style: getSemiBoldStyle(
                            fontSize: 15,
                            color: cs.onSurface,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.public_rounded,
                              size: 13,
                              color: cs.onSurface.withValues(alpha: .4),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Published : ${DateFormat('dd MMM yyyy, hh:mm a').format(link.publishedDate ?? DateTime.now())}',
                              style: getRegularStyle(
                                fontSize: 11,
                                color: cs.onSurface.withValues(alpha: .45),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_horiz_rounded,
                      color: cs.onSurface.withValues(alpha: .4),
                    ),
                    onPressed: () {},
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Inner Content Card ──
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? cs.primary.withValues(alpha: .06)
                  : cs.secondary.withValues(alpha: .04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cs.primary.withValues(alpha: isDark ? .12 : .08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title with ID
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: getMediumStyle(fontSize: 14, color: cs.onSurface),
                    children: [
                      TextSpan(text: 'Task '),
                      TextSpan(
                        text: '#${link.id?.toUpperCase() ?? ''} ',
                        style: getBoldStyle(fontSize: 14, color: cs.primary),
                      ),
                      TextSpan(
                        text: link.url,
                        style: getSemiBoldStyle(
                          fontSize: 12,
                          color: cs.onSurface,
                        ),
                      ),
                      const TextSpan(text: ' 🚀'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Published date
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('📅', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      'Published on: (${DateFormat('dd MMM yyyy, hh:mm a').format(link.publishedDate ?? DateTime.now())})',
                      style: getRegularStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: .6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Stay connected for more tasks!',
                  style: getRegularStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: .55),
                  ),
                ),
                const SizedBox(height: 8),

                // Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Status: ',
                      style: getMediumStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: .6),
                      ),
                    ),
                    Icon(Icons.public_rounded, size: 14, color: cs.secondary),
                    const SizedBox(width: 4),
                    Text(
                      link.status ?? 'Unknown',
                      style: getMediumStyle(fontSize: 12, color: cs.secondary),
                    ),
                  ],
                ),
                if (link.description != null &&
                    link.description!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: getRegularStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: .6),
                      ),
                      children: [
                        TextSpan(
                          text: '${link.description!.split('.').first}. ',
                        ),
                        TextSpan(
                          text: 'Opportunities',
                          style: getSemiBoldStyle(
                            fontSize: 12,
                            color: cs.primary,
                          ),
                        ),
                        TextSpan(
                          text:
                              '. Stay proactive & follow the user to keep the tasks coming your way! ✅',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Footer ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                Text(
                  'Create',
                  style: getRegularStyle(
                    fontSize: 11,
                    color: cs.onSurface.withValues(alpha: .35),
                  ),
                ),
                Text(
                  '*Best Community',
                  style: getMediumStyle(
                    fontSize: 11,
                    color: cs.onSurface.withValues(alpha: .45),
                  ),
                ),
                const Spacer(),
                Text(
                  '(${link.likesCount}) Likes',
                  style: getMediumStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: .5),
                  ),
                ),
                const SizedBox(width: 12),

                // ── Like Button with Cooldown ──
                GestureDetector(
                  onTap: link.isLiked || isCoolingDown ? null : onLike,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: link.isLiked
                          ? cs.error.withValues(alpha: .08)
                          : isCoolingDown
                              ? cs.onSurface.withValues(alpha: .06)
                              : cs.onSurface.withValues(alpha: .04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: link.isLiked
                            ? cs.error.withValues(alpha: .2)
                            : isCoolingDown
                                ? cs.primary.withValues(alpha: .15)
                                : cs.onSurface.withValues(alpha: .1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          link.isLiked
                              ? Icons.thumb_up_alt_rounded
                              : Icons.thumb_up_off_alt_rounded,
                          size: 16,
                          color: link.isLiked
                              ? cs.error
                              : isCoolingDown
                                  ? cs.onSurface.withValues(alpha: .25)
                                  : cs.onSurface.withValues(alpha: .45),
                        ),
                        // Show countdown when cooling down
                        if (isCoolingDown) ...[
                          const SizedBox(width: 6),
                          Text(
                            '${likeCooldownSeconds.toStringAsFixed(1)}s',
                            style: getBoldStyle(
                              fontSize: 12,
                              color: cs.primary.withValues(alpha: .7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
