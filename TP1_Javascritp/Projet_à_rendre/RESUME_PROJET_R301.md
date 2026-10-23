# Résumé du projet R3.01 : Parcoursup Explorer

Résumé écrit le 23/10/2026, pour reprendre le travail sur une autre machine.
A ne pas commiter dans REPO_COURS_BUT2_ARLES_ : ce dépôt de cours est public.

---

## 1. Où on en est

- **Le projet est terminé.** Code, diagramme, README, tests : tout est fait.
- **Rendu :** archive à déposer sur AMETICE **avant le 25/10/2026 à 23h59** (date prolongée par M. Desbenoit ; au départ c'était le 23/10).
  - Consigne AMETICE : aucun dossier temporaire dans l'archive. `node_modules` = malus sur la note.
- **Archive prête :** `~/Documents/BARRY_Mamadou-Bailo_parcoursup-explorer.zip` (1,6 Mo).
  - Elle contient le projet avec le `.git` (57 commits), sans `node_modules` ni `dist`.
  - Vérifiée : décompressée dans un dossier vide, `npm install` (0 vulnérabilité), lint, build, tous les tests OK. Je l'ai aussi testée moi-même à la main : tout marche.
  - **Reste à faire : la déposer, puis vérifier que le dépôt est VALIDÉ (pas en brouillon).**

## 2. Les adresses

| Quoi | Où |
|---|---|
| Projet (dossier) | `~/Documents/parcoursup-explorer` |
| Dépôt GitHub (PRIVÉ, il doit le rester) | `https://github.com/mounabarry620-star/parcoursup-explorer` |
| Branche principale | `main`, dernier commit `80c1760 docs: ajoute le README` |
| Site en ligne (Cloudflare) | `https://explorateur-formations-barry.mounabarry620.workers.dev` |
| Documents de travail | `~/Documents/REPO_COURS_BUT2_ARLES_/TP1_Javascritp/Projet_à_rendre/` |

**Site en ligne :** il fonctionne, mais j'ai choisi de laisser les fichiers `.js.map` en ligne. Ils rendent mon code source lisible par tout le monde (F12, onglet Sources). Pour les enlever plus tard :

```bash
cd ~/Documents/parcoursup-explorer
npm run build
rm dist/js/*.map
```

Puis renvoyer le dossier `dist` sur Cloudflare.

## 3. Reprendre sur une nouvelle machine

1. Installer **Node.js 22 ou plus récent** (le projet a été fait avec Node 24) et **git**.
2. Récupérer le projet depuis GitHub (le dépôt est privé : il faut être connecté à son compte GitHub) :
   ```bash
   cd ~/Documents
   git clone https://github.com/mounabarry620-star/parcoursup-explorer.git
   cd parcoursup-explorer
   git config user.name "BARRY Mamadou-Bailo"
   git config user.email "mamadou-bailo.BARRY@etu.univ-amu.fr"
   npm install
   npm start
   ```
3. Ne jamais lancer git ou npm en root, et toujours commiter avec le mail universitaire.

**Commandes utiles :**

| Commande | Ce qu'elle fait |
|---|---|
| `npm start` | lance le site sur http://localhost:8080 |
| `npm run build` | fabrique la version finale dans `dist/` |
| `npm run lint` | vérifie le style StandardJS (rien ne doit s'afficher) |
| `git log --oneline -5` | les derniers commits |

**Refaire l'archive** (si je change quelque chose avant le dépôt) :

```bash
cd ~/Documents
zip -r BARRY_Mamadou-Bailo_parcoursup-explorer.zip parcoursup-explorer -x "parcoursup-explorer/node_modules/*" "parcoursup-explorer/dist/*"
unzip -l BARRY_Mamadou-Bailo_parcoursup-explorer.zip | grep -c "node_modules"
```

La dernière commande doit afficher **0**.

## 4. Ce que fait l'application

- **Parcours 1, Parcoursup :** ville (avec autocomplétion IGN), puis rayon (1 à 200 km) et filière. Requête 1 : l'IGN donne la position de la ville. Requête 2 : Parcoursup donne les formations dans le cercle.
  - Résultats en liste et sur une carte Leaflet (bulles de regroupement, cercle du rayon).
  - Filtre texte sans accents.
  - Historique 2022-2025 en graphique Chart.js et en tableau.
- **Parcours 2, Mon Master :** ville, zone (région ou département) et discipline (46). Requête 1 : l'IGN donne la région. Requête 2 : Mon Master donne les masters de la région.
  - Taux de proposition, taux pour les licences 3 et taux pour les BUT 3.
  - Historique 2023-2025. Pas de carte (Mon Master ne donne pas la position des masters).
- **Pour tout le site :** mode sombre (couleurs de Mon Master, suit le réglage de l'ordinateur, choix gardé dans localStorage), accessibilité, version téléphone, messages d'erreur clairs, ville de moins de 3 lettres bloquée.
- **Aucune clé d'API :** IGN et open data du ministère sont publics.

## 5. Les classes (diagramme dans `docs/diagramme-classes.drawio.pdf`, 3 pages)

- **Services :** `ServiceApi` (classe mère : fetch, `response.ok`, cache) et ses 3 filles : `ServiceGeocodage`, `ServiceParcoursup`, `ServiceMonMaster`. Un seul `Cache` partagé.
- **Modèles :** `Ville`, `Suggestion`, `Formation`, `Master`, `StatistiqueAnnuelle`, `StatistiqueMaster`, `Historique` (champs privés `#`, getters).
- **Vues :** `VueRecherche`, `VueResultats`, `VueCarte`, `VueHistorique`, `VueTheme`.
- **Contrôleur :** `Application`. `app.js` crée tout.
- **`outils.js` :** `normaliser`, `contientTousLesMots`, `pourcentage`, `versNombre`.
- **Polymorphisme :** `correspond()` (Formation et Master), `historique()` (les deux services).

## 6. A savoir pour l'oral

- **Les 2 requêtes dépendantes :** `Application.rechercher`, dans `src/scripts/application.js`, lignes 97 à 124 (`async/await`, un seul `try/catch`).
- **Recherches qui se croisent :** chaque recherche a un numéro (`#numeroRecherche`). Une réponse en retard est ignorée (commit `c358944`).
- **Historique :** `Promise.all`, car les années ne dépendent pas les unes des autres.
- **Difficulté principale :** la route `records` coupe à 100 résultats sans erreur (Paris 10 km : 100 au lieu de 1 473). Solution : la route `exports/json` avec `select`. Paris 200 km : 4 456 formations.
- **Autres difficultés :**
  - les noms des champs changent selon l'année (tableau `JEUX_HISTORIQUE`) ;
  - les villes d'outre-mer sans région (commit `3323008`) ;
  - la Corse vaut "20" chez Mon Master mais 2A/2B chez l'IGN ;
  - Handlebars refuse les getters, donc on copie les données dans des objets simples ;
  - l'IGN refuse les recherches de moins de 3 caractères (commit `53cf0b9`).
- **Anti-bannissement :** cache, attente de 300 ms en fin de frappe, une seule requête par recherche. Mocks : les fausses vues du commit `c9ab42d`.
- **Hors cours (expliqué dans le README avec les liens MDN) :** `import()`, `localStorage`, `matchMedia`, `<dialog>`, `<datalist>`, `pattern`, variables CSS, `grid`, `closest`, Chart.js, Fontsource.

## 7. Décisions prises pendant le projet

- Projet de cybersécurité abandonné (trop de code). Parcoursup Explorer validé par le prof le 09/10.
- Pas d'API de secours (le prof a dit à l'oral qu'il n'en faut pas).
- Mon Master ajouté (option B : liste et historique, sans carte).
- Prévision et tendance abandonnées : pas fiables sans les notes du candidat, et 4 années ne suffisent pas.
- Design inspiré de Parcoursup et de Mon Master (DSFR), avec mon propre logo (logo officiel interdit sans accord du ministère ; police Marianne réservée à l'État).
- Ajoutés à la fin : mode sombre, zone "mon département", taux licences 3, vérification de la saisie, uniquement des caractères tapables au clavier dans le code et le README.

## 8. Usage de l'IA (déclaré dans le README)

- **Outil :** Claude. Le prof a dit à l'oral que l'IA peut donner du code s'il est expliqué et compris.
- **Ce que l'IA a fait :** l'architecture, le diagramme, le code expliqué étape par étape, les tests automatiques (faits en dehors du dépôt, ils ne sont pas sur ma machine), la relecture, le premier brouillon du README.
- **Ce que j'ai fait :** le choix du sujet, toutes les décisions, les tests à la main (j'ai trouvé des bugs), l'intégration, tous les commits et les fusions.
- La déclaration doit rester complète et honnête : le sujet pénalise un usage non déclaré.

## 9. Limites connues (écrites dans le README)

- Pas de carte pour les masters. Villes de 1 ou 2 lettres : ajouter le code postal ("Eu 76260").
- Données jusqu'à 2025. Chiffres BUT 3 seulement depuis 2024.
- Testé sous Chromium (Chrome, Edge) et Firefox, pas Safari.
- Les bibliothèques sont dans `devDependencies` au lieu de `dependencies` (ça marche, mais ce n'est pas le rangement du TP 2).

## 10. Historique rapide

| Dates | Ce qui a été fait |
|---|---|
| 11/10 | création du dépôt et de la configuration webpack |
| 18/10 | partie obligatoire (classes, 2 requêtes, vues), autocomplétion |
| 19/10 | carte, design, filtre |
| 20-21/10 | historique Parcoursup |
| 22/10 | Mon Master, design du formulaire, mode sombre, zone département, licences 3, corrections |
| 23/10 | caractères tapables au clavier, README, archive, mise en ligne sur Cloudflare |
