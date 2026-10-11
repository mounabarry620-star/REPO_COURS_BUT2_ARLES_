# TP03 Vélib' : correction dans le style du prof

Correction écrite à partir du **sujet** (pas de mon code), en reprenant **mot pour mot** la configuration webpack, le `package.json` et l'arborescence donnés par le prof dans le sujet.

```bash
npm install
npm start        # serveur de développement + proxy, http://localhost:8080
npm run build    # version de production dans dist/
npm run lint     # bonus du TP : vérification StandardJS
```

⚠️ Le proxy n'existe qu'avec `npm start`. Le dossier `dist/` produit par `npm run build` ne peut pas joindre l'API (CORS), comme l'explique le sujet.

## Arborescence (celle du sujet)

```
src
│ index.js                  importe la feuille de style et app.js
├───images                  favicon.ico, velo_prof.png
├───scripts
│   │ app.js                carte, marqueurs, mise à jour toutes les 5 min
│   │ velib.js              accès à l'API (seul fichier qui fait des fetch)
│   └───tpl
│         main.tpl.html     barre de navigation Materialize + bloc de la carte
│         popupview.tpl.html contenu d'une popup (Handlebars)
└───stylesheets
      styles.scss
```

## Ce que demande le sujet → où c'est fait

| Demande du sujet | Où | Notion du cours |
|---|---|---|
| Requêtes HTTP via le proxy `/api/...` | `velib.js` | Chapitre 5 + section « proxy » du TP |
| Vérifier qu'une requête a réussi | `getJson` teste `response.ok` | Chapitre 5 : « fetch ne rejette pas sur 404 ou 500 » |
| Afficher les stations sur une carte Leaflet | `creerCarte`, `ajouterStations` | `import * as L from 'leaflet'` (TP03) |
| Correction des icônes de marqueurs | haut de `app.js` | Encadré « Attention » du sujet (issue 4968) |
| Feuille de style de Leaflet | `@import url("leaflet/dist/leaflet.css")` | Sujet |
| Associer statut et station via `station_id` | `marqueurs` est une **`Map`** | Indice du sujet : « regardez setTimeout et Map » |
| Mise à jour toutes les 5 minutes | `mettreAJour` se reprogramme avec **`setTimeout`** | Indice du sujet |
| Templates `.tpl.html` | `main.tpl.html`, `popupview.tpl.html` | Règle `asset/source` du `webpack.common.js` |
| Bonus StandardJS | `npm run lint` | Bonus du sujet |

Les dépendances `handlebars`, `leaflet.markercluster`, `materialize-css` et `material-icons` sont dans le `package.json` **du prof** : sa correction les utilise donc très probablement. Elles servent ici à :
- **Handlebars** : remplir les templates. Il **échappe** le HTML (`{{name}}` affiche `<b>` comme du texte), ce qui protège de l'injection de code (faille XSS) ;
- **markercluster** : regrouper les ~1 500 marqueurs (sinon la carte est illisible et lente) ;
- **Materialize + material-icons** : la barre de navigation rouge (`#ee6e73` est sa couleur par défaut) et l'icône « mise à jour ».

## Les choix à savoir expliquer

