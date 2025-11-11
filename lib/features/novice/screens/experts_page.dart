import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/services/pro_api_service.dart';

class NoviceExpertsPage extends StatefulWidget {
  const NoviceExpertsPage({super.key, required this.etapeId, this.etapeNom});
  final int etapeId;
  final String? etapeNom;

  @override
  State<NoviceExpertsPage> createState() => _NoviceExpertsPageState();
}

class _NoviceExpertsPageState extends State<NoviceExpertsPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = ProApiService().listProfessionnelsForEtape(widget.etapeId);
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
                  'Trouver un expert',
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Erreur: ${snap.error}'));
          }
          final items = snap.data ?? const <Map<String, dynamic>>[];
          if (items.isEmpty) {
            return Center(
              child: Text(
                'Aucun expert disponible pour cette étape pour le moment',
                style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B4F4A)),
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemBuilder: (context, i) => _ExpertTile(
              data: items[i],
              etapeId: widget.etapeId,
              etapeNom: widget.etapeNom,
            ),
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemCount: items.length,
          );
        },
      ),
    );
  }
}

class _ExpertTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final int etapeId;
  final String? etapeNom;
  const _ExpertTile({required this.data, required this.etapeId, this.etapeNom});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prenom = (data['prenom'] ?? '').toString();
    final nom = (data['nom'] ?? '').toString();
    final name = [prenom, nom].where((e) => e.trim().isNotEmpty).join(' ');
    final role = (data['specialiteLibelle'] ?? '').toString();
    final id = data['id'] is int ? data['id'] as int : int.tryParse((data['id'] ?? '').toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFE7E3DF),
              child: const Icon(Icons.person, color: Color(0xFF6B4F4A)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : (data['entreprise'] ?? '').toString(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF1C120D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (role.isNotEmpty)
                    Text(
                      role,
                      style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B4F4A)),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onPressed: id == null
                  ? null
                  : () {
                      context.push('/Novice/experts/detail', extra: {'professionnelId': id});
                    },
              child: const Text('Voir plus'),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onPressed: id == null
                  ? null
                  : () async {
                      final display = name.isNotEmpty ? name : (data['entreprise'] ?? '').toString();
                      final label = (etapeNom != null && etapeNom!.trim().isNotEmpty) ? etapeNom! : 'n° $etapeId';
                      final msg = "Bonjour, je souhaite vous contacter pour l'étape $label de mon projet.";
                      try {
                        final api = ProApiService();
                        final demandeId = await api.createDemandeForEtape(
                          etapeId: etapeId,
                          professionnelId: id,
                          message: msg,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Demande envoyée à $display (ID: $demandeId)')),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        final errMsg = _extractErrMsg(e);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errMsg)),
                        );
                      }
                    },
              child: const Text('Contacter'),
            ),
          ],
        ),
      ],
    );
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
      if (status != null) return 'Erreur ($status) lors de l\'envoi de la demande';
    } catch (_) {}
    return 'Une erreur est survenue lors de l\'envoi de la demande';
  }
}
