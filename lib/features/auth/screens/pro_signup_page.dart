import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:myapp/core/data/services/public_api_service.dart';
import 'package:myapp/core/data/models/specialite.dart';

/// Page d'inscription pour les utilisateurs "professionnels".
class ProSignupPage extends StatefulWidget {
  const ProSignupPage({super.key});

  @override
  State<ProSignupPage> createState() => _ProSignupPageState();
}

/// État de la page d'inscription pour les professionnels.
class _ProSignupPageState extends State<ProSignupPage> {
  // Contrôleurs pour les champs du formulaire.
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _companyNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _aboutCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();
  bool _loading = false;
  PlatformFile? _selectedDoc;

  // Spécialité sélectionnée et indicateurs pour masquer/afficher les mots de passe.
  String? _specialty;
  List<Specialite> _specialites = const [];
  bool _loadingSpecialites = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _fetchSpecialites();
  }

  Future<void> _fetchSpecialites() async {
    setState(() => _loadingSpecialites = true);
    try {
      final service = PublicApiService();
      final list = await service.getSpecialites();
      setState(() {
        _specialites = list;
        // Ne pas pré-sélectionner: forcer l'utilisateur à choisir.
        _specialty = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec du chargement des spécialités: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingSpecialites = false);
    }
  }

  @override
  void dispose() {
    // Libère les ressources des contrôleurs.
    _lastNameCtrl.dispose();
    _firstNameCtrl.dispose();
    _companyNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _aboutCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  // Bouton de retour.
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Icône d'ajout de personne.
                  Center(
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(
                        Icons.person_add_alt,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Titre et sous-titre de la page.
                  SizedBox(
                    width: 298,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 32,
                          child: Center(
                            child: Text(
                              'Inscription',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 48,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 23,
                                child: Center(
                                  child: Text(
                                    'Créez votre compte professionnel',
                                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 1),
                              SizedBox(
                                height: 23,
                                child: Center(
                                  child: Text(
                                    'pour proposer vos services',
                                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Formulaire d'inscription.
                  SizedBox(
                    width: 298,
                    child: Column(
                      children: [
                        // Champs Nom et Prénom.
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _lastNameCtrl,
                                textInputAction: TextInputAction.next,
                                decoration: _filledDecoration('Nom'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _firstNameCtrl,
                                textInputAction: TextInputAction.next,
                                decoration: _filledDecoration('Prénom'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Champ Nom de l'entreprise.
                        TextField(
                          controller: _companyNameCtrl,
                          textInputAction: TextInputAction.next,
                          decoration: _filledDecoration('Nom de votre entreprise'),
                        ),
                        const SizedBox(height: 16),
                        // Champ de sélection de la spécialité.
                        DropdownButtonFormField<String>(
                          value: _specialty,
                          isExpanded: true,
                          decoration: _filledDecoration(_loadingSpecialites ? 'Chargement...' : 'Sélectionnez votre spécialité'),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          items: _loadingSpecialites
                              ? const <DropdownMenuItem<String>>[]
                              : _specialites
                                  .map((s) => DropdownMenuItem<String>(
                                        value: s.id?.toString(),
                                        child: Text(s.libelle),
                                      ))
                                  .toList(),
                          onChanged: _loadingSpecialites
                              ? null
                              : (v) => setState(() => _specialty = v),
                        ),
                        if (!_loadingSpecialites && _specialites.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Aucune spécialité disponible. Veuillez réessayer plus tard.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.redAccent),
                            ),
                          ),
                        const SizedBox(height: 16),
                        // Champ Email.
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: _filledDecoration('Entrez votre email'),
                        ),
                        const SizedBox(height: 16),
                        // Champ Numéro de téléphone.
                        TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          decoration: _filledDecoration('Entrez votre numéro'),
                        ),
                        const SizedBox(height: 16),
                        // Champ Adresse.
                        TextField(
                          controller: _addressCtrl,
                          textInputAction: TextInputAction.next,
                          decoration: _filledDecoration('Entrez votre adresse'),
                        ),
                        const SizedBox(height: 16),
                        // Champ "À propos de vous".
                        TextField(
                          controller: _aboutCtrl,
                          textInputAction: TextInputAction.newline,
                          keyboardType: TextInputType.multiline,
                          minLines: 3,
                          maxLines: 5,
                          decoration: _filledDecoration('Parlez de vous ici'),
                        ),
                        const SizedBox(height: 24),
                        // Section pour les documents justificatifs.
                        _DocumentsSection(
                          onPick: () async {
                            final res = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                              withData: true,
                            );
                            if (res != null && res.files.isNotEmpty) {
                              setState(() => _selectedDoc = res.files.first);
                            }
                          },
                          onRemove: () => setState(() => _selectedDoc = null),
                          fileName: _selectedDoc?.name,
                        ),
                        const SizedBox(height: 24),
                        // Champ Mot de passe.
                        TextField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          decoration: _filledDecoration('Entrez un mot de passe').copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Champ Confirmation du mot de passe.
                        TextField(
                          controller: _confirmPasswordCtrl,
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          decoration: _filledDecoration('Confirmez votre mot de passe').copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Bouton de création de compte.
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _loading
                                ? null
                                : () async {
                                    final email = _emailCtrl.text.trim();
                                    final pwd = _passwordCtrl.text;
                                    final confirm = _confirmPasswordCtrl.text;
                                    if (!_loadingSpecialites && _specialites.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Impossible de continuer: aucune spécialité n\'est disponible.')),
                                      );
                                      return;
                                    }
                                    if (_specialty == null || _specialty!.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Veuillez sélectionner une spécialité')),
                                      );
                                      return;
                                    }
                                    if (email.isEmpty || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Entrez un email valide')),
                                      );
                                      return;
                                    }
                                    if (pwd.isEmpty || pwd.length < 6) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Mot de passe trop court (min 6)')),
                                      );
                                      return;
                                    }
                                    if (pwd != confirm) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
                                      );
                                      return;
                                    }
                                    if (_selectedDoc == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Veuillez joindre un document justificatif')),
                                      );
                                      return;
                                    }
                                    setState(() => _loading = true);
                                    try {
                                      final repo = AuthRepository();
                                      final data = {
                                        'nom': _lastNameCtrl.text.trim(),
                                        'prenom': _firstNameCtrl.text.trim(),
                                        'entreprise': _companyNameCtrl.text.trim(),
                                        'specialiteId': int.tryParse(_specialty ?? ''),
                                        'email': email,
                                        'telephone': _phoneCtrl.text.trim(),
                                        'adresse': _addressCtrl.text.trim(),
                                        'description': _aboutCtrl.text.trim(),
                                        'password': pwd,
                                      };
                                      MultipartFile? doc;
                                      if (_selectedDoc != null) {
                                        if (_selectedDoc!.bytes != null) {
                                          doc = MultipartFile.fromBytes(_selectedDoc!.bytes!, filename: _selectedDoc!.name);
                                        } else if (_selectedDoc!.path != null) {
                                          doc = await MultipartFile.fromFile(_selectedDoc!.path!, filename: _selectedDoc!.name);
                                        }
                                      }
                                      final res = await repo.registerProfessionnel(data: data, document: doc);
                                      if (!mounted) return;
                                      if (res.token.isEmpty) {
                                        await showDialog<void>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Inscription envoyée'),
                                            content: const Text('Votre compte professionnel a été soumis et sera validé par un administrateur. Vous serez notifié une fois la validation effectuée.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(ctx).pop(),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (!mounted) return;
                                        context.go('/connexion');
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Compte Pro créé, connexion automatique...')),
                                        );
                                        final role = (res.role ?? '').toLowerCase();
                                        if (role == 'professionnel' || role == 'pro') {
                                          context.go('/pro/home');
                                        } else {
                                          context.go('/pro/home');
                                        }
                                      }
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    } finally {
                                      if (mounted) setState(() => _loading = false);
                                    }
                                  },
                            child: _loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Créer mon compte'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Lien vers la page de connexion.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Vous avez déjà un compte ?',
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                            ),
                            TextButton(
                              onPressed: () => context.go('/connexion'),
                              child: const Text('Se connecter'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Crée une décoration de champ de saisie avec un fond rempli.
  InputDecoration _filledDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFEBEBEB), // Couleur de fond grise.
      border: OutlineInputBorder(
        borderSide: BorderSide.none, // Pas de bordure.
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
    );
  }
}

