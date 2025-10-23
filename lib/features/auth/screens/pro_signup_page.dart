import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  // Spécialité sélectionnée et indicateurs pour masquer/afficher les mots de passe.
  String? _specialty;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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
                          initialValue: _specialty,
                          decoration: _filledDecoration('Selectionnez votre spécialité'),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          items: const [
                            DropdownMenuItem(value: 'Maconnerie', child: Text('Maçonnerie')),
                            DropdownMenuItem(value: 'Electricite', child: Text('Électricité')),
                            DropdownMenuItem(value: 'Plomberie', child: Text('Plomberie')),
                            DropdownMenuItem(value: 'Menuiserie', child: Text('Menuiserie')),
                            DropdownMenuItem(value: 'Peinture', child: Text('Peinture')),
                          ],
                          onChanged: (v) => setState(() => _specialty = v),
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
                        _DocumentsSection(),
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
                            onPressed: () {
                              //Implémenter la logique de création de compte.
                            },
                            child: const Text('Créer mon compte'),
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
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFC2C2C2), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.upload_file, size: 28, color: Colors.black54),
                SizedBox(height: 8),
                Text('Glissez-déposez vos fichiers ici ou', textAlign: TextAlign.center),
                SizedBox(height: 2),
                Text('parcourir', style: TextStyle(color: Color(0xFF3F51B5))),
                SizedBox(height: 8),
                Text('.pdf, .jpg, .jpeg, .png (max 5 MB)', style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
