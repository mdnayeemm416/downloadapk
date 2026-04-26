import 'package:adnetwork/config/asset_manager.dart';
import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(backgroundColor: cs.surface, appBar: AppBar(
      backgroundColor: cs.surface, surfaceTintColor: Colors.transparent,
      leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface), onPressed: () => Navigator.pop(context)),
      title: Text('About Us', style: getBoldStyle(fontSize: 18, color: cs.onSurface)),
    ), body: SafeArea(
      child: SingleChildScrollView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.all(24), child: Column(children: [
            const SizedBox(height: 16),
            // Logo with gradient glow
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [cs.primary, cs.secondary])),
              child: Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(shape: BoxShape.circle, color: cs.surface),
                child: ClipOval(child: Image.asset(ImageAssets.adNetworkLogo, width: 72, height: 72, fit: BoxFit.cover))),
            ),
            const SizedBox(height: 20),
            Text('AD NETWORK', style: getBoldStyle(fontSize: 26, color: cs.primary)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(color: cs.primary.withValues(alpha: .1), borderRadius: BorderRadius.circular(20)),
              child: Text('v1.0.0', style: getMediumStyle(fontSize: 12, color: cs.primary)),
            ),
            const SizedBox(height: 32),
            _card(cs, isDark, Icons.rocket_launch_rounded, 'Our Mission', 'Ad Network is a social platform where users share, discover, and interact with curated links. We connect creators with audiences through meaningful content sharing.'),
            const SizedBox(height: 12),
            _card(cs, isDark, Icons.star_rounded, 'Key Features', '• Share up to 20 curated links\n• Discover and follow creators\n• Like and engage with content\n• Beautiful dark & light themes\n• Real-time interactions'),
            const SizedBox(height: 12),
            _card(cs, isDark, Icons.code_rounded, 'Built With', 'Flutter · Dart · BLoC Pattern\nDesigned with ❤ for the community'),
            const SizedBox(height: 32),
            Text('© 2026 Ad Network. All rights reserved.', style: getRegularStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: .3))),
            const SizedBox(height: 20),
          ])),
    ));
  }

  Widget _card(ColorScheme cs, bool isDark, IconData icon, String title, String body) => Container(
    width: double.infinity, padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: isDark ? cs.onSurface.withValues(alpha: .04) : cs.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: cs.primary.withValues(alpha: isDark ? .1 : .05)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: cs.primary.withValues(alpha: .1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: cs.primary)),
        const SizedBox(width: 12),
        Text(title, style: getSemiBoldStyle(fontSize: 16, color: cs.onSurface)),
      ]),
      const SizedBox(height: 12),
      Text(body, style: getRegularStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: .65))),
    ]),
  );
}
