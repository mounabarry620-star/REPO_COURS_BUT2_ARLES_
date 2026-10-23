# Parcoursup Explorer : guide pas à pas

Rendu : **23/10/2026 avant 23h59** sur AMETICE (−1 point par heure de retard).

## Les 4 règles d'or

1. **Toujours en utilisateur normal, jamais en root** (sinon git refuse de travailler, et `npm` crée des fichiers que je ne peux plus modifier).
2. **Indentation de 2 espaces** (style du prof) : réglée dans `.vscode/settings.json` (étape 3.7). Avant chaque commit, `npm run lint` ne doit rien afficher. Sinon, `npx standard --fix` corrige la mise en forme.
3. **Toujours dans le dossier du projet.** J'ouvre le projet dans Antigravity (Fichier → Ouvrir le dossier → `parcoursup-explorer`), puis Terminal → New Terminal. Pour vérifier : `pwd` affiche `/home/nene_goto_/Documents/parcoursup-explorer`.
4. **Le code, je dois savoir l'expliquer ligne par ligne.** Le prof autorise à l'oral que l'IA donne l'architecture **et** le code, à condition qu'elle l'explique comme un prof (cours, documentation MDN, justification de chaque choix). Pour chaque classe, Claude donne le code et l'explication ; **je le tape moi-même** (c'est en tapant qu'on retient), je le teste, puis je commite. Ce que l'IA m'a aidé à faire sera déclaré dans « Usage de l'IA » (on le choisit ensemble).

## Où j'en suis (18/10)

- [x] **Étapes 1 à 3** : dépôt, npm, webpack, lint
- [x] **Étape 4** : diagramme de classes (`diagramme-classes.drawio`, style du TD R2.01, avec légende)
- [x] **Étape 5** : partie obligatoire : `Cache`, `ServiceApi`, `Ville`, `ServiceGeocodage`, `Formation`, `ServiceParcoursup`, `Application`, `VueRecherche`, `VueResultats`, `.env.defaults` ✅
- [ ] **Étape 6** : bonus (carte Leaflet, autocomplétion IGN) ← **je suis ici**
- [ ] **Étape 7** : README et rendu

---

## Étape 1 ✅ Dépôt git (fait le 11/10)

Pour mémoire, ce que j'ai fait (cours R2.03 : créer le dépôt en ligne, puis `git clone`) :
- dépôt **privé** `parcoursup-explorer` créé vide sur GitHub, puis `git clone` dans `~/Documents` ;
- identité du projet : `git config user.name "BARRY Mamadou-Bailo"` et `git config user.email "mamadou-bailo.BARRY@etu.univ-amu.fr"` ;
- `.gitignore` (`node_modules/`, `dist/`, `.env`), puis commit 1 et `git push -u origin main`.

## Étape 2 ✅ npm (fait le 11/10)

`package.json` modifié (type `module`, `private`, scripts, `browserslist`, `standard`), installation des outils, puis commit 2. Leaflet, Handlebars et Chart.js s'installeront **au moment où je m'en servirai**, chacun avec son commit.

---

## Étape 3 : webpack et dossiers du projet

