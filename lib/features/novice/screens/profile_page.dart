import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/core/data/models/user_me_response.dart';
import 'package:myapp/core/storage/token_storage.dart';

class NoviceProfilePage extends StatelessWidget {
  const NoviceProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final futureMe = UserRepository().getMe();
    return Container(
      color: const Color(0xFFFCFAF7),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar + Modifier
              FutureBuilder<UserMeResponse>(
                future: futureMe,
                builder: (context, snapshot) {
                  String initials = 'U';
                  if (snapshot.hasData) {
                    final p = (snapshot.data?.prenom ?? '').trim();
                    final n = (snapshot.data?.nom ?? '').trim();
                    final i1 = p.isNotEmpty ? p[0] : '';
                    final i2 = n.isNotEmpty ? n[0] : '';
                    final combined = (i1 + i2).toUpperCase();
                    initials = combined.isNotEmpty ? combined : 'U';
                  }
                  return CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFFD9D9D9),
                    child: Text(
                      initials,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Modification du profil bientôt disponible')), 
                    );
                  },
                  icon: const Icon(Icons.image_outlined, color: Color(0xFF3F51B5), size: 18),
                  label: Text(
                    'Modifier',
                    style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF3F51B5), fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                ),
              ),
              const SizedBox(height: 6),
              FutureBuilder<UserMeResponse>(
                future: futureMe,
                builder: (context, snapshot) {
                  final nom = snapshot.data?.nom?.trim() ?? '';
                  final prenom = snapshot.data?.prenom?.trim() ?? '';
                  final fullname = (prenom.isNotEmpty || nom.isNotEmpty) ? '$prenom $nom'.trim() : 'Utilisateur';
                  return Text(
                    fullname,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF1C120D),
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
              ),

              const SizedBox(height: 50),
              FutureBuilder<UserMeResponse>(
                future: futureMe,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final email = snapshot.data?.email ?? '—';
                  final tel = snapshot.data?.telephone ?? '—';
                  final addr = snapshot.data?.adresse ?? '—';
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF2EAE8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informations personnelles',
                          style: TextStyle(
                            color: Color(0xFF1C120D),
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(icon: Icons.mail_outline, title: 'Email', value: email),
                        const SizedBox(height: 14),
                        _InfoRow(icon: Icons.phone_outlined, title: 'Téléphone', value: tel),
                        const SizedBox(height: 14),
                        _InfoRow(icon: Icons.location_on_outlined, title: 'Localisation', value: addr),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 180),
              // Changer mot de passe
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => context.push('/Novice/change-password'),
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('Changer de mot de passe'),
                ),
              ),

              const SizedBox(height: 12),
              // Déconnexion
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1C120D),
                    backgroundColor: const Color(0xFFF5F5F7),
                    side: const BorderSide(color: Color(0xFFF0F0F0)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    await TokenStorage.instance.deleteToken();
                    // Redirige vers la page de connexion et remplace la pile
                    // pour éviter un retour en arrière sur des pages protégées
                    // via le bouton Android.
                    // ignore: use_build_context_synchronously
                    context.go('/connexion');
                  },
                  icon: const Icon(Icons.logout_outlined),
                  label: const Text('Déconnexion'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoRow({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF3F51B5)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B4F4A)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF1C120D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
