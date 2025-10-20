
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/widgets/profile_card.dart';

class ProfileChoicePage extends StatelessWidget {
  const ProfileChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  onPressed: () => context.pop(),
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
                                    style: Theme.of(context).textTheme.titleLarge,
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

                        // Cards container width 313
                        SizedBox(
                          width: 313,
                          child: Column(
                            children: [
                              ProfileCard(
                                icon: Icons.home_outlined,
                                title: 'Novice',
                                line1: 'Je souhaite réaliser un projet',
                                line2: 'de construction',
                                onTap: () => context.go('/novice-signup'),
                              ),
                              const SizedBox(height: 16),
                              ProfileCard(
                                icon: Icons.shopping_bag_outlined,
                                title: 'Professionnel',
                                line1: 'Je propose des services dans',
                                line2: 'le domaine de la construction',
                                onTap: () => context.go('/pro-signup'),
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
