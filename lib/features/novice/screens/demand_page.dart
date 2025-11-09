import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/services/pro_api_service.dart';
import 'package:myapp/core/network/api_config.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DemandPage extends StatefulWidget {
  const DemandPage({super.key});

  @override
  State<DemandPage> createState() => _DemandPageState();
}

class _DemandPageState extends State<DemandPage> {
  late Future<List<_Demand>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<List<_Demand>> _fetch() async {
    final raw = await ProApiService().getMyNovicePropositions();
    return raw.map<_Demand>((e) => _mapToDemand(e)).toList(growable: false);
  }

  _Demand _mapToDemand(dynamic e) {
    if (e is! Map) return const _Demand(category: '—', proName: '—', price: '—', description: '—');
    final m = e as Map;
    int? id;
    final rid = m['id'];
    if (rid is int) id = rid; else if (rid is String) id = int.tryParse(rid);
    final montant = m['montant'];
    String price = '—';
    if (montant is num) price = '${montant.toStringAsFixed(0)} CFA';
    if (montant is String) price = '$montant CFA';
    final prof = (m['professionnel'] is Map) ? (m['professionnel'] as Map) : const {};
    int? proId;
    final pid = prof['id'];
    if (pid is int) proId = pid; else if (pid is String) proId = int.tryParse(pid);
    final prenom = (prof['prenom'] ?? '').toString();
    final nom = (prof['nom'] ?? '').toString();
    final proName = [prenom, nom].where((s) => s.toString().trim().isNotEmpty).join(' ').trim().isNotEmpty
        ? [prenom, nom].where((s) => s.toString().trim().isNotEmpty).join(' ')
        : (prof['entreprise']?.toString() ?? '—');
    final category = (prof['specialiteLibelle'] ?? 'Proposition').toString();
    final description = (m['description'] ?? '').toString();
    final rawStatus = (m['statut'] ?? m['status'] ?? m['etat'] ?? '').toString();
    final status = rawStatus.isEmpty ? null : rawStatus;
    // Map possible devis URL fields from API
    dynamic devisField = m['devis'] ?? m['devisUrl'] ?? m['devis_url'] ?? m['urlDevis'] ?? m['fichierDevis'] ?? m['quote'] ?? m['quoteUrl'];
    String? devisUrl;
    if (devisField is String) {
      devisUrl = devisField.trim().isEmpty ? null : devisField.trim();
    } else if (devisField is Map) {
      final url = (devisField['url'] ?? devisField['link'] ?? devisField['href'] ?? devisField['path'] ?? '').toString();
      devisUrl = url.trim().isEmpty ? null : url.trim();
    }
    if (devisUrl != null && devisUrl!.isNotEmpty) {
      final u = devisUrl!;
      if (!(u.startsWith('http://') || u.startsWith('https://'))) {
        final base = ApiConfig.baseUrl.replaceFirst(RegExp(r'/+$'), '');
        final path = u.startsWith('/') ? u : '/$u';
        devisUrl = '$base$path';
      }
    }
    return _Demand(
      id: id,
      proId: proId,
      category: category,
      proName: proName.isEmpty ? '—' : proName,
      price: price,
      description: description.isEmpty ? '—' : description,
      status: status,
      devisUrl: devisUrl,
    );
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
              
              Expanded(
                child: Text(
                  'Mes propositions de devis',
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
      body: FutureBuilder<List<_Demand>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Erreur', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(snap.error.toString(), style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B))),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _future = _fetch()),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          final items = snap.data ?? const <_Demand>[];
          if (items.isEmpty) {
            return const Center(child: Text('Aucune proposition'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              final d = items[i];
              Future<void> Function()? onAccept;
              Future<void> Function()? onRefuse;
              if (d.id != null) {
                onAccept = () async {
                  try {
                    await ProApiService().acceptMyNoviceProposition(d.id!);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Proposition acceptée: ${d.proName}')),
                    );
                    setState(() => _future = _fetch());
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec: $e')));
                  }
                };
                onRefuse = () async {
                  try {
                    await ProApiService().refuseMyNoviceProposition(d.id!);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Proposition refusée: ${d.proName}')),
                    );
                    setState(() => _future = _fetch());
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec: $e')));
                  }
                };
              }
              return _DemandCard(data: d, onAccept: onAccept, onRefuse: onRefuse);
            },
          );
        },
      ),
    );
  }
}

class _DemandCard extends StatelessWidget {
  final _Demand data;
  final Future<void> Function()? onAccept;
  final Future<void> Function()? onRefuse;
  const _DemandCard({required this.data, this.onAccept, this.onRefuse});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = (data.status ?? '').toUpperCase();
    final bool isAccepted = s.contains('ACCEP');
    final bool isRefused = s.contains('REFUS');
    final Color borderColor = isAccepted
        ? const Color(0xFF2E7D32)
        : isRefused
            ? const Color(0xFFB23B3B)
            : const Color(0xFFE7E3DF);
    final Color bgColor = isAccepted
        ? const Color(0xFFE8F5E9)
        : isRefused
            ? const Color(0xFFFFEBEE)
            : Colors.white;
    final String? statusLabel = isAccepted
        ? 'Acceptée'
        : isRefused
            ? 'Refusée'
            : null;
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (statusLabel != null)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isAccepted ? const Color(0xFF2E7D32) : const Color(0xFFB23B3B),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isAccepted ? Icons.check_circle : Icons.block, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(statusLabel, style: theme.textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.proName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF1C120D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.category,
                      style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B4F4A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Devis estimé à ${data.price}',
                      style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B4F4A)),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF3F51B5)),
                          foregroundColor: const Color(0xFF3F51B5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () {
                          context.push('/Novice/experts/detail', extra: {
                            'professionnelId': data.proId,
                          });
                        },
                        child: const Text('Voir profil'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 92,
                  height: 92,
                  color: const Color(0xFFF0E5E1),
                  child: const Icon(Icons.person, size: 48, color: Color(0xFF7A4C3A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.description,
            style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B4F4A)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB23B3B),
                    side: const BorderSide(color: Color(0xFFE7DCD5)),
                    backgroundColor: const Color(0xFFFAF2EE),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final url = data.devisUrl;
                    if (url == null || url.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Aucun devis disponible pour cette proposition.')),
                      );
                      return;
                    }
                    try {
                      final ok = await launchUrlString(url);
                      if (!ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Impossible d'ouvrir le devis.")),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur lors de l\'ouverture du devis: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('Télécharger le devis'),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: (onAccept == null || isAccepted || isRefused) ? null : () async { await onAccept!(); },
                child: Text(isAccepted ? 'Acceptée' : 'Accepter'),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
              onPressed: (onRefuse == null || isAccepted || isRefused) ? null : () async { await onRefuse!(); },
              child: Text(isRefused ? 'Refusée' : 'Refuser'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Demand {
  final int? id;
  final int? proId;
  final String category;
  final String proName;
  final String price;
  final String description;
  final String? status;
  final String? devisUrl;

  const _Demand({
    this.id,
    this.proId,
    required this.category,
    required this.proName,
    required this.price,
    required this.description,
    this.status,
    this.devisUrl,
  });
}

const _mockDemands = <_Demand>[];
