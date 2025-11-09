import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/services/project_api_service.dart';
import 'package:myapp/core/network/api_config.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoviceStepDetailPage extends StatefulWidget {
  const NoviceStepDetailPage({super.key, required this.etapeId, required this.projectId});
  final int etapeId;
  final int projectId;

  @override
  State<NoviceStepDetailPage> createState() => _NoviceStepDetailPageState();
}

class _NoviceStepDetailPageState extends State<NoviceStepDetailPage> {
  Map<String, dynamic>? _step;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _validateCurrentStep(int etapeId) async {
    try {
      final api = ProjectApiService();
      final updated = await api.validateEtape(etapeId: etapeId);
      if (!mounted) return;
      setState(() {
        _step = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Étape validée')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  bool _isAdminTitle(String? t) {
    final s = (t ?? '').toLowerCase();
    if (s.isEmpty) return false;
    // Administratif uniquement (ne pas inclure "plan de situation" ici)
    final isAdminKeyword = s.contains('demande') || s.contains('propri') || s.contains('identit');
    final isPlanDeSituation = s.contains('plan de situation');
    return isAdminKeyword && !isPlanDeSituation;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ProjectApiService();
      final list = await api.getProjectSteps(projectId: widget.projectId);
      Map<String, dynamic>? found;
      for (final e in list) {
        final id = _asInt(e['etapeId']);
        if (id == widget.etapeId) {
          found = e;
          break;
        }
      }
      if (!mounted) return;
      if (found == null) {
        setState(() {
          _error = 'Étape introuvable';
          _loading = false;
        });
      } else {
        setState(() {
          _step = found;
          _loading = false;
        });
      }
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

  String? _toHttpUrl(String? raw) {
    if (raw == null) return null;
    var s = raw.trim();
    if (s.isEmpty) return null;
    s = s.replaceAll('\\', '/');
    if (s.startsWith('http://') || s.startsWith('https://')) return s;
    final lower = s.toLowerCase();
    final idx = lower.indexOf('/uploads/');
    if (idx != -1) {
      final path = s.substring(idx); // includes leading /uploads/
      return '${ApiConfig.baseUrl}$path';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = _step;
    final ordre = s != null ? _asInt(s['ordre']) : null;
    final title = s != null ? (s['modeleNom'] ?? '').toString() : '';
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
                  (ordre != null && ordre > 0)
                      ? (title.isNotEmpty ? 'Étape $ordre : $title' : 'Étape $ordre')
                      : (title.isNotEmpty ? title : 'Détails de l\'étape'),
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

    

    // Préparer les données communes pour les rendus spécifiques
    final d = _step!;
    final ordre = _asInt(d['ordre']);
    final etapeId = _asInt(d['etapeId']);
    final isValidated = d['estValider'] == true;
    final title = (d['modeleNom'] ?? '').toString();
    final description = (d['modeleDescription'] ?? '').toString();
    final illustrations = (d['illustrations'] is List)
        ? List<Map<String, dynamic>>.from(d['illustrations'] as List)
        : const <Map<String, dynamic>>[];

    String? _selectHeaderRaw() {
      // Priorité: illustration avec titre/description vides
      for (final it in illustrations) {
        final title = (it['titre'] ?? '').toString().trim();
        final desc = (it['description'] ?? '').toString().trim();
        final u = (it['urlImage'] ?? '').toString();
        if (u.isEmpty) continue;
        if (title.isEmpty && desc.isEmpty) return u;
      }
      // Sinon: première illustration avec image
      for (final it in illustrations) {
        final u = (it['urlImage'] ?? '').toString();
        if (u.isNotEmpty) return u;
      }
      return null;
    }

    final headerRaw = _selectHeaderRaw();
    String? headerImageUrl() => _toHttpUrl(headerRaw);

    // Rendu spécifique pour l'étape 6, identique à step6_detail_page mais avec données dynamiques
    if (ordre == 6) {
      final contentIllustrations = illustrations
          .where((it) => (it['urlImage'] ?? '').toString().isNotEmpty && (headerRaw == null || (it['urlImage'] ?? '').toString() != headerRaw))
          .toList(growable: false);
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderImage(url: headerImageUrl()),
            const SizedBox(height: 16),
            Text(
              "Aperçu de l'étape",
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF1C120D),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            if (description.isNotEmpty)
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF1C120D)),
              ),
            const SizedBox(height: 16),
            // Blocs dynamiques: une carte par illustration (après l'entête)
            if (contentIllustrations.isNotEmpty)
              for (final it in contentIllustrations)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (((it['titre'] ?? '').toString()).isNotEmpty)
                        Text(
                          (it['titre'] ?? '').toString(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF1C120D),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (_toHttpUrl((it['urlImage'] ?? '').toString()) != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: _HeaderImage(url: _toHttpUrl((it['urlImage'] ?? '').toString())).build(context),
                          ),
                        ),
                    ],
                  ),
                ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F51B5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isValidated ? null : () => _validateCurrentStep(etapeId),
                    child: Text(isValidated ? 'Étape validée' : 'Valider cette étape'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1C120D),
                      side: const BorderSide(color: Color(0xFFE7E3DF)),
                      backgroundColor: const Color(0xFFF5F1EE),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contacter un expert (mock)')),
                      );
                    },
                    child: const Text('Contacter un expert'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    // Rendu spécifique pour l'étape 5, identique à step5_detail_page mais avec données dynamiques
    if (ordre == 5) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderImage(url: headerImageUrl()),
            const SizedBox(height: 16),
            Text(
              "Aperçu de l'étape",
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF1C120D),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            if (description.isNotEmpty)
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF1C120D)),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F51B5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isValidated ? null : () => _validateCurrentStep(etapeId),
                    child: Text(isValidated ? 'Étape validée' : 'Valider cette étape'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1C120D),
                      side: const BorderSide(color: Color(0xFFE7E3DF)),
                      backgroundColor: const Color(0xFFF5F1EE),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contacter un expert (mock)')),
                      );
                    },
                    child: const Text('Contacter un expert'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    // Rendu spécifique pour l'étape 4, identique à step4_detail_page mais avec données dynamiques
    if (ordre == 4) {
      final contentIllustrations = illustrations
          .where((it) => (it['urlImage'] ?? '').toString().isNotEmpty && (headerRaw == null || (it['urlImage'] ?? '').toString() != headerRaw))
          .toList(growable: false);
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderImage(url: headerImageUrl()),
            const SizedBox(height: 16),
            Text(
              "Aperçu de l'étape",
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF1C120D),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            if (description.isNotEmpty)
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF1C120D)),
              ),
            const SizedBox(height: 12),
            // Sous-sections dynamiques: toutes les illustrations hors header
            if (contentIllustrations.isNotEmpty)
              for (final it in contentIllustrations) ...[
                const SizedBox(height: 8),
                if (((it['titre'] ?? '').toString()).isNotEmpty)
                  Text(
                    (it['titre'] ?? '').toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF1C120D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: 8),
                if (_toHttpUrl((it['urlImage'] ?? '').toString()) != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _HeaderImage(url: _toHttpUrl((it['urlImage'] ?? '').toString())).build(context),
                    ),
                  ),
                const SizedBox(height: 6),
                if (((it['description'] ?? '').toString()).isNotEmpty)
                  Text(
                    (it['description'] ?? '').toString(),
                    style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B4F4A)),
                  ),
                const SizedBox(height: 10),
              ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F51B5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isValidated ? null : () => _validateCurrentStep(etapeId),
                    child: Text(isValidated ? 'Étape validée' : 'Valider cette étape'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1C120D),
                      side: const BorderSide(color: Color(0xFFE7E3DF)),
                      backgroundColor: const Color(0xFFF5F1EE),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => context.push('/Novice/experts'),
                    child: const Text('Contacter un expert'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    

    // Rendu spécifique pour l'étape 3, identique à step3_detail_page mais avec données dynamiques
    if (ordre == 3) {
      final contentIllustrations = illustrations
          .where((it) => (it['urlImage'] ?? '').toString().isNotEmpty && (headerRaw == null || (it['urlImage'] ?? '').toString() != headerRaw))
          .toList(growable: false);

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderImage(url: headerImageUrl()),
            const SizedBox(height: 16),
            Text(
              "Aperçu de l'étape",
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF1C120D),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            if (description.isNotEmpty)
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF1C120D)),
              ),
            const SizedBox(height: 16),
            Text(
              'Types de fondations',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF1C120D),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            // Sous-section 1: premier élément hors header
            if (contentIllustrations.length > 0) ...[
              if (((contentIllustrations[0]['titre'] ?? '').toString()).isNotEmpty)
                Text(
                  (contentIllustrations[0]['titre'] ?? '').toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF1C120D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const SizedBox(height: 8),
              if (_toHttpUrl((contentIllustrations[0]['urlImage'] ?? '').toString()) != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _HeaderImage(url: _toHttpUrl((contentIllustrations[0]['urlImage'] ?? '').toString())).build(context),
                  ),
                ),
              const SizedBox(height: 6),
              if (((contentIllustrations[0]['description'] ?? '').toString()).isNotEmpty)
                Text(
                  (contentIllustrations[0]['description'] ?? '').toString(),
                  style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B4F4A)),
                ),
            ],
            const SizedBox(height: 14),
            // Sous-section 2: deuxième élément hors header
            if (contentIllustrations.length > 1) ...[
              if (((contentIllustrations[1]['titre'] ?? '').toString()).isNotEmpty)
                Text(
                  (contentIllustrations[1]['titre'] ?? '').toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF1C120D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const SizedBox(height: 8),
              if (_toHttpUrl((contentIllustrations[1]['urlImage'] ?? '').toString()) != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _HeaderImage(url: _toHttpUrl((contentIllustrations[1]['urlImage'] ?? '').toString())).build(context),
                  ),
                ),
              const SizedBox(height: 6),
              if (((contentIllustrations[1]['description'] ?? '').toString()).isNotEmpty)
                Text(
                  (contentIllustrations[1]['description'] ?? '').toString(),
                  style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B4F4A)),
                ),
            ],
            const SizedBox(height: 12),
            Text(
              "Le choix dépend directement du résultat de l’étude de sol réalisée avant cette étape.",
              style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B4F4A)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F51B5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isValidated ? null : () => _validateCurrentStep(etapeId),
                    child: Text(isValidated ? 'Étape validée' : 'Valider cette étape'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1C120D),
                      side: const BorderSide(color: Color(0xFFE7E3DF)),
                      backgroundColor: const Color(0xFFF5F1EE),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => context.push('/Novice/experts'),
                    child: const Text('Contacter un expert'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    // Rendu spécifique pour l'étape 1, identique à step1_detail_page mais avec données dynamiques
    if (ordre == 1) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderImage(url: headerImageUrl()),
            const SizedBox(height: 16),
            Text(
              "Aperçu de l'étape",
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF1C120D),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF1C120D)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F51B5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isValidated ? null : () => _validateCurrentStep(etapeId),
                    child: Text(isValidated ? 'Étape validée' : 'Valider cette étape'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1C120D),
                      side: const BorderSide(color: Color(0xFFE7E3DF)),
                      backgroundColor: const Color(0xFFF5F1EE),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => context.push('/Novice/experts'),
                    child: const Text('Contacter un expert'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    // Rendu spécifique pour l'étape 2, identique à step2_detail_page mais avec données dynamiques
    if (ordre == 2) {
      final admin = illustrations.where((it) => _isAdminTitle(it['titre']?.toString())).toList(growable: false);
      final tech = illustrations
          .where((it) {
            final isAdmin = _isAdminTitle(it['titre']?.toString());
            final raw = (it['urlImage'] ?? '').toString();
            final isHeader = headerRaw != null && headerRaw.isNotEmpty && raw == headerRaw;
            return !isAdmin && !isHeader;
          })
          .toList(growable: false);
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderImage(url: headerImageUrl()),
            const SizedBox(height: 12),
            Text("Aperçu de l'étape", style: theme.textTheme.titleLarge?.copyWith(color: const Color(0xFF1C120D), fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(description, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF1C120D))),
            const SizedBox(height: 16),
            Text('Documents ou éléments requis', style: theme.textTheme.titleLarge?.copyWith(color: const Color(0xFF1C120D), fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text('1. La Demande et Pièces Administratives', style: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFF1C120D), fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (admin.isNotEmpty)
              for (final it in admin) _IllustrationTile(data: it)
            else
              Text('Aucun élément administratif renseigné', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B4F4A))),
            const SizedBox(height: 12),
            Text('2. Le Dossier Technique', style: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFF1C120D), fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (tech.isNotEmpty)
              for (final it in tech)
                _TechIllustrationBlock(
                  title: (it['titre'] ?? '').toString(),
                  description: (it['description'] ?? '').toString(),
                  imageUrl: _toHttpUrl((it['urlImage'] ?? '').toString()),
                )
            else
              Text('Aucun élément technique renseigné', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B4F4A))),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/icons/icons_idea.svg', width: 24, height: 24),
                const SizedBox(width: 8),
                Text('Faites-vous accompagner', style: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFF1C120D), fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Un architecte ou un professionnel du bâtiment peut vous accompagner pour constituer un dossier complet et conforme.",
              style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B4F4A)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F51B5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isValidated ? null : () => _validateCurrentStep(etapeId),
                    child: Text(isValidated ? 'Étape validée' : 'Valider cette étape'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1C120D),
                      side: const BorderSide(color: Color(0xFFE7E3DF)),
                      backgroundColor: const Color(0xFFF5F1EE),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => context.push('/Novice/experts'),
                    child: const Text('Contacter un expert'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderImage(url: headerImageUrl()),
          const SizedBox(height: 12),
          Text('Étape $ordre', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF7D7D7D))),
          const SizedBox(height: 4),
          Text(
            title.isNotEmpty ? title : 'Étape $ordre',
            style: theme.textTheme.titleLarge?.copyWith(color: const Color(0xFF1C120D), fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (description.isNotEmpty)
            Text(description, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF1C120D))),
          const SizedBox(height: 16),
          if (illustrations.isNotEmpty) ...[
            Text('Illustrations', style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF1C120D), fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final it in illustrations) _IllustrationTile(data: it),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _TechIllustrationBlock extends StatelessWidget {
  const _TechIllustrationBlock({required this.title, required this.description, required this.imageUrl});
  final String title;
  final String description;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(title, style: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFF1C120D), fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildImage(imageUrl),
            ),
          ),
          const SizedBox(height: 10),
          if (description.isNotEmpty)
            Text(description, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B4F4A))),
        ],
      ),
    );
  }

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty || !(url.startsWith('http://') || url.startsWith('https://'))) {
      return Container(color: const Color(0xFFF5EFEC), child: const Center(child: Icon(Icons.image_outlined, color: Color(0xFF6B4F4A))));
    }
    return Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: Color(0xFF6B4F4A)));
  }
}

