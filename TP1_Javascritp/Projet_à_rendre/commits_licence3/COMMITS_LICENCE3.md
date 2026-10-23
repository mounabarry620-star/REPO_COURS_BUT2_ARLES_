# Commits de la licence 3

En utilisateur normal, depuis la racine du projet. Tape les lignes une par une.

```bash
cd ~/Documents/parcoursup-explorer
git switch main
git switch -c feature/licence3
R=~/Documents/REPO_COURS_BUT2_ARLES_/TP1_Javascritp/Projet_à_rendre/commits_licence3
ls "$R"
```

`ls` doit afficher `1-feat-licence3`, `2-docs-diagramme` et ce fichier. Sinon, arrête-toi.

## 1. Le code

```bash
cp -r "$R/1-feat-licence3/." .
git status
npx standard src/
npm run build
```

`git status` doit montrer **7 fichiers modifiés** : master.js, statistiqueMaster.js, serviceMonMaster.js, liste-masters.tpl.html, vueResultats.js, vueHistorique.js, styles.scss. Le lint ne doit rien afficher.

```bash
git add src/scripts/modeles/master.js src/scripts/modeles/statistiqueMaster.js src/scripts/services/serviceMonMaster.js src/scripts/tpl/liste-masters.tpl.html src/scripts/vues/vueResultats.js src/scripts/vues/vueHistorique.js src/stylesheets/styles.scss
git commit -m "feat: ajoute le taux de proposition des licences 3 pour les masters" -m "Mon Master publie les mêmes chiffres pour la licence générale (n_can_lg3_pp, n_prop_lg3_total ; n_can_lg3 et n_prop_lg3 en 2023) que pour le BUT 3. Les comparer montre si un master accepte des licences 3 mais peu de BUT 3. Aucune requête en plus : deux champs ajoutés au select. Troisième courbe en violet glycine du DSFR (contraste d'au moins 3 en clair et en sombre), avec triangles et pointillés fins."
```

## 2. Le diagramme

```bash
cp -r "$R/2-docs-diagramme/." .
git add docs/diagramme-classes.drawio.pdf
git commit -m "docs: ajoute la licence 3 au diagramme de classes" -m "Master et StatistiqueMaster : candidatsLicence3, propositionsLicence3, tauxPropositionLicence3. VueResultats : partDiplome."
```

## Envoi et fusion

```bash
git push -u origin feature/licence3
git switch main
git merge feature/licence3
git push
git log --oneline -4
```
