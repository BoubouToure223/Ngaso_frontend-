import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:myapp/core/data/services/pro_api_service.dart';
import 'package:myapp/core/widgets/auth_image.dart';
import 'package:myapp/core/network/api_config.dart';
import 'package:myapp/core/storage/token_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:myapp/core/state/badge_counters.dart';

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
  String? _pendingFilePath;
  String? _pendingFileName;
  final Set<String> _seenKeys = <String>{};

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

  void _send() {
    final txt = _controller.text.trim();
    if (_pendingFilePath != null && _pendingFilePath!.isNotEmpty) {
      _sendPendingAttachment();
      return;
    }
    if (txt.isEmpty) return;
    if (_conversationId != null) {
      _sendViaApi(txt);
    } else {
      setState(() {
        _messages.add(_ChatMessage(fromMe: true, text: txt, time: _nowLabel()));
      });
      _controller.clear();
      _scrollToEnd();
    }
  }

  Future<void> _sendPendingAttachment() async {
    final path = _pendingFilePath;
    final name = _pendingFileName ?? 'document';
    if (path == null || path.isEmpty) return;
    try {
      if (_conversationId != null) {
        final resp = await _api.sendConversationAttachment(
          conversationId: _conversationId!,
          filePath: path,
          fileName: name,
        );
        if (!mounted) return;
        // Construire un message local immédiat, et marquer la clé de déduplication
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
        final attUrl = (resp['attachmentUrl'] ?? resp['pieceJointe'] ?? resp['attachment'] ?? resp['url'] ?? resp['fileUrl'] ?? '').toString();
        if (attUrl.isNotEmpty) {
          final key = 'att:$attUrl';
          _seenKeys.add(key);
          setState(() {
            _messages = List<_ChatMessage>.from(_messages)..add(_ChatMessage(text: text, fromMe: true, time: '$hh:$mm', attachmentUrl: attUrl));
            _pendingFilePath = null;
            _pendingFileName = null;
          });
          _scrollToEnd();
        } else {
          // Pas d'URL retournée: se contenter de nettoyer l'état, l'affichage viendra via STOMP
          setState(() {
            _pendingFilePath = null;
            _pendingFileName = null;
          });
        }
        return;
      }
      // Mode mock si pas de conversation
      setState(() {
        _messages = List<_ChatMessage>.from(_messages)..add(_ChatMessage(text: '[Document] $name', fromMe: true, time: _nowLabel()));
        _pendingFilePath = null;
        _pendingFileName = null;
      });
      _scrollToEnd();
    } catch (_) {
      // Garder la pièce jointe en attente en cas d'échec
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
            pendingName: _pendingFileName,
            onClearPending: () => setState(() { _pendingFilePath = null; _pendingFileName = null; }),
            onAttach: _attach,
            onSend: _send,
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

  void _scrollToEnd({double extra = 80, bool immediate = false}) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final target = _scroll.position.maxScrollExtent + extra;
      try {
        if (immediate) {
          _scroll.jumpTo(target);
        } else {
          _scroll.animateTo(
            target,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      } catch (_) {}
    });
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
          onConnect: (frame) {
            // debug
            // ignore: avoid_print
            print('[STOMP] Connected: subscriptions for conversation $_conversationId');
            _onStompConnect(frame);
          },
          onWebSocketError: (e) {
            // ignore: avoid_print
            print('[STOMP] WebSocket error: $e');
          },
          onStompError: (f) {
            // ignore: avoid_print
            print('[STOMP] STOMP error: ${f.body}');
          },
          onDisconnect: (f) {
            // ignore: avoid_print
            print('[STOMP] Disconnected');
          },
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
          // ignore: avoid_print
          print('[STOMP] Frame received on /topic/conversations/$cid');
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
    final dedupKey = attachmentUrl.isNotEmpty ? 'att:$attachmentUrl' : 'txt:$content@$hh:$mm';
    if (_seenKeys.contains(dedupKey)) return;
    _seenKeys.add(dedupKey);
    if (!mounted) return;
    setState(() {
      _messages = List<_ChatMessage>.from(_messages)..add(
        _ChatMessage(text: content, fromMe: me, time: '$hh:$mm', attachmentUrl: attachmentUrl.isEmpty ? null : attachmentUrl),
      );
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
        return _ChatMessage(text: content, fromMe: me, time: '$hh:$mm', attachmentUrl: attachmentUrl.isEmpty ? null : attachmentUrl);
      }).toList();
      if (!mounted) return;
      setState(() {
        _messages = items;
      });
      _scrollToEnd(extra: 0, immediate: true);
      // Mark all messages as read on open and refresh global badges
      try {
        await _api.markConversationMessagesRead(conversationId: id);
        await BadgeCounters.instance.refreshMessagesTotal();
      } catch (_) {}
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
      setState(() {
        _pendingFilePath = file.path;
        _pendingFileName = file.name;
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
          _MessageBody(message: message, bg: bg, fg: fg, radius: radius),
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

class _MessageBody extends StatelessWidget {
  final _ChatMessage message;
  final Color bg;
  final Color fg;
  final BorderRadius radius;
  const _MessageBody({required this.message, required this.bg, required this.fg, required this.radius});

  bool _isImageUrl(String url) {
    final u = url.toLowerCase();
    return u.endsWith('.png') || u.endsWith('.jpg') || u.endsWith('.jpeg') || u.endsWith('.gif') || u.endsWith('.webp');
  }

  bool _isDocUrl(String url) {
    final u = url.toLowerCase();
    return u.endsWith('.pdf') || u.endsWith('.doc') || u.endsWith('.docx') || u.endsWith('.xls') || u.endsWith('.xlsx') || u.endsWith('.ppt') || u.endsWith('.pptx') || u.endsWith('.txt');
  }

  String _fileNameFrom(String url, String fallback) {
    final segs = Uri.tryParse(url)?.pathSegments;
    if (segs != null && segs.isNotEmpty) return segs.last;
    return fallback;
  }

  String _absUrl(String u) {
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    final api = Uri.parse(ApiConfig.baseUrl);
    final origin = '${api.scheme}://${api.host}${api.hasPort ? ':${api.port}' : ''}';
    final basePath = api.path.isEmpty ? '' : (api.path.startsWith('/') ? api.path : '/${api.path}');
    final rel = u.startsWith('/') ? u : '/$u';
    return '$origin$basePath$rel';
  }

  Future<void> _openAttachment(String url) async {
    final target = Uri.parse(_absUrl(url));
    await launchUrl(target, mode: LaunchMode.externalApplication);
  }

  Future<void> _downloadAttachment(BuildContext context, String url) async {
    final dio = Dio();
    String? token;
    try {
      token = await TokenStorage.instance.readToken();
    } catch (_) {}
    final resolved = _absUrl(url);
    final dir = await getApplicationDocumentsDirectory();
    final name = _fileNameFrom(resolved, 'document');
    final savePath = '${dir.path}${Platform.pathSeparator}$name';
    await dio.download(
      resolved,
      savePath,
      options: Options(headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        'Accept': '*/*',
      }),
    );
    await OpenFilex.open(savePath);
  }

  @override
  Widget build(BuildContext context) {
    final att = message.attachmentUrl;
    if (att != null && att.isNotEmpty && _isImageUrl(att)) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _ImageViewerPage(url: att, heroTag: att),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280, maxHeight: 220),
            child: Hero(
              tag: att,
              child: AuthImage(url: att, fit: BoxFit.cover),
            ),
          ),
        ),
      );
    }
    if (att != null && att.isNotEmpty && _isDocUrl(att)) {
      final name = _fileNameFrom(att, message.text);
      return Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: bg, borderRadius: radius),
        child: InkWell(
          onTap: () => message.fromMe ? _openAttachment(att) : _downloadAttachment(context, att),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.insert_drive_file, color: fg, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: fg))),
              const SizedBox(width: 8),
              if (!message.fromMe)
                IconButton(
                  icon: Icon(Icons.download, size: 20, color: fg),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _downloadAttachment(context, att),
                ),
            ],
          ),
        ),
      );
    }
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: radius),
      child: Text(message.text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: fg)),
    );
  }
}

class _ImageViewerPage extends StatelessWidget {
  const _ImageViewerPage({required this.url, required this.heroTag});
  final String url;
  final Object heroTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: heroTag,
            child: AuthImage(url: url, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAttach;
  final VoidCallback onSend;
  final String? pendingName;
  final VoidCallback? onClearPending;
  const _Composer({required this.controller, required this.onAttach, required this.onSend, this.pendingName, this.onClearPending});

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
                child: Row(
                  children: [
                    if (pendingName != null) ...[
                      Flexible(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 160),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD1E3FF)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.insert_drive_file, size: 16, color: Color(0xFF3F51B5)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(pendingName!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xFF1F2937))),
                              ),
                              const SizedBox(width: 6),
                              if (onClearPending != null)
                                GestureDetector(
                                  onTap: onClearPending,
                                  child: const Icon(Icons.close, size: 16, color: Color(0xFF6B7280)),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'Écrire un message...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => onSend(),
                      ),
                    ),
                  ],
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
  final String? attachmentUrl;
  const _ChatMessage({required this.fromMe, required this.text, required this.time, this.seen = false, this.attachmentUrl});
}
