import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:adnetwork/layers/data/repo/remote/user_repository.dart';
import 'package:adnetwork/layers/presentation/widget/common_text_field.dart';
import 'package:adnetwork/layers/presentation/widget/gradient_button.dart';
import 'package:adnetwork/layers/presentation/widget/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    final currentPassword = _currentPasswordCtrl.text.trim();
    final newPassword = _newPasswordCtrl.text.trim();
    final confirmPassword = _confirmPasswordCtrl.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      showToast(
        context: context,
        message: 'Please fill in all fields',
        toastificationType: ToastificationType.warning,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      showToast(
        context: context,
        message: 'New password and confirm password do not match',
        toastificationType: ToastificationType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userRepo = context.read<UserRepository>();
      final response = await userRepo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (!mounted) return;

      if (response.success == true) {
        showToast(
          context: context,
          message: 'Password updated successfully',
          toastificationType: ToastificationType.success,
        );
        Navigator.pop(context);
      } else {
        showToast(
          context: context,
          message: response.message ?? 'Failed to update password',
          toastificationType: ToastificationType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        showToast(
          context: context,
          message: e.toString(),
          toastificationType: ToastificationType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Your Password',
                style: getBoldStyle(fontSize: 22, color: cs.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Please enter your current password and your new password below.',
                style: getRegularStyle(
                  fontSize: 14,
                  color: cs.onSurface.withValues(alpha: .6),
                ),
              ),
              const SizedBox(height: 32),

              CommonTextField(
                label: 'Current Password',
                controller: _currentPasswordCtrl,

                isPassword: true,
                hintText: 'Enter current password',
                prefixIcon: Icons.lock_outline_rounded,
              ),
              const SizedBox(height: 20),

              CommonTextField(
                label: 'New Password',
                controller: _newPasswordCtrl,
                isPassword: true,
                hintText: 'Enter new password',
                prefixIcon: Icons.lock_outline_rounded,
              ),
              const SizedBox(height: 20),

              CommonTextField(
                label: 'Confirm New Password',
                controller: _confirmPasswordCtrl,
                isPassword: true,
                hintText: 'Confirm new password',
                prefixIcon: Icons.lock_outline_rounded,
              ),

              const SizedBox(height: 40),
              GradientButton(
                buttonName: 'Update Password',
                isLoading: _isLoading,
                onPressed: _handleChangePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
