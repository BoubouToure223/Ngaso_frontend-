import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoviceServiceRequestsPage extends StatefulWidget {
  const NoviceServiceRequestsPage({super.key});

  @override
  State<NoviceServiceRequestsPage> createState() => _NoviceServiceRequestsPageState();
}

class _NoviceServiceRequestsPageState extends State<NoviceServiceRequestsPage> {
  int selectedIndex = 0; // 0=Toutes,1=Attente,2=Validées,3=Rejetées

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _mockRequests.where((e) {
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
              counts: const [4, 2, 1, 1],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _RequestCard(data: items[i]),
            ),
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
  const _RequestCard({required this.data});

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
                    Text(
                      data.service,
                      style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B4F4A)),
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Demande annulée')),
                  );
                },
                child: const Text('Annuler'),
              ),
            ),
          ],
        ],
      ),
    );
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
  final String name;
  final String service;
  final _Status status;
  const _ServiceRequest({required this.name, required this.service, required this.status});
}

const _mockRequests = <_ServiceRequest>[
  _ServiceRequest(name: 'Mamadou Traoré', service: 'Obtention du permis de construire', status: _Status.pending),
  _ServiceRequest(name: 'Mamadou Traoré', service: 'Obtention du permis de construire', status: _Status.approved),
  _ServiceRequest(name: 'Mamadou Traoré', service: 'Obtention du permis de construire', status: _Status.rejected),
  _ServiceRequest(name: 'Mamadou Traoré', service: 'Obtention du permis de construire', status: _Status.pending),
];
