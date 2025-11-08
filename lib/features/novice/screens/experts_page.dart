import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoviceExpertsPage extends StatelessWidget {
  const NoviceExpertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _experts;
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
                  'Trouver un expert',
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
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemBuilder: (context, i) => _ExpertTile(data: items[i]),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemCount: items.length,
      ),
    );
  }
}

class _ExpertTile extends StatelessWidget {
  final _Expert data;
  const _ExpertTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFE7E3DF),
              child: const Icon(Icons.person, color: Color(0xFF6B4F4A)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF1C120D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    data.role,
                    style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B4F4A)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onPressed: () {
                context.push('/Novice/experts/detail');
              },
              child: const Text('Voir plus'),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Contacter ${data.name}')),
                );
              },
              child: const Text('Contacter'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Expert {
  final String name;
  final String role;
  const _Expert({required this.name, required this.role});
}

const _experts = <_Expert>[
  _Expert(name: 'Mamadou Traoré', role: 'Architecte'),
  _Expert(name: 'Issa Koné', role: 'Architecte'),
  _Expert(name: 'Bintou Samaké', role: 'Architecte'),
  _Expert(name: 'Abdoulaye Doumbo', role: 'Architecte'),
];
