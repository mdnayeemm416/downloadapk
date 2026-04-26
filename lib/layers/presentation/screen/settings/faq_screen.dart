import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _faqs = [
    _FaqItem('What is Ad Network?', 'Ad Network is a social platform where users share, discover, and interact with curated links. You can follow other creators, like their content, and build your own collection of links.'),
    _FaqItem('How many links can I add?', 'Each user can add up to 20 links. You can manage your links from the "My Links" section — add, edit, or swipe to delete.'),
    _FaqItem('How do I follow other users?', 'Visit the Explore page to discover new users. Tap the "Follow" button on any user card, or visit their profile to follow them.'),
    _FaqItem('Can I see who follows me?', 'Yes! Go to your Profile and tap on the "Followers" count to see a full list of people who follow you.'),
    _FaqItem('How do likes work?', 'You can like any link post in your feed. Tap the Like button to show appreciation. The total like count is visible to everyone.'),
    _FaqItem('How do I change the app theme?', 'Go to Settings → Appearance. You can choose Light Mode, Dark Mode, or System Default to match your device settings.'),
    _FaqItem('Is my data secure?', 'We take data security seriously. All data is encrypted and stored securely. Please review our Privacy Policy for detailed information.'),
    _FaqItem('How do I contact support?', 'Go to Settings → Support → Contact Us. You can send us a message directly or email us at support@adnetwork.com.'),
    _FaqItem('Can I delete my account?', 'Yes. Please contact our support team through the Contact Us page to request account deletion. We will process your request within 48 hours.'),
    _FaqItem('How do I report inappropriate content?', 'Tap the three-dot menu (⋯) on any post and select "Report". Our moderation team reviews all reports within 24 hours.'),
  ];

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
        title: Text('FAQ & Help', style: getBoldStyle(fontSize: 20, color: cs.onSurface)),
      ),
      body: SafeArea(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          itemCount: _faqs.length,
          itemBuilder: (context, index) {
            final faq = _faqs[index];
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 50)),
              curve: Curves.easeOutCubic,
              builder: (ctx, val, child) => Opacity(
                opacity: val,
                child: Transform.translate(offset: Offset(0, 15 * (1 - val)), child: child),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isDark ? cs.onSurface.withValues(alpha: .04) : cs.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.primary.withValues(alpha: isDark ? .08 : .04)),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Q${index + 1}',
                        style: getBoldStyle(fontSize: 12, color: cs.primary),
                      ),
                    ),
                    title: Text(faq.question, style: getMediumStyle(fontSize: 14, color: cs.onSurface)),
                    iconColor: cs.primary,
                    collapsedIconColor: cs.onSurface.withValues(alpha: .4),
                    children: [
                      Text(faq.answer, style: getRegularStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: .65))),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem(this.question, this.answer);
}
