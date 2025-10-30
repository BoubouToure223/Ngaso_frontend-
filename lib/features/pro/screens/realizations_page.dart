import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:myapp/core/data/services/pro_api_service.dart';

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
              if (it is Map) {
                imageUrl = it['imageUrl']?.toString();
                title = (it['titre'] ?? it['title'])?.toString();
              }
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.white,
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) {
                            return _ImageFallback(title: title);
                          },
                        )
                      : _ImageFallback(title: title),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddRealizationSheet(context),
        backgroundColor: const Color(0xFF3F51B5),
        label: const Text('Ajouter'),
        icon: const Icon(Icons.add),
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
    );
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

  /// Vérifie les champs obligatoires et soumet (mock).
  void _submit() {
    if (_titleCtrl.text.trim().isEmpty || _locationCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty || _files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')));
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Réalisation publiée (mock)')));
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
              const SizedBox(height: 8),
              Text('Nom du projet*', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF374151), fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              TextField(
                controller: _titleCtrl,
                decoration: _inputDecoration('Ex: Construction villa 3 chambres'),
              ),
              const SizedBox(height: 12),
              Text('Localisation*', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF374151), fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              TextField(
                controller: _locationCtrl,
                decoration: _inputDecoration('Ex: Bamako, Sotuba'),
              ),
              const SizedBox(height: 12),
              Text('Description*', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF374151), fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              TextField(
                controller: _descCtrl,
                minLines: 4,
                maxLines: 8,
                decoration: _inputDecoration('Décrivez votre projet...'),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              Text('Date de début des travaux', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF374151), fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.event),
                  label: Text(_startDate == null ? 'mm/dd/yyyy' : '${_startDate!.month}/${_startDate!.day}/${_startDate!.year}'),
                ),
              ),
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
