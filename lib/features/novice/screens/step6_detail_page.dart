import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoviceStep6DetailPage extends StatelessWidget {
  const NoviceStep6DetailPage({super.key});

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
                  'Étape 6 : Finition',
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
                child: Image.asset('assets/images/etape6_img.png', fit: BoxFit.cover),
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
              "La finition est l’ensemble des travaux qui viennent achever la construction d’un bâtiment après la couverture.\n"
              "C’est durant cette étape que le bâti brut devient habitable et esthétique.\n"
              "Elle comprend tous les travaux de second œuvre, c’est-à-dire ceux qui rendent la maison fonctionnelle, confortable et agréable à vivre.",
              style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF1C120D)),
            ),
            const SizedBox(height: 16),
            _Block(title: 'Plafonnage', imageAsset: 'assets/images/etape5_img.png'),
            _Block(title: 'Plomberie', imageAsset: 'assets/images/etape4_img.png'),
            _Block(title: 'Électricité', imageAsset: 'assets/images/etape3_img.png'),
            _Block(title: 'Carrelage et revêtements de sol', imageAsset: 'assets/images/etape2_img.png'),
            _Block(title: 'Peinture et décoration', imageAsset: 'assets/images/etape1_img.png'),
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contacter un expert (mock)')),
                      );
                    },
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

class _Block extends StatelessWidget {
  final String title;
  final String imageAsset;
  const _Block({required this.title, required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
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
              child: Image.asset(imageAsset, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}
