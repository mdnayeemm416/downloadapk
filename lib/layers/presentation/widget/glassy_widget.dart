import 'dart:ui';

import 'package:flutter/material.dart';

class GlassyWidget extends StatelessWidget {
  final Widget widget;
  const GlassyWidget({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // blur effect
        child: Container(
          padding: EdgeInsets.all(15),

          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .2), // semi-transparent
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Theme.of(context).dividerColor, // light border for glass look
              width: 1.0,
            ),
          ),
          child: widget,
        ),
      ),
    );
  }
}
