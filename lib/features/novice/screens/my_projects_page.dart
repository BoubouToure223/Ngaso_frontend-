import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/repositories/project_repository.dart';

class NoviceMyProjectsPage extends StatefulWidget {
  const NoviceMyProjectsPage({super.key});

  @override
  State<NoviceMyProjectsPage> createState() => _NoviceMyProjectsPageState();
}

class _NoviceMyProjectsPageState extends State<NoviceMyProjectsPage> {
  bool _loading = true;
  String? _error;
  List<_Project> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final repo = ProjectRepository();
      final list = await repo.listMyProjects();
      list.sort((a, b) {
        DateTime parse(dynamic v) {
          if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
          final s = v.toString();
          try {
            return DateTime.parse(s).toLocal();
          } catch (_) {
            return DateTime.fromMillisecondsSinceEpoch(0);
          }
        }

        final da = parse(a['dateCreation']);
        final db = parse(b['dateCreation']);
        return db.compareTo(da);
      });

      final mapped = list.map<_Project>((m) => _Project(
        id: _toInt(m['id']) ?? 0,
        title: (m['titre'] ?? '').toString(),
        budget: _formatAmount(_toDouble(m['budget']) ?? 0) + ' CFA',
        size: (m['dimensionsTerrain'] ?? '').toString(),
      )).toList();
      if (!mounted) return;
      setState(() { _items = mapped; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
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
                    'Mes Projets',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF1C120D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final before = _items.length;
                    await context.push('/Novice/project-create');
                    if (mounted) _load();
                  },
                  icon: const Icon(Icons.add, color: Color(0xFF1C120D)),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      final raw = _error!;
      final msg = raw.startsWith('Exception: ') ? raw.substring('Exception: '.length) : raw;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(msg),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _load, child: const Text('Réessayer')),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(child: Text('Aucun projet'));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, i) => _ProjectTile(
        data: _items[i],
        onChanged: _load,
      ),
    );
  }

  int? _toInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    if (v is double) return v.toInt();
    return null;
  }

  double? _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  String _formatAmount(double n) {
    final s = n.toStringAsFixed(0);
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buf.write(s[i]);
      count++;
      if (count == 3 && i != 0) {
        buf.write(',');
        count = 0;
      }
    }
    return buf.toString().split('').reversed.join();
  }
}

class _ProjectTile extends StatelessWidget {
  final _Project data;
  final Future<void> Function() onChanged;
  const _ProjectTile({required this.data, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                'Budget: ${data.budget}',
                style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B4F4A)),
              ),
              Text(
                'Terrain: ${data.size}',
                style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B4F4A)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F51B5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () async {
                          final res = await context.push('/Novice/project-details', extra: {'projectId': data.id});
                          if (res == true) {
                            await onChanged();
                          }
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Voir détails'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1C120D),
                          side: const BorderSide(color: Color(0xFFE7E3DF)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () {
                          context.push('/Novice/service-requests', extra: {'projectId': data.id});
                        },
                        icon: const Icon(Icons.assignment),
                        label: const Text('Voir demandes'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFF0E5E1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.house_outlined, size: 36, color: Color(0xFF7A4C3A)),
        ),
      ],
    );
  }
}

class _Project {
  final int id;
  final String title;
  final String budget;
  final String size;
  const _Project({required this.id, required this.title, required this.budget, required this.size});
}

// Les données sont désormais chargées depuis l'API /projets/me
