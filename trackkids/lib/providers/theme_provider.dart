import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ThemeProvider extends ChangeNotifier {
  ProjectColors _currentPalette = ProjectColors.paletteOne;

  ThemeData get currentTheme => ThemeData(
    extensions: <ThemeExtension<dynamic>>[
      _currentPalette,
    ],
    // You can also map them to standard Material colors here
    primaryColor: _currentPalette.primary,
    scaffoldBackgroundColor: _currentPalette.background,
  );

  void updatePalette(ProjectColors newPalette) {
    _currentPalette = newPalette;
    notifyListeners();
  }
}