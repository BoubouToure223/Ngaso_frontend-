import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:myapp/core/data/services/pro_api_service.dart';
import 'package:myapp/core/network/api_config.dart';
import 'package:myapp/core/widgets/auth_image.dart';
import 'package:myapp/core/storage/token_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:myapp/core/state/badge_counters.dart';

/// Page de discussion (chat) côté Pro.
///
/// - Affiche une conversation simulée avec une zone de saisie.
/// - Permet d'envoyer des messages texte et de joindre un fichier (mock).
class ProChatPage extends StatefulWidget {
  const ProChatPage({super.key, this.name, this.initials, this.conversationId, this.propositionId});
  /// Nom du contact (affiché dans l'AppBar).
  final String? name;
  /// Initiales du contact (affichées dans l'avatar).
  final String? initials;
  /// Identifiant de la conversation.
  final int? conversationId;
  /// Identifiant de la proposition liée.
  final int? propositionId;

  @override
  State<ProChatPage> createState() => _ProChatPageState();
}

class _ProChatPageState extends State<ProChatPage> {
  /// Contrôleur du champ de saisie.
  final _controller = TextEditingController();
  /// Contrôleur du défilement de la liste des messages.
  final _scrollCtrl = ScrollController();
  final ProApiService _api = ProApiService();
  StompClient? _stomp;
  // Pièce jointe en attente d'envoi (sélectionnée mais non envoyée)
  String? _pendingFilePath;
  String? _pendingFileName;
  final Set<String> _seenKeys = <String>{};

  /// Messages simulés (mock) de la conversation.
  List<_Msg> _messages = <_Msg>[
    _Msg(text: "Bonjour M. Traoré, je suis intéressé par votre devis pour la rénovation de ma cuisine.", me: false, time: '10:03'),
    _Msg(text: "Bonjour. Merci pour votre intérêt. Je peux vous proposer un rendez-vous pour discuter des détails?", me: true, time: '10:05'),
    _Msg(text: "Oui bien sûr. Seriez-vous disponible demain après-midi?", me: false, time: '10:07'),
    _Msg(text: "Parfait. 14h à votre domicile?", me: true, time: '10:08'),
    _Msg(text: "Ces rénovations sont magnifiques! J'ai hâte de discuter de notre projet demain.", me: false, time: '10:25'),
    _Msg(text: "À demain alors. N'hésitez pas si vous avez d'autres questions d'ici là.", me: true, time: '10:26'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.conversationId != null) {
      _messages = <_Msg>[];
      _fetchMessages();
      _connectRealtime();
    }
  }

