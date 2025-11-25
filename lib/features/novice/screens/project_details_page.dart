import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/services/pro_api_service.dart';
import 'package:myapp/core/data/services/project_api_service.dart';

class NoviceProjectDetailsPage extends StatefulWidget {
  const NoviceProjectDetailsPage({super.key, required this.projectId});
  final int projectId;

  @override
  State<NoviceProjectDetailsPage> createState() => _NoviceProjectDetailsPageState();
}

class _NoviceProjectDetailsPageState extends State<NoviceProjectDetailsPage> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;

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
      final api = ProApiService();
      final res = await api.getProjetById(widget.projectId);
      if (!mounted) return;
      setState(() {
        _data = res;
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
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1C120D)),
              ),
              Expanded(
                child: Text(
                  'Details du projet',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1C120D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: _confirmDelete,
                icon: const Icon(Icons.delete_outline, color: Color(0xFFB91C1C)),
              ),
            ],
          ),
        ),
      ),
      body: _buildBody(theme),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le projet ?'),
          content: const Text('Cette action est définitive. Voulez-vous vraiment supprimer ce projet ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteProject();
    }
  }

  Future<void> _deleteProject() async {
    try {
      await ProjectApiService().deleteMyProject(projectId: widget.projectId);
      if (!mounted) return;
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression: $e')),
      );
    }
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
    final d = _data!;
    final titre = (d['titre'] ?? '').toString();
    final dimensions = (d['dimensionsTerrain'] ?? '').toString();
    final budget = _parseDouble(d['budget']);
    final localisation = (d['localisation'] ?? '').toString();
    final totalEtapes = _parseInt(d['totalEtapes']);
    final etapesValidees = _parseInt(d['etapesValidees']);
    final dateCreation = _parseDate(d['dateCreation']);
    final currentEtapeLabel = (d['currentEtape'] ?? '').toString();

    final progress = (totalEtapes > 0) ? (etapesValidees / totalEtapes) : 0.0;
    final progressPercent = (progress * 100).clamp(0, 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progression
          Text('Progression', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('$progressPercent%', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 6),
          _ProgressBar(value: progress),
          const SizedBox(height: 6),
          Text('${etapesValidees}/${totalEtapes}', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF7D7D7D))),
          const SizedBox(height: 20),

          // Aperçu du projet
          Text('Aperçu du projet', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFE7E4E0)),
          const SizedBox(height: 8),
          _TwoColsRow(
            leftLabel: 'Dimensions',
            leftValue: dimensions,
            rightLabel: 'Budget',
            rightValue: budget != null ? '${_formatAmount(budget)} CFA' : '-',
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFE7E4E0)),
          const SizedBox(height: 10),
          _TwoColsRow(
            leftLabel: 'Location',
            leftValue: localisation,
            rightLabel: 'Start Date',
            rightValue: dateCreation != null ? _formatDate(dateCreation) : '-',
          ),
          const SizedBox(height: 24),

          // Étape actuelle
          Text('Étape actuelle', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.home_outlined, color: Color(0xFF1C120D)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Étape ${etapesValidees + 1}', style: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFF1C120D))),
                    Text(
                      currentEtapeLabel.isNotEmpty ? currentEtapeLabel : '-',
                      style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF7D7D7D)),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => context.push('/Novice/steps', extra: {'projectId': widget.projectId}),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Voir les étapes'),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  double? _parseDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  DateTime? _parseDate(dynamic v) {
    if (v is String) {
      try { return DateTime.parse(v); } catch (_) {}
    }
    return null;
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd-$mm-$yy';
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

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});
  final double value;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 8,
        backgroundColor: const Color(0xFFE7E4E0),
        valueColor: const AlwaysStoppedAnimation(Color(0xFF1C120D)),
      ),
    );
  }
}

class _TwoColsRow extends StatelessWidget {
  const _TwoColsRow({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });
  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF7D7D7D));
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF1C120D));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(leftLabel, style: labelStyle),
              const SizedBox(height: 6),
              Text(leftValue.isEmpty ? '-' : leftValue, style: valueStyle),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rightLabel, style: labelStyle),
              const SizedBox(height: 6),
              Text(rightValue.isEmpty ? '-' : rightValue, style: valueStyle),
            ],
          ),
        ),
      ],
    );
  }
}
