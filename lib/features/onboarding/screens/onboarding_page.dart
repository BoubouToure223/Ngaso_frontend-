
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/onboarding/screens/onboarding_screen.dart';

/// La page d'onboarding qui guide l'utilisateur à travers les fonctionnalités de l'application.
///
/// Cette page utilise un [PageView] pour afficher une série d'[OnboardingScreen].
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // Contrôleur pour le PageView, permettant de naviguer entre les écrans.
  final PageController _controller = PageController();
  // Index de la page actuellement affichée.
  int _index = 0;

  /// Passe à l'écran d'onboarding suivant ou navigue vers la page de connexion
  /// si c'est le dernier écran.
  void _next() {
    if (_index < 2) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      // Si c'est le dernier écran, redirige vers la page de connexion.
      context.push('/connexion');
    }
  }

  /// Permet à l'utilisateur de passer l'onboarding et d'aller directement à la connexion.
  void _skip() {
    context.push('/connexion');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Permet au corps du Scaffold de s'étendre derrière la barre d'applications.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        // Masque le bouton de retour par défaut.
        automaticallyImplyLeading: false,
        actions: [
          // Affiche le bouton "Passer" sauf sur le dernier écran.
          if (_index < 2)
            TextButton(
              onPressed: _skip,
              child: const Text('Passer'),
            ),
        ],
      ),
      body: Container(
        // Arrière-plan de la page d'onboarding.
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/onboarding_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
        children: [
          Expanded(
            // PageView pour faire défiler les écrans d'onboarding.
            child: PageView(
              controller: _controller,
              // Met à jour l'index lorsque la page change.
              onPageChanged: (i) => setState(() => _index = i),
              children: const [
                // Premier écran d'onboarding.
                OnboardingScreen(
                  title: 'Bienvenue sur N’Gaso',
                  subtitle: 'Votre projet de construction\ncommence ici.',
                  imagePath: 'assets/images/onboarding_1.png',
                ),
                // Deuxième écran d'onboarding.
                OnboardingScreen(
                  title: 'Trouvez les meilleurs partenaires 👷',
                  subtitle: 'Contactez directement des experts\npour concrétiser votre projet.',
                  imagePath: 'assets/images/onboarding_2.png',
                ),
                // Troisième et dernier écran d'onboarding.
                OnboardingScreen(
                  title: 'Commencez dès aujourd\'hui 🚀',
                  subtitle: 'Créez un compte ou connectez-vous\npour démarrer votre projet.',
                  imagePath: 'assets/images/onboarding_3.png',
                  isFinal: true,
                ),
              ],
            ),
          ),
          // Indicateur de page (les points en bas).
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // Génère les points indicateurs.
              children: List.generate(3, (i) {
                final selected = i == _index;
                // Conteneur animé qui change de taille et de couleur pour la page sélectionnée.
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: selected ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          // Affiche le bouton "Suivant" pour les deux premiers écrans.
          if (_index < 2)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: const Text('Suivant'),
                ),
              ),
            )
          // Affiche les boutons "Créer un compte" et "Se connecter" sur le dernier écran.
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/profile-choice'),
                      child: const Text('Créer un compte'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.push('/connexion'),
                      child: const Text('Se connecter'),
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    ),
    );
  }
}
