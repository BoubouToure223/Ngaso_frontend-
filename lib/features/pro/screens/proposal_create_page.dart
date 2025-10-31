import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:myapp/core/data/services/pro_api_service.dart';
import 'package:myapp/core/storage/token_storage.dart';
import 'dart:convert';

/// Page Pro: création d'une proposition.
///
/// - Résumé du projet en haut (mock).
/// - Formulaire titre + détail.
/// - Ajout de documents (mock, via FilePicker).
/// - Bouton d'envoi simulé.
class ProProposalCreatePage extends StatefulWidget {
  const ProProposalCreatePage({super.key, this.projectId, this.initialTitle, this.initialLocation, this.initialBudget});
  final int? projectId;
  final String? initialTitle;
  final String? initialLocation;
  final dynamic initialBudget;

  @override
  State<ProProposalCreatePage> createState() => _ProProposalCreatePageState();
}

class _ProProposalCreatePageState extends State<ProProposalCreatePage> {
  /// Champ titre de la proposition.
  final _titleCtrl = TextEditingController();
  /// Champ détail de la proposition.
  final _detailCtrl = TextEditingController();
  /// Fichiers joints sélectionnés (mock).
  final List<PlatformFile> _files = [];
  bool _loading = false;
  Future<Map<String, dynamic>>? _futureProject;

  String _formatBudget(dynamic value) {
    if (value == null) return '';
    String s = value.toString();
    // retirer éventuels décimaux inutiles
    if (s.contains('.')) {
      final parts = s.split('.');
      if (parts.length > 1 && (parts[1] == '0' || RegExp(r'^0+$').hasMatch(parts[1]))) {
        s = parts[0];
      }
    }
    final reg = RegExp(r"(\d)(?=(\d{3})+(?!\d))");
    s = s.replaceAllMapped(reg, (m) => '${m[1]} ');
    return '$s Fcfa';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _detailCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Si on a déjà des données initiales, on n'appelle pas l'API
    if (widget.projectId != null && widget.initialTitle == null && widget.initialLocation == null && widget.initialBudget == null) {
      _futureProject = ProApiService().getProjetById(widget.projectId!);
    }
  }

  /// Ouvre le sélecteur de fichiers et ajoute les éléments sélectionnés.
  Future<void> _pickFiles() async {
    try {
      final res = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (res == null) return;
      setState(() {
        _files.addAll(res.files);
      });
    } catch (_) {
      // ignore mock errors
    }
  }

  /// Soumet la proposition multipart (montant + description + devis optionnel)
  Future<void> _send() async {
    final montantStr = _titleCtrl.text.trim();
    final description = _detailCtrl.text.trim();
    if (montantStr.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez renseigner le montant et la description')));
      return;
    }
    final montant = double.tryParse(montantStr.replaceAll(' ', '').replaceAll(',', '.'));
    if (montant == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Montant invalide')));
      return;
    }
    if (widget.projectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Projet introuvable')));
      return;
    }
    // Récupérer professionnelId depuis le JWT (champ sub)
    int professionnelId = 0;
    try {
      final token = await TokenStorage.instance.readToken();
      if (token != null && token.isNotEmpty) {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
          final map = json.decode(payload);
          final sub = map['sub'];
          if (sub is String) professionnelId = int.tryParse(sub) ?? 0;
          if (sub is int) professionnelId = sub;
        }
      }
    } catch (_) {}
    if (professionnelId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de déterminer votre identifiant. Veuillez vous reconnecter.')));
      return;
    }

