# SunRise — application iOS pour le réveil Niditon Sunrise

Projet SwiftUI natif destiné à être compilé via GitHub Actions sur un runner macOS.

## Contenu

- `SunRise.xcodeproj/` : projet Xcode.
- `NiditonControl/SunRiseApp.swift` : interface et diagnostic Bluetooth.
- `NiditonControl/Info.plist` : autorisations et configuration de l'application.
- `.github/workflows/ios-build.yml` : compilation automatique sur GitHub.
- `.gitignore` : fichiers temporaires exclus.

## État fonctionnel — à lire

Cette version est un **prototype de départ**, pas encore une application complète de contrôle du réveil.

- L'interface SwiftUI et les écrans de base sont présents.
- Le scan BLE, la connexion, la découverte des services/caractéristiques et les notifications servent à diagnostiquer le réveil.
- Les UUID AE30 / AE01–AE05 / AE10 / AE3A–AE3C sont des pistes observées, à vérifier sur le matériel.
- Les commandes de lumière, couleur, effets, son et alarmes ne sont pas encore validées sur le réveil réel. Le prototype ne doit pas être présenté comme entièrement fonctionnel tant que ces commandes n'ont pas été testées.

## Importer sur GitHub depuis un iPad

1. Télécharge puis décompresse `SunRise-GitHub.zip` dans Fichiers.
2. Dans le dépôt GitHub vide, utilise **Add file → Upload files**.
3. Téléverse le contenu du dossier extrait en gardant les chemins des dossiers. Le dossier caché `.github` est indispensable au workflow.
4. Valide l'import avec **Commit changes**.
5. Ouvre **Actions** et lance le workflow `iOS build`.

Si l'interface web GitHub ne permet pas de téléverser les dossiers correctement depuis iPad, utilise un environnement de développement en ligne ou GitHub Codespaces pour importer/committer le contenu en conservant les dossiers.

## Compilation

Le workflow compile `SunRise.xcodeproj` pour le simulateur iOS et publie un artefact ZIP. **Cet artefact de simulateur ne peut pas être installé sur un iPhone physique.** L'installation sur iPhone nécessite une compilation destinée à l'appareil et une signature Apple appropriée.

## Étape suivante pour le Bluetooth

Connecter le réveil depuis l'écran de diagnostic, relever les services et caractéristiques, puis comparer les notifications et échanges avec les actions effectuées dans Halo Light. Le format complet des paquets (identifiant, commande, paramètres, encadrement et éventuelle somme de contrôle) doit être confirmé avant d'activer l'envoi des commandes.