class _HeaderImage extends StatelessWidget {
  const _HeaderImage({this.url});
  final String? url;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: _buildImage(url),
      ),
    );
  }

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty || !(url.startsWith('http://') || url.startsWith('https://'))) {
      return Container(color: const Color(0xFFEDE7E3), child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 48, color: Color(0xFF6B4F4A))));
    }
    return Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
      return Container(color: const Color(0xFFEDE7E3), child: const Center(child: Icon(Icons.broken_image_outlined, size: 48, color: Color(0xFF6B4F4A))));
    });
  }
}

class _IllustrationTile extends StatelessWidget {
  const _IllustrationTile({required this.data});
  final Map<String, dynamic> data;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titre = (data['titre'] ?? '').toString();
    final desc = (data['description'] ?? '').toString();
    final url = (data['urlImage'] ?? '').toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (titre.isNotEmpty)
                  Text(titre, style: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFF1C120D), fontWeight: FontWeight.w700)),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(desc, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B4F4A))),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 120,
              height: 80,
              color: const Color(0xFFF5EFEC),
              child: _thumbnail(url),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumbnail(String url) {
    if (url.isEmpty) {
      return const Icon(Icons.image_outlined, color: Color(0xFF6B4F4A));
    }
    var s = url.replaceAll('\\', '/');
    if (!(s.startsWith('http://') || s.startsWith('https://'))) {
      final lower = s.toLowerCase();
      final idx = lower.indexOf('/uploads/');
      if (idx != -1) {
        final path = s.substring(idx);
        s = '${ApiConfig.baseUrl}$path';
      } else {
        return const Icon(Icons.image_outlined, color: Color(0xFF6B4F4A));
      }
    }
    return Image.network(s, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: Color(0xFF6B4F4A)));
  }
}
