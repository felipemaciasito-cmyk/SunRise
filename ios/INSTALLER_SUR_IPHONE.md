# Installer SunRise sur un iPhone ou iPad sans Bluefy

SunRise utilise CoreBluetooth dans une application iOS native. Pour l’installer sur un appareil physique, il faut signer l’application avec une identité Apple et un profil de provisionnement valide. L’archive non signée générée par défaut n’est pas installable directement.

## Préparer la signature Apple
Il faut un compte Apple Developer permettant de créer une signature et un profil de provisionnement Ad Hoc. Le profil doit inclure l’UDID de chaque iPhone/iPad sur lequel l’app sera installée.

Dans Apple Developer :
1. Enregistrer l’UDID de l’appareil.
2. Créer un certificat Apple Distribution et l’exporter en fichier .p12 avec un mot de passe.
3. Créer un profil Ad Hoc pour l’identifiant d’application com.stani.sunrise, associé au certificat et à l’appareil.
4. Encoder les deux fichiers en Base64. Ne jamais les committer dans le dépôt.

## Ajouter les secrets dans GitHub
Dans le dépôt, ouvrir Settings → Secrets and variables → Actions → New repository secret, puis ajouter ces quatre secrets :

- IOS_CERTIFICATE_P12_BASE64 : contenu Base64 du certificat .p12.
- IOS_CERTIFICATE_PASSWORD : mot de passe du fichier .p12.
- IOS_PROVISIONING_PROFILE_BASE64 : contenu Base64 du profil .mobileprovision.
- IOS_TEAM_ID : identifiant de l’équipe Apple Developer.

Le workflow utilise ces secrets uniquement pour la compilation signée. Sans eux, il ne produit qu’une archive non signée destinée à inspection.

## Lancer la compilation
1. Ouvrir l’onglet Actions : https://github.com/felipemaciasito-cmyk/SunRise/actions
2. Sélectionner SunRise iOS build et cliquer sur Run workflow.
3. Télécharger l’artefact SunRise-installable-IPA si la compilation signée réussit.
4. Installer l’IPA avec une méthode compatible avec le profil Ad Hoc (par exemple Apple Configurator sur Mac ou un service de distribution Ad Hoc autorisé).

## Important
- Un fichier IPA n’est pas un lien d’installation web universel : il doit être signé et l’appareil doit être inclus dans le profil.
- L’archive du simulateur ou le ZIP d’une app non signée ne s’installe pas sur un iPhone.
- La compilation et la signature doivent réussir avant de pouvoir tester le Bluetooth natif.
- Les commandes BLE doivent encore être validées sur le modèle physique du réveil. L’éditeur d’alarmes complet et la radio ne sont pas encore intégrés à la version native.
