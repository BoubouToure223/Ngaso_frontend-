import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/models/user_me_response.dart';
import 'package:myapp/core/data/services/pro_api_service.dart';

/// Page Pro: profil utilisateur (affichage et actions rapides).
///
/// - Affiche les informations personnelles.
/// - Accès à la modification du profil via une bottom sheet.
/// - Accès au changement de mot de passe et à la déconnexion.
class ProProfilePage extends StatefulWidget {
  const ProProfilePage({super.key});

  @override
  State<ProProfilePage> createState() => _ProProfilePageState();
}

class _ProProfilePageState extends State<ProProfilePage> {
  late Future<UserMeResponse> _future;

  @override
  void initState() {
    super.initState();
    _future = ProApiService().getUserMe();
  }

  String _initials(UserMeResponse me) {
    final p = (me.prenom ?? '').trim();
    final n = (me.nom ?? '').trim();
    String i = '';
    if (p.isNotEmpty) i += p[0].toUpperCase();
    if (n.isNotEmpty) i += n[0].toUpperCase();
    return i.isNotEmpty ? i : 'BT';
  }

  String _fullName(UserMeResponse me) {
    final p = (me.prenom ?? '').trim();
    final n = (me.nom ?? '').trim();
    final name = [p, n].where((e) => e.isNotEmpty).join(' ');
    return name.isNotEmpty ? name : 'Profil';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFCFAF7),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => context.go('/pro/home'),
        ),
        centerTitle: true,
        title: Text('Profil', style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF1F2937), fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: FutureBuilder<UserMeResponse>(
          future: _future,
          builder: (context, snap) {
            final me = snap.data;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar avec initiales
                  // Avatar initials
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(color: Color(0xFFE5E7EB), shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text(
                          me != null ? _initials(me) : '—',
                          style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 26, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    me != null ? _fullName(me) : '—',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 4),
                  Text('Professionnel - Entrepreneur', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280))),
                  const SizedBox(height: 12),
              // Bouton: modifier le profil (ouvre une bottom sheet)
              // Edit profile
              SizedBox(
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: () => _openEditProfile(context),
                  icon: const Icon(Icons.edit, size: 18, color: Color(0xFF2563EB)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEFF6FF)),
                    backgroundColor: const Color(0xFFEFF6FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  label: const Text('Modifier le profil', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 24),
              // Carte: informations personnelles
              // Personal info card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 2, offset: Offset(0, 1))],
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('Informations personnelles', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500, color: const Color(0xFF1F2937))),
                    ),
                    _InfoRow(
                      iconBg: const Color(0xFFEFF6FF),
                      icon: Icons.mail_outline,
                      label: 'Email',
                      value: (me?.email ?? '').isNotEmpty ? me!.email! : '—',
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    _InfoRow(
                      iconBg: const Color(0xFFEFF6FF),
                      icon: Icons.phone_outlined,
                      label: 'Téléphone',
                      value: (me?.telephone ?? '').isNotEmpty ? me!.telephone! : '—',
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    _InfoRow(
                      iconBg: const Color(0xFFE5E7EB),
                      icon: Icons.place_outlined,
                      label: 'Localisation',
                      value: (me?.adresse ?? '').isNotEmpty ? me!.adresse! : '—',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Bouton: déconnexion
              // deconnexion  button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () { context.go('/connexion'); },
                  icon: const Icon(Icons.logout, color: Color(0xFF374151)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFF3F4F6)),
                    backgroundColor: const Color(0xFFF3F4F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  label: const Text('Déconnexion', style: TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.w500)),
                ),
              ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  /// Champs contrôlés pour l'édition du profil.
  final _nameCtrl = TextEditingController(text: 'Moussa Traoré');
  final _roleCtrl = TextEditingController(text: 'Professionnel - Entrepreneur');
  final _emailCtrl = TextEditingController(text: 'moussa.traore@ngaso.com');
  final _phoneCtrl = TextEditingController(text: '+223 76 45 67 89');
  final _locCtrl = TextEditingController(text: 'Bamako, Mali');
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    // Validation simple des champs puis simulation d'un enregistrement.
    if (_nameCtrl.text.trim().isEmpty ||
        _roleCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().isEmpty ||
        _locCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs')));
      return;
    }
    final emailOk = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(_emailCtrl.text.trim());
    if (!emailOk) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email invalide')));
      return;
    }
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis à jour (mock)')));
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
                  Text('Modifier le profil', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 8),
              _LabeledText('Nom complet*'),
              const SizedBox(height: 4),
              _textField(_nameCtrl, 'Votre nom complet'),
              const SizedBox(height: 12),
              _LabeledText('Rôle*'),
              const SizedBox(height: 4),
              _textField(_roleCtrl, 'Ex: Entrepreneur'),
              const SizedBox(height: 12),
              _LabeledText('Email*'),
              const SizedBox(height: 4),
              _textField(_emailCtrl, 'exemple@mail.com', keyboard: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _LabeledText('Téléphone*'),
              const SizedBox(height: 4),
              _textField(_phoneCtrl, 'Ex: +223 76 45 67 89', keyboard: TextInputType.phone),
              const SizedBox(height: 12),
              _LabeledText('Localisation*'),
              const SizedBox(height: 4),
              _textField(_locCtrl, 'Ville, Pays'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F51B5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: _saving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(TextEditingController ctrl, String hint, {TextInputType? keyboard}) {
    // TextField utilitaire pour les champs de la feuille d'édition.
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }
}

class _LabeledText extends StatelessWidget {
  const _LabeledText(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF374151), fontWeight: FontWeight.w500));
  }
}

void _openEditProfile(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => const _EditProfileSheet(),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.iconBg,
    required this.icon,
    required this.label,
    required this.value,
  });
  final Color iconBg;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Ligne d'information libellé/valeur avec icône circulaire.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF0F172A), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
