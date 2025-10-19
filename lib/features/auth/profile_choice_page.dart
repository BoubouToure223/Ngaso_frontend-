import 'package:flutter/material.dart';

class ProfileChoicePage extends StatelessWidget {
  const ProfileChoicePage({super.key});

  static const Color background = Color(0xFFFCFAF7);
  static const Color headingColor = Color(0xFF333333);
  static const Color bodyColor = Color(0xFF5C5C5C);
  static const Color primaryColor = Color(0xFF3F51B5);
  static const Color borderColor = Color(0xFFC2C2C2);
  static const Color badgeBg = Color(0xFFDEDEFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // top back icon (depth-frame)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: const Color(0xFF171212),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 390),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 68), // ~margin-top: 92 with previous padding
                        // Heading + paragraph container width 313
                        SizedBox(
                          width: 313,
                          child: Column(
                            children: [
                              // heading
                              SizedBox(
                                height: 32,
                                child: Center(
                                  child: Text(
                                    'Choisissez votre profil',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: headingColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20.4,
                                          height: 32 / 20.4,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // paragraph 2 lines
                              SizedBox(
                                height: 48,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 23,
                                      child: Center(
                                        child: Text(
                                          'Sélectionnez le type de compte que',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: bodyColor,
                                                fontSize: 13.6,
                                                height: 24 / 13.6,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    SizedBox(
                                      height: 23,
                                      child: Center(
                                        child: Text(
                                          'vous souhaitez créer',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: bodyColor,
                                                fontSize: 13.6,
                                                height: 24 / 13.6,
                                              ),
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

                        // Cards container width 313
                        SizedBox(
                          width: 313,
                          child: Column(
                            children: [
                              _ProfileCard(
                                icon: Icons.home_outlined,
                                title: 'Novice',
                                line1: 'Je souhaite réaliser un projet',
                                line2: 'de construction',
                                onTap: () {
                                  // TODO: route to novice sign up
                                },
                              ),
                              const SizedBox(height: 16),
                              _ProfileCard(
                                icon: Icons.shopping_bag_outlined,
                                title: 'Professionnel',
                                line1: 'Je propose des services dans',
                                line2: 'le domaine de la construction',
                                onTap: () {
                                  // TODO: route to pro sign up
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 118),

                        // Retour outlined button width 313, height 52
                        SizedBox(
                          width: 313,
                          height: 52,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: primaryColor, width: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              foregroundColor: primaryColor,
                            ),
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back, size: 16),
                            label: const Text(
                              'Retour',
                              style: TextStyle(fontSize: 13.6, fontWeight: FontWeight.w500),
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

class _ProfileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String line1;
  final String line2;
  final VoidCallback onTap;

  const _ProfileCard({
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
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          width: 313,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ProfileChoicePage.borderColor, width: 2),
          ),
          child: Row(
            children: [
              const SizedBox(width: 18),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(color: ProfileChoicePage.badgeBg, shape: BoxShape.circle),
                child: Icon(icon, color: ProfileChoicePage.primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 213,
                height: 64,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 24,
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: ProfileChoicePage.headingColor,
                          fontSize: 13.6,
                          fontWeight: FontWeight.w500,
                          height: 24 / 13.6,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      child: Text(
                        line1,
                        style: const TextStyle(
                          color: ProfileChoicePage.bodyColor,
                          fontSize: 11.9,
                          height: 20 / 11.9,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      child: Text(
                        line2,
                        style: const TextStyle(
                          color: ProfileChoicePage.bodyColor,
                          fontSize: 11.9,
                          height: 20 / 11.9,
                        ),
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
