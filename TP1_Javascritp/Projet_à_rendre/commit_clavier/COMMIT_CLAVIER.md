# Dernier ajustement : que des caractères tapables au clavier

En utilisateur normal, lignes une par une :

```bash
cd ~/Documents/parcoursup-explorer
git switch main
git switch -c style/caracteres-clavier
R=~/Documents/REPO_COURS_BUT2_ARLES_/TP1_Javascritp/Projet_à_rendre/commit_clavier
ls "$R/fichiers/src"
```

`ls` doit afficher `scripts` et `stylesheets`. Sinon, arrête-toi.

```bash
cp -r "$R/fichiers/." .
git status
npx standard src/
npm run build
```

`git status` doit montrer **14 fichiers modifiés**, et aucun autre. Le lint ne doit rien afficher.

```bash
git add src/scripts/application.js src/scripts/modeles/master.js src/scripts/outils.js src/scripts/services/serviceGeocodage.js src/scripts/services/serviceMonMaster.js src/scripts/tpl/historique.tpl.html src/scripts/tpl/liste-masters.tpl.html src/scripts/tpl/main.tpl.html src/scripts/tpl/recherche.tpl.html src/scripts/tpl/resultats.tpl.html src/scripts/vues/vueHistorique.js src/scripts/vues/vueResultats.js src/scripts/vues/vueTheme.js src/stylesheets/styles.scss
git commit -m "style: n'utilise que des caractères tapables au clavier" -m "Guillemets droits au lieu des guillemets français, trois points au lieu du caractère points de suspension, entités HTML (&times;, &middot;, &hellip;, &Eacute;) dans les templates, échappements \\u0300-\\u036f et \\u00a0 dans le JavaScript. L'affichage ne change pas, et la valeur de la discipline électronique reste identique aux données."
git push -u origin style/caracteres-clavier
git switch main
git merge style/caracteres-clavier
git push
git log --oneline -3
```
