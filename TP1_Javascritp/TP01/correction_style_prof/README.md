# TP01 Sommaire automatique : correction dans le style du prof

Correction écrite à partir du **sujet**. Pour la tester, ouvrir `index.html` dans le navigateur (pas besoin de webpack : le TP01 se fait avant).

## Ce que demande le sujet → où c'est fait

| Demande du sujet | Comment |
|---|---|
| Inclure le script suffit à créer le sommaire | `window.addEventListener('load', …)` à la fin du module (chapitre 2 : « utiliser l'événement load de l'objet window ») |
| Sommaire des `<h1>` dans `#toc`, avec des liens | `creerEntree` crée un `<a href="#id">` et donne un `id` au titre s'il n'en a pas |
| Paramétrer la profondeur | `data-depth` (1 = h1, 2 = h1 et h2…) |
| Plusieurs sommaires, chacun avec son titre et sa profondeur | Chaque bloc `data-toc` est lu avec `dataset` (`data-title`, `data-depth`) |
| Numérotation gérée par le CSS | Compteurs CSS (`counter-reset`, `counter-increment`) dans `style.css` |
| `TOC.add('.toto')` | Le module expose seulement `add` |

## Les choix à savoir expliquer

1. **Le module « ad-hoc »** (chapitre 4, *revealing module pattern*) : une fonction appelée immédiatement `(() => { … })()` garde tout privé (`compteurId`, `creerListe`…) et ne rend public que `{ add }`. C'est le seul moyen vu en cours d'avoir un module **sans webpack**, utilisable avec un simple `<script src>`.
2. **ES6 partout** (chapitre 3) : `const` / `let` au lieu de `var`, fonctions fléchées, `for…of`, gabarits `` `#${id}` ``, paramètres par défaut avec décomposition `{ titre = TITRE_DEFAUT, profondeur = PROFONDEUR_DEFAUT } = {}` (exemple `dessinGrapheES2015` du chapitre 3).
3. **`createElement` plutôt qu'`innerHTML`** (chapitre 2, « il est en principe préférable d'utiliser la première méthode ») : le texte des titres est inséré avec `textContent`, donc jamais interprété comme du HTML.
4. **Les listes imbriquées** : `listes` est une pile. `listes[0]` est la liste des h1, `listes[1]` celle des h2 du dernier h1, etc. Un titre moins profond fait remonter (`pop`), un titre plus profond fait descendre (nouvelle sous-liste). Ça marche même si un niveau est sauté (h1 puis h3).
5. **Priorité des réglages** : `data-*` du bloc, puis options passées à `add`, puis valeurs par défaut.
6. **Un `id` existant est gardé** : plusieurs sommaires pointent vers le même titre sans créer de doublons.

## D'où vient chaque élément (vérifié dans le cours)

| Élément utilisé | Source |
|---|---|
| Module `(() => { … return { add } })()` | Chapitre 4 (module ad-hoc, *revealing module pattern*) |
| `window.addEventListener('load', …)` | Chapitre 2 (« utiliser l'événement load de l'objet window ») |
| `const` / `let`, fonctions fléchées, `for…of`, gabarits, paramètres par défaut + décomposition | Chapitre 3 |
| `querySelectorAll`, `createElement`, `appendChild`, `textContent`, `lastChild` | Chapitre 2 + liens du sujet |
| `classList.add` | Chapitre 3 (exemple du `for…of` sur une `NodeList`) |
| `dataset` (`data-title`, `data-depth`) | Sujet du TP01 |
| `parseInt`, `isNaN`, `Number(…)`, `charAt`, `join`, `push` / `pop`, `while` | Chapitre 1 (et chapitre 3 pour `push`) |
| `Math.min`, `Math.max` | Objet `Math`, utilisé dans les chapitres 1, 4 et 5 |
| Compteurs CSS | Le sujet demande que « la numérotation soit gérée par la feuille de style CSS » |

**Un seul élément n'est pas montré dans les diapos** : `tagName` (le nom de la balise, `"H2"` par exemple). Il est dans la page « Element » de la documentation MDN, dont le lien est donné dans le sujet (« Les éléments du DOM »). Le sujet dit que « ce TP est surtout une excuse pour aller lire beaucoup de documentation ».

La mise en page (grille à 2 colonnes, sommaire fixe sur le côté) est du **CSS de présentation**. Elle n'est pas évaluée en R3.01, et on peut la supprimer sans rien casser.

## Différences avec mon TP01 (`TP1_Javascritp/script.js`)

| Mon TP01 | Correction |
|---|---|
| `var` | `const` / `let` (chapitre 3) |
| Seulement les `<h1>` dans `#toc` | Profondeur, plusieurs sommaires, `dataset`, `TOC.add` (les parties « Pour aller plus loin » et « Dernier détail ») |
| Code directement dans le gestionnaire `load`, rien d'exposé | Module qui expose `add` |
| Points-virgules | Style StandardJS (vérifié avec `npx standard`) |
