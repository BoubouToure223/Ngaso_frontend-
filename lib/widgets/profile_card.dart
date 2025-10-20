
import 'package:flutter/material.dart';

/// Une carte réutilisable pour afficher un choix de profil.
///
/// Cette carte affiche une icône, un titre et deux lignes de description.
/// Elle est interactive et exécute une fonction [onTap] lorsqu'elle est pressée.
class ProfileCard extends StatelessWidget {
  /// L'icône à afficher sur la carte.
  final IconData icon;
  /// Le titre de la carte.
  final String title;
  /// La première ligne de description.
  final String line1;
  /// La deuxième ligne de description.
  final String line2;
  /// La fonction à appeler lorsque la carte est pressée.
  final VoidCallback onTap;

  const ProfileCard({
    super.key,
    required this.icon,
    required this.title,
    required this.line1,
    required this.line2,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        // Applique un effet de "ripple" avec un bord arrondi.
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          width: 313,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            // Bordure de la carte.
            border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
          ),
          child: Row(
            children: [
              const SizedBox(width: 18),
              // Conteneur circulaire pour l'icône.
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, shape: BoxShape.circle),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              // Colonne pour le texte.
              SizedBox(
                width: 213,
                height: 64,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Titre.
                    SizedBox(
                      height: 24,
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Première ligne de description.
                    SizedBox(
                      height: 20,
                      child: Text(
                        line1,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Deuxième ligne de description.
                    SizedBox(
                      height: 20,
                      child: Text(
                        line2,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
