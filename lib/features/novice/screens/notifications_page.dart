import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoviceNotificationsPage extends StatelessWidget {
  const NoviceNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = List.generate(
      5,
      (i) => _Notif(
        title: 'Nouveau message',
        body: 'Vous avez reçu un nouveau message\nde Issa Touré',
        time: '1h',
        icon: Icons.mail_outline,
      ),
    );

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
                    'Notifications',
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
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) => _NotifTile(data: items[i]),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final _Notif data;
  const _NotifTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF5EFEC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(data.icon, color: const Color(0xFF1C120D)),
        ),
        const SizedBox(width: 12),
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
                data.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B4F4A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          data.time,
          style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B4F4A)),
        ),
      ],
    );
  }
}

class _Notif {
  final String title;
  final String body;
  final String time;
  final IconData icon;
  const _Notif({required this.title, required this.body, required this.time, required this.icon});
}
