
import 'package:flutter/material.dart';

/// Le [ChangeNotifier] pour la gestion du thème de l'application.
class ThemeProvider with ChangeNotifier {
  // Le mode de thème actuel de l'application.
  ThemeMode _themeMode = ThemeMode.system;

  /// Le mode de thème actuel de l'application.
  ThemeMode get themeMode => _themeMode;

  /// Bascule entre les thèmes clair et sombre.
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notifie les écouteurs du changement de thème.
  }

  /// Rétablit le thème du système.
  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners(); // Notifie les écouteurs du changement de thème.
  }
}
