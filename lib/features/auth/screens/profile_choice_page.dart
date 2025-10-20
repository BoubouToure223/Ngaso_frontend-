import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/widgets/profile_card.dart';

/// Page où l'utilisateur choisit son type de profil (Novice ou Professionnel).
class ProfileChoicePage extends StatelessWidget {
  const ProfileChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Barre supérieure avec bouton de retour.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(), // Navigue vers la page précédente.
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 390),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Conteneur pour le titre et le paragraphe.
                        SizedBox(
                          width: 313,
                          child: Column(
                            children: [
                              // Titre de la page.
                              SizedBox(
                                height: 32,
                                child: Center(
                                  child: Text(
                                    'Choisissez votre profil',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Paragraphe de description.
                              SizedBox(
                                height: 48,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 23,
                                      child: Center(
                                        child: Text(
                                          'Sélectionnez le type de compte que',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    SizedBox(
                                      height: 23,
                                      child: Center(
                                        child: Text(
                                          'vous souhaitez créer',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 55),

                        // Conteneur pour les cartes de choix de profil.
                        SizedBox(
                          width: 313,
                          child: Column(
                            children: [
                              // Carte pour le profil Novice.
                              ProfileCard(
                                icon: Icons.home_outlined,
                                title: 'Novice',
                                line1: 'Je souhaite réaliser un projet',
                                line2: 'de construction',
                                onTap: () => context.push('/novice-signup'), // Navigue vers l'inscription Novice.
                              ),
                              const SizedBox(height: 16),
                              // Carte pour le profil Professionnel.
                              ProfileCard(
                                icon: Icons.shopping_bag_outlined,
                                title: 'Professionnel',
                                line1: 'Je propose des services dans',
                                line2: 'le domaine de la construction',
                                onTap: () => context.push('/pro-signup'), // Navigue vers l'inscription Professionnel.
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 118),

                        // Bouton de retour.
                        SizedBox(
                          width: 313,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back, size: 16),
                            label: const Text(
                              'Retour',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
