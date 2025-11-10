import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/services/notification_api_service.dart';

class NoviceNotificationsPage extends StatefulWidget {
  const NoviceNotificationsPage({super.key});

  @override
  State<NoviceNotificationsPage> createState() => _NoviceNotificationsPageState();
}

class _NoviceNotificationsPageState extends State<NoviceNotificationsPage> {
  bool _loading = true;
  String? _error;
  List<_Notif> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = NotificationApiService();
      // Marquer toutes comme lues dès l'entrée
      await api.markAllRead();
      // Charger la liste ensuite
      final list = await api.listMy();
      final mapped = list
          .where((e) => e is Map)
          .map<_Notif?>((raw) {
            try {
              final m = Map<String, dynamic>.from(raw as Map);
              final type = (m['type'] ?? '').toString();
              final contenu = (m['contenu'] ?? '').toString();
              final dateVal = m['date'];
              DateTime? d;
              if (dateVal is int) d = DateTime.fromMillisecondsSinceEpoch(dateVal);
              if (dateVal is String) d = DateTime.tryParse(dateVal);
              return _Notif(
                title: type.isNotEmpty ? _mapTypeToLabel(type) : 'Notification',
                body: contenu,
                time: d != null ? _formatDate(d) : '',
              );
            } catch (_) { return null; }
          })
          .whereType<_Notif>()
          .toList(growable: false);
      if (!mounted) return;
      setState(() { _items = mapped; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _mapTypeToLabel(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('message')) return 'Nouveau message';
    if (s.contains('proposition')) return 'Nouvelle proposition';
    if (s.contains('demande')) return 'Nouvelle demande';
    return 'Notification';
    }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
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
                  onPressed: () => context.pop(),
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
                      ElevatedButton(onPressed: _load, child: const Text('Réessayer')),
                    ],
                  ),
                )
              : (_items.isEmpty
                  ? const Center(child: Text('Aucune notification'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) => _NotifTile(data: _items[i]),
                    ))),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final _Notif data;
  const _NotifTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
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
                data.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF1C120D),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B4F4A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          data.time,
          style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B4F4A)),
        ),
      ],
    );
  }
}

class _Notif {
  final String title;
  final String body;
  final String time;
  const _Notif({required this.title, required this.body, required this.time});
}
