import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/services/pro_api_service.dart';

/// Page Pro: liste des conversations et accès à la messagerie.
///
/// - Barre de recherche pour filtrer les conversations.
/// - Liste triée (récent d'abord) avec badge d'"non lu".
/// - Accès à la discussion via `ProChatPage`.
class ProMessagesPage extends StatefulWidget {
  const ProMessagesPage({super.key});

  @override
  State<ProMessagesPage> createState() => _ProMessagesPageState();
}

class _ProMessagesPageState extends State<ProMessagesPage> {
  /// Contrôleur pour la recherche.
  final TextEditingController _searchCtrl = TextEditingController();

  final ProApiService _api = ProApiService();
  final List<_Conversation> _all = <_Conversation>[];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.getMyConversations();
      final items = data.map<_Conversation>((e) {
        final m = e as Map;
        final id = (m['id'] as num?)?.toInt() ?? 0;
        final propositionId = (m['propositionId'] is num)
            ? (m['propositionId'] as num).toInt()
            : (m['propositionId'] is String ? int.tryParse(m['propositionId']) : null);
        final last = (m['lastMessage'] as String?) ?? '';
        final lastAtStr = (m['lastMessageAt'] as String?) ?? '';
        DateTime lastAt;
        try {
          lastAt = lastAtStr.isNotEmpty ? DateTime.parse(lastAtStr).toLocal() : DateTime.now();
        } catch (_) {
          lastAt = DateTime.now();
        }
        final noviceNom = (m['noviceNom'] ?? m['nom'] ?? m['lastname'] ?? m['lastName'])?.toString();
        final novicePrenom = (m['novicePrenom'] ?? m['prenom'] ?? m['firstname'] ?? m['firstName'])?.toString();
        String displayName = '';
        if (noviceNom != null && noviceNom.trim().isNotEmpty) displayName = noviceNom.trim();
        if (novicePrenom != null && novicePrenom.trim().isNotEmpty) {
          displayName = displayName.isEmpty ? novicePrenom.trim() : '$displayName ${novicePrenom.trim()}';
        }
        if (displayName.isEmpty) displayName = (m['name'] as String?)?.toString() ?? '';
        if (displayName.isEmpty) displayName = 'Conversation #$id';
        final initials = _computeInitials(displayName);
        final unread = 0;
        final online = (m['active'] == true);
        return _Conversation(
          conversationId: id,
          propositionId: propositionId,
          initials: initials,
          name: displayName,
          last: last.isNotEmpty ? last : '—',
          lastAt: lastAt,
          unread: unread,
          online: online,
        );
      }).toList(growable: false);
      setState(() {
        _all
          ..clear()
          ..addAll(items);
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filter(_all, _searchCtrl.text)
      ..sort((a, b) => b.lastAt.compareTo(a.lastAt));
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF7),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pro/home'),
        ),
        title: const Text('Messages 💬'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          children: [
            if (_loading) const LinearProgressIndicator(),
            if (_error != null) Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
            // Barre de recherche
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
            if (!_loading && filtered.isEmpty)
              // État vide (aucune conversation)
              const Expanded(
                child: _EmptyState(
                  emoji: '💬',
                  title: 'Aucune conversation',
                  subtitle: 'Vous n\'avez pas encore de messages.',
                ),
              )
            else
              // Liste des conversations
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

  /// Filtre la liste des conversations selon la requête [q].
  List<_Conversation> _filter(List<_Conversation> all, String q) {
    if (q.trim().isEmpty) return all;
    final lq = q.toLowerCase();
    return all
        .where((c) => c.name.toLowerCase().contains(lq) || c.last.toLowerCase().contains(lq) || c.initials.toLowerCase().contains(lq))
        .toList(growable: false);
  }

  /// Formate l'horodatage (aujourd'hui -> HH:mm, hier -> "Hier", <7j -> jour,
  /// sinon -> dd/mm).
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

  /// Ouvre la conversation sélectionnée dans la page de chat.
  Future<void> _openConversation(_Conversation conv) async {
    if (conv.unread > 0) {
      setState(() {
        conv.unread = 0;
      });
    }
    await context.push('/pro/chat', extra: {
      'name': conv.name,
      'initials': conv.initials,
      'conversationId': conv.conversationId,
      if (conv.propositionId != null) 'propositionId': conv.propositionId,
    });
    setState(() {});
  }
}

/// Tuile d'une conversation avec avatar, nom, dernier message et heure.
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
            // Avatar + statut en ligne
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
            // Colonne: nom + heure, puis dernier message + badge non lu
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

/// Modèle d'une conversation.
class _Conversation {
  _Conversation({
    required this.conversationId,
    this.propositionId,
    required this.initials,
    required this.name,
    required this.last,
    required this.lastAt,
    this.unread = 0,
    this.online = false,
  });
  final int conversationId;
  final int? propositionId;
  final String initials;
  final String name;
  final String last;
  final DateTime lastAt;
  int unread;
  final bool online;
}

String _computeInitials(String name) {
  final parts = name.trim().split(RegExp(r"\s+")).where((s) => s.isNotEmpty).toList();
  if (parts.isEmpty) return 'CN';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
}

/// État vide avec émoji, titre et sous-titre.
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
