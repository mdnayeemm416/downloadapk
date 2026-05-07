import 'dart:ui';

import 'package:adnetwork/core/services/token_storage.dart';
import 'package:adnetwork/config/theme/routes_config.dart';
import 'package:adnetwork/core/functions/navigator.dart';
import 'package:adnetwork/layers/data/repo/remote/auth_repository.dart';
import 'package:adnetwork/layers/presentation/controller/login/login_bloc.dart';
import 'package:adnetwork/layers/presentation/controller/profile/profile_bloc.dart';
import 'package:adnetwork/layers/presentation/widget/animated_background.dart';
import 'package:adnetwork/layers/presentation/widget/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import 'component/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _cardAnimController;
  late Animation<double> _cardScaleAnim;
  late Animation<double> _cardFadeAnim;
  late LoginBloc _loginBloc;

  @override
  void initState() {
    super.initState();
    _loginBloc = LoginBloc(authRepository: context.read<AuthRepository>());
    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _cardScaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimController, curve: Curves.easeOutBack),
    );
    _cardFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cardAnimController.forward();
    });

    _checkCachedCredentials();
  }

  Future<void> _checkCachedCredentials() async {
    final email = await TokenStorage.instance.getCachedEmail();
    final password = await TokenStorage.instance.getCachedPassword();
    if (email != null &&
        password != null &&
        email.isNotEmpty &&
        password.isNotEmpty) {
      if (mounted) {
        _emailController.text = email;
        _passwordController.text = password;

        // Ensure "Remember me" is checked visually
        _loginBloc.add(const InitializeRememberMe(true));

        final hasManuallyLoggedOut = await TokenStorage.instance
            .hasManuallyLoggedOut();
        if (!hasManuallyLoggedOut) {
          // Attempt auto-login only if they haven't explicitly logged out
          // _loginBloc.add(LoginSubmitted(email: email, password: password));
          Future.delayed(Duration(milliseconds: 300), () {
            if (mounted) {
              _loginBloc.add(LoginSubmitted(email: email, password: password));
            }
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _cardAnimController.dispose();
    _loginBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;

    return BlocProvider.value(
      value: _loginBloc,
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.status == LoginStatus.success) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<ProfileBloc>().add(const LoadProfile());
              showToast(
                context: context,
                message: 'Login Successful!',
                toastificationType: ToastificationType.success,
              );
              navigateAndReplace(context, Routes.home);
            });
          }

          if (state.status == LoginStatus.failure &&
              state.errorMessage.isNotEmpty) {
            showToast(
              context: context,
              message: state.errorMessage,
              toastificationType: ToastificationType.error,
            );
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              const Positioned.fill(child: AnimatedBackground()),
              SafeArea(
                child: Center(
                  child: _CardEntryAnimation(
                    controller: _cardAnimController,
                    scaleAnimation: _cardScaleAnim,
                    fadeAnimation: _cardFadeAnim,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      width: isMobile ? screenWidth * 0.92 : 440,
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 24 : 36,
                              vertical: isMobile ? 32 : 40,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withValues(
                                alpha: isDark ? .05 : .5,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: colorScheme.onSurface.withValues(
                                  alpha: .08,
                                ),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(
                                    alpha: .06,
                                  ),
                                  blurRadius: 40,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: LoginForm(
                              emailController: _emailController,
                              passwordController: _passwordController,
                              formKey: _formKey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardEntryAnimation extends AnimatedWidget {
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;
  final Widget child;

  const _CardEntryAnimation({
    required AnimationController controller,
    required this.scaleAnimation,
    required this.fadeAnimation,
    required this.child,
  }) : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: fadeAnimation.value,
      child: Transform.scale(scale: scaleAnimation.value, child: child),
    );
  }
}
