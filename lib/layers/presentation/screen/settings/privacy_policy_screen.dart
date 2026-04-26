import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
        title: Text('Privacy Policy', style: getBoldStyle(fontSize: 20, color: cs.onSurface)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(cs, isDark, 'Last updated: April 5, 2026'),
              const SizedBox(height: 20),
              _section(cs, isDark, 'Introduction',
                  'Welcome to Ad Network ("we", "our", "us"). We are committed to protecting your personal information and your right to privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.'),
              _section(cs, isDark, 'Information We Collect',
                  '• Account Information: Username, email address, and profile photo.\n• Usage Data: Links you share, likes, follows, and interactions.\n• Device Information: Device type, operating system, and unique device identifiers.\n• Log Data: IP address, browser type, and access times.'),
              _section(cs, isDark, 'How We Use Your Information',
                  '• To provide and maintain our service\n• To personalize your experience\n• To communicate with you about updates and features\n• To monitor usage and improve our platform\n• To detect, prevent, and address technical issues'),
              _section(cs, isDark, 'Data Sharing',
                  'We do not sell your personal data. We may share your information only in the following situations:\n• With your consent\n• To comply with legal obligations\n• To protect our rights and safety\n• With service providers who assist in our operations'),
              _section(cs, isDark, 'Data Retention',
                  'We retain your personal data only for as long as necessary to fulfill the purposes outlined in this policy. When data is no longer needed, we securely delete or anonymize it.'),
              _section(cs, isDark, 'Your Rights',
                  '• Access your personal data\n• Correct inaccurate data\n• Request deletion of your data\n• Object to processing of your data\n• Data portability\n\nTo exercise these rights, contact us at privacy@adnetwork.com.'),
              _section(cs, isDark, 'Security',
                  'We implement industry-standard security measures including encryption, secure servers, and regular security audits to protect your data. However, no method of transmission over the Internet is 100% secure.'),
              _section(cs, isDark, 'Contact Us',
                  'If you have questions about this Privacy Policy, please contact us:\n\nEmail: privacy@adnetwork.com\nAddress: Ad Network Inc., Dhaka, Bangladesh'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(ColorScheme cs, bool isDark, String date) {
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
            child: Icon(Icons.privacy_tip_rounded, size: 24, color: cs.primary),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Privacy Policy', style: getSemiBoldStyle(fontSize: 16, color: cs.onSurface)),
              const SizedBox(height: 2),
              Text(date, style: getRegularStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: .5))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section(ColorScheme cs, bool isDark, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
