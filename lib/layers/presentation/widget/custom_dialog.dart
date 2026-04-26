import 'package:adnetwork/config/theme/app_colors.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  Widget child;
  double? contentPadding;
  Color? backgroundColor;
  ShapeBorder? shape;
  double? elevation;
  VoidCallback? onClosePressed;
  bool? showCloseButton;
  bool? barrierDismissible;

  CustomDialog({
    super.key,
    required this.child,
    this.contentPadding,
    this.backgroundColor,
    this.shape,
    this.elevation,
    this.onClosePressed,
    this.showCloseButton,
    this.barrierDismissible,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        /* detect press outside dialog */
        debugPrint("parent gesture");
        FocusScope.of(context).unfocus();
        if (showCloseButton != true && barrierDismissible != false)
          Navigator.of(context, rootNavigator: true).pop();
      },
      behavior: HitTestBehavior.opaque,
      child: DeferredPointerHandler(
        child: Dialog(
          elevation: elevation ?? 5,
          // backgroundColor: backgroundColor ?? AppColors.surfaceDark,
          shape:
              shape ??
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.passthrough,
            children: [
              GestureDetector(
                /* prevent parent gesture detect to propagate */
                onTap: () {
                  debugPrint("child gesture");
                  FocusScope.of(context).unfocus();
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.all(contentPadding ?? 20.0),
                  child: child,
                ),
              ),
              (showCloseButton == true)
                  ? Positioned(
                      top: -10,
                      right: -10,
                      child: DeferPointer(
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.red,
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () {
                              if (onClosePressed != null) {
                                onClosePressed!();
                              } else {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                              }
                            },
                            icon: Icon(
                              Icons.close,
                              size: 25,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