1. **Pourquoi une `Map` ?** Les deux flux ont `station_id` en commun. Quand un statut arrive, `marqueurs.get(statut.station_id)` retrouve **directement** le bon marqueur. Sans `Map`, il faudrait reparcourir les 1 500 stations pour chacun des 1 500 statuts, soit 2 250 000 comparaisons à chaque mise à jour.
2. **Pourquoi `setTimeout` et pas `setInterval` ?** La mise à jour suivante n'est programmée **qu'une fois la précédente terminée**. Si le serveur est lent, les requêtes ne s'empilent pas.
3. **Pourquoi `velib.js` à part ?** C'est le seul fichier qui connaît les URL de l'API. C'est le même principe que le composant `FTC` du chapitre 5 (module « ad-hoc » qui expose seulement `getStations` et `getStatuts`).
4. **Pourquoi `import Handlebars from 'handlebars/dist/handlebars.js'` ?** Le fichier principal de `handlebars` est prévu pour Node.js et provoque l'avertissement webpack `require.extensions is not supported`.
5. **Pourquoi `try` / `catch` ?** Si l'API ne répond pas, l'utilisateur voit un message dans la barre, et la mise à jour réessaie 5 minutes plus tard au lieu de s'arrêter. C'est dans le cours : chapitre 1 (« try…catch : cette instruction permet de spécifier un ensemble d'instructions à tenter, et de préciser le traitement à effectuer dans le cas où une exception est produite ») et chapitre 5 (`throw new Error` quand `response.ok` est faux).

## D'où vient chaque élément (vérifié dans le cours)

| Élément utilisé | Source |
|---|---|
| `package.json`, `webpack.*.js`, `.env`, arborescence | Sujet du TP03, mot pour mot |
| `import` / `export`, `export { VELIB }` | Chapitre 4 (modules ES2015), chapitre 5 (`export { FTC }`) |
| Module `(() => { … return { … } })()` | Chapitre 4 (module ad-hoc), chapitre 5 (composants `XHR` et `FTC`) |
| `async` / `await`, `fetch`, `response.ok`, `throw new Error` | Chapitre 5 |
| `try` / `catch` | Chapitre 1 (instructions de contrôle) |
| `const` / `let`, fonctions fléchées, `for…of`, gabarits `` `${…}` `` | Chapitre 3 |
| Paramètre par défaut `statut = null` | Chapitre 3 |
| Propriétés raccourcies `{ station, mecaniques }` | Chapitre 3 (littéraux : « Shorthand for handler: handler ») |
| `new Map()`, `get`, `set`, `forEach` | Chapitre 3 + indice du sujet |
| `setTimeout` | Sujet du TP03 (indice) |
| `document.querySelector`, `textContent`, `innerHTML` | Chapitre 2 |
| `delete L.Icon.Default.prototype._getIconUrl` et `mergeOptions` | Sujet du TP03 (encadré « Attention ») |
| `L.map`, `L.tileLayer`, `L.marker`, `bindPopup`, `setPopupContent` | Documentation de Leaflet, que le sujet demande de lire |
| `console.log` pour les erreurs | Chapitre 5 (exemple XHR : `console.log('Une erreur … s'est produite')`) |

**Ce qui va plus loin que le cours** (et pourquoi c'est légitime) :

| Élément | Pourquoi je l'ai utilisé |
|---|---|
| `Handlebars.compile`, `{{#if}}` | `handlebars` est dans le `package.json` **du prof**, mais le sujet ne montre pas comment s'en servir : c'est sa documentation (handlebarsjs.com) |
| `L.markerClusterGroup` | `leaflet.markercluster` est dans le `package.json` du prof |
| Classes Materialize (`nav-wrapper`, `brand-logo`) et `material-icons` | `materialize-css` et `material-icons` sont dans le `package.json` du prof |
| Le script `lint` | Bonus du sujet (StandardJS) |

Si on retire ces 4 bibliothèques, il reste exactement ce que demande le sujet. Mon TP03 (`mon-projet`) s'en passait, et c'était aussi correct.

## Étape 1 du sujet : la liste `<ul>`

Le sujet fait commencer par une simple liste avant la carte. Avec les mêmes fonctions, ça donne :

```js
const liste = document.createElement('ul')
for (const station of await VELIB.getStations()) {
  const item = document.createElement('li')
  item.textContent = `${station.stationCode} - ${station.name}`
  liste.appendChild(item)
}
document.body.appendChild(liste)
```

`createElement` + `textContent` : c'est la méthode que le chapitre 2 conseille plutôt qu'`innerHTML`.

## Différences avec mon TP03 (`mon-projet`)

| Mon TP03 | Correction | Pourquoi c'est mieux |
|---|---|---|
| Points-virgules, guillemets doubles | Style StandardJS | C'est le style du prof et le bonus du TP |
| Pas de test de `response.ok` | `getJson` lève une erreur | Une erreur 404 ou 500 passait inaperçue |
| Pas de `try` / `catch` au premier chargement | Message affiché dans la barre | La page restait vide sans explication |
| `.replace('{{nom}}', …)` | Handlebars | `.replace` ne remplace que la **première** occurrence et n'échappe pas le HTML |
| Popup de départ écrite en HTML dans le JS | Tout est dans `popupview.tpl.html` (`{{#if}}`) | Le HTML reste dans les templates |
| 1 500 marqueurs séparés | `markerClusterGroup` | Carte lisible et fluide |
| Tuiles `{s}.tile.openstreetmap.org` | `tile.openstreetmap.org` | Les sous-domaines `a.`, `b.`, `c.` sont abandonnés par OpenStreetMap |
| Tout dans `app.js` | `velib.js` (données) + `app.js` (affichage) | Un fichier = une responsabilité |

Ce qui était déjà bien dans mon TP03 : la `Map`, le `setTimeout` récursif, la correction des icônes et l'arborescence.
