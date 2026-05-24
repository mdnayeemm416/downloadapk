
import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommonTextField extends StatelessWidget {
  final String? label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final double? height;
  final String hintText;
  final int? maxlines;
  final int? maxLength;
  final IconData? prefixIcon;
  final bool? digitOnly;
  final bool? readonly;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;
  final bool isPassword;

  const CommonTextField({
    super.key,
    this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    required this.hintText,
    this.maxlines,
    this.maxLength,
    this.prefixIcon,
    this.height,
    this.readonly,
    this.validator,
    this.digitOnly,
    this.autofillHints,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        (label != null)
            ? Text(
                label ?? "",
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : SizedBox.shrink(),
        const SizedBox(height: 5),
        Container(
          height: height,
          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1.0,
            ),
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (prefixIcon != null)
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                      child: Icon(
                        prefixIcon,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    )
                  : Container(),
              Expanded(
                child: TextFormField(
                  readOnly: readonly ?? false,
                  maxLines: maxlines ?? 1,
                  maxLength: maxLength,
                  controller: controller,
                  inputFormatters: digitOnly == true
                      ? [FilteringTextInputFormatter.digitsOnly]
                      : null,
                  keyboardType: keyboardType,
                  obscureText: isPassword,
                  autofillHints: autofillHints,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: getRegularStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 6,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: validator,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
