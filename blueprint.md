
# Blueprint de l'application N’gaSo

## Aperçu

Cette application Flutter a pour but de mettre en relation des maîtres d'ouvrage (personnes souhaitant réaliser des travaux) avec des professionnels du bâtiment.

## Architecture et Style

### Thème

L'application utilisera un thème Material 3 moderne et personnalisable. Le thème sera défini dans un fichier centralisé et gérera les couleurs, la typographie et le style des composants. Il prendra en charge les modes clair et sombre.

### Navigation

La navigation sera gérée par le package `go_router`. Cela permettra une navigation déclarative, une gestion simple des liens profonds (deep linking) et une séparation claire des responsabilités.

### Gestion de l'état

La gestion de l'état sera assurée par le package `provider`. Il sera utilisé pour gérer le thème de l'application et pourra être étendu pour gérer d'autres états globaux comme l'authentification de l'utilisateur.

### Structure du projet

Le projet sera structuré par fonctionnalités ("features"). Chaque fonctionnalité aura son propre répertoire contenant les écrans, les widgets et la logique qui lui sont propres.

## Plan de refactoring

### Étape 1 : Préparation

*   Ajouter les dépendances `go_router` et `provider` au fichier `pubspec.yaml`.
*   Créer le fichier `blueprint.md`.

### Étape 2 : Thème

*   Créer un fichier `lib/theme/theme.dart` pour définir le thème de l'application.
*   Utiliser `ColorScheme.fromSeed` pour générer les palettes de couleurs.
*   Définir des styles de texte personnalisés avec `GoogleFonts`.
*   Appliquer le thème dans le `MaterialApp`.

### Étape 3 : Navigation

*   Créer un fichier `lib/navigation/router.dart` pour définir les routes de l'application avec `go_router`.
*   Remplacer toutes les instances de `Navigator.push` et `MaterialPageRoute` par les méthodes de `go_router` (`context.go`, `context.push`, etc.).

### Étape 4 : Gestion de l'état du thème

*   Créer un `ThemeProvider` pour gérer le changement de thème (clair/sombre).
*   Utiliser `ChangeNotifierProvider` pour rendre le `ThemeProvider` accessible dans toute l'application.

### Étape 5 : Réorganisation des fichiers

*   Déplacer les widgets réutilisables dans leurs propres fichiers dans un répertoire `lib/widgets`.
*   Renommer les fichiers pour qu'ils soient plus descriptifs.
*   Supprimer le code du compteur par défaut.

### Étape 6 : Nettoyage et commentaires

*   Supprimer le code inutile.
*   Ajouter des commentaires pour expliquer le code.
*   Mettre en forme le code avec `dart format`.
