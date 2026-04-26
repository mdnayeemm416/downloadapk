import 'package:adnetwork/config/theme/app_colors.dart';
import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:adnetwork/core/extensions/extension.dart';
import 'package:flutter/material.dart';

class ErrorrWidget extends StatelessWidget {
  final String errorMassage;
  final IconData? icon;
  final double? imageHeight;
  const ErrorrWidget({
    super.key,
    required this.errorMassage,
    this.imageHeight,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData currentTheme = Theme.of(context);
    final bool isLight = currentTheme.brightness == Brightness.light;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.width(.04),
        vertical: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.list_alt_rounded,
              size: imageHeight ?? 50,
              color: isLight ? Colors.black : AppColors.cream,
            ),
            Text(
              errorMassage,
              textAlign: TextAlign.center,
              style: getMediumStyle(
                color: isLight ? Colors.black : AppColors.cream,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
