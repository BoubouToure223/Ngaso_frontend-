import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum _NotifCategory { demandes, propositions, messages, acceptations }

class _NotifItem {
  const _NotifItem({
    required this.category,
    required this.borderColor,
    required this.title1,
    this.title2,
    this.title3,
    required this.timeText,
    required this.actionText,
    required this.actionColor,
    this.faded = false,
  });

  final _NotifCategory category;
  final Color borderColor;
  final String title1;
  final String? title2;
  final String? title3;
  final String timeText;
  final String actionText;
  final Color actionColor;
  final bool faded;

  _NotifItem markRead() => _NotifItem(
        category: category,
        borderColor: borderColor,
        title1: title1,
        title2: title2,
        title3: title3,
        timeText: timeText,
        actionText: actionText,
        actionColor: actionColor,
        faded: true,
      );
}

class NoviceNotificationsPage extends StatefulWidget {
  const NoviceNotificationsPage({super.key});

  @override
  State<NoviceNotificationsPage> createState() => _NoviceNotificationsPageState();
}

class _NoviceNotificationsPageState extends State<NoviceNotificationsPage> {
  _NotifCategory? _filter; // null => Tous

  late List<_NotifItem> _items;

  @override
  void initState() {
    super.initState();
    _items = const [
      _NotifItem(
        category: _NotifCategory.demandes,
        borderColor: Color(0xFFD1D5DB),
        title1: 'Moussa Traoré a envoyé une',
        title2: 'demande de service pour Fondation',
        title3: '– Maison R+1.',
        timeText: 'Il y a 10 min',
        actionText: 'Voir la demande',
        actionColor: Color(0xFF374151),
        faded: false,
      ),
      _NotifItem(
        category: _NotifCategory.propositions,
        borderColor: Color(0xFF86EFAC),
        title1: 'Votre proposition pour le projet',
        title2: 'Maison Bamako a été acceptée.',
        timeText: 'Il y a 2 heures',
        actionText: 'Ouvrir la discussion',
        actionColor: Color(0xFF16A34A),
        faded: false,
      ),
      _NotifItem(
        category: _NotifCategory.messages,
        borderColor: Color(0xFF93C5FD),
        title1: 'Nouveau message de Awa Diarra.',
        timeText: 'Il y a 5 min',
        actionText: 'Ouvrir le message',
        actionColor: Color(0xFF1D4ED8),
        faded: false,
      ),
      _NotifItem(
        category: _NotifCategory.propositions,
        borderColor: Color(0xFFFCA5A5),
        title1: 'Votre proposition pour le projet',
        title2: 'Villa Kalabancoro a été rejetée.',
        timeText: 'Hier à 18h',
        actionText: 'Voir les détails',
        actionColor: Color(0xFFDC2626),
        faded: false,
      ),
      // Anciennes notifications (faded true)
      _NotifItem(
        category: _NotifCategory.propositions,
        borderColor: Color(0xFF86EFAC),
        title1: 'Votre proposition pour le projet',
        title2: 'Extension Sikasso a été acceptée.',
        timeText: 'Il y a 3 jours',
        actionText: 'Ouvrir la discussion',
        actionColor: Color(0xFF16A34A),
        faded: true,
      ),
      _NotifItem(
        category: _NotifCategory.messages,
        borderColor: Color(0xFF93C5FD),
        title1: 'Nouveau message de Mamadou Keita.',
        timeText: 'Il y a 4 jours',
        actionText: 'Ouvrir le message',
        actionColor: Color(0xFF1D4ED8),
        faded: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unread = _items.where((e) => !e.faded).toList(growable: false);
    final old = _items.where((e) => e.faded).toList(growable: false);
    List<_NotifItem> filtered(List<_NotifItem> src) =>
        _filter == null ? src : src.where((e) => e.category == _filter).toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/app/home'),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        actionsIconTheme: const IconThemeData(color: Color(0xFF111827)),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Notifications', style: theme.textTheme.titleLarge?.copyWith(color: const Color(0xFF111827), fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text('${unread.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10)),
            ),
          ],
        ),
        // actions removed per request
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _SegmentChip(
                    label: 'Tous',
                    selected: _filter == null,
                    onTap: () => setState(() => _filter = null),
                  ),
                  const SizedBox(width: 8),
                  _SegmentChip(
                    label: 'Demandes',
                    selected: _filter == _NotifCategory.demandes,
                    onTap: () => setState(() => _filter = _NotifCategory.demandes),
                  ),
                  const SizedBox(width: 8),
                  _SegmentChip(
                    label: 'Propositions',
                    selected: _filter == _NotifCategory.propositions,
                    onTap: () => setState(() => _filter = _NotifCategory.propositions),
                  ),
                  const SizedBox(width: 8),
                  _SegmentChip(
                    label: 'Messages',
                    selected: _filter == _NotifCategory.messages,
                    onTap: () => setState(() => _filter = _NotifCategory.messages),
                  ),
                  const SizedBox(width: 8),
                  _SegmentChip(
                    label: 'Acceptations',
                    selected: _filter == _NotifCategory.acceptations,
                    onTap: () => setState(() => _filter = _NotifCategory.acceptations),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nouvelles', style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF374151), fontWeight: FontWeight.w600)),
              TextButton(
                onPressed: unread.isEmpty
                    ? null
                    : () => setState(() {
                          _items = _items.map((e) => e.markRead()).toList(growable: false);
                        }),
                child: const Text('Tout marquer comme lu'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...filtered(unread).map((n) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _NotifCard(
                  borderColor: n.borderColor,
                  title1: n.title1,
                  title2: n.title2,
                  title3: n.title3,
                  timeText: n.timeText,
                  actionText: n.actionText,
                  actionColor: n.actionColor,
                  faded: n.faded,
                ),
              )),
          const SizedBox(height: 24),
          Text('Anciennes notifications', style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF374151), fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...filtered(old).map((n) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _NotifCard(
                  borderColor: n.borderColor,
                  title1: n.title1,
                  title2: n.title2,
                  title3: n.title3,
                  timeText: n.timeText,
                  actionText: n.actionText,
                  actionColor: n.actionColor,
                  faded: true,
                ),
              )),
        ],
      ),
    );
  }

}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({required this.label, required this.selected, this.onTap});
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF1D4ED8) : const Color(0xFFF3F4F6);
    final fg = selected ? Colors.white : const Color(0xFF374151);
    return InkWell(
      borderRadius: BorderRadius.circular(9999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: selected
              ? const [BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 4))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(color: fg, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
class _NotifCard extends StatelessWidget {
  const _NotifCard({
    required this.borderColor,
    required this.title1,
    this.title2,
    this.title3,
    required this.timeText,
    required this.actionText,
    required this.actionColor,
    this.faded = false,
  });

  final Color borderColor;
  final String title1;
  final String? title2;
  final String? title3;
  final String timeText;
  final String actionText;
  final Color actionColor;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: faded ? const Color(0xFFFFFFFF).withOpacity(0.6) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title1, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: const Color(0xFF111827))),
          if (title2 != null)
            Text(title2!, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: const Color(0xFF111827))),
          if (title3 != null)
            Text(title3!, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: const Color(0xFF111827))),
          const SizedBox(height: 4),
          Text(timeText, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.arrow_outward_rounded, size: 16, color: actionColor),
            label: Text(actionText, style: theme.textTheme.bodyMedium?.copyWith(color: actionColor, fontWeight: FontWeight.w500)),
          )
        ],
      ),
    );
  }
}
