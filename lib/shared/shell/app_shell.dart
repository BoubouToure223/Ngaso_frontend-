import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavTab {
  final String path;
  final String label;
  final IconData icon;
  const NavTab(this.path, this.label, this.icon);
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
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFCFAF7),
          border: Border(
            top: BorderSide(color: Color(0xFFF2EAE8), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: current,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFFCFAF7),
          selectedItemColor: const Color(0xFF1C120D),
          unselectedItemColor: const Color(0xFF99604C),
          showUnselectedLabels: true,
          onTap: (i) => context.go(tabs[i].path),
          items: tabs
              .map((t) => BottomNavigationBarItem(icon: Icon(t.icon), label: t.label))
              .toList(),
        ),
      ),
    );
  }
}
