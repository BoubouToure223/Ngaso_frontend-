import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/services/pro_api_service.dart';
import 'package:myapp/core/network/api_config.dart';
import 'package:myapp/core/storage/token_storage.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:myapp/core/state/badge_counters.dart';

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
  StompClient? _stomp;
  int _totalUnread = 0;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
    _connectRealtime();
    _refreshUnreadTotal();
    // Also refresh global badge counter for messages on first open
    BadgeCounters.instance.refreshMessagesTotal();
  }

  @override
  void dispose() {
    _stomp?.deactivate();
    super.dispose();
  }

  Future<void> _fetchConversations() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.getMyConversations();
      if (!mounted) return;
      final items = data.map<_Conversation>((e) {
        final m = e as Map;
        final id = (m['id'] as num?)?.toInt() ?? 0;
        final propositionId = (m['propositionId'] is num)
            ? (m['propositionId'] as num).toInt()
            : (m['propositionId'] is String ? int.tryParse(m['propositionId']) : null);
        final rawLast = (m['lastMessage'] as String?) ?? '';
        final trimmed = rawLast.trim();
        // Si le backend renvoie '_' pour une pièce jointe, on affiche un libellé.
        // Si c'est vraiment vide, on laisse vide pour ne rien afficher.
        final last = trimmed == '_' ? '[Pièce jointe]' : rawLast;
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
        // Afficher le nom du contact (professionnel) et non celui du novice
        String displayName = '';
        // 1) Champs explicites du professionnel
        String? proNom = (m['professionnelNom'] ?? m['proNom'] ?? m['professionnelLastName'] ?? m['proLastName'])?.toString();
        String? proPrenom = (m['professionnelPrenom'] ?? m['proPrenom'] ?? m['professionnelFirstName'] ?? m['proFirstName'])?.toString();
        // 2) Objet imbriqué professionnel/pro
        final prof = m['professionnel'] ?? m['pro'] ?? m['Pro'];
        if ((proNom == null || proNom.trim().isEmpty) || (proPrenom == null || proPrenom.trim().isEmpty)) {
          if (prof is Map) {
            proNom = (prof['nom'] ?? prof['lastName'] ?? prof['lastname'])?.toString() ?? proNom;
            proPrenom = (prof['prenom'] ?? prof['firstName'] ?? prof['firstname'])?.toString() ?? proPrenom;
          }
        }
        // 3) Rôles: destinataire/expediteur pouvant indiquer le pro
        if ((proNom == null || proNom.trim().isEmpty) || (proPrenom == null || proPrenom.trim().isEmpty)) {
          final destRole = (m['destinataireRole'] ?? m['recipientRole'] ?? '').toString().toUpperCase();
          if (destRole == 'PROFESSIONNEL' || destRole == 'PRO') {
            final dn = (m['destinataireNom'] ?? m['recipientLastName'] ?? m['recipientName'])?.toString();
            final dp = (m['destinatairePrenom'] ?? m['recipientFirstName'])?.toString();
            if ((dp ?? '').trim().isNotEmpty) proPrenom = dp;
            if ((dn ?? '').trim().isNotEmpty) proNom = dn;
          }
          final expRole = (m['expediteurRole'] ?? m['senderRole'] ?? '').toString().toUpperCase();
          if ((proNom == null || proNom.trim().isEmpty) || (proPrenom == null || proPrenom.trim().isEmpty)) {
            if (expRole == 'PROFESSIONNEL' || expRole == 'PRO') {
              final en = (m['expediteurNom'] ?? m['senderLastName'] ?? m['senderName'])?.toString();
              final ep = (m['expediteurPrenom'] ?? m['senderFirstName'])?.toString();
              if ((ep ?? '').trim().isNotEmpty) proPrenom = ep;
              if ((en ?? '').trim().isNotEmpty) proNom = en;
            }
          }
        }
        if (proPrenom != null && proPrenom.trim().isNotEmpty) displayName = proPrenom.trim();
        if (proNom != null && proNom.trim().isNotEmpty) {
          displayName = displayName.isEmpty ? proNom.trim() : '$displayName ${proNom.trim()}';
        }
        // 4) Fallbacks génériques pour un nom de contact
        if (displayName.isEmpty) {
          final contactName = (m['contactName'] ?? m['interlocuteur'] ?? m['toName'] ?? m['with'] ?? m['name'])?.toString();
          if (contactName != null && contactName.trim().isNotEmpty) displayName = contactName.trim();
        }
        if (displayName.isEmpty) displayName = 'Conversation #$id';
        final initials = _computeInitials(displayName);
        final online = (m['active'] == true);
        final unread = (m['unread'] is num)
            ? (m['unread'] as num).toInt()
            : (m['unreadCount'] is num)
                ? (m['unreadCount'] as num).toInt()
                : (m['nbNonLu'] is num)
                    ? (m['nbNonLu'] as num).toInt()
                    : (m['nonLu'] is num)
                        ? (m['nonLu'] as num).toInt()
                        : 0;
        return _Conversation(
          conversationId: id,
          propositionId: propositionId,
          initials: initials,
          name: displayName,
          last: last.isNotEmpty ? last : '—',
          lastAt: lastAt,
          online: online,
          unread: unread,
        );
      }).toList(growable: false);
      if (!mounted) return;
      setState(() {
        _all
          ..clear()
          ..addAll(items);
      });
      await _refreshUnreadTotal();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refreshUnreadTotal() async {
    try {
      final t = await _api.getConversationsUnreadTotal();
      if (!mounted) return;
      setState(() {
        _totalUnread = t;
      });
    } catch (_) {}
  }

  void _connectRealtime() async {
    try {
      final origin = ApiConfig.baseOrigin; // e.g. http://10.0.2.2:8080
      final wsUrl = origin.replaceFirst('http', 'ws');
      final token = await TokenStorage.instance.readToken().catchError((_) => null);
      final headers = <String, String>{
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };
      _stomp = StompClient(
        config: StompConfig.SockJS(
          url: '$wsUrl/ws',
          onConnect: _onStompConnect,
          onWebSocketError: (e) {},
          onStompError: (f) {},
          onDisconnect: (f) {},
          stompConnectHeaders: headers,
          webSocketConnectHeaders: headers,
          heartbeatIncoming: const Duration(seconds: 0),
          heartbeatOutgoing: const Duration(seconds: 0),
        ),
      );
      _stomp!.activate();
    } catch (_) {}
  }

  void _onStompConnect(StompFrame f) {
    _stomp?.subscribe(
      destination: '/topic/conversations',
      callback: (frame) {
        try {
          final body = frame.body;
          if (body == null || body.isEmpty) return;
          final data = json.decode(body);
          if (data is Map) {
            _applyConversationEvent(data);
          }
        } catch (_) {}
      },
    );
  }

  void _applyConversationEvent(Map m) {
    final cid = (m['conversationId'] ?? m['id']) as int? ?? int.tryParse('${m['conversationId'] ?? m['id'] ?? ''}') ?? 0;
    if (cid == 0) return;
    String content = (m['content'] ?? m['contenu'] ?? '').toString();
    String attachmentUrl = (m['attachmentUrl'] ?? m['pieceJointe'] ?? m['attachment'] ?? m['url'] ?? m['fileUrl'] ?? '').toString();
    String fileName = (m['fileName'] ?? m['nomFichier'] ?? '').toString();
    if (attachmentUrl.isEmpty && m['attachment'] is Map) {
      final a = Map.from(m['attachment'] as Map);
      attachmentUrl = (a['url'] ?? a['link'] ?? a['href'] ?? '').toString();
      if (fileName.isEmpty) fileName = (a['name'] ?? a['fileName'] ?? a['nom'] ?? '').toString();
    }
    if (content.isEmpty && (attachmentUrl.isNotEmpty || fileName.isNotEmpty)) {
      final name = fileName.isNotEmpty
          ? fileName
          : (Uri.tryParse(attachmentUrl)?.pathSegments.isNotEmpty == true
              ? Uri.parse(attachmentUrl).pathSegments.last
              : 'Document');
      content = '[Document] $name';
    }
    // Si le backend renvoie '_' comme contenu pour une pièce jointe, afficher un libellé plus explicite.
    final trimmedContent = content.trim();
    if (trimmedContent == '_') {
      content = '[Pièce jointe]';
    }
    final sentAtRaw = m['sentAt'] ?? m['dateEnvoi'];
    DateTime dt;
    try {
      if (sentAtRaw is String) {
        dt = sentAtRaw.isNotEmpty ? DateTime.parse(sentAtRaw).toLocal() : DateTime.now();
      } else if (sentAtRaw is int) {
        dt = DateTime.fromMillisecondsSinceEpoch(sentAtRaw).toLocal();
      } else {
        dt = DateTime.now();
      }
    } catch (_) {
      dt = DateTime.now();
    }
    if (!mounted) return;
    setState(() {
      final idx = _all.indexWhere((c) => c.conversationId == cid);
      if (idx >= 0) {
        final old = _all[idx];
        _all[idx] = _Conversation(
          conversationId: old.conversationId,
          propositionId: old.propositionId,
          initials: old.initials,
          name: old.name,
          last: content.isNotEmpty ? content : old.last,
          lastAt: dt,
          online: old.online,
          unread: old.unread,
        );
      } else {
        _all.add(_Conversation(
          conversationId: cid,
          propositionId: null,
          initials: 'CN',
          name: 'Conversation #$cid',
          last: content.isNotEmpty ? content : '—',
          lastAt: dt,
          online: false,
          unread: 0,
        ));
      }
      _all.sort((a, b) => b.lastAt.compareTo(a.lastAt));
    });
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Messages',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF1C120D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_totalUnread > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3F51B5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _totalUnread > 99 ? '99+' : '$_totalUnread',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
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
                          setState(() => c.unread = 0);
                          await context.push('/Novice/chat', extra: {
                            'name': c.name,
                            'initials': c.initials,
                            'conversationId': c.conversationId,
                            if (c.propositionId != null) 'propositionId': c.propositionId,
                          });
                          if (mounted) {
                            await _fetchConversations();
                            await _refreshUnreadTotal();
                          }
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
                      if (conv.unread > 0)
                        Container(
                          height: 18,
                          constraints: const BoxConstraints(minWidth: 18),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3F51B5),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            conv.unread > 99 ? '99+' : '${conv.unread}',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
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
    this.unread = 0,
  });
  final int conversationId;
  final int? propositionId;
  final String initials;
  final String name;
  final String last;
  final DateTime lastAt;
  final bool online;
  int unread;
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
