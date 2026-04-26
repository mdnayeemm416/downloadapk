import 'package:adnetwork/config/theme/app_colors.dart';
import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final Function()? onpressed;
  final String? imagePath;
  final IconData? icon;
  final Color? iconColor;
  final Color? btnColor;
  final String buttonName;
  const CommonButton({
    super.key,
    this.onpressed,
    this.imagePath,
    required this.buttonName,
    this.icon,
    this.iconColor,
    this.btnColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onpressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: (onpressed != null)
            ? btnColor ?? AppColors.primaryColor
            : AppColors.btnDarkBlue,
        foregroundColor: AppColors.cream,
        shadowColor: Colors.black26,
        elevation: 4,
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (imagePath != null)
              ? Image.asset(imagePath ?? "", height: 20, color: AppColors.cream)
              : Icon(icon, size: 20, color: iconColor ?? AppColors.cream),
          SizedBox(width: 05),
          Text(buttonName, style: getBoldStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
