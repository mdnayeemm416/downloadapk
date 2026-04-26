import 'package:adnetwork/config/asset_manager.dart';
import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.primary.withValues(alpha: .06),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: .12),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              ImageAssets.adNetworkLogo,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Welcome Back',
          style: getBoldStyle(
            fontSize: 26,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to your Ad Network account',
          style: getRegularStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: .6),
          ),
        ),
      ],
    );
  }
}
