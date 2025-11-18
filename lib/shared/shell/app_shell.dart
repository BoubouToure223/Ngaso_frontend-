import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavTab {
  final String path;
  final String label;
  final Widget iconWidget;
  const NavTab(this.path, this.label, this.iconWidget);
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.tabs});
  final Widget child;
  final List<NavTab> tabs;

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final idx = tabs.indexWhere((t) => loc.startsWith(t.path));
    return idx >= 0 ? idx : 0;
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex(context);
    final loc = GoRouterState.of(context).uri.toString();
    final bool showBottomBar = tabs.any((t) => loc.startsWith(t.path));
    return Scaffold(
      body: child,
      bottomNavigationBar: showBottomBar
          ? Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFCFAF7),
                border:
                    Border(top: BorderSide(color: Color(0xFFF2EAE8), width: 1)),
              ),
              child: BottomNavigationBar(
                currentIndex: current,
                type: BottomNavigationBarType.fixed,
                backgroundColor: const Color(0xFFFCFAF7),
                // Couleurs mises à jour : onglet actif marron 0xFF99614D, inactifs noirs
                selectedItemColor: const Color(0xFF99614D),
                unselectedItemColor: Colors.black,
                showUnselectedLabels: true,
                onTap: (i) => context.go(tabs[i].path),
                items: tabs
                    .asMap()
                    .entries
                    .map((entry) {
                      final int index = entry.key;
                      final NavTab t = entry.value;
                      final bool isSelected = index == current;
                      // Même logique de couleur pour les icônes : actif 0xFF99614D, inactif noir
                      final Color color = isSelected
                          ? const Color(0xFF99614D)
                          : Colors.black;

                      // Applique toujours la couleur sur l'icône (même si c'est un Stack).
                      // Cela permet de colorer aussi les icônes Novice (Messages / Demandes).
                      final Widget coloredIcon = ColorFiltered(
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                        child: t.iconWidget,
                      );

                      return BottomNavigationBarItem(
                        icon: coloredIcon,
                        label: t.label,
                      );
                    })
                    .toList(),
              ),
            )
          : null,
    );
  }
}
