import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/services/project_api_service.dart';
import 'package:myapp/core/network/api_config.dart';

class NoviceStepsPage extends StatefulWidget {
  const NoviceStepsPage({super.key, required this.projectId});
  final int projectId;

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
      final pid = widget.projectId;
      final list = await api.getProjectSteps(projectId: pid);
      // Normalize and sort by ordre (on transporte aussi l'URL d'image de profil si présente)
      final normalized = list.map<Map<String, dynamic>>((e) => {
            'ordre': _asInt(e['ordre']),
            'estValider': _asBool(e['estValider']),
            'modeleNom': (e['modeleNom'] ?? '').toString(),
            'etapeId': _asInt(e['etapeId']),
            'imageProfilUrl': (e['imageProfilUrl'] ?? '').toString(),
          }).toList(growable: false)
        ..sort((a, b) => (a['ordre'] as int).compareTo(b['ordre'] as int));

      // Find first non-validated step index
      final firstPendingIdx = normalized.indexWhere((e) => e['estValider'] == false);

      final mapped = normalized.map<_Step>((e) {
        final ordre = e['ordre'] as int;
        final estValider = e['estValider'] as bool;
        final nom = e['modeleNom'] as String;
        final etapeId = e['etapeId'] as int;
        // On convertit en String de manière défensive pour éviter les erreurs de cast
        final rawImageProfil = (e['imageProfilUrl'] ?? '').toString();
        String? fullImageUrl;
        if (rawImageProfil.isNotEmpty) {
          // Si le backend renvoie une URL absolue, on l'utilise telle quelle,
          // sinon on la préfixe avec l'URL de base de l'API (qui inclut déjà /api/v1).
          if (rawImageProfil.startsWith('http://') || rawImageProfil.startsWith('https://')) {
            fullImageUrl = rawImageProfil;
          } else {
            // Exemple: baseUrl = http://<ip>:8080/api/v1 et imageProfilUrl = /uploads/...
            // Résultat: http://<ip>:8080/api/v1/uploads/...
            fullImageUrl = ApiConfig.baseUrl + rawImageProfil;
          }
        }
        String subtitle;
        if (estValider) {
          subtitle = 'Terminé';
        } else if (firstPendingIdx != -1 && normalized[firstPendingIdx]['ordre'] == ordre) {
          subtitle = 'En cours';
        } else {
          subtitle = 'À venir';
        }
        return _Step(
          title: nom.isNotEmpty ? nom : 'Étape ${ordre > 0 ? ordre : ''}'.trim(),
          subtitle: subtitle,
          ordre: ordre,
          imageUrl: fullImageUrl,
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
              child: data.imageUrl != null && data.imageUrl!.isNotEmpty
                  ? Image.network(
                      data.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : const ColoredBox(
                      color: Color(0xFFE8E4E1),
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Color(0xFF6B4F4A),
                          size: 32,
                        ),
                      ),
                    ),
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
                  final pid = context.findAncestorStateOfType<_NoviceStepsPageState>()!.widget.projectId;
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
  final String? imageUrl;
  final int ordre;
  final int etapeId;
  const _Step({required this.title, required this.subtitle, this.imageUrl, required this.ordre, required this.etapeId});
}
