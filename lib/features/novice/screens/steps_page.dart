import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/services/project_api_service.dart';

class NoviceStepsPage extends StatefulWidget {
  const NoviceStepsPage({super.key, this.projectId});
  final int? projectId; // TODO: brancher l'id réel via navigation

  @override
  State<NoviceStepsPage> createState() => _NoviceStepsPageState();
}

class _NoviceStepsPageState extends State<NoviceStepsPage> {
  bool _loading = true;
  String? _error;
  List<_Step> _steps = const [];

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
    try {
      final api = ProjectApiService();
      final pid = widget.projectId ?? 1; // fallback temporaire
      final list = await api.getProjectSteps(projectId: pid);
      final mapped = list.map<_Step>((e) {
        final ordre = _asInt(e['ordre']);
        final estValider = _asBool(e['estValider']);
        final nom = (e['modeleNom'] ?? '').toString();
        final etapeId = _asInt(e['etapeId']);
        return _Step(
          title: nom.isNotEmpty ? nom : 'Étape ${ordre > 0 ? ordre : ''}'.trim(),
          subtitle: estValider ? 'Terminé' : 'À venir',
          ordre: ordre,
          imageAsset: _imageForOrdre(ordre),
          etapeId: etapeId,
        );
      }).toList(growable: false);
      if (!mounted) return;
      setState(() {
        _steps = mapped;
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

  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  bool _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true' || v == '1';
    if (v is num) return v != 0;
    return false;
  }

  String _imageForOrdre(int ordre) {
    switch (ordre) {
      case 1:
        return 'assets/images/etape1_img.png';
      case 2:
        return 'assets/images/etape2_img.png';
      case 3:
        return 'assets/images/etape3_img.png';
      case 4:
        return 'assets/images/etape4_img.png';
      case 5:
        return 'assets/images/etape5_img.png';
      case 6:
        return 'assets/images/etape6_img.png';
      default:
        return 'assets/images/etape1_img.png';
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
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1C120D)),
              ),
              Expanded(
                child: Text(
                  'Guide de construction',
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
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      final raw = _error!;
      final msg = raw.startsWith('Exception: ') ? raw.substring('Exception: '.length) : raw;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(msg, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _load, child: const Text('Réessayer')),
          ],
        ),
      );
    }

    final steps = _steps;
    final done = steps.where((e) => e.subtitle.toLowerCase().contains('termin')).length;
    final total = steps.length;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suivez et validez chaque étape de votre projet de maison.',
            style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B4F4A)),
          ),
          const SizedBox(height: 12),
          Text('Progression', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF1C120D))),
          const SizedBox(height: 8),
          _Progress(value: _computeProgress(steps), done: done, total: total),
          const SizedBox(height: 16),
          for (final s in steps) _StepCard(data: s),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  double _computeProgress(List<_Step> steps) {
    if (steps.isEmpty) return 0.0;
    final done = steps.where((e) => e.subtitle.toLowerCase().contains('termin')).length;
    return done / steps.length;
  }
}

class _Progress extends StatelessWidget {
  final double value;
  final int done;
  final int total;
  const _Progress({required this.value, required this.done, required this.total});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (value * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$percent%', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B4F4A))),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value,
          minHeight: 6,
          backgroundColor: const Color(0xFFE8E4E1),
          valueColor: const AlwaysStoppedAnimation(Color(0xFF3F51B5)),
        ),
        const SizedBox(height: 6),
        Text('$done/$total', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B4F4A))),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final _Step data;
  const _StepCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(data.imageAsset, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Étape ${data.ordre}',
                      style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF7D7D7D)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF1C120D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      data.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B4F4A)),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final etapeId = data.etapeId;
                  final pid = (context.findAncestorStateOfType<_NoviceStepsPageState>()?.widget.projectId) ?? 1;
                  context.push('/Novice/step-details/$etapeId', extra: {'projectId': pid});
                },
                child: const Text('Voir détails'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Step {
  final String title;
  final String subtitle;
  final String imageAsset;
  final int ordre;
  final int etapeId;
  const _Step({required this.title, required this.subtitle, required this.imageAsset, required this.ordre, required this.etapeId});
}
