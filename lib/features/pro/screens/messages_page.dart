import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProMessagesPage extends StatefulWidget {
  const ProMessagesPage({super.key});

  @override
  State<ProMessagesPage> createState() => _ProMessagesPageState();
}

class _ProMessagesPageState extends State<ProMessagesPage> {
  final TextEditingController _searchCtrl = TextEditingController();

  late final List<_Conversation> _all = [
    _Conversation(
      initials: 'AB',
      name: 'Amadou Bakayoko',
      last: 'Je peux passer demain pour voir le chantier.',
      lastAt: DateTime.now().subtract(const Duration(minutes: 5)),
      unread: 2,
      online: true,
    ),
    _Conversation(
      initials: 'EB',
      name: 'Entreprise BTP Mali',
      last: "Nous avons reçu votre devis et nous allons l'étudier.",
      lastAt: DateTime.now().subtract(const Duration(hours: 20)),
      unread: 0,
    ),
    _Conversation(
      initials: 'FK',
      name: 'Fatoumata Koné',
      last: 'Merci pour votre disponibilité. À bientôt !',
      lastAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      unread: 1,
    ),
    _Conversation(
      initials: 'MD',
      name: 'Mariam Diallo',
      last: 'Je voudrais savoir si vous êtes disponible la semaine prochaine pour finir les travaux.',
      lastAt: DateTime.now().subtract(const Duration(days: 2)),
      unread: 0,
    ),
    _Conversation(
      initials: 'SC',
      name: 'Société de Carrelage',
      last: 'Nous avons bien reçu votre paiement.',
      lastAt: DateTime.now().subtract(const Duration(days: 3)),
      unread: 3,
    ),
    _Conversation(
      initials: 'IT',
      name: 'Ibrahim Touré',
      last: 'Est-ce que vous pourriez me donner un devis pour la rénovation de ma salle de bain ?',
      lastAt: DateTime.now().subtract(const Duration(days: 5)),
      unread: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filter(_all, _searchCtrl.text)
      ..sort((a, b) => b.lastAt.compareTo(a.lastAt));
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF7),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => context.go('/pro/home'),
        ),
        title: Text('Messages 💬', style: theme.textTheme.titleLarge?.copyWith(color: const Color(0xFF0F172A), fontWeight: FontWeight.w600)),
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
                      hintText: 'Rechercher une conversation...',
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
              ],
            ),
            const SizedBox(height: 12),
            if (filtered.isEmpty)
              const Expanded(
                child: _EmptyState(
                  emoji: '💬',
                  title: 'Aucune conversation',
                  subtitle: 'Vous n\'avez pas encore de messages.',
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final conv = filtered[index];
                    return _ConversationTile(
                      conv: conv,
                      formatTime: _formatTime,
                      onTap: () => _openConversation(conv),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<_Conversation> _filter(List<_Conversation> all, String q) {
    if (q.trim().isEmpty) return all;
    final lq = q.toLowerCase();
    return all
        .where((c) => c.name.toLowerCase().contains(lq) || c.last.toLowerCase().contains(lq) || c.initials.toLowerCase().contains(lq))
        .toList(growable: false);
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(date).inDays;
    if (diff == 0) {
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
    if (diff == 1) return 'Hier';
    if (diff < 7) {
      const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return days[dt.weekday - 1];
    }
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    return '$dd/$mm';
  }

  Future<void> _openConversation(_Conversation conv) async {
    if (conv.unread > 0) {
      setState(() {
        conv.unread = 0;
      });
    }
    await context.push('/pro/chat', extra: {'name': conv.name, 'initials': conv.initials});
    setState(() {});
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conv, required this.formatTime, this.onTap});
  final _Conversation conv;
  final String Function(DateTime) formatTime;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFDDE3F5),
                  child: Text(conv.initials, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF3F51B5))),
                ),
                if (conv.online)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(width: 10, height: 10, decoration: BoxDecoration(color: const Color(0xFF7AD738), borderRadius: BorderRadius.circular(9999))),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(conv.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Text(formatTime(conv.lastAt), style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(conv.last, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      if (conv.unread > 0)
                        Container(
                          height: 18,
                          constraints: const BoxConstraints(minWidth: 18),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: const Color(0xFF3F51B5), borderRadius: BorderRadius.circular(9999)),
                          child: Text('${conv.unread}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Conversation {
  _Conversation({
    required this.initials,
    required this.name,
    required this.last,
    required this.lastAt,
    this.unread = 0,
    this.online = false,
  });
  final String initials;
  final String name;
  final String last;
  final DateTime lastAt;
  int unread;
  final bool online;
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
