# SunRise iOS — connexion Bluetooth native

Cette version utilise **CoreBluetooth** d’Apple : elle ne dépend ni de Safari Web Bluetooth, ni de Bluefy.

## Contenu
- `SunRiseApp.swift` : interface SwiftUI native.
- `SunRiseBluetooth.swift` : recherche BLE, connexion, découverte des services/caractéristiques, notifications et commandes couleur/luminosité/volume/heartbeat.

## Créer l’application
1. Sur un Mac, ouvrir Xcode et créer un projet **iOS App** nommé `SunRise`, interface **SwiftUI**, langage **Swift**.
2. Ajouter les deux fichiers Swift de ce dossier au projet (en retirant le fichier `App.swift` généré automatiquement pour éviter deux points d’entrée `@main`).
3. Dans la cible de l’application, ajouter dans **Info** la clé **Privacy - Bluetooth Always Usage Description** (`NSBluetoothAlwaysUsageDescription`) avec le texte : `SunRise utilise le Bluetooth pour se connecter à votre réveil lumineux.`
4. Choisir une équipe de signature dans **Signing & Capabilities**, puis lancer sur un iPhone ou iPad.
5. Accepter l’autorisation Bluetooth et tester avec le réveil à proximité.

## Limites à valider sur le matériel
- Les commandes reprennent les paquets déjà présents dans le prototype web. Le fonctionnement de chaque écriture doit être vérifié sur le réveil physique.
- Le scan filtre les périphériques nommés, car certains appareils n’annoncent pas leurs services BLE.
- Cette première version native ne reprend pas encore toutes les pages et fonctions de l’interface web (éditeur d’alarmes, radio, couleurs détaillées, etc.).
- Le dépôt contient les sources Swift, pas encore une application signée ou un fichier IPA. La compilation et la signature iOS nécessitent Xcode sur macOS.
