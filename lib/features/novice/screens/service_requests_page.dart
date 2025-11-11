import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/services/project_api_service.dart';
import 'package:myapp/core/data/repositories/dashboard_repository.dart';
import 'package:myapp/core/data/models/dashboard_novice_response.dart';

class NoviceServiceRequestsPage extends StatefulWidget {
  const NoviceServiceRequestsPage({super.key, required this.projectId});
  final int projectId;

  @override
  State<NoviceServiceRequestsPage> createState() => _NoviceServiceRequestsPageState();
  String _extractErrMsg(Object e) {
    try {
      final resp = (e as dynamic).response;
      final data = resp?.data;
      if (data is Map) {
        final m = data['message'];
        if (m is String && m.trim().isNotEmpty) return m;
        final err = data['error'];
        if (err is String && err.trim().isNotEmpty) return err;
      }
      if (data is String && data.trim().isNotEmpty) return data;
      final status = resp?.statusCode;
      if (status != null) return 'Erreur ($status) lors de l\'annulation';
    } catch (_) {}
    return 'Une erreur est survenue lors de l\'annulation';
  }
}

class _NoviceServiceRequestsPageState extends State<NoviceServiceRequestsPage> {
  int selectedIndex = 0; // 0=Toutes,1=Attente,2=Validées,3=Rejetées
  bool _loading = true;
  String? _error;
  List<_ServiceRequest> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    // Determine target projectId: use provided one, else fallback to last project from dashboard
    int targetProjectId = widget.projectId;
    if (targetProjectId == 0) {
      try {
        final DashboardNoviceResponse dash = await DashboardRepository().getNoviceDashboard();
        final lastId = dash.lastProject?.id ?? 0;
        if (lastId != 0) {
          targetProjectId = lastId;
        } else {
          setState(() {
            _error = "Aucun projet trouvé. Allez dans 'Mes projets' pour en créer ou en sélectionner un.";
            _loading = false;
          });
          return;
        }
      } catch (e) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
        return;
      }
    }
    try {
      final api = ProjectApiService();
      final list = await api.getProjectDemandes(projectId: targetProjectId);
      final mapped = list
          .where((e) => e is Map)
          .map<_ServiceRequest?>((raw) {
            try {
              final m = Map<String, dynamic>.from(raw as Map);
              final idVal = m['id'] ?? m['demandeId'];
              final demandeId = (idVal is int)
                  ? idVal
                  : (idVal is String ? int.tryParse(idVal) : null);
              final statutRaw = (m['statut'])?.toString() ?? '';
              final st = _mapBackendStatus(statutRaw);
              final proNom = (m['professionnelNom'])?.toString() ?? '';
              final proPrenom = (m['professionnelPrenom'])?.toString() ?? '';
              final fullName = [proPrenom, proNom].where((s) => s.isNotEmpty).join(' ').trim();
              final entreprise = (m['professionnelEntreprise'])?.toString() ?? '';
              final service = (m['etapeModeleNom'])?.toString() ?? '';
              final dateVal = m['dateCreation'];
              DateTime? createdAt;
              if (dateVal is int) {
                createdAt = DateTime.fromMillisecondsSinceEpoch(dateVal);
              } else if (dateVal is String) {
                createdAt = DateTime.tryParse(dateVal);
              }
              return _ServiceRequest(
                id: (demandeId != null && demandeId > 0) ? demandeId : null,
                name: fullName.isNotEmpty ? fullName : (entreprise.isNotEmpty ? entreprise : 'Professionnel inconnu'),
                service: service.isNotEmpty ? service : 'Service',
                status: st,
                createdAt: createdAt,
              );
            } catch (_) {
              return null;
            }
          })
          .whereType<_ServiceRequest>()
          .toList(growable: false);
      if (!mounted) return;
      setState(() {
        _items = mapped;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  _Status _mapBackendStatus(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('attent')) return _Status.pending;
    if (s.contains('valid')) return _Status.approved;
    if (s.contains('rejet') || s.contains('refus')) return _Status.rejected;
    return _Status.pending;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _items.where((e) {
      switch (selectedIndex) {
        case 1:
          return e.status == _Status.pending;
        case 2:
          return e.status == _Status.approved;
        case 3:
          return e.status == _Status.rejected;
        default:
          return true;
      }
    }).toList();
    final allCount = _items.length;
    final pendingCount = _items.where((e) => e.status == _Status.pending).length;
    final approvedCount = _items.where((e) => e.status == _Status.approved).length;
    final rejectedCount = _items.where((e) => e.status == _Status.rejected).length;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1C120D)),
              ),
              Expanded(
                child: Text(
                  'Mes demandes de service',
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
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _Filters(
              selectedIndex: selectedIndex,
              onChanged: (i) => setState(() => selectedIndex = i),
              counts: [allCount, pendingCount, approvedCount, rejectedCount],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : (_error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            ElevatedButton(onPressed: _load, child: const Text('Réessayer')),
                          ],
                        ),
                      )
                    : (items.isEmpty
                        ? const Center(child: Text('Aucune demande'))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, i) => _RequestCard(
                              data: items[i],
                              onCancelled: _load,
                            ),
                          ))),
          ),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<int> counts; // [toutes, attente, validées, rejetées]
  const _Filters({
    required this.selectedIndex,
    required this.onChanged,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E3DF)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          _TabChip(
            label: 'Toutes',
            count: counts[0],
            active: selectedIndex == 0,
            onTap: () => onChanged(0),
            dotColor: const Color(0xFF3F51B5),
          ),
          _TabChip(
            label: 'attente',
            count: counts[1],
            active: selectedIndex == 1,
            onTap: () => onChanged(1),
            dotColor: const Color(0xFFF1C40F),
          ),
          _TabChip(
            label: 'Validées',
            count: counts[2],
            active: selectedIndex == 2,
            onTap: () => onChanged(2),
            dotColor: const Color(0xFF2ECC71),
          ),
          _TabChip(
            label: 'Rejetées',
            count: counts[3],
            active: selectedIndex == 3,
            onTap: () => onChanged(3),
            dotColor: const Color(0xFFE74C3C),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;
  final Color dotColor;
  const _TabChip({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = active ? const Color(0xFF1C120D) : const Color(0xFF6B4F4A);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (label != 'Toutes') ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2EAE8),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$count',
                      style: theme.textTheme.labelSmall?.copyWith(color: const Color(0xFF1C120D)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 2,
                color: active ? const Color(0xFF3F51B5) : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final _ServiceRequest data;
  final VoidCallback? onCancelled;
  const _RequestCard({required this.data, this.onCancelled});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E3DF)),
        boxShadow: const [
          BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF1C120D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data.service,
                            style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B4F4A)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (data.createdAt != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(data.createdAt!),
                            style: theme.textTheme.labelSmall?.copyWith(color: const Color(0xFF6B4F4A)),
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: data.status),
            ],
          ),
          const SizedBox(height: 12),
          if (data.status == _Status.pending) ...[
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFFE53935),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: data.id == null
                    ? null
                    : () async {
                        try {
                          await ProjectApiService().cancelDemande(demandeId: data.id!);
                          if (onCancelled != null) onCancelled!();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Demande annulée')),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          final msg = _extractErrMsg(e);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(msg)),
                          );
                        }
                      },
                child: const Text('Annuler'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    // Simple dd/MM/yyyy formatting without intl
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  String _extractErrMsg(Object e) {
    try {
      final resp = (e as dynamic).response;
      final data = resp?.data;
      if (data is Map) {
        final m = data['message'];
        if (m is String && m.trim().isNotEmpty) return m;
        final err = data['error'];
        if (err is String && err.trim().isNotEmpty) return err;
      }
      if (data is String && data.trim().isNotEmpty) return data;
      final status = resp?.statusCode;
      if (status != null) return 'Erreur ($status) lors de l\'annulation';
    } catch (_) {}
    return 'Une erreur est survenue lors de l\'annulation';
  }
}

class _StatusBadge extends StatelessWidget {
  final _Status status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final String label;
    switch (status) {
      case _Status.pending:
        bg = const Color(0xFFFFF3C4);
        fg = const Color(0xFF8A6D00);
        label = 'En attente';
        break;
      case _Status.approved:
        bg = const Color(0xFFE9F9EF);
        fg = const Color(0xFF1E7E34);
        label = 'Validée';
        break;
      case _Status.rejected:
        bg = const Color(0xFFFDE7EA);
        fg = const Color(0xFFB00020);
        label = 'Rejetée';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }
}

enum _Status { pending, approved, rejected }

class _ServiceRequest {
  final int? id;
  final String name;
  final String service;
  final _Status status;
  final DateTime? createdAt;
  const _ServiceRequest({required this.id, required this.name, required this.service, required this.status, this.createdAt});
}
