import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoviceChatPage extends StatefulWidget {
  const NoviceChatPage({super.key});

  @override
  State<NoviceChatPage> createState() => _NoviceChatPageState();
}

class _NoviceChatPageState extends State<NoviceChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      fromMe: false,
      text:
          'Bonjour M. Traoré, je suis intéressé par votre devis pour la rénovation de ma cuisine.',
      time: '10:03',
    ),
    const _ChatMessage(
      fromMe: true,
      text:
          'Bonjour M. Diallo. Merci pour votre intérêt. Je peux vous proposer un rendez-vous pour discuter des détails?',
      time: '10:05',
      seen: true,
    ),
    const _ChatMessage(
      fromMe: false,
      text: 'Oui bien sûr. Seriez-vous disponible demain après-midi?',
      time: '10:07',
    ),
    const _ChatMessage(
      fromMe: true,
      text: 'Parfait. 14h à votre domicile?',
      time: '10:08',
      seen: true,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
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
            onSend: () {
              final txt = _controller.text.trim();
              if (txt.isEmpty) return;
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
  final VoidCallback onSend;
  const _Composer({required this.controller, required this.onSend});

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
              onPressed: () {},
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
