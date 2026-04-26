import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:adnetwork/core/extensions/extension.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showToast({
  required BuildContext context,
  required String message,
  required ToastificationType toastificationType,
}) {
  toastification.dismissAll(delayForAnimation: false);
  toastification.show(
    context: context,
    title: Text(message, style: getMediumStyle(fontSize: 16)),
    pauseOnHover: true,
    progressBarTheme: const ProgressIndicatorThemeData(
      color: Colors.white,
      linearMinHeight: 1,
    ),
    type: toastificationType,
    borderSide: BorderSide(color: Colors.black12),
    showIcon: false,
    closeButton: ToastCloseButton(
      buttonBuilder: (context, onClose) {
        return const Icon(Icons.close);
      },
    ),
    style: ToastificationStyle.flat,
    alignment: Alignment.topRight,
    autoCloseDuration: const Duration(seconds: 2),

    margin: EdgeInsets.only(left: context.width(1) / 3),

    icon: const Icon(Icons.check, color: Colors.white),
  );
}
