# Parcoursup Explorer

Projet du module **R3.01 - Développement web** (BUT Informatique, 2e année, IUT d'Aix-Marseille, site d'Arles).

- **Nom :** BARRY
- **Prénom :** Mamadou-Bailo
- **Mail universitaire :** mamadou-bailo.BARRY@etu.univ-amu.fr

---

## Description

### L'idée de départ

Quand on cherche ses études, on se pose souvent la même question : "qu'est-ce que je peux faire près de chez moi, et est-ce que j'ai des chances d'être pris ?". Les sites officiels donnent ces informations, mais formation par formation. J'ai voulu une application qui part **d'une ville** et montre **tout ce qu'il y a autour**, avec les chiffres qui aident à choisir.

Au début, je voulais faire un autre projet en cybersécurité, mais il demandait beaucoup trop de code pour le temps donné. J'ai donc choisi Parcoursup Explorer, que le professeur a validé le 09/10.

L'application propose deux parcours.

### Parcours 1 : après le bac (Parcoursup)

1. Je tape une ville. Pendant que j'écris, l'application me propose des communes (c'est l'autocomplétion).
2. Je choisis un **rayon** de 1 à 200 km, et si je veux une **filière** (BUT, BTS, licence, prépa, école d'ingénieur...).
3. **Requête 1 :** l'API de l'IGN me donne la position de la ville sur la carte (longitude et latitude).
4. **Requête 2**, qui a besoin de la première : l'open data de Parcoursup (session 2025) me donne toutes les formations dans le cercle autour de cette position.
5. Les résultats s'affichent de deux façons :
   - une **liste**, avec pour chaque formation : le nom, l'établissement, la ville, le taux d'accès, le nombre de places, le nombre de candidats par place et un lien vers la fiche Parcoursup ;
   - une **carte** : les formations proches sont regroupées dans une bulle, et le cercle du rayon est dessiné.
6. Un champ **filtre** réduit la liste et la carte pendant que je tape. Il ne tient pas compte des accents ni des majuscules : "informatique arles" marche.
7. **Historique :** pour chaque formation, un bouton ouvre une fenêtre avec les chiffres de 2022 à 2025 (places, candidats, taux d'accès, rang du dernier appelé), en **graphique** et en **tableau**.

### Parcours 2 : après la licence ou le BUT (Mon Master)

J'ai ajouté ce parcours pour aller plus loin, parce qu'il me concerne directement : je suis en BUT et je chercherai bientôt un master.

1. Je tape une ville, je choisis une **zone** ("ma région" ou "mon département") et si je veux une **discipline** (46 au choix).
2. **Requête 1 :** l'IGN me donne la région et le département de la ville.
3. **Requête 2**, qui a besoin de la première : l'open data de Mon Master (session 2025) me donne les masters de cette région. Pour "mon département", l'application garde seulement ceux du département, sans refaire de requête.
4. Pour chaque master, je vois :
   - le nombre de places, de candidats, et le **taux de proposition** (la part des candidats qui ont reçu une proposition d'admission) ;
   - ce même taux pour les candidats de **licence 3** et pour ceux de **BUT 3**. C'est ce qui m'intéressait le plus : savoir si un master prend des étudiants de BUT, ou presque seulement des étudiants de licence.
5. **Historique** de 2023 à 2025, en graphique et en tableau.
6. Il n'y a **pas de carte** pour les masters, parce que Mon Master ne donne pas leur position. L'application l'explique à l'écran.

### Pour tout le site

- **Mode sombre** avec les couleurs de Mon Master. Au début, le site suit le réglage de l'ordinateur. Si je clique sur le bouton, mon choix est gardé pour la prochaine visite.
- **Accessibilité** (pour que tout le monde puisse utiliser le site) :
  - chaque champ a un nom et un texte d'aide ;
  - tout marche au clavier ;
  - les couleurs sont assez contrastées ;
  - le graphique se lit même sans voir les couleurs, grâce aux formes des points et aux traits différents.
- **Téléphone :** la page s'adapte aux petits écrans.
- **Messages clairs** quand quelque chose ne va pas : ville inconnue, aucune formation dans le rayon, service qui ne répond pas, ville de moins de 3 lettres (bloquée avant d'appeler l'API).

---

## Installation et lancement

Il faut **Node.js 22 ou plus récent** (j'ai testé avec Node.js 24) et npm.

```bash
# 1. Installer les dépendances (le dossier node_modules n'est pas dans l'archive)
npm install

# 2. Lancer le site en mode développement (il s'ouvre sur http://localhost:8080)
npm start

# 3. Ou fabriquer la version finale dans le dossier dist/
npm run build

# 4. Vérifier que le code respecte le style StandardJS
npm run lint
```

Après `npm run build`, il faut ouvrir `dist/index.html` avec un petit serveur web (par exemple l'extension Live Server de VS Code, ou `npx serve dist`), et pas en double-cliquant dessus : sinon le navigateur bloque les requêtes `fetch`.

---

## Les API et les clés d'API

**Il n'y a besoin d'aucune clé d'API.** Toutes les API que j'utilise sont publiques et gratuites, donc aucune clé ne peut expirer.

| API | Ce qu'elle me permet de faire | Adresse |
|---|---|---|
| IGN, géocodage | trouver la position, le département et la région d'une ville | `https://data.geopf.fr/geocodage/search` |
| IGN, autocomplétion | proposer des communes pendant la saisie | `https://data.geopf.fr/geocodage/completion` |
| Open data Parcoursup | formations 2025, et historique 2022 à 2024 | jeux `fr-esr-parcoursup`, `fr-esr-parcoursup_2022`, `_2023`, `_2024` |
| Open data Mon Master | masters 2024 et 2025, et 2023 | jeux `fr-esr-mon_master`, `fr-esr-mon_master_2023` |

Les deux open data sont sur le site du ministère : `https://data.enseignementsup-recherche.gouv.fr/api/explore/v2.1/catalog/datasets/...`

J'ai mis les adresses des API dans le fichier **`.env.defaults`** (il est dans git, car il ne contient rien de secret). Pour les changer sans toucher au code, on peut créer un fichier `.env` avec les mêmes noms.

**Pour vérifier que les API marchent**, on peut ouvrir ces adresses dans un navigateur, ou taper ces commandes. Chacune doit afficher du texte en JSON, pas une erreur :

```bash
curl "https://data.geopf.fr/geocodage/search?q=Arles&type=municipality&limit=1"
curl "https://data.geopf.fr/geocodage/completion?text=Arl&type=PositionOfInterest&poiType=commune&maximumResponses=3"
curl "https://data.enseignementsup-recherche.gouv.fr/api/explore/v2.1/catalog/datasets/fr-esr-parcoursup/records?limit=1"
curl "https://data.enseignementsup-recherche.gouv.fr/api/explore/v2.1/catalog/datasets/fr-esr-mon_master/records?limit=1"
```

### Ne pas se faire bloquer par les API

Ces API limitent le nombre de requêtes : si on en envoie trop, on peut être bloqué pour un moment. J'ai fait en sorte d'en envoyer le moins possible :

- **Le cache :** l'application garde en mémoire chaque réponse reçue. Si je refais la même recherche, si je change de zone ou si je rouvre un historique, elle ne redemande rien. Une réponse en erreur n'est jamais gardée.
- **Attendre la fin de la frappe :** l'autocomplétion attend que j'arrête de taper pendant 300 millisecondes, et seulement à partir de 3 lettres. Le filtre de la liste n'envoie aucune requête.
- **Une seule requête par recherche :** je récupère toutes les formations d'un coup, en demandant seulement les informations utiles.
- **Bloquer les mauvaises saisies :** une ville de moins de 3 caractères est refusée avant d'appeler l'IGN (l'IGN la refuserait de toute façon).
- **Des fausses vues pour tester :** au début, j'ai testé la classe `Application` avec de fausses vues (des "mocks") qui écrivaient dans la console au lieu de la page (commit `c9ab42d`). Je n'avais donc pas besoin de cliquer sur le site à chaque essai.

---

## Organisation du code

Le diagramme de classes est dans **`docs/diagramme-classes.drawio.pdf`**. Il fait 3 pages : la vue d'ensemble, l'historique, puis Mon Master et le mode sombre.

```
src/
    index.js                  le point de départ pour webpack (styles, polices, app.js)
    images/                   le logo et l'icône de l'onglet (faits pour le projet)
    stylesheets/styles.scss   les styles (Sass), avec les couleurs des deux thèmes
    scripts/
        app.js                crée les services, les vues et l'Application, puis lance tout
        application.js        l'Application : elle décide de l'ordre des actions
        outils.js             petites fonctions utilisées à plusieurs endroits
        services/             Cache, ServiceApi (la classe mère) et ses 3 classes filles
        modeles/              Ville, Suggestion, Formation, Master, StatistiqueAnnuelle,
                              StatistiqueMaster, Historique
        vues/                 VueRecherche, VueResultats, VueCarte, VueHistorique, VueTheme
        tpl/                  les modèles de page HTML (Handlebars)
```

---

## Choix de conception

### Pourquoi j'ai découpé l'application avec ces classes

Ce découpage à été fait par moi mais revisité avec claude (voir "Usage de l'IA"). Je l'ai gardé parce qu'il suit une règle simple que j'ai comprise : **une classe = un seul travail**. Il y a quatre sortes de classes :

- **Les services** vont chercher les données sur internet.
- **Les modèles** rangent ces données (une ville, une formation, un master...).
- **Les vues** s'occupent de la page : afficher, et écouter les clics.
- **L'Application** est le chef d'orchestre : elle reçoit les demandes des vues, appelle les services dans le bon ordre, puis donne les résultats aux vues.

**Les services.** `ServiceApi` est la **classe mère**. C'est elle qui fait le `fetch`, qui vérifie `response.ok` (vu au chapitre 5) et qui utilise le cache. `ServiceGeocodage`, `ServiceParcoursup` et `ServiceMonMaster` en **héritent** avec `extends` (vu au chapitre 1). Ce code n'est donc écrit qu'une seule fois. Je l'ai vu quand j'ai ajouté Mon Master : le nouveau service n'a eu besoin d'aucune ligne de `fetch`, il a hérité de tout directement. Il n'y a aussi qu'**un seul cache**, créé dans `app.js` et partagé par les trois services.

**Les modèles.** `Ville`, `Suggestion`, `Formation`, `Master`, `StatistiqueAnnuelle`, `StatistiqueMaster` et `Historique`.
- Leurs données sont **privées** (le `#`) et se lisent avec des **getters**. Comme ça, le reste du code ne peut pas modifier une formation par erreur.
- Certains getters **calculent** au lieu de garder une valeur : par exemple `candidatsParPlace`, ou `tauxPropositionBut3` (propositions divisées par candidats).
- Les noms des données de l'API sont compliqués (`g_ea_lib_vx`, `n_can_pp`...). Je les traduis en noms clairs une seule fois, dans les services. Le reste du code ne voit que des noms clairs.

**Les vues** sont les seules à toucher la page, avec les modèles Handlebars que j'avais utilisés au TP 3. Elles ne font aucune requête : quand on clique, elles préviennent l'Application (`quandRecherche`, `quandFiltre`, `quandHistorique`).

**Le polymorphisme** (la même idée que Forme, Ellipse et Cercle du chapitre 1) :
- `Formation` et `Master` ont chacune leur méthode `correspond(recherche)`. Le filtre l'appelle sans savoir si c'est une formation ou un master.
- `ServiceParcoursup` et `ServiceMonMaster` ont chacun leur méthode `historique(code)`. La même fenêtre d'historique sert donc aux deux.

**`outils.js`** regroupe de petites fonctions utilisées par plusieurs classes (`normaliser`, `pourcentage`...). Je ne les ai pas mises dans une classe, parce qu'elles n'ont aucune donnée à garder (commit `f6097fa`).

### Comment s'enchaînent mes deux requêtes

Tout se passe dans la méthode `rechercher` de l'Application (`src/scripts/application.js`, lignes 97 à 124). Elle est `async` : chaque `await` attend la réponse avant de passer à la ligne suivante (chapitre 5).

1. **Requête 1** (ligne 104) : je demande la ville à l'IGN. Il me renvoie sa position, son département et sa région.
2. Si la ville n'existe pas, j'affiche un message et **je m'arrête** : la requête 2 n'est pas envoyée.
3. **Requête 2** (lignes 112 à 117), avec ce que la requête 1 m'a donné :
   - pour Parcoursup, la position de la ville sert à chercher les formations dans le cercle (`serviceParcoursup.js`, ligne 21) ;
   - pour Mon Master, la région de la ville sert à chercher les masters ; pour "mon département", je trie ensuite dans le navigateur.
4. **Un seul `try/catch`** entoure les deux requêtes. Si l'une échoue (pas d'internet, API en panne), j'affiche un message au lieu de laisser la page bloquée.
5. **Le problème des recherches qui se croisent** (commit `c358944`) : si on lance une deuxième recherche avant la fin de la première, la première pouvait arriver en retard et effacer les bons résultats. J'ai réglé ça en donnant un **numéro** à chaque recherche (lignes 98 et 99). Après chaque `await`, je vérifie que c'est toujours la dernière recherche ; sinon, j'ignore la réponse.

L'historique fait l'inverse : il demande les quatre années **en même temps** avec `Promise.all` (`serviceParcoursup.js`, ligne 40). Ces requêtes ne dépendent pas les unes des autres, donc il n'y a pas de raison de les attendre une par une.

### La difficulté principale que j'ai rencontrée, et comment je l'ai résolue

**Les résultats étaient coupés à 100 formations, sans aucun message d'erreur.** Pour Paris dans un rayon de 10 km, l'API m'en donnait 100 alors qu'il y en a 1 473. J'aurais pu ne jamais m'en rendre compte. Le problème venait de la route `records` de l'API, qui renvoie au maximum 100 résultats à la fois (si on en demande 101, elle répond par une erreur). En lisant la documentation de l'API (Opendatasoft), j'ai trouvé la route `exports/json`, qui renvoie **tout en une seule requête**. Je lui demande seulement les informations utiles (`select`), pour que la réponse reste légère. Maintenant, Paris dans un rayon de 200 km donne bien 4 456 formations, en environ 3 secondes.

J'ai aussi eu d'autres difficultés :
- **Ajouter Mon Master sans casser ce qui marchait déjà.** Il fallait que le nouveau service hérite directement de ma classe mère, et que le filtre et la fenêtre d'historique servent aux deux parcours. C'est là que l'héritage et le polymorphisme m'ont vraiment servi.
- **Construire l'historique.** Chaque année est un jeu de données différent dans l'API, et les noms changent parfois d'une année à l'autre (en 2023, Mon Master n'utilise pas les mêmes noms). J'ai fait un tableau qui donne, pour chaque année, le bon jeu de données et les bons noms.
- **Des cas que je n'avais pas imaginés :** les villes d'outre-mer n'avaient pas de région (commit `3323008`), la Corse est notée "20" chez Mon Master mais "2A" et "2B" chez l'IGN, et une ville de 1 ou 2 lettres faisait afficher une fausse erreur de connexion (commit `53cf0b9`). Ce dernier bug, c'est moi qui l'ai trouvé en testant.

### Mon regard critique sur mon projet

**Ce que j'ai décidé, et pourquoi :**
- **Pas de carte pour les masters :** Mon Master ne donne pas leur position. J'ai préféré le dire clairement à l'écran plutôt que de placer les masters au mauvais endroit.
- **Pas de prévision :** au départ, je voulais calculer une probabilité d'admission, ou une tendance pour l'année suivante. J'ai abandonné, parce que ce n'est pas possible honnêtement : il faudrait connaître le candidat (ses notes, son dossier...), et quatre années de chiffres ne suffisent pas pour prévoir. Je montre donc l'historique, et je laisse l'utilisateur juger.
- **Le design :** j'ai voulu que le site ressemble à Parcoursup et à Mon Master, pour que l'utilisateur s'y retrouve. Mais j'ai fait mon propre logo, car le logo officiel de Parcoursup ne peut pas être utilisé sans l'accord du ministère (vu dans le cours de Mr.chikaoui droits des contrats).
- **Les licences 3 à côté des BUT 3 :** sans cette comparaison, on ne voit pas si un master défavorise les étudiants de BUT.

**Ce qui pourrait être mieux :**
- **J'ai assez  utilisé l'IA** (voir la section suivante). J'ai écrit le code et claude à corriger pour moi, la prochaine fois j'aimerais tout écrire sans me faire vérifier par l'IA.
- **Les tests ne sont pas dans le projet :** ils ont été faits à part. Il faudrait ajouter de vrais tests automatiques dans le dépôt, avec de fausses réponses d'API, pour ne pas dépendre d'internet.
- **L'Application grossit :** elle gère les deux parcours. Si j'ajoutais un troisième parcours, je la découperais en plusieurs classes plus petites.
- **Le cache est perdu quand on recharge la page.** On pourrait le garder dans le navigateur, avec une date limite pour ne pas montrer de vieux chiffres.
- **Le message d'erreur reste général :** il ne sait pas dire si le problème vient de ma connexion ou du serveur.
- **Je n'ai pas pu tester sur Safari** (je n'ai pas de Mac), ni avec un vrai lecteur d'écran.
- **Les bibliothèques** (Leaflet, Chart.js...) sont rangées dans `devDependencies` alors que le TP 2 dit de mettre dans `dependencies` celles qu'utilise le site. Cela fonctionne, mais ce n'est pas le bon rangement.

---

## Ce qui va au-delà du cours

Tout le reste du projet vient du cours et des TP de R3.01 :
- les classes, l'héritage, `try/catch`, `fetch`, `async/await`, `Promise.all` ;
- le DOM et les modules ;
- webpack, Babel, Sass, dotenv ;
- Handlebars, Leaflet et markercluster.

Voici ce qui n'y était pas, avec la page qui l'explique :

| Notion | Où dans le code | Documentation |
|---|---|---|
| Import dynamique `import()` : Chart.js n'est téléchargé qu'au premier historique ouvert | `vues/vueHistorique.js` | [MDN](https://developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Operators/import), [webpack](https://webpack.js.org/guides/code-splitting/#dynamic-imports) |
| Décomposition `{ a, b } = objet` : sortir plusieurs valeurs d'un objet en une ligne | `application.js`, services | [MDN](https://developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Operators/Destructuring) |
| `clearTimeout` : attendre la fin de la frappe | `vues/vueRecherche.js`, `vues/vueResultats.js` | [MDN](https://developer.mozilla.org/fr/docs/Web/API/Window/clearTimeout) |
| `closest` : un seul écouteur pour tous les boutons de la liste | `vues/vueResultats.js` | [MDN](https://developer.mozilla.org/fr/docs/Web/API/Element/closest) |
| `preventDefault` et `form.elements` : lire le formulaire sans recharger la page | `vues/vueRecherche.js` | [MDN](https://developer.mozilla.org/fr/docs/Web/API/Event/preventDefault), [MDN](https://developer.mozilla.org/fr/docs/Web/API/HTMLFormElement/elements) |
| `normalize('NFD')` : enlever les accents pour le filtre | `outils.js` | [MDN](https://developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Global_Objects/String/normalize) |
| `toLocaleString('fr-FR')` : écrire 26,6 et 1 491 à la française | `vues/vueResultats.js`, `vues/vueHistorique.js` | [MDN](https://developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Global_Objects/Number/toLocaleString) |
| `localStorage` : se souvenir du thème choisi | `vues/vueTheme.js` | [MDN](https://developer.mozilla.org/fr/docs/Web/API/Window/localStorage) |
| `matchMedia` et `prefers-color-scheme` : connaître le thème de l'ordinateur | `vues/vueTheme.js` | [MDN](https://developer.mozilla.org/fr/docs/Web/API/Window/matchMedia), [MDN](https://developer.mozilla.org/fr/docs/Web/CSS/@media/prefers-color-scheme) |
| `getComputedStyle` : donner au graphique les couleurs du thème | `vues/vueHistorique.js` | [MDN](https://developer.mozilla.org/fr/docs/Web/API/Window/getComputedStyle) |
| Variables CSS `var(--...)` : changer toutes les couleurs d'un coup (mode sombre) | `styles.scss` | [MDN](https://developer.mozilla.org/fr/docs/Web/CSS/Using_CSS_custom_properties) |
| Grille CSS `grid` : ranger les champs du formulaire | `styles.scss` | [MDN](https://developer.mozilla.org/fr/docs/Web/CSS/CSS_grid_layout) |
| Balise `<dialog>` : la fenêtre de l'historique | `tpl/historique.tpl.html` | [MDN](https://developer.mozilla.org/fr/docs/Web/HTML/Element/dialog) |
| Balise `<datalist>` : la liste des communes proposées | `tpl/recherche.tpl.html` | [MDN](https://developer.mozilla.org/fr/docs/Web/HTML/Element/datalist) |
| `pattern`, `min`, `max`, `maxlength` : bloquer les mauvaises saisies | `tpl/recherche.tpl.html` | [MDN](https://developer.mozilla.org/fr/docs/Web/HTML/Attributes/pattern) |
| `aria-describedby`, `aria-pressed` : aider les lecteurs d'écran | templates | [MDN](https://developer.mozilla.org/fr/docs/Web/Accessibility/ARIA/Attributes/aria-describedby), [MDN](https://developer.mozilla.org/fr/docs/Web/Accessibility/ARIA/Attributes/aria-pressed) |
| Séquences `\u0300` et `\u00a0` : écrire un caractère spécial avec le clavier | `outils.js`, `vues/vueHistorique.js` | [MDN](https://developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Lexical_grammar) |
| Bibliothèque **Chart.js** (graphiques), installée avec npm | `vues/vueHistorique.js` | [Chart.js](https://www.chartjs.org/docs/latest/) |
| Polices **Fontsource**, installées avec npm pour que webpack gère aussi les polices | `index.js` | [Fontsource](https://fontsource.org/docs/getting-started/install) |

---

## Usage de l'IA

**Outil utilisé :** Claude (Anthropic), comme assistant de programmation. Le professeur nous a dit qu'on  pouvait s'aider un peu de l'ia pour faire certaine partie du code mais pas l'architecture,  à condition qu'il soit expliqué et compris.

**Ce que l'IA a fait :**

- **Le code :** J'ai écrit le code moi même à travers le cours sur la POO et beaucoup  d'aide de la MDN et aussi en m'inspirant d'autre site web et application existante.
Mais si mon code marchait pas je le donnait à l'IA pour me proposer des solutions.
- **Les notions hors cours :** c'est elle qui les a trouvées et expliquées (voir le tableau au-dessus), par exemple l'import dynamique de Chart.js, le mode sombre, la vérification de la saisie, le tri par département et le calcul des taux pour les licences 3 et les BUT 3.
- **Les tests :** elle a écrit et lancé des tests automatiques dans un navigateur, en dehors de ce dépôt, pour chercher les bugs. Elle a aussi relu mes commits. Des bugs ont été trouvés comme ça : les villes d'outre-mer sans région, les recherches qui se croisaient, des messages d'erreur trompeurs.
- **Ce README :** elle m'as proposé l'architecture de ce readme et moi j'ai adapté mes idées et mes choix notamment le choix de conception.

**Ce que j'ai fait moi-même :**
- J'ai choisi le sujet et je l'ai fait valider par le professeur.
- J'ai pris les décisions sur les fonctionnalités : ajouter Mon Master, abandonner la prévision, le design, le mode sombre, la zone "mon département", les taux pour les licences 3.
- J'ai testé le site à la main, et ça a fait apparaître des problèmes à corriger : la ville de moins de 3 lettres, le comportement du thème, un formulaire peu lisible.
- J'ai intégré et fait  le code parfois corrigé par claude, fait tous les commits et fusionné les branches.
- J'ai travaillé à comprendre ce que vraiment le code fait derrière dans le navigateur pour m'améliorer plus tard.

**Parties du code concernées :** tout le dossier `src/`, la configuration webpack et le diagramme `docs/diagramme-classes.drawio.pdf`.

---

## Limites connues

- **Pas de carte pour les masters :** Mon Master donne seulement le nom des lieux. Pour "mon département", je lis le numéro écrit à la fin de chaque lieu, par exemple "ARLES (13)".
- **Villes au nom très court** (Y, Eu...) : l'IGN demande au moins 3 caractères. Il faut ajouter le code postal, par exemple "Eu 76260".
- **Les données s'arrêtent à 2025 :** il n'existe pas encore de données pour 2026. Pour Mon Master, les chiffres des BUT 3 existent seulement depuis 2024, car les premiers BUT 3 ont demandé un master cette année-là.
- **Navigateurs testés :** Chromium (le moteur de Chrome et d'Edge) et Firefox. Pas Safari.

---

## Sources et licences

- **Données :**
  - positions des villes : IGN (Géoplateforme) ;
  - formations et masters : open data du ministère de l'Enseignement supérieur et de la Recherche (Parcoursup et Mon Master), sous Licence Ouverte (Etalab).
- **Fond de carte :** les contributeurs d'OpenStreetMap.
- **Couleurs :** reprises du [DSFR, le système de design des sites de l'administration](https://www.systeme-de-design.gouv.fr/).
- **Icônes loupe et lune :** [Remix Icon](https://remixicon.com/), le jeu d'icônes libre utilisé par le DSFR (conditions d'utilisation sur leur site).
- **Bibliothèques :** Leaflet et Leaflet.markercluster, Chart.js, Handlebars ; polices Source Sans 3 et Spectral avec Fontsource (licence SIL OFL).
- **Logo et icône de l'onglet :** faits pour le projet. Le logo officiel de Parcoursup n'est pas utilisé.
- Projet étudiant indépendant, qui n'est pas lié au ministère. Parcoursup est une marque déposée, propriété de l'administration française.
