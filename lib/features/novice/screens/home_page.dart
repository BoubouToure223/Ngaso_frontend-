import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoviceHomePage extends StatelessWidget {
  const NoviceHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar: app logo (left) and notification (right)
                  Row(
                    children: [
                      // App logo placeholder
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/Mini logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.notifications_none),
                        color: const Color(0xFF1C120D),
                        onPressed: () {
                          context.go('/app/notifications');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bienvenue Amadou 👋',
                    style: theme.textTheme.titleLarge?.copyWith(color: const Color(0xFF2C3E50)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Voici un aperçu de votre activité aujourd'hui.",
                    style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF333333)),
                  ),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // KPI Cards
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => context.go('/app/proposition-details'),
                              child: _StatCard(
                                emoji: '📬',
                                title: 'Propositions',
                                value: '7',
                                subtitle: '5 en attente, 2 validées',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            emoji: '🧾',
                            title: 'Demande de service',
                            value: '3',
                            subtitle: 'Envoyés',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => context.go('/app/messages'),
                              child: _StatCard(
                                emoji: '💬',
                                title: 'Messages',
                                value: '5',
                                subtitle: '3 non lus',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Projets disponibles header
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Projets disponibles 🔥',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            context.go('/app/projet');
                          },
                          icon: const Icon(Icons.chevron_right, size: 18),
                          label: const Text('Voir tout'),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Project cards
                    _ProjectCard(
                      title: 'Construction de Bâtiment',
                      location: 'ACI 2000',
                      budget: '2 0000000 fcfa',
                      dateText: 'Il y a 2 jours',
                      onPropose: () { context.push('/app/proposition-create'); },
                      onTap: () { context.push('/app/proposition-create'); },
                      primary: const Color(0xFF3F51B5),
                    ),
                    const SizedBox(height: 12),
                    _ProjectCard(
                      title: 'Construction de Bâtiment',
                      location: 'ACI 2000',
                      budget: '2 0000000 fcfa',
                      dateText: 'Il y a 2 jours',
                      onPropose: () { context.push('/app/proposition-create'); },
                      onTap: () { context.push('/app/proposition-create'); },
                      primary: const Color(0xFF3F51B5),
                    ),
                    const SizedBox(height: 12),
                    _ProjectCard(
                      title: 'Construction de Bâtiment',
                      location: 'ACI 2000',
                      budget: '2 0000000 fcfa',
                      dateText: 'Il y a 2 jours',
                      onPropose: () { context.push('/app/proposition-create'); },
                      onTap: () { context.push('/app/proposition-create'); },
                      primary: const Color(0xFF3F51B5),
                    ),
                    const SizedBox(height: 20),
                    // Réalisations
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Vos réalisations',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF2C3E50)),
                          ),
                        ),
                        TextButton(onPressed: () {}, child: const Text('Voir tout')),
                      ],
                    ),
                    SizedBox(
                      height: 140,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final path in const [
                              'assets/images/onboarding_1.png',
                              'assets/images/onboarding_2.png',
                              'assets/images/onboarding_3.png',
                            ])
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 200,
                                    height: 140,
                                    color: Colors.white,
                                    child: Image.asset(
                                      path,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) {
                                        return Container(
                                          color: const Color(0xFFF5F5F5),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Image manquante',
                                            style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FloatingActionButton(
                        onPressed: () {},
                        backgroundColor: const Color(0xFF3F51B5),
                        mini: true,
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.emoji, required this.title, required this.value, required this.subtitle});
  final String emoji;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 106),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 33,
            height: 32,
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: const Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.title,
    required this.location,
    required this.budget,
    required this.dateText,
    required this.onPropose,
    required this.primary,
    this.onTap,
  });

  final String title;
  final String location;
  final String budget;
  final String dateText;
  final VoidCallback onPropose;
  final Color primary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 16, color: Color(0xFF0F172A)),
                const SizedBox(width: 6),
                Text(location, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF0F172A))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 16, color: Color(0xFF0F172A)),
                    const SizedBox(width: 4),
                    Text(budget, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: const Color(0xFF0F172A))),
                  ],
                ),
                Text(dateText, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B))),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPropose,
                icon: const Icon(Icons.send, size: 16),
                label: const Text('Faire une proposition'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
