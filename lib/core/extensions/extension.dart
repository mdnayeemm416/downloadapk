import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

extension MediaQueryExtension on BuildContext {
  Size get size => mediaQuery.size;
  double height(double value) => mediaQuery.size.height * value;

  double width(double value) => mediaQuery.size.width * value;
}
