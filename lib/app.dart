
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/core/router/app_router.dart';
import 'package:myapp/core/theme/theme.dart';
import 'package:myapp/core/theme/theme_provider.dart';

/// Le widget racine de l'application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Le Consumer écoute les changements du ThemeProvider et reconstruit
    // le MaterialApp lorsque le thème change.
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'N’gaSo',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: router, // Utilise la configuration du routeur GoRouter
        );
      },
    );
  }
}
