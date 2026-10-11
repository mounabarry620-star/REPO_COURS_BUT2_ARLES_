# TP02 Prise en main de webpack 5 : correction

Le TP02 est un **guide pas à pas** : le prof y donne « le contenu complet des fichiers ». La correction, c'est donc **l'état final du guide (Partie 8), recopié mot pour mot**, plus les deux premiers points de « Pour aller plus loin » (Sass et le linter `standard`).

```bash
npm install
npm start        # serveur de développement, http://localhost:8080
npm run build    # version de production dans dist/
npm run lint     # « Pour aller plus loin » : standard
```

## D'où vient chaque fichier

| Fichier | Source |
|---|---|
| `package.json` | Parties 3.1, 5.3 et 8.2 (scripts `start` / `build`, `browserslist`) |
| `webpack.common.js`, `webpack.dev.js`, `webpack.prod.js` | Partie 8.2, mot pour mot |
| `src/index.html` | Partie 6.2 (le gabarit, **sans** `<link>` ni `<script>` : le plugin les ajoute) |
| `src/salutation.js`, `src/compteur.js`, `src/index.js`, `src/style.css` | Parties 2.1, 4.1, 4.2, 5.2, mot pour mot |
| `.gitignore` | Partie 1.4 |
| Règle Sass `type: 'css', use: ['sass-loader']` + `src/bouton.scss` | « Pour aller plus loin » : Sass |
| Script `lint` + `"standard": { "env": ["browser"] }` | « Pour aller plus loin » : un linter |

**Pourquoi `"env": ["browser"]` ?** Sans ce réglage, `standard` ne connaît pas `Image` et signale `'Image' is not defined`. Il faut lui dire que le code tourne dans un navigateur.

## Ce que le style du prof montre ici

Le code du guide **respecte déjà StandardJS** : pas de points-virgules, guillemets simples, indentation de 2 espaces, et **un espace avant les parenthèses** dans les déclarations : `function saluer (nom)`, `incrementer ()`, `get valeur ()`. C'est la preuve que c'est bien le style que le prof attend.

## « Ce que vous devez savoir expliquer » (fin du guide)

1. webpack part d'un point d'entrée, suit tous les `import` et produit un bundle.
2. Un **loader** transforme **un fichier** ; il se déclare dans `module.rules` et s'applique de droite à gauche.
3. Un **plugin** agit sur **toute la compilation** ; il se déclare dans `plugins` et s'instancie avec `new`.
4. Le `mode` active d'un coup des dizaines d'optimisations.
5. Les source maps (`devtool`) rendent le bundle débogable.
6. `[contenthash]` + `html-webpack-plugin` = cache du navigateur géré sans intervention.

## Différences avec mon TP02 (`tp-webpack`)

Mon TP02 suit bien le guide. Les seules différences :

| Mon TP02 | Guide du prof |
|---|---|
| Indentation de 4 espaces | 2 espaces |
| `function saluer(nom)`, `incrementer()` | `function saluer (nom)`, `incrementer ()` (espace avant la parenthèse) |
| « Salut » et `h1` bleu | Normal : ce sont les expériences des Parties 7.3 et 4.1, sans conséquence |
| Un fichier `src/.woff2` qui contient **du texte**, pas une police | La Partie 4.3 parle d'une **vraie** police (`ma-police.woff2`) déclarée avec `@font-face`. Ce fichier ne sert à rien : à supprimer |
| « Pour aller plus loin » non fait | Sass et `standard` ajoutés ici |
