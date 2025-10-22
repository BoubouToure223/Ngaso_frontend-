import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

class NoviceProposalCreatePage extends StatefulWidget {
  const NoviceProposalCreatePage({super.key});

  @override
  State<NoviceProposalCreatePage> createState() => _NoviceProposalCreatePageState();
}

class _NoviceProposalCreatePageState extends State<NoviceProposalCreatePage> {
  final _titleCtrl = TextEditingController();
  final _detailCtrl = TextEditingController();
  final List<PlatformFile> _files = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _detailCtrl.dispose();
    super.dispose();
  }

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

  void _send() {
    // Mock submit
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Proposition envoyée (données fictives)')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => context.pop(),
        ),
        title: Text('Détails du projet', style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF0F172A), fontWeight: FontWeight.w500)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project summary (mock)
            Container(
              decoration: const BoxDecoration(color: Colors.white),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Construction villa moderne', style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF0F172A), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  Row(children: const [
                    Icon(Icons.place_outlined, size: 18, color: Color(0xFF0F172A)),
                    SizedBox(width: 8),
                    Expanded(child: Text('Bamako, Lafiabougou', style: TextStyle(color: Color(0xFF4B5563))))
                  ]),
                  const SizedBox(height: 8),
                  Row(children: const [
                    Icon(Icons.attach_money, size: 18, color: Color(0xFF0F172A)),
                    SizedBox(width: 8),
                    Expanded(child: Text('25 000 000 Fcfa', style: TextStyle(color: Color(0xFF4B5563), fontSize: 15)))
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Faire une proposition', style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF0F172A), fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),

            // Title
            Text('Titre de la proposition', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF374151), fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                hintText: 'Ex: Prise en charge des fondations',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
              ),
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
                onPressed: _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('Envoyer la proposition'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