    setState(() => _loading = true);
    try {
      // Récupérer la spécialité depuis le profil
      int? specialiteId;
      try {
        final profile = await ProApiService().getMyProfile();
        // Essayer différentes structures possibles
        final direct = profile['specialiteId'] ?? profile['idSpecialite'];
        if (direct is int) {
          specialiteId = direct;
        } else if (direct is String) {
          specialiteId = int.tryParse(direct);
        } else {
          final spec = profile['specialite'] ?? profile['specialty'];
          if (spec is Map) {
            final sid = spec['id'] ?? spec['code'] ?? spec['value'];
            if (sid is int) specialiteId = sid; else if (sid is String) specialiteId = int.tryParse(sid);
          }
        }
      } catch (_) {
        // Ignorer si non disponible
      }
      // Fichier devis: prendre le premier fichier sélectionné s’il a un path
      String? devisPath;
      if (_files.isNotEmpty && _files.first.path != null) {
        devisPath = _files.first.path;
      }

      await ProApiService().submitPropositionMultipart(
        professionnelId: professionnelId,
        projetId: widget.projectId!,
        montant: montant,
        description: description,
        specialiteId: specialiteId,
        devisFilePath: devisPath,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proposition envoyée')));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec de l\'envoi: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        // Retour arrière
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Détails du projet'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Résumé du projet (réel si disponible)
            if (_futureProject == null && (widget.initialTitle != null || widget.initialLocation != null || widget.initialBudget != null))
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.initialTitle ?? 'Projet', style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF0F172A), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    if (widget.initialBudget != null) ...[
                      Text('Budget: ${_formatBudget(widget.initialBudget)}', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4B5563))),
                      const SizedBox(height: 4),
                    ],
                    if (widget.initialLocation != null)
                      Text('Localité: ${widget.initialLocation}', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4B5563))),
                  ],
                ),
              )
            else if (_futureProject == null)
              Container(
                decoration: const BoxDecoration(color: Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Détails du projet', style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF0F172A), fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    const Text('Informations non disponibles.', style: TextStyle(color: Color(0xFF4B5563)))
                  ],
                ),
              )
            else
              FutureBuilder<Map<String, dynamic>>(
                future: _futureProject,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snap.hasError || snap.data == null) {
                    return Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(color: Colors.white),
                      padding: const EdgeInsets.all(16),
                      child: Text('Erreur de chargement: ${snap.error}', style: theme.textTheme.bodySmall),
                    );
                  }
                  final p = snap.data!;
                  final titre = (p['titre'] ?? p['title'] ?? 'Projet').toString();
                  final loc = (p['localisation'] ?? p['lieu'] ?? p['location'] ?? '-').toString();
                  final budgetVal = p['budget'];
                  final budget = budgetVal == null ? '' : _formatBudget(budgetVal);
                  return Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(titre, style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF0F172A), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        if (budget.isNotEmpty) ...[
                          Text('Budget: $budget', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4B5563))),
                          const SizedBox(height: 4),
                        ],
                        Text('Localité: $loc', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4B5563))),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
            Text('Faire une proposition', style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF0F172A), fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),

            // Montant
            Text('Montant', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF374151), fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                hintText: 'Ex: 15000000',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            // Detail
            Text('Détail de la proposition', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF374151), fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            TextField(
              controller: _detailCtrl,
              minLines: 4,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Décrivez votre proposition en détail...',
                alignLabelWithHint: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
              ),
            ),
            const SizedBox(height: 16),

            // Attachments
            Text('Documents joints (devis, plans, références...)', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF374151), fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF93C5FD), width: 2, style: BorderStyle.solid),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.upload_file, color: Color(0xFF3F51B5)),
                  const SizedBox(height: 8),
                  const Text('Déposez vos fichiers ici ou cliquez pour parcourir', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF4B5563))),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _pickFiles,
                      icon: const Icon(Icons.attach_file, size: 16),
                      label: const Text('Parcourir les fichiers'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F51B5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ),
                  if (_files.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _files
                            .map((f) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                                    const Icon(Icons.insert_drive_file, size: 16, color: Color(0xFF374151)),
                                    const SizedBox(width: 6),
                                    Text(f.name, style: const TextStyle(color: Color(0xFF374151))),
                                  ]),
                                ))
                            .toList(),
                      ),
                    )
                  ]
                ],
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Envoyer la proposition'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
