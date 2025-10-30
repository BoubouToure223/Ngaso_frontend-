import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoviceStep2DetailPage extends StatelessWidget {
  const NoviceStep2DetailPage({super.key});

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
                  "Étape 2 : Obtention du permis de construire",
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
            _headerImage(),
            const SizedBox(height: 12),
            _SectionTitle("Aperçu de l'étape"),
            const SizedBox(height: 6),
            _BodyText(
              "Cette étape consiste à obtenir le permis de construire, une autorisation indispensable pour démarrer vos travaux en toute légalité. Elle s'assure que votre projet respecte les règles d'urbanisme en vigueur et permet d'éviter des problèmes juridiques.",
            ),
            const SizedBox(height: 16),
            _SectionTitle('Documents ou éléments requis'),
            const SizedBox(height: 10),
            _SubSectionTitle('1. La Demande et Pièces Administratives'),
            const SizedBox(height: 8),
            _DocTileImageRight(
              title: 'Demande de Permis de Construire',
              desc: 'Le formulaire officiel dûment rempli par le demandeur.',
              imageAsset: 'assets/images/demande_img.png',
            ),
            _DocTileImageRight(
              title: 'Titre de Propriété',
              desc: 'Preuve de propriété (acte de propriété ou acte notarié).',
              imageAsset: 'assets/images/titrePropriete_img.png',
            ),
            _DocTileImageRight(
              title: "Pièce d'Identité",
              desc: "Copie d'une pièce d'identité valide.",
              imageAsset: 'assets/images/pieceIdentit_img.png',
            ),
            const SizedBox(height: 14),
            _SubSectionTitle('2. Le Dossier Technique'),
            const SizedBox(height: 8),
            _DocBlockImageBelow(
              title: 'Plan de Situation',
              imageAsset: 'assets/images/permis.png',
              desc: "Situe la parcelle sur la commune (échelle 1/2000e min).",
            ),
            _DocBlockImageBelow(
              title: 'Plan de Masse',
              imageAsset: 'assets/images/permis.png',
              desc: "Représentation de la parcelle et des constructions (échelle ≥ 1/500e).",
            ),
            _DocBlockImageBelow(
              title: 'Plan en Coupe',
              imageAsset: 'assets/images/permis.png',
              desc: "Vues en coupe précisant hauteur et implantation par rapport au terrain.",
            ),
            _DocBlockImageBelow(
              title: 'Plans Façades et Toitures',
              imageAsset: 'assets/images/permis.png',
              desc: "Aspect extérieur et toitures (échelle 1/50e à 1/100e).",
            ),
            _DocBlockImageBelow(
              title: 'Plans Ouvrages Sanitaires',
              imageAsset: 'assets/images/permis.png',
              desc: "Spécifique aux installations sanitaires (échelle 1/50e).",
            ),
            const SizedBox(height: 14),
            _SubSectionTitle('Faites-vous accompagner'),
            const SizedBox(height: 6),
            _BodyText(
              "Un architecte ou un professionnel du bâtiment peut vous accompagner pour constituer un dossier complet et conforme.",
            ),
            const SizedBox(height: 16),
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

  Widget _headerImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.asset('assets/images/permis.png', fit: BoxFit.cover),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFF1C120D),
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _SubSectionTitle extends StatelessWidget {
  final String text;
  const _SubSectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF1C120D),
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF6B4F4A),
          ),
    );
  }
}

class _DocTileImageRight extends StatelessWidget {
  final String title;
  final String desc;
  final String imageAsset;
  const _DocTileImageRight({
    required this.title,
    required this.desc,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF1C120D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B4F4A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 130,
              height: 86,
              color: const Color(0xFFF5EFEC),
              child: Image.asset(imageAsset, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocBlockImageBelow extends StatelessWidget {
  final String title;
  final String imageAsset;
  final String desc;
  const _DocBlockImageBelow({
    required this.title,
    required this.imageAsset,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF1C120D),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(imageAsset, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B4F4A),
            ),
          ),
        ],
      ),
    );
  }
}
