import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Filtre possible pour les propositions
enum _ProposalStatus { all, pending, validated, rejected }

class ProProposalDetailsPage extends StatefulWidget {
  const ProProposalDetailsPage({super.key});

  @override
  State<ProProposalDetailsPage> createState() => _ProProposalDetailsPageState();
}

class _ProProposalDetailsPageState extends State<ProProposalDetailsPage> {
  // Palette alignée avec Notifications
  Color get blue => const Color(0xFF2563EB);
  Color get yellow => const Color(0xFFFDE047);
  Color get green => const Color(0xFF86EFAC);
  Color get red => const Color(0xFFFCA5A5);
  Color get slate => const Color(0xFF0F172A);
  Color get gray => const Color(0xFF6B7280);

  // Source de données simple (mock) pour afficher et filtrer
  final List<_Item> _items = [
    _Item(
      status: _ProposalStatus.pending,
      title: 'Construction de villa',
      author: 'Oumar Touré',
      description: 'Prise en charge des fondations',
      sentDate: '16 juin 2023',
    ),
    _Item(
      status: _ProposalStatus.validated,
      title: 'Construction de villa',
      author: 'Oumar Touré',
      description: 'Prise en charge des fondations',
      sentDate: '16 juin 2023',
    ),
    _Item(
      status: _ProposalStatus.rejected,
      title: 'Extension maison',
      author: 'Boubou Touré',
      description: 'Plan',
      sentDate: '8 juin 2023',
      rejectReasons: const ['Budget trop', 'élevé par', 'rapport aux', 'autres devis', 'reçus.'],
    ),
  ];

  _ProposalStatus _filter = _ProposalStatus.all; // filtre sélectionné

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Comptages par statut
    final int countAll = _items.length;
    final int countPending = _items.where((e) => e.status == _ProposalStatus.pending).length;
    final int countValidated = _items.where((e) => e.status == _ProposalStatus.validated).length;
    final int countRejected = _items.where((e) => e.status == _ProposalStatus.rejected).length;

