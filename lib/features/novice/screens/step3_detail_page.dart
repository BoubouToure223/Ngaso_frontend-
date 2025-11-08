import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoviceStep3DetailPage extends StatelessWidget {
  const NoviceStep3DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1C120D)),
              ),
              Expanded(
                child: Text(
                  'Étape 3 : Fondations',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1C120D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  'assets/images/etape4_img.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFEDE7E3),
                    child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 48, color: Color(0xFF6B4F4A))),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Aperçu de l'étape",
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF1C120D),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Cette étape consiste à monter les murs porteurs et de refend selon les plans.\n"
              "Elle inclut le choix des matériaux (briques, blocs, béton), la mise en place des chaînages et linteaux,"
              " ainsi que le respect des niveaux, aplombs et alignements pour garantir la stabilité et la qualité du bâti.",
              style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF1C120D)),
            ),
            const SizedBox(height: 16),
            // Section: Types de fondations
            Text(
              'Types de fondations',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF1C120D),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            // Sous-section: Fondations superficielles
            Text(
              'Fondations superficielles',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF1C120D),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  'assets/images/etape3_img.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pour les bâtiments légers sur un sol résistant.',
              style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B4F4A)),
            ),
            const SizedBox(height: 14),
            // Sous-section: Fondations profondes
            Text(
              'Fondations profondes',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF1C120D),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  'assets/images/etape3_img.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Utilisées quand le sol en surface est faible.',
              style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B4F4A)),
            ),
            const SizedBox(height: 12),
            Text(
              "Le choix dépend directement du résultat de l’étude de sol réalisée avant cette étape.",
              style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B4F4A)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F51B5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Étape validée (mock)')),
                      );
                    },
                    child: const Text('Valider cette étape'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1C120D),
                      side: const BorderSide(color: Color(0xFFE7E3DF)),
                      backgroundColor: const Color(0xFFF5F1EE),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => context.push('/Novice/experts'),
                    child: const Text('Contacter un expert'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
