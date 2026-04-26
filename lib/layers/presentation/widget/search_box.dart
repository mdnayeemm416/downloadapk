import 'package:adnetwork/config/theme/app_colors.dart';
import 'package:adnetwork/core/extensions/extension.dart';
import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final void Function()? onClear;
  final double? width;
  final double? height;
  final String? hintText;
  final bool? closeClearButton;
  final Color? searchBorderColor;
  const SearchBox({
    super.key,
    required this.controller,
    this.onChanged,
    this.closeClearButton = true,
    this.onClear,
    this.width,
    this.height,
    this.hintText,
    this.searchBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData currentTheme = Theme.of(context);
    final bool isDarkMode = currentTheme.brightness == Brightness.dark;
    return Container(
      height: height ?? context.height(.04),
      constraints: BoxConstraints(maxWidth: width ?? double.infinity),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        border: Border.all(
          color:
              searchBorderColor ??
              (!isDarkMode
                  ? Color.fromARGB(255, 233, 233, 233)
                  : Color.fromARGB(255, 99, 99, 99)),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(05),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: !isDarkMode ? Colors.black54 : AppColors.cream,
            size: 20,
          ),
          Expanded(
            child: TextField(
              cursorHeight: 13,
              controller: controller,
              onChanged: onChanged,

              cursorColor: !isDarkMode ? Colors.black : AppColors.cream,
              style: TextStyle(
                color: !isDarkMode ? Colors.black : AppColors.cream,
                fontSize: 15,
                fontWeight: FontWeight.w300,
              ),
              decoration: InputDecoration(
                suffixIcon:
                    (controller.text.isNotEmpty && (closeClearButton == true))
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 18, color: AppColors.red),
                        onPressed: () {
                          controller.clear();
                          onClear?.call();
                        },
                      )
                    : null,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                hintText: hintText ?? "Search..",
                hintStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  color: !isDarkMode ? Colors.black : AppColors.cream,
                ),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
