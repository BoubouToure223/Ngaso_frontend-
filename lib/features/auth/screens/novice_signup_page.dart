import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/repositories/auth_repository.dart';

/// Page d'inscription pour les utilisateurs "novices" (particuliers).
class NoviceSignupPage extends StatefulWidget {
  const NoviceSignupPage({super.key});

  @override
  State<NoviceSignupPage> createState() => _NoviceSignupPageState();
}

/// État de la page d'inscription pour les novices.
class _NoviceSignupPageState extends State<NoviceSignupPage> {
  // Contrôleurs pour les champs du formulaire.
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();
  bool _loading = false;

  // Indicateurs pour masquer/afficher les mots de passe.
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    // Libère les ressources des contrôleurs.
    _lastNameCtrl.dispose();
    _firstNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
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
                  const SizedBox(height: 34),
                  // Bouton de retour.
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Icône de l'utilisateur.
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
                                    'Créez votre compte pour démarrer',
                                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 1),
                              SizedBox(
                                height: 23,
                                child: Center(
                                  child: Text(
                                    'votre projet de construction',
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
                  const SizedBox(height: 24),
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
                        // Champ Email.
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: _filledDecoration('Entrez votre adresse email'),
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
                                    setState(() => _loading = true);
                                    try {
                                      final repo = AuthRepository();
                                      final body = {
                                        'lastName': _lastNameCtrl.text.trim(),
                                        'firstName': _firstNameCtrl.text.trim(),
                                        'email': email,
                                        'phone': _phoneCtrl.text.trim(),
                                        'address': _addressCtrl.text.trim(),
                                        'password': pwd,
                                      };
                                      final res = await repo.registerNovice(body);
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Compte créé, connexion automatique...')),
                                      );
                                      final role = (res.role ?? '').toLowerCase();
                                      if (role == 'novice') {
                                        context.go('/Novice/home');
                                      } else {
                                        context.go('/Novice/home');
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
                        const SizedBox(height: 16),
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
