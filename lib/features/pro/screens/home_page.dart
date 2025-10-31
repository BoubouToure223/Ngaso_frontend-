import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:myapp/core/data/services/pro_api_service.dart';
import 'package:myapp/core/data/models/pro_dashboard.dart';
import 'package:myapp/core/storage/token_storage.dart';
import 'package:myapp/core/network/api_config.dart';
import 'package:myapp/core/widgets/auth_image.dart';

/// Page d'accueil (Espace Pro).
///
/// - En-tête fixe avec logo et bouton notifications.
/// - Cartes KPI cliquables (propositions, demandes, messages).
/// - Liste de projets disponibles (accès rapide à la création de proposition).
/// - Section "Vos réalisations" avec galerie horizontale.
class ProHomePage extends StatefulWidget {
  const ProHomePage({super.key, required this.professionnelId});
  final int professionnelId;

  @override
  State<ProHomePage> createState() => _ProHomePageState();
}

class _ProHomePageState extends State<ProHomePage> {
  Future<ProDashboard>? _future;
  int? _proId;

  String? _absUrl(String? u) {
    if (u == null) return null;
    u = u.trim();
    if (u.isEmpty) return null;
    // Normalize Windows backslashes
    u = u.replaceAll('\\', '/');
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    final base = Uri.parse(ApiConfig.baseUrl);
    final origin = '${base.scheme}://${base.host}${base.hasPort ? ':${base.port}' : ''}';
    if (u.startsWith('/')) return '$origin$u';
    return '$origin/$u';
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final id = await _resolveProfessionnelId(widget.professionnelId);
    if (!mounted) return;
    setState(() {
      _proId = id;
      if (id != 0) {
        _future = ProApiService().getDashboard(professionnelId: id);
      } else {
        _future = null;
      }
    });
  }