/// Section pour le téléversement de documents justificatifs.
class _DocumentsSection extends StatelessWidget {
  final VoidCallback? onPick;
  final VoidCallback? onRemove;
  final String? fileName;
  const _DocumentsSection({super.key, this.onPick, this.onRemove, this.fileName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 298,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFC2C2C2), width: 2),
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Titre de la section.
          Text(
            'Documents justificatifs',
            style: theme.textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          // Description de la section.
          Text(
            'Veuillez fournir des documents qui\nprouvent votre activité professionnelle\n(SIRET, assurance décennale, diplômes, etc.)',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Zone de glisser-déposer.
          InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC2C2C2), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.upload_file, size: 28, color: Colors.black54),
                  const SizedBox(height: 8),
                  const Text('Glissez-déposez vos fichiers ici ou', textAlign: TextAlign.center),
                  const SizedBox(height: 2),
                  onPick != null
                      ? TextButton(
                          onPressed: onPick,
                          child: const Text('parcourir', style: TextStyle(color: Color(0xFF3F51B5))),
                        )
                      : const Text('parcourir', style: TextStyle(color: Color(0xFF3F51B5))),
                  const SizedBox(height: 8),
                  const Text('.pdf, .jpg, .jpeg, .png (max 5 MB)', style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
          ),
          if (fileName != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    'Fichier sélectionné: $fileName',
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Retirer',
                  child: InkWell(
                    onTap: onRemove,
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.close, size: 18, color: Colors.black54),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
