import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/repositories/auth_repository.dart';

/// La page de connexion, où les utilisateurs peuvent entrer leurs identifiants.
class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

/// L'état de la page de connexion, gérant le formulaire et les contrôleurs de texte.
class _ConnexionPageState extends State<ConnexionPage> {
  // Clé globale pour le formulaire, utilisée pour la validation.
  final _formKey = GlobalKey<FormState>();
  // Contrôleur pour le champ de saisie de l'e-mail.
  final _emailController = TextEditingController();
  // Contrôleur pour le champ de saisie du mot de passe.
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePwd = true;

  @override
  void dispose() {
    // Libère les ressources des contrôleurs lorsque le widget est supprimé.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Espacement supérieur pour simuler une barre d'état.
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 346),
                    // Formulaire contenant les champs de saisie et le bouton de soumission.
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo et nom de l'application.
                          SizedBox(
                            width: 280,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 80,
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Ngaso',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Titre et paragraphe de la page.
                          SizedBox(
                            width: 280,
                            child: Column(
                              children: [
                                Text(
                                  'Connexion',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Accédez à votre espace personnel',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'pour gérer vos projets de',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'construction',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Champ de saisie pour le numéro de téléphone (8 chiffres).
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            maxLength: 8,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Entrez votre numéro de téléphone';
                              if (v.length != 8) return 'Le numéro doit contenir 8 chiffres';
                              return null;
                            },
                            decoration: const InputDecoration(labelText: 'Entrez votre numéro (8 chiffres)'),
                          ),
                          const SizedBox(height: 16),
                          // Champ de saisie pour le mot de passe.
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePwd,
                            validator: (v) => v == null || v.isEmpty ? 'Entrez votre mot de passe' : null,
                            decoration: InputDecoration(
                              labelText: 'Entrez votre mot de passe',
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscurePwd = !_obscurePwd),
                                icon: Icon(_obscurePwd ? Icons.visibility_off : Icons.visibility),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Bouton pour la récupération du mot de passe.
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push('/forgot-password'),
                              child: const Text('Mot de passe oublié ?'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Bouton de connexion.
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _loading
                                  ? null
                                  : () async {
                                      if (!(_formKey.currentState?.validate() ?? false)) return;
                                      setState(() => _loading = true);
                                      try {
                                        final repo = AuthRepository();
                                        final res = await repo.login(
                                          _emailController.text.trim(),
                                          _passwordController.text,
                                        );
                                        final role = (res.role ?? '').toLowerCase();
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Connexion réussie')),
                                        );
                                        if (role == 'novice') {
                                          context.go('/Novice/home');
                                        } else if (role == 'professionnel' || role == 'pro') {
                                          context.go('/pro/home', extra: {'professionnelId': res.userId});
                                        } else {
                                          context.go('/Novice/home');
                                        }
                                      } catch (e) {
                                        if (!mounted) return;
                                        final raw = e.toString();
                                        final msg = raw.startsWith('Exception: ')
                                            ? raw.substring('Exception: '.length)
                                            : raw;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(msg)),
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
                                  : const Text('Se connecter'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Lien pour s'inscrire.
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Vous n'avez pas de compte ?",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              TextButton(
                                onPressed: () => context.push('/profile-choice'),
                                style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
                                child: const Text("S'inscrire"),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
