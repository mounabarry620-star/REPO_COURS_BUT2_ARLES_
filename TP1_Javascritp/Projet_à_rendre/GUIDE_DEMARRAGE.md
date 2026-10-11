# Parcoursup Explorer : guide de démarrage

Guide préparé le 11/10/2026 après lecture du sujet, de mes notes, des chapitres 1 à 5 du cours et des TP01 à TP03.
**Règle : c'est moi qui tape et qui commite.** Claude explique et relit, il n'écrit ni mes classes ni mon architecture (règle du prof sur l'IA).

---

## 0. Ce que le prof attend (relevé dans ses cours et TP)

### Contraintes du sujet (non négociables)
| Contrainte | Comment je la respecte |
|---|---|
| Programmation orientée objet | Classes ES6 (`class`, `constructor`, `get`, champs privés `#`), une classe par fichier |
| Module empaqueté par webpack | Config `common` / `dev` / `prod` reprise du TP03 |
| 3 dernières versions des navigateurs | `browserslist` dans `package.json` + Babel (`@babel/preset-env`) |
| Toutes les dépendances par webpack | `npm install`, puis `import`. Pas de CDN, pas de `<script>` écrit à la main, images et CSS importés |
| 2 requêtes `fetch` dépendantes | IGN (ville → coordonnées) **puis** Parcoursup (coordonnées → formations) |
| Git, README, « Usage de l'IA », « Choix de conception » | Commits réguliers, README complété au fil de l'eau |

### Le style du prof (à copier)
| Point de style | Où il le montre | Exemple |
|---|---|---|
| Modules ES (`import` / `export`) | Chapitre 4, TP02 | `export class Compteur { … }` puis `import { Compteur } from './compteur.js'` |
| Classes ES6 avec champs privés `#` et getters | Chapitre 3, TP02 (`Compteur`) | `#valeur = 0` et `get valeur () { … }` |
| **Pas de points-virgules**, guillemets simples | Toute sa config du TP03 | `import path from 'node:path'` |
| Indentation de 2 espaces, **espace avant les parenthèses** des déclarations | Code du TP02 (= règles StandardJS) | `function saluer (nom)`, `incrementer ()`, `get valeur ()` |
| `async` / `await` + **tester `response.ok`** | Chapitre 5 | `if (!response.ok) { throw new Error(…) }` |
| `Promise.all` pour les requêtes en parallèle | Chapitre 5 | historique 2022, 2023, 2024 en même temps |
| `Map` pour garder des données, `setTimeout` | TP03 (indice donné) | cache des réponses |
| Debounce sur la saisie | Chapitre 5 | attendre la fin de la frappe avant de chercher la ville |
| `addEventListener`, jamais `onclick` dans le HTML | Chapitre 2 | séparer le comportement du contenu |
| `createElement` préférable à `innerHTML` | Chapitre 2 | sauf pour les templates (voir plus bas) |
| Templates dans des fichiers `.tpl.html` | TP03 (`main.tpl.html`, `popupview.tpl.html`) | règle webpack `asset/source` |
| Arborescence `src/scripts`, `src/tpl`, `src/stylesheets`, `src/images` | TP03 | voir étape 4 |
| Bonus : StandardJS (règles de style ESLint) | Fin du TP03 | `npx standard` |

⚠️ Mon code du TP03 (`app.js`) a des points-virgules et des guillemets doubles : **ce n'est pas le style du prof**. Dans le projet, je suis StandardJS dès le début (étape 2).

---

## 1. Créer le dépôt git (hors du dépôt public)

⚠️ Mon dépôt `REPO_COURS_BUT2_ARLES_` est **public** sur GitHub. Le projet doit avoir **son propre `.git`** et ne jamais être poussé dans un dépôt public. Je le crée donc **à côté**, dans `~/Documents/parcoursup-explorer`.

```bash
mkdir ~/Documents/parcoursup-explorer
cd ~/Documents/parcoursup-explorer
git init
git config user.name "Prénom Nom"
git config user.email "prenom.nom@etu.univ-amu.fr"
```

**Pourquoi sans `--global` ?** La config ne s'applique qu'à ce projet (elle est enregistrée dans `.git/config`). Mon identité de cours apparaîtra dans chaque commit, et non `nene_goto_`.

Je crée ensuite le fichier `.gitignore` :
```
node_modules/
dist/
.env
```

**Commit 1** : `git add .` puis `git commit -m "Initialisation du dépôt et du .gitignore"`

---

## 2. Initialiser npm et installer les dépendances

```bash
npm init -y
```

Dans `package.json`, je modifie à la main (comme le `package.json` du prof au TP03) :
- `"private": true` : empêche de publier le projet sur npm par erreur ;
- `"type": "module"` : permet d'écrire la config webpack avec `import` au lieu de `require` ;
- `"description"`, `"author"` : ma description et mon nom ;
- les scripts :
  ```json
  "scripts": {
    "start": "webpack serve --config webpack.dev.js",
    "build": "webpack --config webpack.prod.js",
    "lint": "standard"
  }
  ```
- la compatibilité navigateurs :
  ```json
  "browserslist": [
    "last 3 versions",
    "not dead"
  ]
  ```
- le réglage de StandardJS (sans lui, `standard` signale `'Image' is not defined` et les autres objets du navigateur, constaté sur le TP02) :
  ```json
  "standard": {
    "env": ["browser"]
  }
  ```

  **Pourquoi `last 3 versions` ?** Le sujet exige les **3 dernières versions** (le prof a mis `last 2 versions` au TP03, mais c'était un TP). `not dead` exclut les navigateurs abandonnés (Internet Explorer). Babel lit cette liste pour savoir quel code transformer.

Les outils de construction (comme au TP03, le prof met tout en `-D`) :
```bash
npm install -D webpack webpack-cli webpack-dev-server webpack-merge html-webpack-plugin
npm install -D babel-loader @babel/core @babel/preset-env
npm install -D sass sass-loader
npm install -D standard
```

Les bibliothèques de l'appli (toutes autorisées par le prof) :
```bash
npm install -D leaflet handlebars
```
Chart.js s'installera plus tard, pour le bonus 1 (historique) : `npm install -D chart.js`.

**Pas de `dotenv` cette fois.** Au TP03, le `.env` servait au proxy (CORS). Mes API acceptent le CORS et n'ont **pas de clé** : pas besoin de proxy, ni de `.env`. Le prof n'aura rien à configurer. C'est un argument à mettre dans « Choix de conception ».

**Commit 2** : `"Initialisation npm et installation des dépendances"` (le `package-lock.json` **se commite** : il fige les versions exactes).

---

## 3. Configurer webpack (reprise du TP03)

Je copie mes 3 fichiers du TP03 (`TP1_Javascritp/TP03/mon-projet/webpack.*.js`), puis je fais **ces changements** :

### `webpack.common.js`
| À faire | Pourquoi |
|---|---|
| Supprimer `import Dotenv from 'dotenv-webpack'` et `new Dotenv()` | Pas de `.env` dans ce projet |
| `title: 'Parcoursup Explorer'` | Titre de l'onglet |
| Ajouter `favicon: path.resolve(import.meta.dirname, './src/images/favicon.ico')` | Comme le prof : l'icône passe aussi par webpack |
| Garder les règles `babel-loader`, `sass-loader`, `.tpl.html` (`asset/source`), images, polices | Ce sont les mêmes besoins |

Ce que fait chaque bloc (à savoir expliquer) :
- `entry` : le fichier par lequel webpack commence à suivre les `import` ;
- `output` : où il écrit le résultat (`dist/`), `clean: true` vide le dossier avant chaque build ;
- `HtmlWebpackPlugin` : génère `index.html` et y ajoute le `<script>` **tout seul** (je n'en écris aucun) ;
- `babel-loader` : traduit mon JS moderne pour les navigateurs de `browserslist` ;
- `asset/source` : un `.tpl.html` importé devient une **chaîne de caractères** ;
- `asset/resource` : une image importée devient un fichier dans `dist/images/` et l'`import` me donne son URL.

### `webpack.dev.js`
- Supprimer `import 'dotenv/config'` et tout le bloc `proxy`. Le reste ne change pas.

### `webpack.prod.js`
- Rien à changer.

---

## 4. Créer l'arborescence (celle du TP03)

```
parcoursup-explorer
│ package.json
│ webpack.common.js
│ webpack.dev.js
│ webpack.prod.js
│ .gitignore
│ README.md
│
└───src
    │ index.js
    ├───images
    │     favicon.ico
    ├───scripts
    │     app.js        (+ mes classes, une par fichier)
    ├───tpl
    │     main.tpl.html
    └───stylesheets
          styles.scss
```

Premier test minimal :
- `src/index.js` importe `./stylesheets/styles.scss` et `./scripts/app.js` (comme au TP03) ;
- `app.js` contient juste un `console.log('Parcoursup Explorer démarre')` ;
- `npm start` : la page s'ouvre sur `localhost:8080`, le message est dans la console (F12) ;
- `npm run build` : le dossier `dist/` se crée sans erreur ;
- `npm run lint` : StandardJS ne signale rien.

**Commit 3** : `"Configuration de webpack et arborescence du projet"`

### 💡 Piège connu avec Handlebars + webpack
`import Handlebars from 'handlebars'` affiche l'avertissement `require.extensions is not supported by webpack`. La cause : le fichier principal de Handlebars est prévu pour Node.js (j'ai vérifié, ligne 23 de `node_modules/handlebars/lib/index.js`). Il faut importer la version prévue pour le navigateur :
```js
import Handlebars from 'handlebars/dist/handlebars.js'
```

**Pourquoi Handlebars plutôt que `.replace('{{nom}}', …)` comme dans mon TP03 ?** `{{nom}}` dans Handlebars **échappe** le HTML : si une donnée de l'API contenait `<script>`, elle s'afficherait comme du texte au lieu de s'exécuter (protection contre la faille XSS). Avec `.replace` + `innerHTML`, rien ne me protège. C'est un bon argument « sécurité » pour le README.

---

## 5. Concevoir mes classes (le diagramme de classes)

**C'est la partie la plus importante de la note** (« Éléments de conception ») et de la section « Choix de conception ». Elle doit venir de moi. Voici une méthode.

### 5.1 Lister ce que l'appli doit faire (les « responsabilités »)
1. Lire ce que tape l'utilisateur (ville, filière, rayon) et réagir aux clics.
2. Envoyer une requête HTTP et vérifier la réponse (`response.ok`, liste vide).
3. Transformer une ville en coordonnées (IGN).
4. Faire la même chose avec l'API de secours (geo.api.gouv.fr) si l'IGN ne répond pas. *(bonus 2)*
5. Chercher les formations autour d'un point (Parcoursup 2025).
6. Récupérer l'historique d'une formation (2022-2024). *(bonus 1)*
7. Garder les réponses en mémoire pour ne pas redemander (cache).
8. Représenter **une ville** et **une formation** dans **mon propre format** (nombres convertis, champs renommés).
9. Calculer la tendance, la fourchette et le R². *(bonus 1)*
10. Afficher : la liste, la carte Leaflet, le graphique.
11. Orchestrer : enchaîner 1 → 3 → 5, et afficher les erreurs.

### 5.2 Regrouper les responsabilités en classes
Je regroupe ce qui change **pour la même raison**. Les questions à me poser :
- **« Si l'IGN change le format de sa réponse demain, combien de fichiers dois-je modifier ? »** Idéalement un seul. C'est le conseil oral du prof : « dépendre de la structure, pas des API ».
- **« Le reste de mon code sait-il si la ville vient de l'IGN ou du secours ? »** Il ne devrait pas. Les deux sources doivent rendre **le même type d'objet**.
- **« Où le `taux_acces_ens` texte (`"52"`) est-il converti en nombre ? »** À **un seul endroit**, une seule fois.
- **« Mon affichage fait-il des `fetch` ? »** Non : afficher et télécharger sont deux métiers différents.
- **« Le cache connaît-il Parcoursup ? »** Non : un cache stocke une valeur sous une clé (une URL par exemple), c'est tout. Il peut donc servir à toutes les API.
- **« L'héritage a-t-il un sens quelque part ? »** Le cours le montre (chapitre 1 : `Forme` → `Rectangle`, chapitre 3 : `extends`, `super`). Exemple de question : mes deux sources de géocodage ont-elles un comportement commun ?

### 5.3 Dessiner le diagramme
- Une boîte par classe : nom, attributs (avec `-` pour les privés `#`), méthodes.
- Les flèches : « utilise », « hérite de ».
- Outil possible : **draw.io** (gratuit, exporte en PNG), ou papier puis photo.
- Le diagramme va dans le dépôt (`docs/diagramme-classes.png`) et dans le README.

👉 **Quand j'ai un premier diagramme, je le montre à Claude pour une relecture** (c'est un usage autorisé : « relecture et pistes d'amélioration »).

---

## 6. Ordre de codage et commits prévus

Un commit = une modification cohérente. Exemple de progression :

| # | Ce que je code | Message de commit (exemple) |
|---|---|---|
| ✅ 4 | Diagramme de classes | `Ajout du diagramme de classes` |
| ✅ 5 | La classe qui fait les requêtes (avec `response.ok`) | `Classe d'accès HTTP avec gestion des erreurs` |
| ✅ 6 | Requête 1 seule : ville → coordonnées, affichées dans la console | `Géocodage d'une ville avec l'API IGN` |
| ✅ 7 | Mon format « ville » (lon, lat, nom, département, région) | `Modèle Ville indépendant de l'API` |
| ✅ 8 | Requête 2 qui utilise le résultat de la 1 | `Recherche des formations autour d'une ville` |
| ✅ 9 | Mon format « formation » (conversion des nombres) | `Modèle Formation et conversion des champs` |
| ✅ 10 | Formulaire + liste des résultats (template) | `Affichage des formations dans la page` |
| ✅ 11 | Cas d'erreur : ville inconnue, 0 résultat, réseau | `Gestion des cas d'erreur et messages` |
| ✅ 12 | Cache (`Map` + date d'expiration) | `Cache des réponses` |
| ⭐ 13 | Carte Leaflet | `Carte Leaflet des formations` |
| ⭐ 14 | Choix parmi les villes homonymes + debounce | `Choix de la ville avec debounce` |
| ⭐ 15 | API de secours | `Bascule sur geo.api.gouv.fr si l'IGN échoue` |
| ⭐ 16 | Historique + `Promise.all` + Chart.js | `Historique 2022-2025 et graphique` |
| ⭐ 17 | Tendance, R², fourchette, rang du dernier appelé | `Calcul de la tendance et de sa fiabilité` |
| ⭐ 18 | Mon Master | `Parcours étudiant diplômé avec Mon Master` |

✅ = obligatoire · ⭐ = bonus. **Je ne passe aux ⭐ que quand les ✅ marchent et sont commités.**

---

## 7. Pièges déjà repérés (vérifiés le 09 et le 11/10)

| Piège | Conséquence | Parade |
|---|---|---|
| Coordonnées IGN au format **[lon, lat]** | Inversées : 0 résultat, **sans erreur** | Nommer clairement `lon` / `lat` dans mon format |
| Ville inconnue | Code 200 + liste vide | Tester la longueur de la liste, pas seulement `response.ok` |
| `fetch` ne rejette pas sur 404 / 500 | L'erreur passe inaperçue | `if (!response.ok) throw new Error(…)` (chapitre 5) |
| `limit` > 100 | Erreur 400 | `limit=100` + `offset` pour la page suivante |
| `taux_acces_ens`, `ran_grp1` : nombre, texte ou décimal selon l'année | Calculs faux | Conversion **une seule fois** dans mon format |
| Champs différents avant 2022 | Erreur 400 | Historique limité à 2022-2025 |
| Apostrophe de « Côte d'Azur » | Erreur 400 dans Mon Master | Guillemets doubles dans le `where` |
| Paramètre `where` avec espaces et apostrophes | URL cassée | `encodeURIComponent` ou `URLSearchParams` |
| Quota : 5 000 requêtes / jour / IP (IP partagée à l'IUT) | Blocage | Cache + debounce |
| `npm start` après un changement de config webpack | Ancienne config utilisée | Relancer `npm start` |

---

## 8. Planning (rendu le 23/10/2026 avant 23h59, −1 pt/heure de retard)

| Date | À faire |
|---|---|
| 11-12/10 | Étapes 1 à 4 (git, npm, webpack) → commits 1 à 3 |
| 13/10 | Diagramme de classes (étape 5), relecture par Claude |
| 14-16/10 | Commits 5 à 12 : **l'obligatoire fonctionne** |
| 17-20/10 | Bonus dans l'ordre (carte, debounce, secours, historique…) |
| 21/10 | `npm run build`, test sur Firefox, Chrome et Edge, `npm run lint` |
| 22/10 | README complet (description, installation, Usage de l'IA, Choix de conception) |
| 23/10 | Archive **sans** `node_modules`, **avec** `.git` (ouvrir l'archive pour vérifier), dépôt AMETICE **bien avant 23h59** |

---

## 9. À noter au fil de l'eau pour le README

- **Usage de l'IA** : Claude (Claude Code) : tests des API, explications du cours, guide de démarrage, relecture de mon code (préciser quels fichiers). Gemini : TP précédents, si utilisé ici.
- **Choix de conception** : noter **dès maintenant** chaque décision et chaque difficulté rencontrée, avec la date. À la fin, la section s'écrira presque toute seule.
