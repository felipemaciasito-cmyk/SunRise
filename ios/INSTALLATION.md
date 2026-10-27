# SunRise — installation et compilation

## Build automatique
Le workflow GitHub Actions `.github/workflows/ios-build.yml` génère le projet Xcode et construit une version **simulateur iOS**. Après son exécution :
1. Ouvrir le dépôt GitHub, onglet **Actions**.
2. Sélectionner **Build SunRise iOS**.
3. Ouvrir une exécution terminée et télécharger l’artefact `SunRise-iOS-Simulator`.

Cette archive sert au simulateur Xcode sur Mac. **Elle ne s’installe pas sur un iPhone ou iPad physique.**

## Pour installer sur iPhone/iPad
Une compilation pour appareil et une signature sont nécessaires. Il faut une identité Apple Developer valide et une méthode de distribution adaptée (par exemple installation depuis Xcode ou TestFlight). Ne partagez jamais de certificat ou de clé privée dans le dépôt.

## Fonctions incluses dans cette première version native
- Scan BLE et choix d’un périphérique détecté.
- Connexion via CoreBluetooth, découverte des services et caractéristiques.
- Notifications BLE et journal de diagnostic.
- Commandes couleur, luminosité, volume et heartbeat, reprises du prototype web.

## Fonctions non finalisées
- Éditeur et sauvegarde d’alarmes.
- Contrôle confirmé des sons et de la radio FM.
- Correspondance complète entre les cinq onglets du prototype web et l’interface native.
- Validation de toutes les commandes sur le modèle physique du réveil.

Les commandes existantes sont une hypothèse de départ basée sur le prototype web. Vérifiez leur effet sur le réveil avant de considérer la fonctionnalité comme validée.