La configuration est celle du **TP03 du prof**, avec 3 changements : pas de `.env` ni de `dotenv` (mes API n'ont pas de clé), pas de proxy (mes API acceptent le CORS), et le titre de mon application.

### 3.1 Créer les dossiers et récupérer une icône

```bash
mkdir -p src/images src/scripts/tpl src/stylesheets
cp ~/Documents/REPO_COURS_BUT2_ARLES_/TP1_Javascritp/TP03/mon-projet/src/images/favicon.ico src/images/
```

L'icône du TP03 sert en attendant d'en avoir une à moi. Le dossier `src/scripts/tpl` reste vide pour l'instant : git ne garde pas les dossiers vides, ce n'est pas grave.

### 3.2 Créer les 3 fichiers de configuration (à la racine du projet)

**`webpack.common.js`** : la configuration commune au développement et à la production.
```js
import path from 'node:path'
import HtmlWebpackPlugin from 'html-webpack-plugin'

export default {
  entry: './src/index.js',
  output: {
    path: path.resolve(import.meta.dirname, 'dist'),
    clean: true
  },
  plugins: [
    new HtmlWebpackPlugin({
      title: 'Parcoursup Explorer',
      favicon: path.resolve(import.meta.dirname, './src/images/favicon.ico')
    })
  ],
  module: {
    rules: [
      {
        test: /\.js$/i,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env']
          }
        }
      },
      {
        test: /\.s[ac]ss$/i,
        type: 'css/auto',
        use: [
          {
            loader: 'sass-loader',
            options: {
              sassOptions: {
                quietDeps: true
              }
            }
          }
        ]
      },
      {
        test: /\.tpl\.html$/i,
        type: 'asset/source'
      },
      {
        test: /\.(png|jpe?g|gif|svg|webp)$/i,
        type: 'asset/resource',
        generator: {
          filename: 'images/[name].[contenthash][ext]'
        }
      },
      {
        test: /\.(woff2?|ttf|otf|eot)$/i,
        type: 'asset/resource',
        generator: {
          filename: 'fonts/[name].[contenthash][ext]'
        }
      }
    ]
  },
  experiments: {
    css: true
  }
}
```

**`webpack.dev.js`** : pour travailler (`npm start`).
```js
import { merge } from 'webpack-merge'
import commun from './webpack.common.js'

export default merge(commun, {
  mode: 'development',
  devtool: 'eval-source-map',
  output: {
    filename: 'js/[name].js',
    cssFilename: 'css/[name].css'
  },
  devServer: {
    port: 8080,
    open: true,
    hot: true,
    watchFiles: ['src/**/*.html']
  }
})
```

**`webpack.prod.js`** : pour la version finale (`npm run build`).
```js
import { merge } from 'webpack-merge'
import commun from './webpack.common.js'

export default merge(commun, {
  mode: 'production',
  devtool: 'source-map',
  output: {
    filename: 'js/[name].[contenthash].js',
    cssFilename: 'css/[name].[contenthash].css'
  }
})
```

### 3.3 Créer les 3 premiers fichiers de `src/`

**`src/index.js`** : le point d'entrée. Il importe le style et l'application (comme au TP03).
```js
import './stylesheets/styles.scss'
import './scripts/app.js'
```

**`src/scripts/app.js`** : pour l'instant, juste un message pour vérifier que tout marche.
```js
console.log('Parcoursup Explorer démarre')
```

**`src/stylesheets/styles.scss`**
```scss
body {
  margin: 0;
  font-family: system-ui, sans-serif;
}
```

Mon projet ressemble maintenant à ceci :
```
parcoursup-explorer
│ .gitignore
│ package.json
│ package-lock.json
│ webpack.common.js
│ webpack.dev.js
│ webpack.prod.js
│
└───src
    │ index.js
    ├───images
    │     favicon.ico
    ├───scripts
    │   │ app.js
    │   └───tpl          (les templates .tpl.html viendront ici)
    └───stylesheets
          styles.scss
```

### 3.4 Vérifier (3 commandes)

| Commande | Ce que je dois obtenir |
|---|---|
| `npm start` | Le navigateur s'ouvre sur `http://localhost:8080`, avec l'onglet « Parcoursup Explorer ». F12 → Console : `Parcoursup Explorer démarre`. Puis **Ctrl+C** dans le terminal pour arrêter |
| `npm run build` | `webpack … compiled successfully`, et un dossier `dist/` apparaît |
| `npm run lint` | Aucun message : le code respecte le style StandardJS |

### 3.5 Commit 3

```bash
git status
git add webpack.common.js webpack.dev.js webpack.prod.js src/
git status
git commit -m "chore: configure webpack à partir du TP03 et crée l'arborescence src"
git push
```

`git status` ne doit lister **ni `node_modules/` ni `dist/`** (le `.gitignore` les exclut).

### 3.6 Ce que je dois savoir expliquer sur cette étape

- **`entry`** : le fichier par lequel webpack commence à suivre les `import`.
- **`output`** : où il écrit le résultat (`dist/`). `clean: true` vide le dossier avant chaque build.
- **Loader ou plugin ?** Un loader transforme **un fichier** (`babel-loader`, `sass-loader`) et se déclare dans `module.rules`. Un plugin agit sur **toute la compilation** (`HtmlWebpackPlugin`) et s'instancie avec `new` (TP02, partie 0.3).
- **`HtmlWebpackPlugin`** : il génère `index.html` et y ajoute **lui-même** les balises `<script>` et `<link>`. Je n'en écris aucune, comme l'exige le sujet.
- **`babel-loader`** : il traduit mon JavaScript moderne pour les navigateurs listés dans `browserslist` (`last 3 versions` : exigence du sujet).
- **`asset/source`** : un `.tpl.html` importé devient une **chaîne de caractères**. **`asset/resource`** : une image importée devient un fichier dans `dist/images/`, et l'`import` me donne son adresse.
- **`common` / `dev` / `prod`** : le développement doit aller vite et rester lisible, la production veut des fichiers petits avec une empreinte (`[contenthash]`) pour le cache. `webpack-merge` combine la partie commune avec l'une ou l'autre (TP02, partie 8).
- **Pourquoi pas de proxy ni de `.env` ?** Au TP03, ils servaient à contourner le CORS de Vélib'. Mes API autorisent le navigateur (CORS vérifié) et n'ont pas de clé : le prof n'a rien à configurer. C'est un argument pour la section « Choix de conception ».

### 3.7 Corriger l'indentation (fait après le commit 3)

Au collage, Antigravity a converti les 2 espaces en **4 espaces**, et il manque le retour à la ligne final : `npm run lint` affichait 83 erreurs. Deux actions :

**1. Régler Antigravity pour ce projet.** Je crée le fichier `.vscode/settings.json` :
```json
{
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.detectIndentation": false,
  "files.insertFinalNewline": true
}
```

**2. Laisser StandardJS corriger les fichiers** (testé sur une copie du projet : toutes les erreurs disparaissent) :
```bash
npx standard --fix
npm run lint
```
`npm run lint` ne doit plus rien afficher.

**Commit 4** :
```bash
git add .vscode/settings.json webpack.common.js webpack.dev.js webpack.prod.js src/
git commit -m "chore: applique le style StandardJS et règle l'éditeur sur 2 espaces"
git push
```

---

## Étape 4 : dessiner mes classes (sans code)

**C'est l'étape la plus importante pour la note** (« Éléments de conception ») et pour la section « Choix de conception » du README.

✅ **Le prof m'a autorisé à l'oral** à demander une architecture à une IA, puis à dessiner le diagramme moi-même. La proposition est dans **`ARCHITECTURE_PROPOSEE.md`** : les classes, l'enchaînement des 2 requêtes, et un texte **à importer dans draw.io** (section 5). Je dois **comprendre et savoir justifier** chaque classe (section 8 du document).

Les sections 4.1 à 4.3 ci-dessous expliquent le raisonnement qui mène à cette architecture.

### 4.1 Ce que l'application doit faire (les « responsabilités »)
1. Lire ce que tape l'utilisateur (ville, filière, rayon) et réagir aux clics.
2. Envoyer une requête HTTP et vérifier la réponse (`response.ok`, liste vide).
3. Transformer une ville en coordonnées (IGN).
4. Chercher les formations autour d'un point (Parcoursup 2025).
5. Récupérer l'historique d'une formation (2022-2024). *(bonus)*
6. Garder les réponses en mémoire pour ne pas redemander (cache).
7. Représenter **une ville** et **une formation** dans **mon propre format** (nombres convertis, noms de champs à moi).
8. Calculer la tendance, la fourchette et le R². *(bonus)*
9. Afficher : la liste, la carte Leaflet, le graphique.
10. Enchaîner 1 → 3 → 4, et afficher les erreurs.

### 4.2 Les questions pour regrouper ces responsabilités en classes
- **« Si l'IGN change le format de sa réponse demain, combien de fichiers dois-je modifier ? »** Idéalement un seul. C'est le conseil du prof à l'oral : « dépendre de la structure, pas des API ».
- **« Le reste de mon code connaît-il les noms des champs de l'IGN (`features`, `coordinates`) ? »** Il ne devrait pas : le service rend **mes propres objets** (`Ville`).
- **« Où le taux d'accès en texte (`"52"`) est-il converti en nombre ? »** À **un seul endroit**, une seule fois.
- **« Mon affichage fait-il des `fetch` ? »** Non : afficher et télécharger sont deux métiers différents.
- **« Le cache connaît-il Parcoursup ? »** Non : un cache range une valeur sous une clé (une URL par exemple), il peut donc servir à toutes les API.
- **« L'héritage a-t-il un sens quelque part ? »** Le cours le montre (chapitre 1 : `Forme` → `Rectangle` ; chapitre 3 : `extends`, `super`). Exemple : mes services de géocodage et de Parcoursup font-ils leurs requêtes de la même façon ?

### 4.3 Dessiner
- Une boîte par classe : son nom, ses attributs (`-` devant les privés `#`) et ses méthodes.
- Des flèches : « utilise », « hérite de ».
- Outil : **draw.io** (gratuit, export en PNG), ou papier puis photo.
- Le fichier va dans `docs/diagramme-classes.png`.

👉 Une fois le diagramme exporté en `docs/diagramme-classes.png` (et `docs/diagramme-classes.drawio`) : `git add docs/` puis `git commit -m "docs: ajoute le diagramme de classes"`.

---

## Étape 5 : coder la partie obligatoire

Une ligne = au moins un commit. Entre ces lignes, il y aura **aussi** des `fix:` et des `refactor:` : c'est normal, ça montre le vrai travail.

L'ordre, les tests et les messages de commit sont dans la **section 7 de `ARCHITECTURE_PROPOSEE.md`** :

| # | Classes | Message de commit (exemple) |
|---|---|---|
| 5.1 | `Cache`, puis `ServiceApi` (la classe mère qui fait les `fetch`) | `feat: ajoute ServiceApi avec cache et vérification de response.ok` |
| 5.2 | `Ville`, `ServiceGeocodage` (requête 1) | `feat: géocode une ville avec l'API IGN` |
| 5.3 | `Formation`, `ServiceParcoursup` (requête 2, qui utilise le résultat de la 1) | `feat: recherche les formations Parcoursup autour d'une ville` |
| 5.4 | `Application`, version console | `feat: enchaîne géocodage et recherche des formations` |
| 5.5 | `npm install -D handlebars`, templates, `VueRecherche`, `VueResultats` | `chore: installe Handlebars`, puis `feat: ajoute le formulaire et l'affichage des résultats` |
| 5.6 | Cas d'erreur : ville inconnue, 0 résultat, réseau | `feat: affiche les messages d'erreur et de liste vide` |

✅ **Quand 5.1 à 5.6 marchent et sont poussés, la partie obligatoire est faite.**

💡 **Handlebars** : écrire `import Handlebars from 'handlebars/dist/handlebars.js'`. Avec `import Handlebars from 'handlebars'`, webpack affiche l'avertissement `require.extensions is not supported by webpack`, parce que ce fichier-là est prévu pour Node.js. Avantage de Handlebars : `{{nom}}` **échappe** le HTML, ce qui protège de l'injection de code (faille XSS). C'est un bon argument pour le README.

---

## Étape 6 : les bonus (une branche par bonus)

Pour chaque bonus, je travaille sur une branche (cours R2.03). Si le bonus n'est pas fini le 23/10, `main` reste propre.

```bash
git switch -c feature/carte-leaflet
# … plusieurs commits …
git switch main
git merge feature/carte-leaflet
git push
```

| Bonus | Branche | Message de commit (exemple) |
|---|---|---|
| Carte Leaflet (`npm install -D leaflet`) | `feature/carte-leaflet` | `feat: affiche les formations sur une carte Leaflet` |
| Villes homonymes et debounce | `feature/choix-ville` | `feat: propose les villes homonymes avec debounce` |
| Historique, `Promise.all`, Chart.js (`npm install -D chart.js`) | `feature/historique` | `feat: affiche l'historique 2022-2025 dans un graphique` |
| Tendance, R², fourchette, rang du dernier appelé | `feature/tendance` | `feat: calcule la tendance et sa fiabilité` |
| Mon Master | `feature/mon-master` | `feat: ajoute le parcours étudiant diplômé avec Mon Master` |

💡 **Leaflet** : le TP03 donne les 5 lignes qui corrigent les icônes de marqueurs avec webpack, et l'`@import` de `leaflet/dist/leaflet.css`.

---

## Étape 7 : README et rendu

### 7.1 Le README (`README.md` à la racine)
Le sujet exige :
- nom, prénom, mail universitaire ;
- une description complète du projet ;
- les commandes pour installer et lancer (`npm install`, `npm start`, `npm run build`) ;
- une section **« Usage de l'IA »** : les parties où l'IA m'a aidé (consigne orale du prof : pas besoin du nom de l'IA ni de date ; on choisit ensemble quoi déclarer) ;
- une section **« Choix de conception »**, avec mes mots : pourquoi ces classes ? comment les 2 requêtes dépendantes s'enchaînent ? quelle difficulté principale, et comment je l'ai résolue ?

