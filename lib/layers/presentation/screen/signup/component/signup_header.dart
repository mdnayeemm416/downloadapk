import 'package:adnetwork/config/asset_manager.dart';
import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:flutter/material.dart';

class SignupHeader extends StatelessWidget {
  const SignupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
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
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Create Account',
          style: getBoldStyle(fontSize: 24, color: colorScheme.onSurface),
        ),
        const SizedBox(height: 6),
        Text(
          'Join Ad Network to get started',
          style: getRegularStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: .6),
          ),
        ),
      ],
    );
  }
}
