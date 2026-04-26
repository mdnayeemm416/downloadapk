import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:flutter/material.dart';

class PasswordTextField extends StatelessWidget {
  final String? label;
  final TextEditingController controller;
  final String hintText;
  final bool isPasswordVisible;
  final VoidCallback onToggleVisibility;
  final FormFieldValidator<String>? validator;
  final IconData? prefixIcon;
  final Iterable<String>? autofillHints;

  const PasswordTextField({
    super.key,
    this.label,
    required this.controller,
    required this.hintText,
    required this.isPasswordVisible,
    required this.onToggleVisibility,
    this.validator,
    this.prefixIcon,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: getMediumStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: .8),
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor, width: 1.0),
          ),
          child: Row(
            children: [
              if (prefixIcon != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                  child: Icon(
                    prefixIcon,
                    size: 20,
                    color: colorScheme.onSurface.withValues(alpha: .6),
                  ),
                ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  obscureText: !isPasswordVisible,
                  keyboardType: TextInputType.visiblePassword,
                  autofillHints: autofillHints,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: getRegularStyle(
                      color: colorScheme.onSurface.withValues(alpha: .4),
                    ),
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                    focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                    errorBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                    focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  validator: validator,
                ),
              ),
              GestureDetector(
                onTap: onToggleVisibility,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      isPasswordVisible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      key: ValueKey<bool>(isPasswordVisible),
                      size: 20,
                      color: colorScheme.onSurface.withValues(alpha: .5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
