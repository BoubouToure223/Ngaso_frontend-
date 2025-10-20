
import 'package:flutter/material.dart';

/// Un écran individuel utilisé dans le carrousel d'onboarding.
///
/// Affiche une image, un titre et un sous-titre pour présenter une fonctionnalité
/// ou un concept de l'application.
class OnboardingScreen extends StatelessWidget {
  /// Le titre principal de l'écran.
  final String title;
  /// Le sous-titre descriptif.
  final String subtitle;
  /// Le chemin vers l'image à afficher.
  final String imagePath;
  /// Indique si c'est le dernier écran de l'onboarding.
  final bool isFinal;

  const OnboardingScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.isFinal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Conteneur de l'image avec une ombre portée.
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 380),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 40,
                    spreadRadius: -6,
                    offset: Offset(0, 22),
                  ),
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 12,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              // Permet d'appliquer le `borderRadius` à l'image.
              clipBehavior: Clip.antiAlias,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Titre de l'écran.
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Sous-titre de l'écran.
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
