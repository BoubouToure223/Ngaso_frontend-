import 'package:flutter/material.dart';

// Définition de l'énumération des onglets pour une meilleure gestion de l'état
enum NoviceTab { accueil, messages, demandes, profile }

class NoviceBottomNavBar extends StatelessWidget {
  // L'index de l'onglet actuellement sélectionné
  final NoviceTab selectedTab;
  
  // Le callback appelé lorsque l'utilisateur sélectionne un nouvel onglet
  final ValueChanged<NoviceTab> onTabSelected;

  const NoviceBottomNavBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  // Fonction pour obtenir l'index entier à partir de l'énumération
  int get _currentIndex {
    return NoviceTab.values.indexOf(selectedTab);
  }

  // Fonction pour gérer le changement d'index et appeler le callback
  void _onItemTapped(int index) {
    onTabSelected(NoviceTab.values[index]);
  }

  @override
  Widget build(BuildContext context) {
    // Les couleurs des icônes et du texte : actif 0xFF99614D, inactif noir
    const Color selectedColor = Color(0xFF99614D);
    const Color unselectedColor = Colors.black;
    
    // La couleur de fond de la barre (similaire au Figma)
    const Color backgroundColor = Color(0xFFF7F3EF); 
    
    // Le thème est récupéré pour les styles de texte par défaut
    final ThemeData theme = Theme.of(context);

    return BottomNavigationBar(
      // Réglages visuels de la barre
      type: BottomNavigationBarType.fixed, // Assure que tous les labels sont affichés
      backgroundColor: backgroundColor,
      elevation: 0, // Enlève l'ombre par défaut
      
      // Gestion de l'état
      currentIndex: _currentIndex,
      onTap: _onItemTapped,
      
      // Styles des éléments
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      selectedLabelStyle: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
      unselectedLabelStyle: theme.textTheme.labelSmall,
      
      // Les éléments de la barre
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          // Une icône générique pour "Groupes/Demandes"
          icon: Icon(Icons.groups_outlined),
          activeIcon: Icon(Icons.groups),
          label: 'Demandes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}