import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoviceGuidePermisPage extends StatelessWidget {
  const NoviceGuidePermisPage({super.key});

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
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF1C120D),
                ),
              ),
              Expanded(
                child: Text(
                  'Obtention du permis de\nconstruire',
                  maxLines: 2,
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
            _SectionTitle('Aperçu de l\'étape'),
            const SizedBox(height: 6),
            _BodyText(
              "Cette étape cruciale consiste à obtenir le permis de construire, une autorisation administrative indispensable pour démarrer votre projet de construction en toute légalité. Elle garantit que votre projet respecte les règles d'urbanisme en vigueur et prévient d'éventuels problèmes juridiques.",
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
              desc:
                  'Une preuve de propriété du terrain, comme un acte de propriété ou un acte notarié.',
              imageAsset: 'assets/images/titrePropriete_img.png',
            ),
            _DocTileImageRight(
              title: 'Pièce d\'Identité',
              desc: 'Une copie de votre pièce d\'identité valide.',
              imageAsset: 'assets/images/pieceIdentit_img.png',
            ),
            const SizedBox(height: 14),
            _SubSectionTitle('2. Le Dossier Technique'),
            const SizedBox(height: 8),
            _DocBlockImageBelow(
              title: 'Plan de Situation',
              imageAsset: 'assets/images/planSituation.png',
              desc:
                  'Un document qui situe la parcelle sur la commune, à une échelle minimale du 1/2000ème, pour identifier les règles d\'urbanisme applicables.',
            ),
            _DocBlockImageBelow(
              title: 'Plan Masse',
              imageAsset: 'assets/images/planMasse.png',
              desc:
                  'Représentation graphique de la parcelle et des constructions existantes et à construire, à l\'échelle 1/500ème au moins.',
            ),
            _DocBlockImageBelow(
              title: 'Plan en Coupe',
              imageAsset: 'assets/images/planCoupe.png',
              desc:
                  'Des plans montrant les vues en coupe des bâtiments, précisant la hauteur et l\'implantation par rapport au profil du terrain.',
            ),
            _DocBlockImageBelow(
              title: 'Plan des Façades et Toitures',
              imageAsset: 'assets/images/planFacade.png',
              desc:
                  'Des plans montrant l\'aspect extérieur et les toitures des bâtiments, à l\'échelle 1/50ème ou 1/100ème selon la dimension.',
            ),
            _DocBlockImageBelow(
              title: 'Plans Ouvrages Sanitaires',
              imageAsset: 'assets/images/planOuvrage.png',
              desc:
                  'Un plan spécifique pour les installations sanitaires, à l\'échelle 1/50ème.',
            ),
            _DocBlockImageBelow(
              title: 'Devis Descriptif Détaillé',
              imageAsset: 'assets/images/DevisDescriptif.png',
              desc:
                  'Un document décrivant le projet dans sa globalité, y compris les matériaux et les techniques de construction prévus.',
            ),
            const SizedBox(height: 14),
            _IdeaTitle('Faites-vous accompagner'),
            const SizedBox(height: 6),
            _BodyText(
              "Un architecte ou un professionnel du bâtiment peut vous aider à constituer un dossier complet et conforme.",
            ),
            const SizedBox(height: 24),
          ],
        ),
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
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                width: 358,
                height: 165,
              ),
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

Widget _headerImage() {
  // Placeholder visuel (évite de dépendre d\'assets spécifiques)
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Container(
      height: 197,

      child: Center(
        child: Image.asset('assets/images/permis.png', fit: BoxFit.cover),
      ),
    ),
  );
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

class _IdeaTitle extends StatelessWidget {
  final String text;
  const _IdeaTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset('assets/icons/icons_idea.svg', width: 30, height: 30),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF1C120D),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B4F4A)),
    );
  }
}

class _DocTile extends StatelessWidget {
  final String title;
  final String desc;
  const _DocTile({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF5EFEC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.insert_drive_file_outlined,
              color: Color(0xFF1C120D),
            ),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B4F4A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