  Future<int> _resolveProfessionnelId(int incoming) async {
    if (incoming != 0) return incoming;
    // Decode JWT to get user id from 'sub'
    final token = await TokenStorage.instance.readToken();
    if (token == null || token.isEmpty) return 0;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return 0;
      String normalized = base64Url.normalize(parts[1]);
      final payloadJson = utf8.decode(base64Url.decode(normalized));
      final payload = json.decode(payloadJson);
      final sub = payload['sub'];
      if (sub is String) return int.tryParse(sub) ?? 0;
      if (sub is int) return sub;
      final userId = payload['userId'];
      if (userId is int) return userId;
      if (userId is String) return int.tryParse(userId) ?? 0;
      return 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // En-tête fixe: logo + notifications et message d'accueil
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barre du haut: logo à gauche et notifications à droite
                  Row(
                    children: [
                      // Placeholder du logo de l'app
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/Mini logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.notifications_none),
                        color: const Color(0xFF1C120D),
                        onPressed: () {
                          context.go('/pro/notifications');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<ProDashboard>(
                    future: _future,
                    builder: (context, snap) {
                      final title = snap.hasData ? 'Bienvenue ${snap.data!.prenom} 👋' : 'Bienvenue 👋';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(color: const Color(0xFF2C3E50)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Voici un aperçu de votre activité aujourd'hui.",
                            style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF333333)),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            // Contenu scrollable: KPI, projets, réalisations
            Expanded(
              child: _future == null
                  ? const Center(child: CircularProgressIndicator())
                  : FutureBuilder<ProDashboard>(
                future: _future!,
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
                          Text(
                            'Impossible de charger le tableau de bord',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snap.error.toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (_proId == null || _proId == 0) {
                                  _init();
                                } else {
                                  setState(() {
                                    _future = ProApiService().getDashboard(professionnelId: _proId!);
                                  });
                                }
                              },
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Réessayer'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final data = snap.data;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => context.go('/pro/proposition-details'),
                                  child: _StatCard(
                                    emoji: '📬',
                                    title: 'Propositions',
                                    value: data != null ? (data.propositionsEnAttente + data.propositionsValidees).toString() : '-',
                                    subtitle: data != null ? '${data.propositionsEnAttente} en attente, ${data.propositionsValidees} validées' : '',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => context.go('/pro/service-requests'),
                                  child: _StatCard(
                                    emoji: '🧾',
                                    title: 'Demande de service',
                                    value: data != null ? data.demandesTotal.toString() : '-',
                                    subtitle: 'Envoyés',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => context.go('/pro/messages'),
                                  child: _StatCard(
                                    emoji: '💬',
                                    title: 'Messages',
                                    value: data != null ? data.messagesNonLus.toString() : '-',
                                    subtitle: data != null ? '${data.messagesNonLus} non lus' : '',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Projets disponibles 🔥',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => context.go('/pro/projet'),
                              icon: const Icon(Icons.chevron_right, size: 18),
                              label: const Text('Voir tout'),
                              style: TextButton.styleFrom(foregroundColor: const Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (data != null && data.derniersProjets.isNotEmpty) ...[
                          for (final p in data.derniersProjets) ...[
                            _ProjectCard(
                              title: (p['titre'] ?? p['title'] ?? 'Projet').toString(),
                              location: (p['lieu'] ?? p['location'] ?? p['localisation'] ?? '-').toString(),
                              budget: (p['budget'] ?? '-').toString(),
                              dateText: (p['dateCreation'] ?? p['date'] ?? '').toString(),
                              onPropose: () {
                                final dynamic rawId = p['id'];
                                int? pid;
                                if (rawId is int) pid = rawId;
                                if (rawId is String) pid = int.tryParse(rawId);
                                if (pid != null) {
                                  context.push('/pro/proposition-create', extra: {
                                    'projectId': pid,
                                    'projectTitle': (p['titre'] ?? p['title'] ?? 'Projet').toString(),
                                    'projectLocation': (p['lieu'] ?? p['location'] ?? p['localisation'] ?? '-').toString(),
                                    'projectBudget': p['budget'],
                                  });
                                } else {
                                  context.push('/pro/proposition-create');
                                }
                              },
                              onTap: () {
                                final dynamic rawId = p['id'];
                                int? pid;
                                if (rawId is int) pid = rawId;
                                if (rawId is String) pid = int.tryParse(rawId);
                                if (pid != null) {
                                  context.push('/pro/proposition-create', extra: {
                                    'projectId': pid,
                                    'projectTitle': (p['titre'] ?? p['title'] ?? 'Projet').toString(),
                                    'projectLocation': (p['lieu'] ?? p['location'] ?? p['localisation'] ?? '-').toString(),
                                    'projectBudget': p['budget'],
                                  });
                                } else {
                                  context.push('/pro/proposition-create');
                                }
                              },
                              primary: const Color(0xFF3F51B5),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Vos réalisations',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF2C3E50)),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/pro/realizations'),
                              child: const Text('Voir tout'),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 140,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                if (data != null && data.realisations.isNotEmpty)
                                  for (final r in data.realisations)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          width: 200,
                                          height: 140,
                                          color: Colors.white,
                                          child: () {
                                            String? rawUrl;
                                            String? title;
                                            if (r is String) {
                                              rawUrl = r;
                                            } else if (r is Map) {
                                              rawUrl = (r['imageUrl'] ?? r['url'] ?? r['image'])?.toString();
                                              title = (r['titre'] ?? r['title'])?.toString();
                                            }
                                            final resolved = _absUrl(rawUrl);
                                            if (resolved != null) {
                                              return AuthImage(url: resolved, fit: BoxFit.cover);
                                            }
                                            return Center(
                                              child: Text(
                                                title ?? 'Réalisation',
                                                style: theme.textTheme.bodySmall,
                                              ),
                                            );
                                          }(),
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte KPI (statistique) avec émoji, titre, valeur et sous-titre.
///
/// Utilisée pour afficher des statistiques clés sur la page d'accueil.
class _StatCard extends StatelessWidget {
  const _StatCard({required this.emoji, required this.title, required this.value, required this.subtitle});
  final String emoji;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 106),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 33,
            height: 32,
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: const Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte projet compacte pour l'accueil Pro (tap -> action, CTA -> proposer).
///
/// Utilisée pour afficher les projets disponibles sur la page d'accueil.
class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.title,
    required this.location,
    required this.budget,
    required this.dateText,
    required this.onPropose,
    required this.primary,
    this.onTap,
  });

  final String title;
  final String location;
  final String budget;
  final String dateText;
  final VoidCallback onPropose;
  final Color primary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 16, color: Color(0xFF0F172A)),
                const SizedBox(width: 6),
                Text(location, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF0F172A))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 16, color: Color(0xFF0F172A)),
                    const SizedBox(width: 4),
                    Text(budget, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: const Color(0xFF0F172A))),
                  ],
                ),
                Text(dateText, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B))),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPropose,
                icon: const Icon(Icons.send, size: 16),
                label: const Text('Faire une proposition'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
