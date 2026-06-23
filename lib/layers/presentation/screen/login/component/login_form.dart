import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:adnetwork/layers/presentation/controller/login/login_bloc.dart';
import 'package:adnetwork/layers/presentation/widget/common_text_field.dart';
import 'package:adnetwork/layers/presentation/widget/gradient_button.dart';
import 'package:adnetwork/layers/presentation/widget/password_text_field.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_header.dart';
import 'social_login_section.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Form(
          key: formKey,
          child: SingleChildScrollView(
            child: AutofillGroup(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LoginHeader(),
                  const SizedBox(height: 32),

                  // Email
                  CommonTextField(
                    label: 'Email Address',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    hintText: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your email';
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // Password
                  PasswordTextField(
                    label: 'Password',
                    controller: passwordController,
                    hintText: 'Enter your password',
                    autofillHints: const [AutofillHints.password],
                    prefixIcon: Icons.lock_outline_rounded,
                    isPasswordVisible: state.isPasswordVisible,
                    onToggleVisibility: () => context.read<LoginBloc>().add(
                      const TogglePasswordVisibility(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your password';
                      if (value.length < 6)
                        return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Remember Me + Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => context.read<LoginBloc>().add(
                          const ToggleRememberMe(),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: state.isRememberMe
                                    ? colorScheme.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: state.isRememberMe
                                      ? colorScheme.primary
                                      : colorScheme.onSurface.withValues(
                                          alpha: .3,
                                        ),
                                  width: 1.5,
                                ),
                              ),
                              child: state.isRememberMe
                                  ? Icon(
                                      Icons.check,
                                      size: 14,
                                      color: colorScheme.onPrimary,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remember me',
                              style: getRegularStyle(
                                fontSize: 13,
                                color: colorScheme.onSurface.withValues(
                                  alpha: .7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showForgotPasswordDialog(context),
                        child: Text(
                          'Forgot Password?',
                          style: getMediumStyle(
                            fontSize: 13,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Error
                  if (state.status == LoginStatus.failure &&
                      state.errorMessage.isNotEmpty)
                    _buildError(colorScheme, state.errorMessage),

                  // Success (Forgot Password)
                  if (state.forgotPasswordSuccessMessage.isNotEmpty)
                    _buildSuccess(
                      colorScheme,
                      state.forgotPasswordSuccessMessage,
                    ),

                  // Login Button
                  GradientButton(
                    buttonName: 'Sign In',
                    icon: Icons.login_rounded,
                    isLoading: state.status == LoginStatus.loading,
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        TextInput.finishAutofillContext();
                        context.read<LoginBloc>().add(
                          LoginSubmitted(
                            email: emailController.text.trim(),
                            password: passwordController.text,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Admin Telegram Info Banner
                  _AdminTelegramBanner(cs: colorScheme),
                  const SizedBox(height: 24),

                  const SocialLoginSection(),
                  const SizedBox(height: 20),

                  // Sign Up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: getRegularStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withValues(alpha: .6),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed('/signup'),
                        child: Text(
                          'Sign Up',
                          style: getBoldStyle(
                            fontSize: 13,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // About & Contact links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed('/about'),
                        child: Text(
                          'About Us',
                          style: getMediumStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: .45),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '·',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: .3),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context).pushNamed('/contact'),
                        child: Text(
                          'Contact Us',
                          style: getMediumStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: .45),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildError(ColorScheme cs, String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cs.error.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.error.withValues(alpha: .3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: cs.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              msg,
              style: getRegularStyle(fontSize: 12, color: cs.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(ColorScheme cs, String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withValues(alpha: .3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 18,
            color: Colors.green,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              msg,
              style: getRegularStyle(fontSize: 12, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final identifierCtrl = TextEditingController(text: emailController.text);
    final newPasswordCtrl = TextEditingController();
    final loginBloc = context.read<LoginBloc>();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: loginBloc,
        child: StatefulBuilder(
          builder: (dialogCtrlCtx, setState) {
            final cs = Theme.of(dialogCtrlCtx).colorScheme;
            return AlertDialog(
              backgroundColor: cs.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Forgot Password',
                style: getBoldStyle(fontSize: 18, color: cs.onSurface),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter your username or email and your new password to request a password reset.',
                      style: getRegularStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: .6)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: identifierCtrl,
                      style: getMediumStyle(fontSize: 14, color: cs.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Email or Username',
                        labelStyle: getRegularStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: .5)),
                        hintText: 'Enter username or email',
                        hintStyle: getRegularStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: .35)),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        prefixIcon: Icon(Icons.person_outline_rounded, size: 20, color: cs.primary.withValues(alpha: .6)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newPasswordCtrl,
                      obscureText: obscurePassword,
                      style: getMediumStyle(fontSize: 14, color: cs.onSurface),
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle: getRegularStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: .5)),
                        hintText: 'Enter new password',
                        hintStyle: getRegularStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: .35)),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        prefixIcon: Icon(Icons.lock_outline_rounded, size: 20, color: cs.primary.withValues(alpha: .6)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            size: 20,
                            color: cs.onSurface.withValues(alpha: .5),
                          ),
                          onPressed: () => setState(() => obscurePassword = !obscurePassword),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: getMediumStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: .5)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final id = identifierCtrl.text.trim();
                    final pwd = newPasswordCtrl.text.trim();
                    if (id.isEmpty || pwd.isEmpty) {
                      ScaffoldMessenger.of(dialogCtrlCtx).showSnackBar(
                        SnackBar(
                          content: const Text('Please fill in all fields'),
                          backgroundColor: cs.error,
                        ),
                      );
                      return;
                    }
                    if (pwd.length < 6) {
                      ScaffoldMessenger.of(dialogCtrlCtx).showSnackBar(
                        SnackBar(
                          content: const Text('Password must be at least 6 characters'),
                          backgroundColor: cs.error,
                        ),
                      );
                      return;
                    }
                    loginBloc.add(
                      ForgotPasswordSubmitted(identifier: id, newPassword: pwd),
                    );
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Request Reset',
                    style: getBoldStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AdminTelegramBanner extends StatelessWidget {
  final ColorScheme cs;

  const _AdminTelegramBanner({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            cs.primary,
            Color.lerp(cs.primary, cs.secondary, 0.7) ?? cs.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          splashColor: Colors.white.withValues(alpha: 0.2),
          onTap: () async {
            await Clipboard.setData(
              const ClipboardData(text: 'https://t.me/AdNetworkPro'),
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Username copied to clipboard!',
                        style: getMediumStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: cs.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: Stack(
            children: [
              // Subtle background noise/icon overlay for premium feel
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.telegram_rounded,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    // Avatar / Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.telegram_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🚀 অ্যাডমিন পারমিশন নিতে চান?',
                            style: getMediumStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'এখনই আমাদের টেলিগ্রাম চ্যানেলে যোগ দিন!',
                            style: getBoldStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          IntrinsicWidth(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.campaign_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'https://t.me/AdNetworkPro',
                                      style: getBoldStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '👉 Tap to copy & connect',
                            style: getMediumStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Trailing Action indicator
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.copy_rounded,
                        color: cs.primary,
                        size: 16,
                      ),
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
