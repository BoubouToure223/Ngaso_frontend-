import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

class NoviceChatPage extends StatefulWidget {
  const NoviceChatPage({super.key, this.name, this.initials});
  final String? name;
  final String? initials;

  @override
  State<NoviceChatPage> createState() => _NoviceChatPageState();
}

class _NoviceChatPageState extends State<NoviceChatPage> {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();

  late final List<_Msg> _messages = <_Msg>[
    _Msg(text: "Bonjour M. Traoré, je suis intéressé par votre devis pour la rénovation de ma cuisine.", me: false, time: '10:03'),
    _Msg(text: "Bonjour. Merci pour votre intérêt. Je peux vous proposer un rendez-vous pour discuter des détails?", me: true, time: '10:05'),
    _Msg(text: "Oui bien sûr. Seriez-vous disponible demain après-midi?", me: false, time: '10:07'),
    _Msg(text: "Parfait. 14h à votre domicile?", me: true, time: '10:08'),
    _Msg(text: "Ces rénovations sont magnifiques! J'ai hâte de discuter de notre projet demain.", me: false, time: '10:25'),
    _Msg(text: "À demain alors. N'hésitez pas si vous avez d'autres questions d'ici là.", me: true, time: '10:26'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _attach() async {
    try {
      final res = await FilePicker.platform.pickFiles(allowMultiple: false);
      if (res == null || res.files.isEmpty) return;
      final file = res.files.first;
      final name = file.name;
      final now = TimeOfDay.now();
      final hh = now.hour.toString().padLeft(2, '0');
      final mm = now.minute.toString().padLeft(2, '0');
      setState(() {
        _messages.add(_Msg(text: '[Document] $name', me: true, time: '$hh:$mm'));
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

  void _send() {
    final txt = _controller.text.trim();
    if (txt.isEmpty) return;
    final now = TimeOfDay.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    setState(() {
      _messages.add(_Msg(text: txt, me: true, time: '$hh:$mm'));
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contactName = widget.name ?? 'Contact';
    final contactInitials = widget.initials ?? 'CN';

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF7),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: const Color(0xFFDDE3F5),
              child: Text(contactInitials, style: const TextStyle(fontSize: 12, color: Color(0xFF3F51B5), fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            Text(contactName, style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF1F2937), fontWeight: FontWeight.w600)),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                return _Bubble(msg: m);
              },
            ),
          ),
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

class _Msg {
  const _Msg({required this.text, required this.me, required this.time});
  final String text;
  final bool me;
  final String time;
}
