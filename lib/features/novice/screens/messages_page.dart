import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/services/pro_api_service.dart';

class NoviceMessagesPage extends StatefulWidget {
  const NoviceMessagesPage({super.key});

  @override
  State<NoviceMessagesPage> createState() => _NoviceMessagesPageState();
}

class _NoviceMessagesPageState extends State<NoviceMessagesPage> {
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
        final lastAtRaw = m['lastMessageAt'];
        DateTime lastAt;
        try {
          if (lastAtRaw is String) {
            lastAt = lastAtRaw.isNotEmpty ? DateTime.parse(lastAtRaw).toLocal() : DateTime.now();
          } else if (lastAtRaw is int) {
            lastAt = DateTime.fromMillisecondsSinceEpoch(lastAtRaw).toLocal();
          } else {
            lastAt = DateTime.now();
          }
        } catch (_) {
          lastAt = DateTime.now();
        }
        final noviceNom = (m['noviceNom'] ?? m['nom'] ?? m['lastname'] ?? m['lastName'])?.toString();
        final novicePrenom = (m['novicePrenom'] ?? m['prenom'] ?? m['firstname'] ?? m['firstName'])?.toString();
        String displayName = '';
        if (novicePrenom != null && novicePrenom.trim().isNotEmpty) displayName = novicePrenom.trim();
        if (noviceNom != null && noviceNom.trim().isNotEmpty) {
          displayName = displayName.isEmpty ? noviceNom.trim() : '$displayName ${noviceNom.trim()}';
        }
        if (displayName.isEmpty) displayName = (m['name'] as String?)?.toString() ?? '';
        if (displayName.isEmpty) displayName = 'Conversation #$id';
        final initials = _computeInitials(displayName);
        final online = (m['active'] == true);
        return _Conversation(
          conversationId: id,
          propositionId: propositionId,
          initials: initials,
          name: displayName,
          last: last.isNotEmpty ? last : '—',
          lastAt: lastAt,
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
    return Container(
      color: const Color(0xFFFCFAF7),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Messages',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF1C120D),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (_loading) const LinearProgressIndicator(),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Rechercher une conversation...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF99604C),
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF99604C)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF2EAE8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5DBD7)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (!_loading && filtered.isEmpty)
                const Expanded(
                  child: Center(child: Text('Aucune conversation')),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final c = filtered[index];
                      return _ConversationTile(
                        conv: c,
                        onTap: () async {
                          await context.push('/Novice/chat', extra: {
                            'name': c.name,
                            'initials': c.initials,
                            'conversationId': c.conversationId,
                            if (c.propositionId != null) 'propositionId': c.propositionId,
                          });
                          if (mounted) setState(() {});
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
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

  String _computeInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '??';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conv, required this.onTap});
  final _Conversation conv;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFDDE3F5),
              child: Text(conv.initials, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF3F51B5))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF1C120D),
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(conv.lastAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B4F4A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          conv.last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF6B4F4A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (conv.online) const Icon(Icons.circle, size: 10, color: Color(0xFF2DD44D)),
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
}

class _Conversation {
  _Conversation({
    required this.conversationId,
    this.propositionId,
    required this.initials,
    required this.name,
    required this.last,
    required this.lastAt,
    this.online = false,
  });
  final int conversationId;
  final int? propositionId;
  final String initials;
  final String name;
  final String last;
  final DateTime lastAt;
  final bool online;
}

class _Avatar extends StatelessWidget {
  final String? initials;
  final String? imageUrl;
  const _Avatar({this.initials, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 48,
            height: 48,
            color: const Color(0xFFEAF2FF),
            child: hasImage
                ? Image.asset(imageUrl!, fit: BoxFit.cover)
                : Center(
                    child: Text(
                      (initials ?? '').toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF3F51B5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
