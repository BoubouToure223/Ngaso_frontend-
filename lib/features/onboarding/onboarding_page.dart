import 'package:flutter/material.dart';
import '../auth/connexion_page.dart';
import '../auth/profile_choice_page.dart';

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
      Navigator.of(context).pop();
    }
  }

  void _skip() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF3F51B5); // Boutons principaux (#3F51B5)
    const Color headingColor = Color(0xFF1F2937); // Titres (#1F2937)
    const Color bodyColor = Color(0xFF4B5563); // Paragraphes (#4B5563)
    const Color indicatorActive = Color(0xFF2563EB); // Indicateur actif (#2563EB)
    const Color indicatorInactive = Color(0xFFE5E7EB); // Indicateur inactif (#E5E7EB)
    const Color skipColor = Color(0xFF6B7280); // Texte "Passer"

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          if (_index < 2)
            TextButton(
              onPressed: _skip,
              child: const Text('Passer'),
              style: TextButton.styleFrom(foregroundColor: skipColor),
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
                _OnboardingScreen(
                  title: 'Bienvenue sur N’Gaso',
                  subtitle: 'Votre projet de construction\ncommence ici.',
                  imagePath: 'assets/images/onboarding_1.png',
                ),
                _OnboardingScreen(
                  title: 'Trouvez les meilleurs partenaires 👷',
                  subtitle: 'Contactez directement des experts\npour concrétiser votre projet.',
                  imagePath: 'assets/images/onboarding_2.png',
                ),
                _OnboardingScreen(
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
                    color: selected ? indicatorActive : indicatorInactive,
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileChoicePage()),
                      ),
                      child: const Text('Créer un compte'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: headingColor,
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ConnexionPage()),
                      ),
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

class _OnboardingScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isFinal;
  const _OnboardingScreen({required this.title, required this.subtitle, required this.imagePath, this.isFinal = false});

  @override
  Widget build(BuildContext context) {
    const Color headingColor = Color(0xFF1F2937);
    const Color bodyColor = Color(0xFF4B5563);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: headingColor,
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: bodyColor, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
