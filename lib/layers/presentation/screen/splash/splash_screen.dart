import 'dart:async';

import 'package:adnetwork/config/asset_manager.dart';
import 'package:adnetwork/config/theme/routes_config.dart';
import 'package:adnetwork/core/functions/navigator.dart';
import 'package:flutter/material.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final GlobalKey<OffsetTextState> offsetTextBTKey =
      GlobalKey<OffsetTextState>();

  @override
  void initState() {
    super.initState();
    _checkAppUpdateAndNavigate();
  }

  Future<void> _checkAppUpdateAndNavigate() async {
    // Wait for the animation to complete
    await Future.delayed(const Duration(milliseconds: 2600));

    if (mounted) {
      navigateAndReplace(context, Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? const Color(0xFF121212)
        : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Beautiful Animated Card Effect for the Logo
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.4, end: 1.0),
                duration: const Duration(milliseconds: 1400),
                curve: Curves.elasticOut, // Gives a nice pop-out bounce
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.black.withValues(alpha: 0.6)
                            : Colors.black.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.black.withValues(alpha: 0.4)
                            : Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    ImageAssets.adNetworkLogo,
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Animated Text using pretty_animated_text
              OffsetText(
                key: offsetTextBTKey,
                text: "AD NETWORK",
                duration: const Duration(milliseconds: 300),
                type: AnimationType.letter,
                slideType: SlideAnimationType.bottomTop,
                textStyle: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: isDarkMode ? Colors.white : const Color(0xFF2D3142),
                  shadows: [
                    Shadow(
                      color: isDarkMode
                          ? Colors.black.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
