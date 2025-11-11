import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:myapp/core/data/services/pro_api_service.dart';
import 'package:myapp/core/network/api_config.dart';
import 'package:myapp/core/storage/token_storage.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class NoviceChatPage extends StatefulWidget {
  const NoviceChatPage({super.key});

  @override
  State<NoviceChatPage> createState() => _NoviceChatPageState();
}

class _NoviceChatPageState extends State<NoviceChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final ProApiService _api = ProApiService();
  List<_ChatMessage> _messages = <_ChatMessage>[];
  int? _conversationId;
  bool _initialized = false;
  StompClient? _stomp;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final state = GoRouterState.of(context);
    final extra = state.extra;
    if (extra is Map) {
      final cid = extra['conversationId'];
      if (cid is int) _conversationId = cid; else if (cid is String) _conversationId = int.tryParse(cid);
    }
    if (_conversationId != null) {
      _messages = <_ChatMessage>[];
      _fetchMessages();
      _connectRealtime();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _stomp?.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = GoRouterState.of(context);
    String? name;
    String? initials;
    String? imageUrl;
    bool online = false;
    final extra = state.extra;
    if (extra is Map) {
      name = extra['name'] as String?;
      initials = extra['initials'] as String?;
      imageUrl = extra['imageUrl'] as String?;
      online = (extra['online'] as bool?) ?? false;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SafeArea(
          bottom: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(color: Color(0xFFFCFAF7)),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1C120D)),
                ),
                _HeaderAvatar(initials: initials, imageUrl: imageUrl),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name ?? 'Discussion',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF1C120D),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        online ? 'En ligne' : 'Hors ligne',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B4F4A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                return _Bubble(message: m);
              },
            ),
          ),
          _Composer(
            controller: _controller,
            onAttach: _attach,
            onSend: () {
              final txt = _controller.text.trim();
              if (txt.isEmpty) return;
              if (_conversationId != null) {
                _sendViaApi(txt);
              } else {
                setState(() {
                  _messages.add(_ChatMessage(fromMe: true, text: txt, time: _nowLabel()));
                });
                _controller.clear();
                Future.delayed(const Duration(milliseconds: 100), () {
                  _scroll.animateTo(
                    _scroll.position.maxScrollExtent + 80,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
                });
              }
            },
          )
        ],
      ),
    );
  }

  String _nowLabel() {
    final now = TimeOfDay.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(now.hour)}:${two(now.minute)}';
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
    final cid = _conversationId;
    if (cid == null) return;
    _stomp?.subscribe(
      destination: '/topic/conversations/$cid',
      callback: (frame) {
        try {
          final body = frame.body;
          if (body == null || body.isEmpty) return;
          final data = json.decode(body);
          if (data is Map) {
            _appendIncoming(data);
          }
        } catch (_) {}
      },
    );
  }

  void _appendIncoming(Map m) {
    String content = (m['content'] ?? m['contenu'] ?? '').toString();
    final attachment = (m['attachmentUrl'] ?? m['pieceJointe'] ?? '').toString();
    if (content.isEmpty && attachment.isNotEmpty) {
      final name = Uri.parse(attachment).pathSegments.isNotEmpty ? Uri.parse(attachment).pathSegments.last : 'Document';
      content = '[Document] $name';
    }
    final senderRole = (m['senderRole'] ?? m['role'] ?? '').toString().toUpperCase();
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
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final me = senderRole == 'NOVICE';
    if (!mounted) return;
    setState(() {
      _messages = List<_ChatMessage>.from(_messages)..add(_ChatMessage(text: content, fromMe: me, time: '$hh:$mm'));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _fetchMessages() async {
    try {
      final id = _conversationId!;
      final data = await _api.getConversationMessages(conversationId: id, page: 0, size: 20);
      // API renvoie du plus récent au plus ancien; on inverse pour affichage chronologique
      final items = data.reversed.map<_ChatMessage>((e) {
        final m = e as Map;
        String content = (m['content'] ?? m['contenu'] ?? '').toString();
        final attachment = (m['attachmentUrl'] ?? m['pieceJointe'] ?? '').toString();
        if (content.isEmpty && attachment.isNotEmpty) {
          final name = Uri.parse(attachment).pathSegments.isNotEmpty ? Uri.parse(attachment).pathSegments.last : 'Document';
          content = '[Document] $name';
        }
        final senderRole = (m['senderRole'] ?? m['role'] ?? '').toString().toUpperCase();
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
        final hh = dt.hour.toString().padLeft(2, '0');
        final mm = dt.minute.toString().padLeft(2, '0');
        final me = senderRole == 'NOVICE';
        return _ChatMessage(text: content, fromMe: me, time: '$hh:$mm');
      }).toList();
      if (!mounted) return;
      setState(() {
        _messages = items;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.jumpTo(_scroll.position.maxScrollExtent);
        }
      });
    } catch (_) {
      // ignore for now
    }
  }

  Future<void> _sendViaApi(String txt) async {
    try {
      final id = _conversationId!;
      final res = await _api.sendConversationMessage(conversationId: id, content: txt);
      final content = (res['content'] ?? res['contenu'] ?? '').toString();
      final sentAtStr = (res['sentAt'] ?? res['dateEnvoi'] ?? '').toString();
      DateTime dt;
      try {
        dt = sentAtStr.isNotEmpty ? DateTime.parse(sentAtStr).toLocal() : DateTime.now();
      } catch (_) {
        dt = DateTime.now();
      }
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      if (!mounted) return;
      setState(() {
        _messages = List<_ChatMessage>.from(_messages)..add(_ChatMessage(text: content.isEmpty ? txt : content, fromMe: true, time: '$hh:$mm'));
      });
      _controller.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent + 80,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (_) {
      if (!mounted) return;
      // fallback local
      final now = TimeOfDay.now();
      final hh = now.hour.toString().padLeft(2, '0');
      final mm = now.minute.toString().padLeft(2, '0');
      setState(() {
        _messages = List<_ChatMessage>.from(_messages)..add(_ChatMessage(text: txt, fromMe: true, time: '$hh:$mm'));
      });
      _controller.clear();
    }
  }

  Future<void> _attach() async {
    try {
      final res = await FilePicker.platform.pickFiles(allowMultiple: false);
      if (res == null || res.files.isEmpty) return;
      final file = res.files.first;
      final name = file.name;
      if (_conversationId != null && (file.path ?? '').isNotEmpty) {
        try {
          final resp = await _api.sendConversationAttachment(
            conversationId: _conversationId!,
            filePath: file.path!,
            fileName: name,
          );
          final content = (resp['content'] ?? resp['contenu'] ?? '').toString();
          final sentAtStr = (resp['sentAt'] ?? resp['dateEnvoi'] ?? '').toString();
          DateTime dt;
          try {
            dt = sentAtStr.isNotEmpty ? DateTime.parse(sentAtStr).toLocal() : DateTime.now();
          } catch (_) {
            dt = DateTime.now();
          }
          final hh = dt.hour.toString().padLeft(2, '0');
          final mm = dt.minute.toString().padLeft(2, '0');
          final text = content.isNotEmpty ? content : '[Document] $name';
          if (!mounted) return;
          setState(() {
            _messages = List<_ChatMessage>.from(_messages)..add(_ChatMessage(text: text, fromMe: true, time: '$hh:$mm'));
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scroll.hasClients) {
              _scroll.animateTo(
                _scroll.position.maxScrollExtent + 80,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
              );
            }
          });
          return;
        } catch (_) {
          // fallback local
        }
      }
      final now = TimeOfDay.now();
      final hh = now.hour.toString().padLeft(2, '0');
      final mm = now.minute.toString().padLeft(2, '0');
      if (!mounted) return;
      setState(() {
        _messages = List<_ChatMessage>.from(_messages)..add(_ChatMessage(text: '[Document] $name', fromMe: true, time: '$hh:$mm'));
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent + 80,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (_) {}
  }
}

class _HeaderAvatar extends StatelessWidget {
  final String? initials;
  final String? imageUrl;
  const _HeaderAvatar({this.initials, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
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
    );
  }
}

class _Bubble extends StatelessWidget {
  final _ChatMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = message.fromMe ? const Color(0xFF3F51B5) : const Color(0xFFF2F6FF);
    final fg = message.fromMe ? Colors.white : const Color(0xFF1C120D);
    final align = message.fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: Radius.circular(message.fromMe ? 12 : 4),
      bottomRight: Radius.circular(message.fromMe ? 4 : 12),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: bg, borderRadius: radius),
            child: Text(message.text, style: theme.textTheme.bodyMedium?.copyWith(color: fg)),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: message.fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.time,
                style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B4F4A)),
              ),
              if (message.fromMe) const SizedBox(width: 6),
              if (message.fromMe)
                const Icon(Icons.done_all, size: 16, color: Color(0xFF6B8CFF)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAttach;
  final VoidCallback onSend;
  const _Composer({required this.controller, required this.onAttach, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: const BoxDecoration(color: Color(0xFFFCFAF7)),
        child: Row(
          children: [
            IconButton(
              onPressed: onAttach,
              icon: const Icon(Icons.attachment, color: Color(0xFF99604C)),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: const Border.fromBorderSide(
                    BorderSide(color: Color(0xFFF2EAE8)),
                  ),
                ),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Écrire un message...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: onSend,
              icon: const Icon(Icons.send_rounded, color: Color(0xFF3F51B5)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final bool fromMe;
  final String text;
  final String time;
  final bool seen;
  const _ChatMessage({required this.fromMe, required this.text, required this.time, this.seen = false});
}
