import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoviceMyProjectsPage extends StatelessWidget {
  const NoviceMyProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _mockProjects;
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1C120D)),
                ),
                Expanded(
                  child: Text(
                    'Mes Projets',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF1C120D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/Novice/project-create'),
                  icon: const Icon(Icons.add, color: Color(0xFF1C120D)),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, i) => _ProjectTile(data: items[i]),
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  final _Project data;
  const _ProjectTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF1C120D),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Budget: ${data.budget}',
                style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B4F4A)),
              ),
              Text(
                'Terrain: ${data.size}',
                style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B4F4A)),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Voir détails: ${data.title}')),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Voir détails'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFF0E5E1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.house_outlined, size: 36, color: Color(0xFF7A4C3A)),
        ),
      ],
    );
  }
}

class _Project {
  final String title;
  final String budget;
  final String size;
  const _Project({required this.title, required this.budget, required this.size});
}

const _mockProjects = <_Project>[
  _Project(title: 'Villa Moderne', budget: '15,000,000 CFA', size: '20×30m'),
  _Project(title: 'Maison Familiale', budget: '10,000,000 CFA', size: '15×25m'),
  _Project(title: 'Résidence de Luxe', budget: '25,000,000 CFA', size: '25×40m'),
];
