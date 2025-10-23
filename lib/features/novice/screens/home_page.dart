import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoviceHomePage extends StatelessWidget {
  const NoviceHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE7E3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(Icons.house_outlined, color: Color(0xFF6B4F4A)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bienvenue Mariam',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF1C120D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF1C120D)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Mon projet de construction',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF1C120D),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF2EAE8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: Image.asset(
                              'assets/images/project.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                color: const Color(0xFFEDE7E3),
                                child: const Icon(Icons.image_outlined, color: Color(0xFF6B4F4A)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Projet de construction',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF1C120D),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Étape actuelle: Fondation',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF6B4F4A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Prochaine étape: Élévation des murs',
                      style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B4F4A)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: 0.35,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFE9DFDC),
                              valueColor: const AlwaysStoppedAnimation(Color(0xFF5A67D8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5A67D8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            // TODO: remplacer par la page des étapes détaillées
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ouverture des étapes du projet…')));
                            // ignore: use_build_context_synchronously
                            context.go('/pro/projet');
                          },
                          child: const Text('Voir les étapes'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Accès rapide',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF1C120D),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickCard(
                      icon: Icons.home_outlined,
                      title: 'Mes projets',
                      onTap: () {
                        context.go('/pro/projet');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickCard(
                      icon: Icons.badge_outlined,
                      title: 'Guide permis',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guide permis bientôt disponible')));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _QuickCard(
                icon: Icons.add,
                title: 'Créer un projet de construction',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Création de projet bientôt disponible')));
                },
                dense: true,
              ),
              const SizedBox(height: 20),
              Text(
                'Comment ça marche',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF1C120D),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _StepItem(icon: Icons.add_box_outlined, title: 'Créez votre projet de construction'),
              _StepItem(icon: Icons.view_list_outlined, title: 'Suivez les étapes de votre projet'),
              _StepItem(icon: Icons.support_agent_outlined, title: 'Contactez un pro pour vous aider'),
              _StepItem(icon: Icons.fact_check_outlined, title: 'Validez chaque étape à votre rythme'),
              const SizedBox(height: 20),
              _TipCarousel(),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool dense;
  const _QuickCard({required this.icon, required this.title, required this.onTap, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF2EAE8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF5EFEC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF1C120D)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF1C120D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (!dense) const Icon(Icons.chevron_right_rounded, color: Color(0xFF6B4F4A)),
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final IconData icon;
  final String title;
  const _StepItem({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5EFEC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1C120D)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF1C120D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCarousel extends StatefulWidget {
  @override
  State<_TipCarousel> createState() => _TipCarouselState();
}

class _TipCarouselState extends State<_TipCarousel> {
  final controller = PageController();
  int index = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = List.generate(3, (i) => i);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: controller,
            onPageChanged: (i) => setState(() => index = i),
            itemCount: pages.length,
            itemBuilder: (context, i) {
              return Container(
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/tip.jpg'),
                    fit: BoxFit.cover,
                    onError: null,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Conseil du jour',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Permis de construire',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Avant de commencer la construction, assurez-vous d\'avoir tous les permis nécessaires et de bien comprendre les réglementations locales.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(pages.length, (i) {
            final active = i == index;
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: active ? const Color(0xFF1C120D) : const Color(0xFFD8CBC7),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }
}
