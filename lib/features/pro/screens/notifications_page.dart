import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/services/pro_api_service.dart';
import 'package:myapp/core/data/models/app_notification.dart';

/// Page des notifications (Espace Pro).
///
/// - Affiche les notifications récentes et anciennes.
/// - Filtres par catégorie: Demandes, Propositions, Messages.
/// - Comportement au clic configuré pour ouvrir la bonne page.
/// - Les propositions rejetées n'exposent pas d'action (désactivées).
enum _NotifCategory { demandes, propositions, messages,}

/// Modèle léger d'une notification à afficher.
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

/// Entrée de route vers la page des notifications (Pro).
class ProNotificationsPage extends StatefulWidget {
  const ProNotificationsPage({super.key});

  @override
  State<ProNotificationsPage> createState() => _ProNotificationsPageState();
}

/// State de la page Notifications côté Pro.
///
/// - Gère le filtre actif `_filter`.
/// - Initialise une liste mock `_items`.
/// - Calcule les listes `unread`/`old`.
/// - Assure la navigation au clic selon la catégorie.
class _ProNotificationsPageState extends State<ProNotificationsPage> {
  _NotifCategory? _filter; // null => Tous

  late List<_NotifItem> _items;
  final _api = ProApiService();
  bool _loading = true;
  String? _error;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _items = const [];
    // Charge les notifications puis les marque comme lues dès l'entrée sur la page.
    _fetchNotifications().then((_) => _markAllRead());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.go('/pro/home'),
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1C120D)),
                ),
                Expanded(
                  child: Text(
                    'Notifications',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF1C120D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _fetchNotifications, child: const Text('Réessayer')),
                    ],
                  ),
                )
              : (_items.isEmpty
                  ? const Center(child: Text('Aucune notification'))
                  : RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => _NotifTilePro(data: _items[i], onTap: () => _handleNotificationTap(_items[i])),
                      ),
                    ))),
    );
  }

  /// True si la notification correspond à une proposition rejetée,
  /// ce qui désactive toute action.
  bool _isProposalRejected(_NotifItem n) {
    return n.category == _NotifCategory.propositions &&
        (n.actionText.toLowerCase().contains('détail') || n.actionText.toLowerCase().contains('details'));
  }

  /// Gère la navigation au clic sur une notification selon sa catégorie.
  void _handleNotificationTap(_NotifItem n) {
    switch (n.category) {
      case _NotifCategory.demandes:
        context.go('/pro/service-requests');
        break;
      case _NotifCategory.propositions:
        // Accepted proposal -> open discussion
        if (n.actionText.toLowerCase().contains('discussion')) {
          context.push('/pro/chat', extra: {'name': 'Client', 'initials': 'CL'});
        }
        // Rejetée: do nothing
        break;
      case _NotifCategory.messages:
        // Open messages discussion
        context.push('/pro/chat', extra: {'name': 'Contact', 'initials': 'CN'});
        break;
    }
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final List<AppNotification> data = await _api.getMyNotifications();
      final items = data.map(_mapToItem).toList(growable: false);
      setState(() {
        _items = items;
        _unreadCount = items.where((e) => !e.faded).length;
        _loading = false;
      });
      // Met à jour le compteur après chargement de la liste
      _fetchUnreadCount();
    } catch (e) {
      setState(() {
        _error = 'Impossible de charger les notifications';
        _loading = false;
      });
    }
  }

  _NotifItem _mapToItem(AppNotification n) {
    final t = n.type.toLowerCase();
    if (t.contains('demandeservice')) {
      return _NotifItem(
        category: _NotifCategory.demandes,
        borderColor: n.estVu ? const Color(0xFFD1D5DB) : const Color(0xFFF59E0B),
        title1: n.contenu,
        timeText: _relativeTime(n.date),
        actionText: 'Voir la demande',
        actionColor: const Color(0xFF374151),
        faded: n.estVu,
      );
    }
    if (t.contains('propositiondevis')) {
      final isAccepted = n.contenu.toLowerCase().contains('accept');
      final isRefused = n.contenu.toLowerCase().contains('refus');
      return _NotifItem(
        category: _NotifCategory.propositions,
        borderColor: isAccepted ? const Color(0xFF86EFAC) : (isRefused ? const Color(0xFFFCA5A5) : const Color(0xFFD1D5DB)),
        title1: n.contenu,
        timeText: _relativeTime(n.date),
        actionText: isAccepted ? 'Ouvrir la discussion' : 'Voir les détails',
        actionColor: isAccepted ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
        faded: n.estVu,
      );
    }
    return _NotifItem(
      category: _NotifCategory.messages,
      borderColor: const Color(0xFF93C5FD),
      title1: n.contenu,
      timeText: _relativeTime(n.date),
      actionText: 'Ouvrir le message',
      actionColor: const Color(0xFF1D4ED8),
      faded: n.estVu,
    );
  }

  String _relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    return 'Il y a ${diff.inDays} j';
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final c = await _api.getMyNotificationsCount();
      if (mounted) {
        final local = _items.where((e) => !e.faded).length;
        setState(() => _unreadCount = c > local ? c : local);
      }
    } catch (_) {
      // ignore: avoid_print
      // print('Failed to fetch notifications count');
    }
  }

  Future<void> _onRefresh() async {
    await _fetchNotifications();
    await _fetchUnreadCount();
  }

  Future<void> _markAllRead() async {
    try {
      await _api.markAllNotificationsRead();
      if (!mounted) return;
      // Mise à jour locale : toutes les notifications deviennent "lues".
      setState(() {
        _items = _items.map((e) => e.markRead()).toList(growable: false);
        _unreadCount = 0;
      });
    } catch (_) {
      // On ignore l'erreur ici pour ne pas casser l'affichage de la page.
    }
  }
}

/// Puce de segment (onglet horizontal) pour filtrer les notifications.
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

class _NotifTilePro extends StatelessWidget {
  final _NotifItem data;
  final VoidCallback onTap;
  const _NotifTilePro({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF5EFEC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_none_rounded, color: Color(0xFF1C120D)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title1,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF1C120D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                if (data.actionText.isNotEmpty)
                  Text(
                    data.actionText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B4F4A),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            data.timeText,
            style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B4F4A)),
          ),
        ],
      ),
    );
  }
}
/// Carte d'une notification.
///
/// - Supporte un état `faded` (ancien) qui atténue l'opacité.
/// - Expose `onTap` et `actionEnabled` pour gérer l'action.
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
    this.onTap,
    this.actionEnabled = true,
  });

  final Color borderColor;
  final String title1;
  final String? title2;
  final String? title3;
  final String timeText;
  final String actionText;
  final Color actionColor;
  final bool faded;
  final VoidCallback? onTap;
  final bool actionEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: faded ? const Color(0xFFFFFFFF).withValues(alpha: 0.6) : Colors.white,
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
          if (actionEnabled)
            TextButton.icon(
              onPressed: onTap,
              icon: Icon(Icons.arrow_outward_rounded, size: 16, color: actionColor),
              label: Text(actionText, style: theme.textTheme.bodyMedium?.copyWith(color: actionColor, fontWeight: FontWeight.w500)),
            )
        ],
      ),
      ),
    );
  }
}
