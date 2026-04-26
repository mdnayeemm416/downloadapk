import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:adnetwork/core/extensions/capitalize_first_extension.dart';
import 'package:adnetwork/layers/presentation/controller/signup/signup_bloc.dart';
import 'package:adnetwork/layers/presentation/widget/common_text_field.dart';
import 'package:adnetwork/layers/presentation/widget/gradient_button.dart';
import 'package:adnetwork/layers/presentation/widget/option_selector.dart';
import 'package:adnetwork/layers/presentation/widget/password_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'signup_header.dart';

class SignupForm extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController userNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final GlobalKey<FormState> formKey;

  const SignupForm({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.formKey,
    required this.userNameController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<SignupBloc, SignupState>(
      builder: (context, state) {
        return Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SignupHeader(),
                const SizedBox(height: 28),

                // First Name + Last Name side by side
                Row(
                  children: [
                    Expanded(
                      child: CommonTextField(
                        label: 'First Name',
                        controller: firstNameController,
                        keyboardType: TextInputType.name,
                        hintText: 'First name',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CommonTextField(
                        label: 'Last Name',
                        controller: lastNameController,
                        keyboardType: TextInputType.name,
                        hintText: 'Last name',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  label: 'User Name',
                  controller: userNameController,
                  keyboardType: TextInputType.text,
                  hintText: 'User name',
                  prefixIcon: Icons.face,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                // Gender Selector
                OptionSelector<Gender>(
                  label: 'Gender',
                  options: Gender.values,
                  selectedOption: state.selectedGender,
                  labelBuilder: (g) => g.name.capitalizeFirst,
                  iconBuilder: (g) => switch (g) {
                    Gender.male => Icons.male_rounded,
                    Gender.female => Icons.female_rounded,
                    Gender.other => Icons.transgender_rounded,
                  },
                  onSelected: (g) =>
                      context.read<SignupBloc>().add(SelectGender(g)),
                ),
                const SizedBox(height: 16),

                // Email
                CommonTextField(
                  label: 'Email Address',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                PasswordTextField(
                  label: 'Password',
                  controller: passwordController,
                  hintText: 'Create a password',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPasswordVisible: state.isPasswordVisible,
                  onToggleVisibility: () => context.read<SignupBloc>().add(
                    const ToggleSignupPasswordVisibility(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password
                PasswordTextField(
                  label: 'Confirm Password',
                  controller: confirmPasswordController,
                  hintText: 'Re-enter your password',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPasswordVisible: state.isConfirmPasswordVisible,
                  onToggleVisibility: () => context.read<SignupBloc>().add(
                    const ToggleConfirmPasswordVisibility(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Error
                if (state.status == SignupStatus.failure &&
                    state.errorMessage.isNotEmpty)
                  _buildError(colorScheme, state.errorMessage),

                // Sign Up Button
                GradientButton(
                  buttonName: 'Create Account',
                  icon: Icons.person_add_alt_1_rounded,
                  isLoading: state.status == SignupStatus.loading,
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      context.read<SignupBloc>().add(
                        SignupSubmitted(
                          userName: userNameController.text.trim(),
                          firstName: firstNameController.text.trim(),
                          lastName: lastNameController.text.trim(),
                          email: emailController.text.trim(),
                          password: passwordController.text,
                          confirmPassword: confirmPasswordController.text,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Sign In link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: getRegularStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: .6),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'Sign In',
                        style: getBoldStyle(
                          fontSize: 13,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
}
