# Commits des corrections (vérification totale)

En utilisateur normal, lignes une par une :

```bash
cd ~/Documents/parcoursup-explorer
git switch main
git switch -c fix/verification-totale
R=~/Documents/REPO_COURS_BUT2_ARLES_/TP1_Javascritp/Projet_à_rendre/commits_corrections
ls "$R"
```

`ls` doit afficher les 4 dossiers et ce fichier. Après chaque `cp` : `git status` (un seul fichier modifié) puis `npx standard src/` (rien ne doit s'afficher).

## 1. Ville trop courte

```bash
cp -r "$R/1-fix-ville-courte/." .
git status
git add src/scripts/tpl/recherche.tpl.html
git commit -m "fix: refuse une ville de moins de 3 caractères avant d'appeler l'IGN" -m "L'IGN répond 400 si q fait moins de 3 caractères ou ne commence pas par une lettre ou un chiffre : l'application affichait à tort « Vérifiez votre connexion internet ». Le pattern HTML bloque la saisie avec un message clair. Les communes au nom très court (Y, Eu) restent trouvables avec leur code postal (« Eu 76260 »). maxlength évite de dépasser les 200 caractères acceptés."
```

## 2. Nombres à la française

```bash
cp -r "$R/2-fix-nombres-francais/." .
git status
git add src/scripts/vues/vueResultats.js
git commit -m "fix: écrit les nombres de la liste à la française" -m "« Candidats par place : 26.6 » devient « 26,6 », et « 1491 » devient « 1 491 », avec toLocaleString('fr-FR') comme dans la fenêtre d'historique."
```

## 3. Thème du système

```bash
cp -r "$R/3-fix-theme-systeme/." .
git status
git add src/scripts/vues/vueTheme.js
git commit -m "fix: suit de nouveau le thème du système quand on revient à lui" -m "Quand le choix fait avec le bouton redevient le thème du système, on l'efface de localStorage : la page suit de nouveau prefers-color-scheme. Avant, une fois le bouton utilisé, il n'y avait plus aucun moyen de revenir au réglage du système."
```

## 4. Diagramme

```bash
cp -r "$R/4-docs-diagramme/." .
git status
git add docs/diagramme-classes.drawio.pdf
git commit -m "docs: met à jour VueTheme dans le diagramme de classes" -m "Attribut systemeSombre et méthode themeSysteme."
```

## Envoi et fusion

```bash
git push -u origin fix/verification-totale
git switch main
git merge fix/verification-totale
git push
git log --oneline -4
```
