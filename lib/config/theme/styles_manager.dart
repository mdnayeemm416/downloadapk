import 'package:flutter/material.dart';

import '../font_manager.dart';

TextStyle _getTextStyle({required double fontSize, required FontWeight fontWeight, Color? color}) {
  return TextStyle(fontSize: fontSize, fontFamily: FontConstants.fontFamily, color: color, fontWeight: fontWeight);
}

// regular style
TextStyle getRegularStyle({double fontSize = FontSize.s14, Color? color}) {
  return _getTextStyle(fontSize: fontSize, fontWeight: FontWeightManager.regular, color: color);
}

// medium style
TextStyle getMediumStyle({double fontSize = FontSize.s16, Color? color}) {
  return _getTextStyle(fontSize: fontSize, fontWeight: FontWeightManager.medium, color: color);
}

// medium style
TextStyle getLightStyle({double fontSize = FontSize.s12,  Color? color}) {
  return _getTextStyle(fontSize: fontSize, fontWeight: FontWeightManager.light, color: color);
}

// bold style
TextStyle getBoldStyle({double fontSize = FontSize.s22, Color? color}) {
  return _getTextStyle(fontSize: fontSize, fontWeight: FontWeightManager.bold, color: color);
}

// semi bold style
TextStyle getSemiBoldStyle({double fontSize = FontSize.s18, Color? color}) {
  return _getTextStyle(fontSize: fontSize, fontWeight: FontWeightManager.semiBold, color: color);
}

ButtonStyle applyRoundedButton() {
  return ButtonStyle(
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: const BorderSide(color: Colors.red),
      ),
    ),
  );
}

ButtonStyle applyButtonRadius(double radius) {
  return ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius), // <-- Radius
    ),
  );
}

TextStyle getTitleStyle({double fontSize = 20}) {
  return _getTextStyle(fontSize: fontSize, fontWeight: FontWeightManager.bold);
}
