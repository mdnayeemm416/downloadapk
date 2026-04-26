import 'package:flutter/material.dart';

/// Circular avatar with initials and a gradient matching the app's theme palette.
class UserAvatar extends StatelessWidget {
  final String username;
  final String? photoUrl;
  final double radius;
  final bool showBorder;

  const UserAvatar({
    super.key,
    required this.username,
    this.photoUrl,
    this.radius = 22,
    this.showBorder = false,
  });

  /// Curated gradient pairs in the app's violet-blue-cyan palette.
  static const _gradients = [
    [Color(0xFF7C4DFF), Color(0xFF536DFE)], // Violet → Indigo
    [Color(0xFF6C63FF), Color(0xFF448AFF)], // Periwinkle → Blue
    [Color(0xFF5C6BC0), Color(0xFF00B8D4)], // Indigo → Cyan
    [Color(0xFF7E57C2), Color(0xFF7C4DFF)], // Deep Purple → Violet
    [Color(0xFF536DFE), Color(0xFF00B8D4)], // Indigo → Cyan
    [Color(0xFF9C27B0), Color(0xFF6C63FF)], // Purple → Periwinkle
    [Color(0xFF1A237E), Color(0xFF5C6BC0)], // Navy → Indigo
    [Color(0xFF00838F), Color(0xFF448AFF)], // Teal → Blue
  ];

  @override
  Widget build(BuildContext context) {
    final initials = username.isNotEmpty
        ? username.substring(0, 1).toUpperCase()
        : '?';

    // Pick a consistent gradient based on username
    final index =
        username.codeUnits.fold<int>(0, (a, b) => a + b) % _gradients.length;
    final colors = _gradients[index];

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        border: showBorder
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: radius * 0.8,
          ),
        ),
      ),
    );
  }
}
