import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:myapp/core/data/services/pro_api_service.dart';

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
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  /// Action: joindre un fichier (mock) puis scroller en bas.
  Future<void> _attach() async {
    try {
      final res = await FilePicker.platform.pickFiles(allowMultiple: false);
      if (res == null || res.files.isEmpty) return;
      final file = res.files.first;
      final name = file.name;
      // Si conversation liée, envoyer via l'API upload
      if (widget.conversationId != null && (file.path ?? '').isNotEmpty) {
        try {
          final resp = await _api.sendConversationAttachment(
            conversationId: widget.conversationId!,
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
          setState(() {
            _messages = List<_Msg>.from(_messages)..add(_Msg(text: text, me: true, time: '$hh:$mm'));
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
          return;
        } catch (_) {
          // Si l'upload échoue, retombe sur l'affichage local mock
        }
      }
      // Fallback/mock: afficher localement
      final now = TimeOfDay.now();
      final hh = now.hour.toString().padLeft(2, '0');
      final mm = now.minute.toString().padLeft(2, '0');
      setState(() {
        _messages = List<_Msg>.from(_messages)..add(_Msg(text: '[Document] $name', me: true, time: '$hh:$mm'));
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
    } catch (e) {
      // Ignore errors for mock flow
    }
  }

  /// Action: envoyer le contenu du champ de saisie comme message.
  void _send() {
    final txt = _controller.text.trim();
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

  Future<void> _fetchMessages() async {
    try {
      final id = widget.conversationId!;
      final data = await _api.getConversationMessages(conversationId: id, page: 0, size: 20);
      // L'API renvoie les messages du plus récent au plus ancien; on les inverse pour l'affichage chronologique
      final items = data.reversed.map<_Msg>((e) {
        final m = e as Map;
        final content = (m['content'] ?? m['contenu'] ?? '').toString();
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
        return _Msg(text: content, me: me, time: '$hh:$mm');
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
          Container(
            decoration: BoxDecoration(color: bg, borderRadius: border),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(msg.text, style: theme.textTheme.bodyMedium?.copyWith(color: fg)),
          ),
          const SizedBox(height: 4),
          Text(msg.time, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

/// Modèle d'un message dans la conversation.
class _Msg {
  const _Msg({required this.text, required this.me, required this.time});
  /// Contenu textuel du message.
  final String text;
  /// True si le message a été envoyé par le pro (moi).
  final bool me;
  /// Heure d'envoi formatée (HH:mm).
  final String time;
}