Commit : `docs: rédige le README (installation, Usage de l'IA, Choix de conception)`.

### 7.2 Avant de rendre
```bash
npm run lint
npm run build
git status          # rien en attente
git push
```
Puis tester l'application sur Firefox, Chrome et Edge.

### 7.3 L'archive (sans `node_modules`, avec `.git`)
```bash
cd ~/Documents
zip -r BARRY_Mamadou-Bailo_parcoursup-explorer.zip parcoursup-explorer -x "parcoursup-explorer/node_modules/*" "parcoursup-explorer/dist/*"
unzip -l BARRY_Mamadou-Bailo_parcoursup-explorer.zip | grep "\.git/HEAD"
```
La dernière commande doit afficher une ligne avec `.git/HEAD`. C'est la preuve que le dossier `.git` est bien dans l'archive (le prof insiste : « vérifiez qu'il figure bien dans votre archive »).

Dépôt sur AMETICE **bien avant 23h59**.

---

## Annexe A : le cycle git à chaque étape (cours R2.03)

```bash
git status                             # où j'en suis
git diff                               # ce que j'ai modifié
npm run lint && npm run build          # le style est respecté et le projet compile
git add fichier1 fichier2              # seulement les fichiers de CETTE étape
git diff --staged                      # je relis ce qui va partir
git commit -m "type: description"      # ou « git commit » seul pour écrire aussi un corps
git push                               # sauvegarde sur GitHub
git log --oneline --graph --decorate   # l'historique
```

**Les types de commit** (*Conventional Commits*, cours R2.03) :

| Type | Quand | Exemple |
|---|---|---|
| `feat:` | nouvelle fonctionnalité | `feat: géocode une ville avec l'API IGN` |
| `fix:` | correction de bug | `fix: inverse longitude et latitude dans la requête Parcoursup` |
| `refactor:` | réorganisation, sans nouvelle fonctionnalité | `refactor: extrait la conversion des champs dans Formation` |
| `docs:` | README, diagramme | `docs: ajoute le diagramme de classes` |
| `chore:` | configuration, dépendances | `chore: installe Leaflet` |

**Un commit avec un corps** (je tape `git commit` sans `-m`, l'éditeur s'ouvre, j'écris, j'enregistre et je ferme l'onglet) :
```
fix: convertit le taux d'accès en nombre pour toutes les années

L'API renvoie 44 en 2025, "52" en 2024 et 59.0 en 2023.
La conversion est faite une seule fois, à la création d'une Formation.
```
À éviter : « fix », « update », « modifs », « test ». Le prof R3.01 pénalise aussi « un historique réduit à quelques commits massifs ».

| Problème | Solution |
|---|---|
| `fatal: n'est pas un dépôt git` | Je ne suis pas dans le dossier du projet, ou je suis en root |
| `git push` demande un mot de passe | Pousser depuis le terminal d'Antigravity, ou depuis l'onglet « Contrôle de code source » |
| `GH007: Your push would publish a private email address` | GitHub → Settings → Emails : décocher « Block command line pushes that expose my email » |
| J'ai ajouté un fichier de trop avec `git add` | `git restore --staged fichier` (rien n'est perdu) |

## Annexe B : le style du prof

| Règle | Où il la montre | Exemple |
|---|---|---|
| Modules ES (`import` / `export`), une classe par fichier | Chapitre 4, TP02 | `export class Compteur { … }` |
| Classes ES6, champs privés `#`, getters | Chapitre 3, TP02 | `#valeur = 0`, `get valeur () { … }` |
| Style StandardJS : pas de `;`, guillemets simples, 2 espaces, espace avant `(` dans les déclarations | TP02, TP03 | `function saluer (nom) {` |
| `async` / `await`, **tester `response.ok`**, `throw new Error` | Chapitre 5 | `if (!response.ok) { throw new Error(…) }` |
| `try` / `catch` | Chapitre 1 | |
| `Promise.all` pour les requêtes en parallèle | Chapitre 5 | l'historique 2022, 2023, 2024 en même temps |
| `Map` pour retrouver vite une donnée, `setTimeout` | Chapitre 3, TP03 | le cache |
| Debounce sur la saisie | Chapitre 5 | attendre la fin de la frappe |
| `addEventListener`, jamais `onclick` dans le HTML | Chapitre 2 | |
| `createElement` / `textContent` plutôt qu'`innerHTML` | Chapitre 2 | sauf pour les templates Handlebars |
| Templates dans des fichiers `.tpl.html` | TP03 | `src/scripts/tpl/` |

Pour voir ce style appliqué : les dossiers `correction_style_prof` des TP01, TP02 et TP03.

## Annexe C : pièges des API (vérifiés le 09 et le 11/10)

| Piège | Conséquence | Parade |
|---|---|---|
| Coordonnées IGN au format **[lon, lat]** | Inversées : 0 résultat, **sans erreur** | Des noms clairs, `lon` et `lat`, dans mon format |
| Ville inconnue | Code 200 et liste vide | Tester la longueur de la liste, pas seulement `response.ok` |
| `fetch` ne rejette pas sur 404 / 500 | Erreur invisible | `if (!response.ok) throw new Error(…)` |
| `limit` supérieur à 100 | Erreur 400 | `limit=100`, et `offset` pour la page suivante |
| `taux_acces_ens`, `ran_grp1` : nombre, texte ou décimal selon l'année | Calculs faux | Conversion **une seule fois** dans mon format |
| Champs différents avant 2022 | Erreur 400 | Historique limité à 2022-2025 |
| Apostrophe de « Côte d'Azur » | Erreur 400 dans Mon Master | Guillemets doubles dans le `where` |
| Paramètre `where` avec espaces et apostrophes | URL cassée | `encodeURIComponent` |
| Quota : 5 000 requêtes par jour et par IP (IP partagée à l'IUT) | Blocage | Cache et debounce |

## Annexe D : planning (refait le 18/10, il reste 5 jours)

| Date | À faire |
|---|---|
| 18/10 | Commit 4 (étape 3.7), diagramme (étape 4), puis `Cache` + `ServiceApi` (5.1) |
| 19/10 | `Ville` + `ServiceGeocodage` (5.2), `Formation` + `ServiceParcoursup` (5.3), `Application` (5.4) |
| 20/10 | Handlebars, `VueRecherche`, `VueResultats` (5.5), cas d'erreur (5.6) → **la partie obligatoire fonctionne** |
| 21/10 | Notes du prof du 16/10 : mocks (fausses données pour ne pas se faire bannir), autocomplétion IGN ; tests Firefox, Chrome, Edge ; `npm run lint`, `npm run build` |
| 22/10 | README complet ; bonus seulement s'il reste du temps (carte Leaflet en premier) |
| 23/10 | Archive, puis dépôt sur AMETICE **le matin** |

## Annexe E : à noter au fil de l'eau pour le README

- **Usage de l'IA** : noter au fil de l'eau **les parties** où l'IA m'a aidé (architecture, configuration, code de telle classe, relecture…). Pas besoin du nom de l'IA ni de date (consigne orale du prof).
- **Choix de conception** : noter **dès maintenant** chaque décision et chaque difficulté, avec la date. Les corps de mes commits serviront aussi.
