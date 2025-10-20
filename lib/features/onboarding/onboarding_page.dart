
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/onboarding/onboarding_screen.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;

  void _next() {
    if (_index < 2) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      context.go('/');
    }
  }

  void _skip() {
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          if (_index < 2)
            TextButton(
              onPressed: _skip,
              child: const Text('Passer'),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/onboarding_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _index = i),
              children: const [
                OnboardingScreen(
                  title: 'Bienvenue sur N’Gaso',
                  subtitle: 'Votre projet de construction\ncommence ici.',
                  imagePath: 'assets/images/onboarding_1.png',
                ),
                OnboardingScreen(
                  title: 'Trouvez les meilleurs partenaires 👷',
                  subtitle: 'Contactez directement des experts\npour concrétiser votre projet.',
                  imagePath: 'assets/images/onboarding_2.png',
                ),
                OnboardingScreen(
                  title: 'Commencez dès aujourd\'hui 🚀',
                  subtitle: 'Créez un compte ou connectez-vous\npour démarrer votre projet.',
                  imagePath: 'assets/images/onboarding_3.png',
                  isFinal: true,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final selected = i == _index;
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
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/profile-choice'),
                      child: const Text('Créer un compte'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go('/connexion'),
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
