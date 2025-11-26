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
                // Couleurs : onglet actif noir, inactifs marron 0xFF99614D
                selectedItemColor: Colors.black,
                unselectedItemColor: const Color(0xFF99614D),
                showUnselectedLabels: true,
                onTap: (i) => context.go(tabs[i].path),
                items: tabs
                    .asMap()
                    .entries
                    .map((entry) {
                      final int index = entry.key;
                      final NavTab t = entry.value;
                      final bool isSelected = index == current;
                      // Même logique de couleur pour les icônes : actif noir, inactif marron 0xFF99614D
                      final Color color = isSelected
                          ? Colors.black
                          : const Color(0xFF99614D);

                      // On applique toujours ColorFiltered pour que toutes les icônes
                      // suivent la couleur active/inactive définie ci-dessus.
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
