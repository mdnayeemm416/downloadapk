import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:adnetwork/layers/presentation/controller/contact/contact_bloc.dart';
import 'package:adnetwork/layers/presentation/widget/common_text_field.dart';
import 'package:adnetwork/layers/presentation/widget/gradient_button.dart';
import 'package:adnetwork/layers/presentation/widget/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});
  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _msgCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(create: (_) => ContactBloc(),
      child: BlocConsumer<ContactBloc, ContactState>(
        listener: (ctx, state) {
          if (state.status == ContactStatus.success) { showToast(context: ctx, message: 'Message sent successfully!', toastificationType: ToastificationType.success); _nameCtrl.clear(); _emailCtrl.clear(); _msgCtrl.clear(); }
          if (state.status == ContactStatus.failure) { showToast(context: ctx, message: state.errorMessage, toastificationType: ToastificationType.error); }
        },
        builder: (context, state) => Scaffold(backgroundColor: cs.surface,
          appBar: AppBar(backgroundColor: cs.surface, surfaceTintColor: Colors.transparent,
            leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface), onPressed: () => Navigator.pop(context)),
            title: Text('Contact Us', style: getBoldStyle(fontSize: 18, color: cs.onSurface))),
          body: SafeArea(
            child: SingleChildScrollView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Header
              Container(width: double.infinity, padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [cs.primary.withValues(alpha: isDark ? .12 : .06), cs.secondary.withValues(alpha: isDark ? .08 : .04)]),
                  borderRadius: BorderRadius.circular(20)),
                child: Column(children: [
                  Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: cs.primary.withValues(alpha: .1), shape: BoxShape.circle),
                    child: Icon(Icons.mail_rounded, size: 32, color: cs.primary)),
                  const SizedBox(height: 14),
                  Text('Get in Touch', style: getBoldStyle(fontSize: 22, color: cs.onSurface)),
                  const SizedBox(height: 6),
                  Text("We'd love to hear from you!", style: getRegularStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: .55)), textAlign: TextAlign.center),
                ])),
              const SizedBox(height: 16),
              // Email info
              Container(width: double.infinity, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? cs.onSurface.withValues(alpha: .04) : cs.primaryContainer,
                  borderRadius: BorderRadius.circular(14), border: Border.all(color: cs.primary.withValues(alpha: isDark ? .1 : .05))),
                child: Row(children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: cs.primary.withValues(alpha: .1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.email_rounded, color: cs.primary, size: 18)),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Email Support', style: getMediumStyle(fontSize: 13, color: cs.onSurface)),
                    Text('support@adnetwork.com', style: getRegularStyle(fontSize: 12, color: cs.primary)),
                  ]),
                ])),
              const SizedBox(height: 28),
              Text('Send a Message', style: getSemiBoldStyle(fontSize: 16, color: cs.onSurface)),
              const SizedBox(height: 16),
              CommonTextField(label: 'Name', controller: _nameCtrl, keyboardType: TextInputType.name, hintText: 'Your name', prefixIcon: Icons.person_outline_rounded),
              const SizedBox(height: 14),
              CommonTextField(label: 'Email', controller: _emailCtrl, keyboardType: TextInputType.emailAddress, hintText: 'your@email.com', prefixIcon: Icons.email_outlined),
              const SizedBox(height: 14),
              CommonTextField(label: 'Message', controller: _msgCtrl, keyboardType: TextInputType.multiline, hintText: 'Write your message...', prefixIcon: Icons.message_outlined, maxlines: 4),
              const SizedBox(height: 28),
              GradientButton(buttonName: 'Send Message', icon: Icons.send_rounded, isLoading: state.status == ContactStatus.loading,
                onPressed: () => context.read<ContactBloc>().add(SubmitContact(name: _nameCtrl.text, email: _emailCtrl.text, message: _msgCtrl.text))),
              const SizedBox(height: 32),
            ])),
          ),
        ),
      ),
    );
  }
}
