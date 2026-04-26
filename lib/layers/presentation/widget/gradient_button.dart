import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GradientButton extends StatefulWidget {
  final String buttonName;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final List<Color>? gradientColors;
  final double borderRadius;

  const GradientButton({
    super.key,
    required this.buttonName,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 52,
    this.gradientColors,
    this.borderRadius = 14,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradientEnd = Color.lerp(colorScheme.primary, Colors.white, 0.25)!;
    final colors = widget.gradientColors ?? [colorScheme.primary, gradientEnd];

    return _ScaleAnimWidget(
      animation: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) {
          if (widget.onPressed != null && !widget.isLoading) {
            _animController.forward();
          }
        },
        onTapUp: (_) {
          _animController.reverse();
          if (widget.onPressed != null && !widget.isLoading) {
            widget.onPressed!();
          }
        },
        onTapCancel: () => _animController.reverse(),
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.onPressed != null && !widget.isLoading
                  ? colors
                  : [Colors.grey.shade400, Colors.grey.shade500],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              if (widget.onPressed != null && !widget.isLoading)
                BoxShadow(
                  color: colors.first.withValues(alpha: .35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CupertinoActivityIndicator(
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 20, color: colorScheme.onPrimary),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.buttonName,
                          style: getBoldStyle(fontSize: 16, color: colorScheme.onPrimary),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScaleAnimWidget extends AnimatedWidget {
  final Widget child;
  const _ScaleAnimWidget({
    required Animation<double> animation,
    required this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final anim = listenable as Animation<double>;
    return Transform.scale(scale: anim.value, child: child);
  }
}
