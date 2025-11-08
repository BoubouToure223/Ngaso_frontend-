import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoviceExpertDetailPage extends StatelessWidget {
  const NoviceExpertDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1C120D)),
              ),
              Expanded(
                child: Text(
                  "Détails de l'expert",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1C120D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  'assets/images/etape5_img.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Mamadou Traoré',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF1C120D),
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Architecte',
              style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B4F4A)),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Color(0xFF7C6EE6)),
                const SizedBox(width: 4),
                Text('4.5★', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF1C120D))),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Informations de contact',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF1C120D),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            _InfoRow(icon: Icons.phone, text: '+223 77 123 456'),
            _InfoRow(icon: Icons.location_on_outlined, text: 'Bamako, Mali'),
            _InfoRow(icon: Icons.apartment_outlined, text: 'Traoré Architecture'),
            const SizedBox(height: 16),
            Text(
              'À propos de cet expert',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF1C120D),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Mamadou Traoré est un architecte basé à Bamako, spécialisé dans la conception de résidences modernes et fonctionnelles. Avec plus de 10 ans d'expérience, il a réalisé de nombreux projets à travers le Mali, alliant esthétique et durabilité.",
              style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF1C120D)),
            ),
            const SizedBox(height: 16),
            Text(
              'Réalisations',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF1C120D),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _projects.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final p = _projects[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 200,
                          height: 120,
                          color: const Color(0xFFF0ECE9),
                          child: Image.asset(p.imageAsset, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 200,
                        child: Text(
                          p.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF1C120D)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F51B5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contacter cet expert')),
                      );
                    },
                    child: const Text('Contacter cet expert'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6B4F4A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF1C120D)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Project {
  final String title;
  final String imageAsset;
  const _Project({required this.title, required this.imageAsset});
}

const _projects = <_Project>[
  _Project(title: 'Projet 1', imageAsset: 'assets/images/etape5_img.png'),
  _Project(title: 'Projet 2', imageAsset: 'assets/images/etape4_img.png'),
  _Project(title: 'Projet 3', imageAsset: 'assets/images/etape3_img.png'),
];
