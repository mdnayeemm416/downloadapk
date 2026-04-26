import 'dart:math';
import 'package:flutter/material.dart';

/// Floating gradient orbs background — derives all colors from theme.
/// Reusable across login, signup, and any auth screens.
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late final List<_FloatingOrb> _orbs;

  @override
  void initState() {
    super.initState();
    _orbs = List.generate(5, (index) => _FloatingOrb(this, index));
  }

  @override
  void dispose() {
    for (final orb in _orbs) {
      orb.dispose();
    }
    super.dispose();
  }

  List<Color> _orbColors(ColorScheme cs) {
    final pHSL = HSLColor.fromColor(cs.primary);
    final sHSL = HSLColor.fromColor(cs.secondary);
    return [
      cs.primary,
      cs.secondary,
      pHSL.withLightness((pHSL.lightness + 0.15).clamp(0.0, 1.0)).toColor(),
      sHSL.withLightness((sHSL.lightness + 0.10).clamp(0.0, 1.0)).toColor(),
      cs.tertiary,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final colors = _orbColors(cs);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(cs.surface, cs.primary, isDark ? 0.08 : 0.04)!,
                Color.lerp(cs.surface, cs.primary, isDark ? 0.12 : 0.07)!,
                Color.lerp(cs.surface, cs.secondary, isDark ? 0.05 : 0.03)!,
              ],
            ),
          ),
        ),
        ...List.generate(
          _orbs.length,
          (i) => _OrbWidget(
            orb: _orbs[i],
            color: colors[i % colors.length],
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _OrbWidget extends AnimatedWidget {
  final _FloatingOrb orb;
  final Color color;
  final bool isDark;

  _OrbWidget({
    required this.orb,
    required this.color,
    required this.isDark,
  }) : super(listenable: orb.controller);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final v = orb.controller.value;
    final dx = orb.baseX * size.width + sin(v * 2 * pi) * orb.driftX;
    final dy = orb.baseY * size.height + cos(v * 2 * pi) * orb.driftY;

    return Positioned(
      left: dx - orb.radius,
      top: dy - orb.radius,
      child: Container(
        width: orb.radius * 2,
        height: orb.radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: isDark ? .18 : .12),
              color.withValues(alpha: .0),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingOrb {
  late final AnimationController controller;
  final double baseX, baseY, radius, driftX, driftY;

  static final _rng = Random(42);

  _FloatingOrb(TickerProvider vsync, int index)
      : baseX = 0.1 + _rng.nextDouble() * 0.8,
        baseY = 0.1 + _rng.nextDouble() * 0.8,
        radius = 80 + _rng.nextDouble() * 120,
        driftX = 20 + _rng.nextDouble() * 40,
        driftY = 15 + _rng.nextDouble() * 35 {
    controller = AnimationController(
      vsync: vsync,
      duration: Duration(seconds: 8 + _rng.nextInt(7)),
    )..repeat();
  }

  void dispose() => controller.dispose();
}