    // Liste filtrée
    final List<_Item> visible = _filter == _ProposalStatus.all
        ? _items
        : _items.where((e) => e.status == _filter).toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/app/home'),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        title: Text('Proposition', style: theme.textTheme.titleLarge?.copyWith(color: slate, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // HEADER FILTRES (optimisé + commenté)
          // - 4 boutons: Toutes, attente, Validées, Rejetées
          // - Affiche les compteurs avec couleurs cohérentes
          Container(
            height: 57,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                // Bouton: Toutes
                _FilterTab(
                  active: _filter == _ProposalStatus.all,
                  label: 'Toutes',
                  count: countAll,
                  activeColor: blue,
                  onTap: () => setState(() => _filter = _ProposalStatus.all),
                ),
                // Bouton: attente
                _StatusPill(
                  active: _filter == _ProposalStatus.pending,
                  dotColor: const Color(0xFFFACC15),
                  countBg: const Color(0xFFFEF9C3),
                  countFg: const Color(0xFF854D0E),
                  label: 'attente',
                  count: countPending,
                  onTap: () => setState(() => _filter = _ProposalStatus.pending),
                ),
                // Bouton: Validées
                _StatusPill(
                  active: _filter == _ProposalStatus.validated,
                  dotColor: const Color(0xFF22C55E),
                  countBg: const Color(0xFFDCFCE7),
                  countFg: const Color(0xFF166534),
                  label: 'Validées',
                  count: countValidated,
                  onTap: () => setState(() => _filter = _ProposalStatus.validated),
                ),
                // Bouton: Rejetées
                _StatusPill(
                  active: _filter == _ProposalStatus.rejected,
                  dotColor: const Color(0xFFEF4444),
                  countBg: const Color(0xFFFEE2E2),
                  countFg: const Color(0xFF991B1B),
                  label: 'Rejetées',
                  count: countRejected,
                  onTap: () => setState(() => _filter = _ProposalStatus.rejected),
                ),
                const SizedBox(width: 8),
              ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Liste des cartes selon filtre
          for (final it in visible) ...[
            _buildCardFromItem(it, theme),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  // Construit une carte à partir d'un item
  Widget _buildCardFromItem(_Item it, ThemeData theme) {
    switch (it.status) {
      case _ProposalStatus.pending:
        return _ProposalCard(
          borderColor: yellow,
          statusBg: const Color(0xFFFEF9C3),
          statusTextColor: const Color(0xFF854D0E),
          title: it.title,
          author: it.author,
          description: it.description,
          sentDate: it.sentDate,
          leadingIcon: Icons.schedule,
          actionLeftLabel: 'Modifier',
          actionLeftBorderColor: const Color(0xFFD1D5DB),
          actionLeftTextColor: slate,
          actionRightLabel: 'Annuler',
          actionRightBorderColor: red,
          actionRightTextColor: const Color(0xFFDC2626),
          primaryButtonLabel: 'Détails',
          primaryButtonColor: blue,
        );
      case _ProposalStatus.validated:
        return _ProposalCard(
          borderColor: green,
          statusBg: const Color(0xFFDCFCE7),
          statusTextColor: const Color(0xFF166534),
          title: it.title,
          author: it.author,
          description: it.description,
          sentDate: it.sentDate,
          leadingIcon: Icons.check_circle_outline,
          primaryPillIcon: Icons.image_outlined,
          primaryPillLabel: 'Messagerie',
          statusLabel: 'Validée',
          primaryPillBg: const Color(0xFFDBEAFE),
          primaryPillTextColor: blue,
          primaryButtonLabel: 'Détails',
          primaryButtonColor: blue,
        );
      case _ProposalStatus.rejected:
        return _ProposalCard(
          borderColor: red,
          title: it.title,
          author: it.author,
          description: it.description,
          sentDate: it.sentDate,
          leadingIcon: Icons.close_rounded,
          statusBg: const Color(0xFFFEE2E2),
          statusTextColor: const Color(0xFF991B1B),
          statusLabel: 'Rejetée',
          primaryButtonLabel: 'Détails',
          primaryButtonColor: blue,
          rejectReasons: it.rejectReasons,
        );
      case _ProposalStatus.all:
        // non utilisé directement
        return const SizedBox.shrink();
    }
  }
}

// Modèle de données minimal pour la liste
class _Item {
  const _Item({
    required this.status,
    required this.title,
    required this.author,
    required this.description,
    required this.sentDate,
    this.rejectReasons,
  });
  final _ProposalStatus status;
  final String title;
  final String author;
  final String description;
  final String sentDate;
  final List<String>? rejectReasons;
}

// Bouton filtre "Toutes" avec soulignement actif et badge compteur
class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.active,
    required this.label,
    required this.count,
    required this.activeColor,
    required this.onTap,
  });
  final bool active;
  final String label;
  final int count;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : const Color(0xFF6B7280);
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 57,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: active ? activeColor : Colors.transparent, width: 2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(color: Color(0xFFE5E7EB), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: SizedBox(
                width: 16,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('$count', style: const TextStyle(color: Color(0xFF1F2937), fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bouton de statut (attente, Validées, Rejetées) avec pastille et badge compteur
class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.active,
    required this.dotColor,
    required this.countBg,
    required this.countFg,
    required this.label,
    required this.count,
    required this.onTap,
  });
  final bool active;
  final Color dotColor;
  final Color countBg;
  final Color countFg;
  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final labelColor = active ? const Color(0xFF0F172A) : const Color(0xFF6B7280);
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 57,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          // outer container border handled by header; underline per-pill set below dynamically
        ),
        foregroundDecoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: active ? Color(0xFF2563EB) : Colors.transparent, width: 2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pastille
            Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, borderRadius: BorderRadius.circular(9999))),
            const SizedBox(width: 6),
            // Libellé compact
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 70),
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: labelColor, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(width: 6),
            // Badge compteur
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(color: countBg, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: SizedBox(
                width: 16,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('$count', style: TextStyle(color: countFg, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  const _ProposalCard({
    required this.borderColor,
    required this.title,
    required this.author,
    required this.description,
    required this.sentDate,
    required this.leadingIcon,
    this.statusBg,
    this.statusTextColor,
    this.statusLabel,
    this.actionLeftLabel,
    this.actionLeftBorderColor,
    this.actionLeftTextColor,
    this.actionRightLabel,
    this.actionRightBorderColor,
    this.actionRightTextColor,
    this.primaryPillIcon,
    this.primaryPillLabel,
    this.primaryPillBg,
    this.primaryPillTextColor,
    required this.primaryButtonLabel,
    required this.primaryButtonColor,
    this.rejectReasons,
  });

  final Color borderColor;
  final String title;
  final String author;
  final String description;
  final String sentDate;
  final IconData leadingIcon;
  final Color? statusBg;
  final Color? statusTextColor;
  final String? statusLabel; // If null, infer from colors
  final String? actionLeftLabel;
  final Color? actionLeftBorderColor;
  final Color? actionLeftTextColor;
  final String? actionRightLabel;
  final Color? actionRightBorderColor;
  final Color? actionRightTextColor;
  final IconData? primaryPillIcon;
  final String? primaryPillLabel;
  final Color? primaryPillBg;
  final Color? primaryPillTextColor;
  final String primaryButtonLabel;
  final Color primaryButtonColor;
  final List<String>? rejectReasons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
        ),
        child: Stack(
          children: [
            // Left colored strip
            Align(
              alignment: Alignment.centerLeft,
              child: Container(width: 4, color: borderColor),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF0F172A), fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(author, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280))),
                  ],
                ),
              ),
              if (statusBg != null)
                Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(9999)),
                  alignment: Alignment.center,
                  child: Text(statusLabel ?? 'En attente', style: theme.textTheme.bodySmall?.copyWith(color: statusTextColor ?? const Color(0xFF854D0E), fontWeight: FontWeight.w500)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(description, style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF0F172A), fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(leadingIcon, size: 14, color: const Color(0xFF0F172A)),
              const SizedBox(width: 6),
              Text('Envoyée le', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
              const SizedBox(width: 6),
              Text(sentDate, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
            ],
          ),
          if (rejectReasons != null) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 14, color: Color(0xFF0F172A)),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: rejectReasons!
                      .map((t) => Text(t, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFFDC2626))))
                      .toList(),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              if (actionLeftLabel != null)
                SizedBox(
                  height: 30,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: actionLeftTextColor,
                      side: BorderSide(color: actionLeftBorderColor ?? const Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Text(actionLeftLabel!),
                  ),
                ),
              if (actionRightLabel != null) ...[
                const SizedBox(width: 8),
                SizedBox(
                  height: 30,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: actionRightTextColor,
                      side: BorderSide(color: actionRightBorderColor ?? const Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Text(actionRightLabel!),
                  ),
                ),
              ],
              const Spacer(),
              if (primaryPillLabel != null)
                Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: primaryPillBg, borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    children: [
                      if (primaryPillIcon != null) ...[
                        Icon(primaryPillIcon, size: 14, color: primaryPillTextColor ?? const Color(0xFF1D4ED8)),
                        const SizedBox(width: 4),
                      ],
                      Text(primaryPillLabel!, style: theme.textTheme.bodySmall?.copyWith(color: primaryPillTextColor ?? const Color(0xFF1D4ED8))),
                    ],
                  ),
                ),
              const SizedBox(width: 8),
              SizedBox(
                height: 28,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryButtonColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Text(primaryButtonLabel, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
