
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';

/// La page de démarrage (splash screen) de l'application.
///
/// Affiche le logo et le nom de l'application pendant un court instant,
/// puis redirige l'utilisateur vers la page d'onboarding.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // Timer pour contrôler la durée d'affichage du splash screen.
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Démarre un timer de 2 secondes.
    _timer = Timer(const Duration(seconds: 2), () {
      // Vérifie si le widget est toujours monté avant de naviguer.
      if (!mounted) return;
      // Redirige vers la page d'onboarding.
      context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    // Annule le timer si le widget est supprimé pour éviter les fuites de mémoire.
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 64),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Affiche le logo de l'application.
                    SizedBox(
                      height: 200,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Affiche le nom de l'application.
                    Text(
                      'N’gaSo',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
