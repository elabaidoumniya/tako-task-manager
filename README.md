# Task Manager — Application Flutter MVC

Application mobile de gestion des tâches développée avec Flutter, dans le cadre du mini-projet 2ème année cycle ingénieur.

## Captures d'écran

> *(Ajouter les captures après exécution)*

## Architecture MVC

```
lib/
├── models/              # Couche Model
│   ├── task.dart        # Modèle tâche (id, title, priority, status...)
│   ├── user.dart        # Modèle utilisateur
│   └── category.dart    # Modèle catégorie
│
├── controllers/         # Couche Controller
│   ├── auth_controller.dart    # Logique d'authentification
│   └── task_controller.dart   # CRUD tâches + filtres
│
├── views/               # Couche View
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── task_form_screen.dart
│   │   ├── task_detail_screen.dart
│   │   ├── profile_screen.dart
│   │   └── stats_screen.dart
│   └── widgets/
│       ├── task_card.dart
│       └── filter_chips.dart
│
├── services/            # Services (accès données)
│   ├── database_service.dart   # SQLite
│   └── auth_service.dart       # SharedPreferences
│
├── routes/
│   └── app_router.dart         # Navigation go_router
│
├── theme/
│   └── app_theme.dart          # Thème clair/sombre
│
└── main.dart
```

## Fonctionnalités

- **Authentification** : inscription, connexion, déconnexion avec persistance de session
- **Gestion des tâches** : CRUD complet (créer, lire, modifier, supprimer)
- **Priorités** : Faible / Moyenne / Haute avec code couleur
- **Statuts** : À faire / En cours / Terminé
- **Catégories** : Travail, Personnel, École, Santé
- **Filtres** : par statut et par catégorie
- **Date d'échéance** : avec alerte de retard
- **Statistiques** : graphiques de progression, répartition par statut et priorité
- **Dark Mode** : automatique selon les préférences système
- **Swipe to delete** : glisser une carte pour la supprimer

## Technologies

| Technologie | Usage |
|---|---|
| Flutter + Dart | Framework mobile |
| SQLite (sqflite) | Base de données locale |
| SharedPreferences | Session utilisateur |
| go_router | Navigation |
| Provider | Gestion d'état (MVC) |
| fl_chart | Graphiques statistiques |
| intl | Formatage des dates |

## Installation et exécution

```bash
# 1. Cloner le projet
git clone https://github.com/votre-username/task_manager.git
cd task_manager

# 2. Installer les dépendances
flutter pub get

# 3. Lancer l'application
flutter run
```

**Prérequis** : Flutter SDK 3.x, un émulateur Android/iOS ou un appareil physique.

## Groupe

- Étudiant 1 : ...
- Étudiant 2 : ...

Année universitaire : 2025/2026
