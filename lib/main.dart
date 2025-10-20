
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/app.dart';
import 'package:myapp/core/theme/theme_provider.dart';

/// Point d'entrée principal de l'application.
void main() {
  // Exécute l'application en l'enveloppant avec un ChangeNotifierProvider.
  // Cela permet de fournir le ThemeProvider à l'ensemble de l'arborescence des widgets
  // pour la gestion du thème de l'application.
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}
