import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/repositories/dashboard_repository.dart';
import 'package:myapp/core/data/services/notification_api_service.dart';
import 'package:myapp/core/data/models/dashboard_novice_response.dart';

class NoviceHomePage extends StatefulWidget {
  const NoviceHomePage({super.key});

  @override
  State<NoviceHomePage> createState() => _NoviceHomePageState();
}

class _NoviceHomePageState extends State<NoviceHomePage> {
  late Future<DashboardNoviceResponse> _futureDash;

  @override
  void initState() {
    super.initState();
    _reloadDashboard();
  }

  void _reloadDashboard() {
    _futureDash = DashboardRepository().getNoviceDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: const Color(0xFFFCFAF7),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.house_outlined,
                        color: Color(0xFF6B4F4A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FutureBuilder<DashboardNoviceResponse>(
                      future: _futureDash,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text(
                            'Bienvenue',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF1C120D),
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text(
                            'Bienvenue',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF1C120D),
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }
                        final prenom = snapshot.data?.prenom?.trim();
                        final text = (prenom != null && prenom.isNotEmpty)
                            ? 'Bienvenue $prenom'
                            : 'Bienvenue';
                        return Text(
                          text,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF1C120D),
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  FutureBuilder<int>(
                    future: NotificationApiService().countUnread(),
                    builder: (context, snapshot) {
                      final unread = snapshot.data ?? 0;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            onPressed: () async {
                              await context.push('/Novice/notifications');
                              if (!mounted) return;
                              setState(() {
                                _reloadDashboard();
                              });
                            },
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: Color(0xFF1C120D),
                            ),
                          ),
                          if (unread > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE53935),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  unread > 99 ? '99+' : '$unread',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Mon projet de construction',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF1C120D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<DashboardNoviceResponse>(
                      future: _futureDash,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFFFCFAF7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: const [
                                SizedBox(width: 56, height: 56, child: ColoredBox(color: Color(0xFFEDE7E3))),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 18, child: ColoredBox(color: Color(0xFFEDE7E3))),
                                      SizedBox(height: 8),
                                      SizedBox(height: 12, child: ColoredBox(color: Color(0xFFEDE7E3))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFFFCFAF7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.error_outline, color: Color(0xFFE53935)),
                                    SizedBox(width: 8),
                                    Text('Erreur de chargement du tableau de bord'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text('Veuillez réessayer plus tard.'),
                              ],
                            ),
                          );
                        }
                        final last = snapshot.data?.lastProject;
                        final titre = (last?.titre?.isNotEmpty ?? false) ? last!.titre! : 'Projet de construction';
                        final current = last?.currentEtape ?? '—';
                        final next = last?.prochaineEtape ?? '—';
                        final progress = ((last?.progressPercent ?? 0).clamp(0, 100)) / 100.0;
                        if (last == null) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFFFCFAF7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SizedBox(
                                        width: 56,
                                        height: 56,
                                        child: Image.asset(
                                          'assets/images/mon_projet.png',
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Container(
                                            color: const Color(0xFFEDE7E3),
                                            child: const Icon(
                                              Icons.image_outlined,
                                              color: Color(0xFF6B4F4A),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Aucun projet pour le moment',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              color: const Color(0xFF1C120D),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Vous n\'avez pas encore de projet de construction. Créez un projet et suivez son avancement ici.',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: const Color(0xFF6B4F4A),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          );
                        }
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFFFCFAF7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: Image.asset(
                                        'assets/images/mon_projet.png',
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          color: const Color(0xFFEDE7E3),
                                          child: const Icon(
                                            Icons.image_outlined,
                                            color: Color(0xFF6B4F4A),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          titre,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color: const Color(0xFF1C120D),
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Étape actuelle: $current',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: const Color(0xFF6B4F4A),
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Prochaine étape: $next',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF6B4F4A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 8,
                                      backgroundColor: const Color(0xFFE9DFDC),
                                      valueColor: const AlwaysStoppedAnimation(Color(0xFF5A67D8)),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF3F51B5),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () async {
                                        try {
                                          final dash = await DashboardRepository().getNoviceDashboard();
                                          final id = dash.lastProject?.id;
                                          if (id != null && id != 0) {
                                            // ignore: use_build_context_synchronously
                                            await context.push('/Novice/steps', extra: {'projectId': id});
                                          } else {
                                            // ignore: use_build_context_synchronously
                                            await context.push('/Novice/my-projects');
                                          }
                                        } catch (_) {
                                          // ignore: use_build_context_synchronously
                                          await context.push('/Novice/my-projects');
                                        }
                                        if (!mounted) return;
                                        setState(() {
                                          _reloadDashboard();
                                        });
                                      },
                                      child: const Text('Voir les étapes'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Accès rapide',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF1C120D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickCard(
                            icon: Icons.home,
                            title: 'Mes projets',
                            onTap: () async {
                              await context.push('/Novice/my-projects');
                              if (!mounted) return;
                              setState(() {
                                _reloadDashboard();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickCard(
                            icon: Icons.book,
                            title: 'Guide permis',
                            onTap: () {
                              context.push('/Novice/guide-permis');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _QuickCard(
                      icon: Icons.add,
                      title: 'Créer un projet de construction',
                      onTap: () async {
                        await context.push('/Novice/project-create');
                        if (!mounted) return;
                        setState(() {
                          _reloadDashboard();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _QuickCard(
                      icon: Icons.assignment,
                      title: 'Mes demandes services',
                      onTap: () {
                        () async {
                          try {
                            final dash = await DashboardRepository().getNoviceDashboard();
                            final id = dash.lastProject?.id;
                            if (id != null && id != 0) {
                              // Ouvrir directement les demandes du dernier projet
                              // en passant projectId
                              // ignore: use_build_context_synchronously
                              await context.push('/Novice/service-requests', extra: {'projectId': id});
                            } else {
                              // Aucun dernier projet -> rediriger vers Mes projets
                              // ignore: use_build_context_synchronously
                              await context.push('/Novice/my-projects');
                            }
                          } catch (_) {
                            // En cas d'erreur, fallback Mes projets
                            // ignore: use_build_context_synchronously
                            await context.push('/Novice/my-projects');
                          }
                          if (!mounted) return;
                          setState(() {
                            _reloadDashboard();
                          });
                        }();
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Comment ça marche',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF1C120D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _StepItem(
                      icon: Icons.add_box_outlined,
                      title: 'Créez votre projet de construction',
                    ),
                    _StepItem(
                      icon: Icons.view_list_outlined,
                      title: 'Suivez les étapes de votre projet',
                    ),
                    _StepItem(
                      icon: Icons.message_outlined,
                      title: 'Contactez un pro pour vous aider',
                    ),
                    _StepItem(
                      icon: Icons.fact_check_outlined,
                      title: 'Validez chaque étape à votre rythme',
                    ),
                    const SizedBox(height: 20),
                    _TipCarousel(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Color(0xFFFCFAF7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE5DBD7), // un peu plus contrasté que F2EAE8
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              child: Icon(icon, color: const Color(0xFF1C120D)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF1C120D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final IconData icon;
  final String title;
  const _StepItem({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            child: Icon(icon, color: const Color(0xFF1C120D)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF1C120D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCarousel extends StatefulWidget {
  @override
  State<_TipCarousel> createState() => _TipCarouselState();
}

class _TipCarouselState extends State<_TipCarousel> {
  final controller = PageController();
  int index = 0;
  Timer? _timer;
  final List<Map<String, String>> _tips = [
    {
      'image': 'assets/images/carousel_1.png',
      'title': 'Permis de construire',
      'body':
          'Avant de commencer la construction, assurez-vous d\'avoir tous les permis nécessaires et de bien comprendre les réglementations locales.',
    },
    {
      'image': 'assets/images/Estimation.avif',
      'title': 'Budget et imprévus',
      'body':
          'Ajoutez 10 % de plus à votre budget pour les imprévus. Cela vous permettra d’éviter les blocages en cours de chantier.',
    },
    {
      'image': 'assets/images/doors.jpg',
      'title': 'Choisir les bons pros',
      'body':
          'Comparez plusieurs professionnels, lisez les avis et vérifiez leurs références avant de signer un contrat.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (t) {
      if (!mounted) return;
      if (!controller.hasClients) return;
      final pageCount = _tips.length;
      if (pageCount == 0) return;
      final nextPage = ((index + 1) % pageCount).toDouble();
      controller.animateToPage(
        nextPage.toInt(),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = List.generate(_tips.length, (i) => i);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 358,
          child: PageView.builder(
            controller: controller,
            onPageChanged: (i) => setState(() => index = i),
            itemCount: pages.length,
            itemBuilder: (context, i) {
              final tip = _tips[i];
              return Container(
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(tip['image'] as String),
                    fit: BoxFit.cover,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Conseil du jour',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.white,
                                  fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tip['title'] as String,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tip['body'] as String,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(pages.length, (i) {
            final active = i == index;
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF1C120D)
                    : const Color(0xFFD8CBC7),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }
}
