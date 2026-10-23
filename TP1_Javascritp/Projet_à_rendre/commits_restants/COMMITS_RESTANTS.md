# Commits restants de la branche feature/mon-master

Chaque dossier numéroté contient **les fichiers complets d'un seul commit**, déjà rangés comme dans le projet
(`src/...`, `docs/...`). Tu copies le dossier dans le projet, tu vérifies, tu commites, puis tu passes au suivant.
J'ai rejoué les 8 étapes (dossier `dist` effacé avant chaque build) dans l'ordre à partir de ton dernier commit (24da65d) : lint, build et tests OK à chaque étape.

À faire **en utilisateur normal** (pas en root), depuis la racine du projet :

```bash
cd ~/Documents/parcoursup-explorer
git switch feature/mon-master
R=~/Documents/REPO_COURS_BUT2_ARLES_/TP1_Javascritp/Projet_à_rendre/commits_restants
```

Pour chaque étape, la routine est toujours la même :

```bash
cp -r "$R/<dossier de l'étape>/." .      # le /. copie le CONTENU du dossier dans le projet
git status                               # seuls les fichiers de l'étape doivent apparaître
npx standard src/                        # rien ne doit s'afficher
npm run build                            # « compiled successfully »
```

---

## 1. `1-style-lint`

```bash
cp -r "$R/1-style-lint/." .
git add src/scripts/services/serviceParcoursup.js
git commit -m "style: supprime les lignes vides en trop dans ServiceParcoursup" -m "StandardJS signalait padded-blocks et no-multiple-empty-lines."
```

## 2. `2-refactor-formation`

```bash
cp -r "$R/2-refactor-formation/." .
git add src/scripts/modeles/formation.js
git commit -m "refactor: utilise contientTousLesMots du module outils dans Formation" -m "Le commit f6097fa avait créé outils.js mais Formation gardait sa propre copie de normaliser. Formation et Master partagent maintenant la même fonction : un seul endroit à corriger."
```

## 3. `3-feat-mon-master`

Il s'agit de la fin du Mon Master que tu avais commencé : app.js, VueResultats, VueHistorique, VueCarte et le style.
Tu as déjà une partie des fichiers (application.js, vueRecherche.js, les templates) : la copie les remplace par la même chose.

```bash
cp -r "$R/3-feat-mon-master/." .
git add src/scripts/app.js src/scripts/application.js src/scripts/vues/vueRecherche.js src/scripts/vues/vueResultats.js src/scripts/vues/vueHistorique.js src/scripts/vues/vueCarte.js src/scripts/tpl/recherche.tpl.html src/scripts/tpl/resultats.tpl.html src/scripts/tpl/historique-contenu.tpl.html src/scripts/tpl/liste-masters.tpl.html src/stylesheets/styles.scss
git commit -m "feat: affiche les masters d'une région et leur historique" -m "Choix Parcoursup / Mon Master dans le formulaire. Liste des masters (taux de proposition, chiffres BUT 3), filtre polymorphe (Formation et Master ont chacun correspond) et fenêtre d'historique commune aux deux. Pas de carte : Mon Master ne publie pas de coordonnées, VueCarte.masquer() cache la carte."
```

## 4. `4-fix-outre-mer`

```bash
cp -r "$R/4-fix-outre-mer/." .
git add src/scripts/services/serviceGeocodage.js
git commit -m "fix: trouve la région des villes d'outre-mer" -m "L'IGN renvoie « 971, Guadeloupe » (2 morceaux) au lieu de « 13, Bouches-du-Rhône, Provence-Alpes-Côte d'Azur » (3 morceaux) : la région restait inconnue et les 131 masters des DROM étaient introuvables. Outre-mer, la région est le département lui-même."
```

## 5. `5-style-formulaire`

```bash
cp -r "$R/5-style-formulaire/." .
git add src/scripts/tpl/recherche.tpl.html src/scripts/tpl/main.tpl.html src/stylesheets/styles.scss
git commit -m "style: refait le formulaire de recherche sur le modèle de Mon Master" -m "Titre, choix du parcours en boutons accolés (vrais boutons radio, utilisables au clavier), textes d'aide reliés aux champs par aria-describedby, grille qui passe sur une colonne sur téléphone, bouton Rechercher avec une loupe et à la hauteur des champs. Les couleurs passent en variables CSS."
```

## 6. `6-feat-mode-sombre`

```bash
cp -r "$R/6-feat-mode-sombre/." .
git add src/scripts/vues/vueTheme.js src/scripts/app.js src/scripts/tpl/main.tpl.html src/scripts/vues/vueHistorique.js src/scripts/vues/vueCarte.js src/stylesheets/styles.scss
git commit -m "feat: ajoute un mode sombre aux couleurs de Mon Master" -m "VueTheme pose data-theme sur <html> : styles.scss redéfinit alors les variables CSS avec les valeurs sombres du DSFR. Sans choix, on suit prefers-color-scheme ; le choix du bouton est gardé dans localStorage (try/catch si le stockage est bloqué). Le graphique lit les variables CSS, le cercle de la carte prend sa couleur dans le CSS, les tuiles sont inversées par un filtre."
```

## 7. `7-feat-zone-departement`

```bash
cp -r "$R/7-feat-zone-departement/." .
git add src/scripts/tpl/recherche.tpl.html src/scripts/vues/vueRecherche.js src/scripts/application.js src/scripts/vues/vueResultats.js src/scripts/modeles/master.js src/scripts/services/serviceMonMaster.js
git commit -m "feat: permet de chercher les masters de son département" -m "Mon Master ne sait pas filtrer par département de façon fiable (« (13) » se trouve aussi dans « CEDEX 13 ») : on garde la même requête par région, et Application trie avec Master.estDansLeDepartement. Aucune requête en plus. La Corse est notée « 20 » chez Mon Master mais 2A/2B chez l'IGN."
```

## 8. `8-docs-diagramme`

```bash
cp -r "$R/8-docs-diagramme/." .
git add docs/diagramme-classes.drawio.pdf
git commit -m "docs: ajoute Mon Master, la zone et VueTheme au diagramme de classes" -m "Page 3 : ServiceMonMaster, Master, StatistiqueMaster, outils.js et VueTheme."
```

## Envoi et fusion

```bash
git push -u origin feature/mon-master
git switch main
git merge feature/mon-master
git push
git log --oneline -10
```
