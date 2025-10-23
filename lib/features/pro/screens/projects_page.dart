import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProProjectsPage extends StatefulWidget {
  const ProProjectsPage({super.key});

  @override
  State<ProProjectsPage> createState() => _ProProjectsPageState();
}

class _ProProjectsPageState extends State<ProProjectsPage> {
  final TextEditingController _searchCtrl = TextEditingController();

  final List<_ProjectItem> _items = const [
    _ProjectItem(
      title: 'Construction de Batiment',
      location: 'ACI 2000',
      budget: '2 000 000 FCFA',
      dateText: 'Il y a 2 jours',
      author: 'Fatoumata Koné',
    ),
    _ProjectItem(
      title: 'Extension maison',
      location: 'Bamako, ACI',
      budget: '1 500 000 FCFA',
      dateText: 'Il y a 3 jours',
      author: 'Fatoumata Koné',
    ),
    _ProjectItem(
      title: 'Rénovation cuisine',
      location: 'Kalaban Coura',
      budget: '800 000 FCFA',
      dateText: 'Hier',
      author: 'Fatoumata Koné',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _filtered(_items, _searchCtrl.text);

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF7),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => context.go('/pro/home'),
        ),
        title: Text('Projets', style: theme.textTheme.titleLarge?.copyWith(color: const Color(0xFF0F172A), fontWeight: FontWeight.w600)),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un projet...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    icon: const Icon(Icons.tune, size: 18, color: Color(0xFF374151)),
                    label: const Text('Filtrer', style: TextStyle(color: Color(0xFF374151))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              const Expanded(
                child: _EmptyState(
                  emoji: '📂',
                  title: 'Aucun projet',
                  subtitle: 'Revenez plus tard ou modifiez votre recherche.',
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final it = items[index];
                    return _ProjectCard(item: it);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<_ProjectItem> _filtered(List<_ProjectItem> all, String q) {
    if (q.trim().isEmpty) return all;
    final lq = q.toLowerCase();
    return all
        .where((e) => e.title.toLowerCase().contains(lq) || e.location.toLowerCase().contains(lq) || e.author.toLowerCase().contains(lq))
        .toList(growable: false);
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.item});
  final _ProjectItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.place_outlined, size: 16, color: Color(0xFF0F172A)),
                  const SizedBox(width: 6),
                  Flexible(child: Text(item.location, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF0F172A)), overflow: TextOverflow.ellipsis)),
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
                      Text(item.budget, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: const Color(0xFF0F172A))),
                    ],
                  ),
                  Text(item.dateText, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B))),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/pro/proposition-create'),
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('Faire une proposition'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.badge_outlined, size: 16, color: Color(0xFF0F172A)),
                  const SizedBox(width: 6),
                  Text(item.author, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4B5563))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectItem {
  const _ProjectItem({required this.title, required this.location, required this.budget, required this.dateText, required this.author});
  final String title;
  final String location;
  final String budget;
  final String dateText;
  final String author;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.emoji, required this.title, required this.subtitle});
  final String emoji;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B))),
        ],
      ),
    );
  }
}
