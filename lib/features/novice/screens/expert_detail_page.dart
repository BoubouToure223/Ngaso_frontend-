import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/services/pro_api_service.dart';
import 'package:myapp/core/widgets/auth_image.dart';
import 'package:myapp/core/network/api_config.dart';

class NoviceExpertDetailPage extends StatefulWidget {
  const NoviceExpertDetailPage({super.key, this.professionnelId});
  final int? professionnelId;

  @override
  State<NoviceExpertDetailPage> createState() => _NoviceExpertDetailPageState();
}

class _NoviceExpertDetailPageState extends State<NoviceExpertDetailPage> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    final id = widget.professionnelId ?? 0;
    _future = ProApiService().getProfessionnelProfil(id);
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
                  "Détails de l'expert",
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Erreur: ${snap.error}'));
          }
          final data = snap.data ?? const {};
          final prenom = (data['prenom'] ?? '').toString();
          final nom = (data['nom'] ?? '').toString();
          final name = [prenom, nom].where((e) => e.toString().trim().isNotEmpty).join(' ');
          final role = (data['specialiteLibelle'] ?? '').toString();
          final tel = (data['telephone'] ?? '').toString();
          final addr = (data['adresse'] ?? '').toString();
          final ent = (data['entreprise'] ?? '').toString();
          final desc = (data['description'] ?? '').toString();
          final List<String> realisations = () {
            final raw = data['realisations'];
            final out = <String>[];
            if (raw is List) {
              for (final it in raw) {
                if (it is String) {
                  final u = _absUrl(it);
                  if (u != null && u.isNotEmpty) out.add(u);
                } else if (it is Map) {
                  final s = (it['imageUrl'] ?? it['url'] ?? it['image'])?.toString();
                  final u = _absUrl(s);
                  if (u != null && u.isNotEmpty) out.add(u);
                }
              }
            }
            return out;
          }();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (realisations.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: AuthImage(url: realisations.first),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  name.isNotEmpty ? name : ent,
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
                const SizedBox(height: 16),
                Text(
                  'Informations de contact',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF1C120D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                if (tel.isNotEmpty) _InfoRow(icon: Icons.phone, text: tel),
                if (addr.isNotEmpty) _InfoRow(icon: Icons.location_on_outlined, text: addr),
                if (ent.isNotEmpty) _InfoRow(icon: Icons.apartment_outlined, text: ent),
                const SizedBox(height: 16),
                Text(
                  'À propos de cet expert',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF1C120D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc.isNotEmpty ? desc : '—',
                  style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF1C120D)),
                ),
                if (realisations.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Réalisations',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF1C120D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: realisations.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final url = realisations[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 200,
                            height: 120,
                            child: AuthImage(url: url, fit: BoxFit.cover),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String? _absUrl(String? u) {
    if (u == null || u.isEmpty) return null;
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    final base = Uri.parse(ApiConfig.baseUrl);
    final basePath = base.path; // e.g. /api/v1
    var path = u;
    // Ensure path starts with '/'
    if (!path.startsWith('/')) path = '/$path';
    // If the path wrongly includes the API base path, strip it
    if (basePath.isNotEmpty && path.startsWith(basePath)) {
      path = path.substring(basePath.length);
      if (!path.startsWith('/')) path = '/$path';
    }
    // Return '/uploads/...' (or any absolute path). AuthImage will resolve to origin.
    return path;
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6B4F4A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF1C120D)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Project {
  final String title;
  final String imageAsset;
  const _Project({required this.title, required this.imageAsset});
}

const _projects = <_Project>[
  _Project(title: 'Projet 1', imageAsset: 'assets/images/etape5_img.png'),
  _Project(title: 'Projet 2', imageAsset: 'assets/images/etape4_img.png'),
  _Project(title: 'Projet 3', imageAsset: 'assets/images/etape3_img.png'),
];
