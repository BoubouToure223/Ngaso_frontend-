import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoviceMessagesPage extends StatelessWidget {
  const NoviceMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messages = _mockConversations;

    return Container(
      color: const Color(0xFFFCFAF7),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Messages',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF1C120D),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
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
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, i) {
                  final c = messages[i];
                  return _ConversationTile(
                    data: c,
                    onTap: () {
                      context.push(
                        '/Novice/chat',
                        extra: {
                          'name': c.name,
                          'initials': c.initials,
                          'imageUrl': c.imageUrl,
                          'online': c.online,
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final _Conversation data;
  final VoidCallback onTap;
  const _ConversationTile({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            _Avatar(initials: data.initials, imageUrl: data.imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data.name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF1C120D),
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        data.timeLabel,
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
                          data.preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF6B4F4A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (data.online)
                        const Icon(Icons.circle, size: 10, color: Color(0xFF2DD44D)),
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

class _Conversation {
  final String name;
  final String? initials;
  final String? imageUrl;
  final String preview;
  final String timeLabel;
  final bool online;
  const _Conversation({
    required this.name,
    this.initials,
    this.imageUrl,
    required this.preview,
    required this.timeLabel,
    this.online = false,
  });
}

final _mockConversations = <_Conversation>[
  const _Conversation(
    name: 'Amadou Bakayoko',
    initials: 'AB',
    preview: 'Je peux passer demain  pour voir',
    timeLabel: '10:30',
    online: true,
  ),
  const _Conversation(
    name: 'Entreprise BTP Mali',
    imageUrl: 'assets/images/onboarding_1.png',
    preview: 'Nous avons reçu votre devis et n',
    timeLabel: 'Hier',
    online: true,
  ),
  const _Conversation(
    name: 'Fatoumata Koné',
    initials: 'FK',
    preview: 'Merci pour votre disponibilité. À',
    timeLabel: 'Hier',
  ),
  const _Conversation(
    name: 'Mariam Diallo',
    imageUrl: 'assets/images/onboarding_2.png',
    preview: 'Je voudrais savoir si vous êtes di',
    timeLabel: 'Lun',
  ),
  const _Conversation(
    name: 'Société de Carrelage',
    initials: 'SC',
    preview: 'Nous avons bien reçu votre',
    timeLabel: '23/05',
  ),
  const _Conversation(
    name: 'Ibrahim Touré',
    imageUrl: 'assets/images/onboarding_3.png',
    preview: 'Est-ce que vous pourriez me don',
    timeLabel: '20/05',
  ),
];
