import 'dart:ui';

import 'package:adnetwork/config/theme/routes_config.dart';
import 'package:adnetwork/core/functions/navigator.dart';
import 'package:adnetwork/layers/data/repo/remote/auth_repository.dart';
import 'package:adnetwork/layers/presentation/controller/signup/signup_bloc.dart';
import 'package:adnetwork/layers/presentation/widget/animated_background.dart';
import 'package:adnetwork/layers/presentation/widget/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import 'component/signup_form.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _firstNameController = TextEditingController();
  final _userNameController = TextEditingController();

  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _cardAnimController;
  late Animation<double> _cardScaleAnim;
  late Animation<double> _cardFadeAnim;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cardAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 850;

    return BlocProvider(
      create: (_) => SignupBloc(authRepository: context.read<AuthRepository>()),
      child: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          if (state.status == SignupStatus.success) {
            showToast(
              context: context,
              message: 'Account Created Successfully!',
              toastificationType: ToastificationType.success,
            );
            navigateAndReplace(context, Routes.login);
          }
          if (state.status == SignupStatus.failure &&
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
                      width: isMobile ? screenWidth * 0.92 : 500,
                      constraints: BoxConstraints(
                        maxWidth: 540,
                        maxHeight: screenHeight * 0.9,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 24 : 36,
                              vertical: isMobile ? 28 : 36,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withValues(
                                alpha: isDark ? .08 : .5,
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
                            child: SignupForm(
                              userNameController: _userNameController,
                              firstNameController: _firstNameController,
                              lastNameController: _lastNameController,
                              emailController: _emailController,
                              passwordController: _passwordController,
                              confirmPasswordController:
                                  _confirmPasswordController,
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