  void _connectRealtime() async {
    try {
      final origin = ApiConfig.baseOrigin; // ex: http://10.0.2.2:8080
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
    final cid = widget.conversationId;
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
    final sentAtStr = (m['sentAt'] ?? m['dateEnvoi'] ?? '').toString();
    DateTime dt;
    try {
      dt = sentAtStr.isNotEmpty ? DateTime.parse(sentAtStr).toLocal() : DateTime.now();
    } catch (_) {
      dt = DateTime.now();
    }
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final me = senderRole == 'PROFESSIONNEL';
    final dedupKey = attachmentUrl.isNotEmpty ? 'att:$attachmentUrl' : 'txt:$content@$hh:$mm';
    if (_seenKeys.contains(dedupKey)) return;
    _seenKeys.add(dedupKey);
    if (!mounted) return;
    setState(() {
      _messages = List<_Msg>.from(_messages)..add(_Msg(text: content, me: me, time: '$hh:$mm', attachmentUrl: attachmentUrl.isEmpty ? null : attachmentUrl));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    _stomp?.deactivate();
    super.dispose();
  }

  /// Action: joindre un fichier (mock) puis scroller en bas.
  Future<void> _attach() async {
    try {
      final res = await FilePicker.platform.pickFiles(allowMultiple: false);
      if (res == null || res.files.isEmpty) return;
      final file = res.files.first;
      setState(() {
        _pendingFilePath = file.path;
        _pendingFileName = file.name;
      });
    } catch (e) {
      // Ignore errors for mock flow
    }
  }

  /// Action: envoyer le contenu du champ de saisie comme message.
  void _send() {
    final txt = _controller.text.trim();
    // Priorité: si une pièce jointe est en attente, on l'envoie; sinon on envoie le texte
    if (_pendingFilePath != null && (_pendingFilePath!.isNotEmpty)) {
      _sendPendingAttachment();
      return;
    }
    if (txt.isEmpty) return;
    if (widget.conversationId != null) {
      // Envoyer via l'API puis ajouter le message retourné
      _sendViaApi(txt);
    } else {
      // Mode mock (aucune conversation liée)
      final now = TimeOfDay.now();
      final hh = now.hour.toString().padLeft(2, '0');
      final mm = now.minute.toString().padLeft(2, '0');
      setState(() {
        _messages = List<_Msg>.from(_messages)..add(_Msg(text: txt, me: true, time: '$hh:$mm'));
      });
      _controller.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent + 80,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendPendingAttachment() async {
    final path = _pendingFilePath;
    final name = _pendingFileName ?? 'document';
    if (path == null || path.isEmpty) return;
    try {
      if (widget.conversationId != null) {
        final resp = await _api.sendConversationAttachment(
          conversationId: widget.conversationId!,
          filePath: path,
          fileName: name,
        );
        // Afficher immédiatement, puis dédupliquer à la réception STOMP
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
            _messages = List<_Msg>.from(_messages)..add(_Msg(text: text, me: true, time: '$hh:$mm', attachmentUrl: attUrl));
            _pendingFilePath = null;
            _pendingFileName = null;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollCtrl.hasClients) {
              _scrollCtrl.animateTo(
                _scrollCtrl.position.maxScrollExtent + 80,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
              );
            }
          });
        } else {
          setState(() {
            _pendingFilePath = null;
            _pendingFileName = null;
          });
        }
        return;
      }
      // Mode mock: pas de conversation, juste afficher localement
      final now = TimeOfDay.now();
      final hh = now.hour.toString().padLeft(2, '0');
      final mm = now.minute.toString().padLeft(2, '0');
      setState(() {
        _messages = List<_Msg>.from(_messages)..add(_Msg(text: '[Document] $name', me: true, time: '$hh:$mm'));
        _pendingFilePath = null;
        _pendingFileName = null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent + 80,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (_) {
      // Ne rien faire, on peut garder la pièce jointe en attente
    }
  }

  Future<void> _fetchMessages() async {
    try {
      final id = widget.conversationId!;
      final data = await _api.getConversationMessages(conversationId: id, page: 0, size: 20);
      // L'API renvoie les messages du plus récent au plus ancien; on les inverse pour l'affichage chronologique
      final items = data.reversed.map<_Msg>((e) {
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
        final sentAtStr = (m['sentAt'] ?? m['dateEnvoi'] ?? '').toString();
        DateTime dt;
        try {
          dt = sentAtStr.isNotEmpty ? DateTime.parse(sentAtStr).toLocal() : DateTime.now();
        } catch (_) {
          dt = DateTime.now();
        }
        final hh = dt.hour.toString().padLeft(2, '0');
        final mm = dt.minute.toString().padLeft(2, '0');
        final me = senderRole == 'PROFESSIONNEL';
        return _Msg(text: content, me: me, time: '$hh:$mm', attachmentUrl: attachmentUrl.isEmpty ? null : attachmentUrl);
      }).toList();
      setState(() {
        _messages = items;
      });
      // Scroll en bas après chargement
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
        }
      });
      // Marquer comme lu et rafraîchir le badge global
      try {
        await _api.markConversationMessagesRead(conversationId: id);
        await BadgeCounters.instance.refreshMessagesTotal();
      } catch (_) {}
    } catch (_) {
      // Ignorer pour l'instant; on peut afficher un toast si souhaité
    }
  }

  Future<void> _sendViaApi(String txt) async {
    try {
      final id = widget.conversationId!;
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
      setState(() {
        _messages = List<_Msg>.from(_messages)..add(_Msg(text: content.isEmpty ? txt : content, me: true, time: '$hh:$mm'));
      });
      _controller.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent + 80,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (_) {
      // En cas d'erreur API, fallback: afficher localement
      final now = TimeOfDay.now();
      final hh = now.hour.toString().padLeft(2, '0');
      final mm = now.minute.toString().padLeft(2, '0');
      setState(() {
        _messages = List<_Msg>.from(_messages)..add(_Msg(text: txt, me: true, time: '$hh:$mm'));
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contactName = widget.name ?? 'Contact';
    final contactInitials = widget.initials ?? 'CN';

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF7),
      appBar: AppBar(
        // Retour arrière
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        // En-tête: avatar + nom du contact
        title: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: const Color(0xFFDDE3F5),
              child: Text(contactInitials, style: const TextStyle(fontSize: 12, color: Color(0xFF3F51B5), fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            Text(contactName),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Liste des messages (bulle à gauche/droite selon l'émetteur)
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('📭', style: TextStyle(fontSize: 36)),
                        SizedBox(height: 8),
                        Text('Aucun message', style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text('Commencez la conversation en envoyant un message.'),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final m = _messages[index];
                      return _Bubble(msg: m);
                    },
                  ),
          ),
          // Barre d'entrée (joindre un fichier + champ + envoyer)
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            color: Colors.white,
            child: Row(
              children: [
                InkWell(
                  onTap: _attach,
                  child: SizedBox(
                    width: 38,
                    height: 38,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
                      child: const Icon(Icons.attach_file, size: 18, color: Color(0xFF374151)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (_pendingFileName != null)
                  Container(
                    constraints: const BoxConstraints(maxWidth: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD1E3FF)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.insert_drive_file, size: 16, color: Color(0xFF3F51B5)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _pendingFileName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Color(0xFF1F2937), fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => setState(() { _pendingFilePath = null; _pendingFileName = null; }),
                          child: const Icon(Icons.close, size: 16, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                if (_pendingFileName != null) const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Écrire un message...',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _send,
                  child: SizedBox(
                    width: 38,
                    height: 38,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(color: Color(0xFFE5E7EB), shape: BoxShape.circle),
                      child: const Icon(Icons.send, size: 18, color: Color(0xFF1F2937)),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// Bulle de message (gauche/droite selon l'émetteur).
class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg});
  final _Msg msg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = msg.me ? const Color(0xFF3F51B5) : const Color(0xFFF3F4F6);
    final fg = msg.me ? Colors.white : const Color(0xFF1F2937);
    final align = msg.me ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final border = msg.me
        ? const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomLeft: Radius.circular(16))
        : const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomRight: Radius.circular(16));

    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 4, left: msg.me ? 80 : 0, right: msg.me ? 0 : 80),
      child: Column(
        crossAxisAlignment: align,
        children: [
          _ProMessageBody(msg: msg, bg: bg, fg: fg, border: border),
          const SizedBox(height: 4),
          Text(msg.time, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

class _ProMessageBody extends StatelessWidget {
  final _Msg msg;
  final Color bg;
  final Color fg;
  final BorderRadius border;
  const _ProMessageBody({required this.msg, required this.bg, required this.fg, required this.border});

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
    if (kIsWeb) {
      await launchUrl(Uri.parse(_absUrl(url)), mode: LaunchMode.externalApplication);
      return;
    }
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
    final att = msg.attachmentUrl;
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
          borderRadius: border,
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
      final name = _fileNameFrom(att, msg.text);
      return Container(
        decoration: BoxDecoration(color: bg, borderRadius: border),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 320),
        child: InkWell(
          onTap: () => msg.me ? _openAttachment(att) : _downloadAttachment(context, att),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.insert_drive_file, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: fg))),
              const SizedBox(width: 8),
              if (!msg.me)
                IconButton(
                  icon: const Icon(Icons.download, size: 20, color: Colors.white),
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
      decoration: BoxDecoration(color: bg, borderRadius: border),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(msg.text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: fg)),
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

/// Modèle d'un message dans la conversation.
class _Msg {
  const _Msg({required this.text, required this.me, required this.time, this.attachmentUrl});
  /// Contenu textuel du message.
  final String text;
  /// True si le message a été envoyé par le pro (moi).
  final bool me;
  /// Heure d'envoi formatée (HH:mm).
  final String time;
  final String? attachmentUrl;
}
