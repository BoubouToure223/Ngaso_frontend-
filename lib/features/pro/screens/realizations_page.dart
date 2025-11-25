import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:myapp/core/data/services/pro_api_service.dart';
import 'package:myapp/core/network/api_config.dart';
import 'package:myapp/core/widgets/auth_image.dart';

/// Page Pro: vos réalisations (galerie d'images mock).
///
/// - Grille d'images (assets) avec gestion d'erreur d'affichage.
/// - Bouton flottant pour ajouter une réalisation (ouvre une bottom sheet).
class ProRealizationsPage extends StatefulWidget {
  const ProRealizationsPage({super.key});

  @override
  State<ProRealizationsPage> createState() => _ProRealizationsPageState();
}

class _ProRealizationsPageState extends State<ProRealizationsPage> {
  late Future<List<dynamic>> _future;

  String? _absUrl(String? u) {
    if (u == null || u.isEmpty) return null;
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    final base = Uri.parse(ApiConfig.baseUrl);
    final basePath = base.path; // e.g. /api/v1
    var path = u;
    if (path.startsWith('/')) path = path.substring(1);
    final normalizedBase = basePath.startsWith('/') ? basePath.substring(1) : basePath;
    if (normalizedBase.isNotEmpty && path.startsWith(normalizedBase)) {
      path = path.substring(normalizedBase.length);
      if (path.startsWith('/')) path = path.substring(1);
    }
    return path; // relative like 'uploads/...'
  }

  String? _extractId(Map it) {
    for (final k in ['id', 'realisationId', 'uuid', 'key', 'identifier']) {
      final v = it[k];
      if (v == null) continue;
      return v.toString();
    }
    // Try to parse from image/url fields (last path segment without extension)
    final u = (it['imageUrl'] ?? it['url'] ?? it['image'])?.toString();
    if (u is String && u.isNotEmpty) {
      try {
        final uri = Uri.parse(u);
        final seg = (uri.pathSegments.isNotEmpty ? uri.pathSegments.last : u).split('?').first;
        final dot = seg.lastIndexOf('.');
        final base = dot > 0 ? seg.substring(0, dot) : seg;
        if (base.isNotEmpty) return base;
      } catch (_) {}
    }
    return null;
  }

  Future<void> _confirmDelete(BuildContext context, String realisationId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette réalisation ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ProApiService().deleteMyRealisationById(realisationId);
      if (!mounted) return;
      setState(() {
        _future = ProApiService().getMyRealisationsItems();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Réalisation supprimée')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Suppression échouée: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _future = ProApiService().getMyRealisationsItems();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pro/home'),
        ),
        title: const Text('Vos réalisations'),
        centerTitle: false,
      ),
      body: FutureBuilder<List<dynamic>>(
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
                    onPressed: () => setState(() => _future = ProApiService().getMyRealisationsItems()),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const _EmptyState();
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final it = items[index];
              String? imageUrl;
              String? title;
              String? realId;
              if (it is String) {
                imageUrl = it;
              } else if (it is Map) {
                imageUrl = (it['imageUrl'] ?? it['url'] ?? it['image'])?.toString();
                title = (it['titre'] ?? it['title'])?.toString();
                realId = _extractId(it);
              }
              final resolved = _absUrl(imageUrl);
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: Colors.white,
                      child: resolved != null && resolved.isNotEmpty
                          ? AuthImage(url: resolved, fit: BoxFit.cover)
                          : _ImageFallback(title: title),
                    ),
                    if (realId != null && realId.isNotEmpty)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Material(
                          color: Colors.black45,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                            tooltip: 'Supprimer',
                            onPressed: () => _confirmDelete(context, realId!),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddRealizationSheet(context),
        backgroundColor: const Color(0xFF3F51B5),
        label: const Text('Ajouter', style: TextStyle(color: Colors.white),),
        icon: const Icon(Icons.add, color: Color(0xFFFFFFFF),),
      ),
    );
  }

  /// Ouvre la feuille pour ajouter une nouvelle réalisation.
  void _openAddRealizationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const _AddRealizationSheet(),
    ).then((added) {
      if (added == true) {
        setState(() {
          _future = ProApiService().getMyRealisationsItems();
        });
      }
    });
  }
}

/// Feuille (bottom sheet) pour ajouter une réalisation.
class _AddRealizationSheet extends StatefulWidget {
  const _AddRealizationSheet();

  @override
  State<_AddRealizationSheet> createState() => _AddRealizationSheetState();
}

class _AddRealizationSheetState extends State<_AddRealizationSheet> {
  /// Champs contrôlés
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  /// Fichiers sélectionnés (mock)
  final List<PlatformFile> _files = [];
  /// Date de début (optionnelle)
  DateTime? _startDate;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  /// Sélectionne des fichiers (mock)
  Future<void> _pickFiles() async {
    try {
      final res = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (res == null) return;
      setState(() => _files.addAll(res.files));
    } catch (_) {}
  }

  /// Ouvre un sélecteur de date.
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  /// Vérifie les champs obligatoires et soumet en uploadant la première image.
  Future<void> _submit() async {
    if (_files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner une image')));
      return;
    }
    final first = _files.first;
    final path = first.path;
    if (path == null || path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de lire le fichier sélectionné')));
      return;
    }
    String? mime;
    final ext = first.extension?.toLowerCase();
    if (ext == 'jpg' || ext == 'jpeg') mime = 'image/jpeg';
    if (ext == 'png') mime = 'image/png';
    if (ext == 'webp') mime = 'image/webp';

    try {
      final items = await ProApiService().uploadMyRealisationImage(
        filePath: path,
        fileName: first.name,
        mimeType: mime,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Réalisation publiée')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de l\'upload: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ajouter une réalisation', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 16),
              Text('Photos*', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF374151), fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _pickFiles,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Ajouter des photos'),
                ),
              ),
              if (_files.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _files
                      .map((f) => Chip(
                            label: Text(f.name, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F51B5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('Publier'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Décoration standard pour les champs de saisie.
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📷', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text('Aucune réalisation', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Publiez vos premières réalisations pour les voir ici.', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({this.title});
  final String? title;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: const Color(0xFFF5F5F5),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Text(
        title ?? 'Réalisation',
        style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
