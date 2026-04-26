import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text('Terms of Service', style: getBoldStyle(fontSize: 20, color: cs.onSurface)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(cs, isDark),
              const SizedBox(height: 20),
              _section(cs, isDark, '1. Acceptance of Terms',
                  'By accessing or using Ad Network, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the application.'),
              _section(cs, isDark, '2. User Accounts',
                  '• You must provide accurate and complete information when creating an account.\n• You are responsible for maintaining the security of your account credentials.\n• You must be at least 13 years old to use this service.\n• One person may not maintain more than one account.'),
              _section(cs, isDark, '3. User Content',
                  '• You retain ownership of the links and content you share.\n• By posting content, you grant Ad Network a non-exclusive license to display and distribute your content within the platform.\n• You are solely responsible for the content you share.\n• Content must not violate any laws or third-party rights.'),
              _section(cs, isDark, '4. Acceptable Use',
                  'You agree not to:\n• Share malicious or harmful links\n• Engage in spam or automated activities\n• Harass, abuse, or threaten other users\n• Impersonate other users or entities\n• Attempt to gain unauthorized access to the platform\n• Use the service for any illegal purpose'),
              _section(cs, isDark, '5. Link Sharing',
                  '• Each user may share up to 20 links.\n• Links must lead to legitimate, accessible web pages.\n• We reserve the right to remove links that violate our policies.\n• You are responsible for ensuring your links do not infringe on others\' rights.'),
              _section(cs, isDark, '6. Intellectual Property',
                  'The Ad Network name, logo, and all related graphics, software, and content are the property of Ad Network Inc. and are protected by copyright and trademark laws.'),
              _section(cs, isDark, '7. Termination',
                  'We may terminate or suspend your account at any time, without prior notice, for conduct that we believe violates these Terms or is harmful to other users, us, or third parties.'),
              _section(cs, isDark, '8. Limitation of Liability',
                  'Ad Network is provided "as is" without warranties of any kind. We shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the service.'),
              _section(cs, isDark, '9. Changes to Terms',
                  'We reserve the right to modify these terms at any time. Continued use of the service after changes constitutes acceptance of the modified terms.'),
              _section(cs, isDark, '10. Contact',
                  'For questions about these Terms of Service, contact us at:\n\nEmail: legal@adnetwork.com\nAddress: Ad Network Inc., Dhaka, Bangladesh'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(ColorScheme cs, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [cs.primary.withValues(alpha: isDark ? .12 : .06), cs.secondary.withValues(alpha: isDark ? .08 : .04)]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: cs.primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.description_rounded, size: 24, color: cs.primary),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Terms of Service', style: getSemiBoldStyle(fontSize: 16, color: cs.onSurface)),
              const SizedBox(height: 2),
              Text('Effective: April 5, 2026', style: getRegularStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: .5))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section(ColorScheme cs, bool isDark, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? cs.onSurface.withValues(alpha: .04) : cs.primaryContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.primary.withValues(alpha: isDark ? .08 : .04)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: getSemiBoldStyle(fontSize: 15, color: cs.primary)),
            const SizedBox(height: 10),
            Text(body, style: getRegularStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: .65))),
          ],
        ),
      ),
    );
  }
}
