# Parcoursup Explorer : présentation du projet au prof

Fiche **temporaire** pour la séance du 09/10/2026. Ce n'est pas le README du rendu final.

---

## 1. Le projet en une phrase

**Parcoursup Explorer** montre **les formations post-bac autour d'une ville**, avec leurs chances d'admission et leur **évolution sur 4 ans**.

On tape une ville (ex. `Arles`), on choisit une filière (ex. `BUT`) et un rayon (ex. `30 km`). L'application affiche les formations sur une carte, avec le nombre de places, le nombre de candidats et le taux d'accès.

**Deux profils d'utilisateurs, une seule application :**

| | 🎓 Lycéen | 🎓 Étudiant diplômé (licence, BUT) |
|---|---|---|
| Sa question | « Quelle formation après le bac, près de chez moi ? » | « Quel master après mon diplôme, dans ma région ? » |
| Données | Parcoursup | Mon Master (voir section 9) |

### Obligatoire ou bonus ?

| | Ce que je fais | Pourquoi |
|---|---|---|
| ✅ **OBLIGATOIRE** | Ville → coordonnées (**IGN**) → formations autour (**Parcoursup 2025**) | Le sujet exige **au moins 2 requêtes qui dépendent l'une de l'autre** |
| ⭐ **BONUS 1** | Historique 2022-2024 de la formation choisie (même API Parcoursup) | Le sujet : « ne pas vous limiter au minimum demandé » |
| ⭐ **BONUS 2** | API de secours **geo.api.gouv.fr** si l'IGN ne répond pas | Conseil du prof à l'oral : « si une API meurt, l'autre prend le relais » |
| ⭐ **BONUS 3** | Parcours « étudiant diplômé » : ville → région → masters (**Mon Master**, même API que Parcoursup) | Le prof a dit d'aller le plus loin possible |

**Ordre de travail :** d'abord l'obligatoire (fonctionnel et commité), ensuite le bonus 1, puis le 2, puis le 3.

---

## 2. Les mots et sigles, traduits simplement

### Les mots techniques

| Mot ou sigle | Traduction courte | C'est quoi ? |
|---|---|---|
| **API** | Interface de programmation | Une adresse web qui renvoie des données au lieu d'une page |
| **JSON** | Format de données | Le texte que renvoient les API |
| **Open data** | Données publiques | Données que l'État publie gratuitement |
| **Géocodage** | Ville → coordonnées GPS | Transformer « Arles » en latitude et longitude |
| **IGN** | Institut national de l'information géographique | Il fournit l'API de géocodage (la « Géoplateforme ») |
| **Latitude / longitude** | Position nord-sud / est-ouest | Les deux nombres d'un point GPS |
| **CORS** | Autorisation entre sites | Permet au navigateur de lire les données d'un autre site |
| **Taux d'accès** | Chance d'avoir une proposition | Sur 100 candidats, combien ont pu recevoir une proposition d'admission |
| **Cache** | Mémoire des réponses | Garder une réponse pour ne pas redemander la même chose |

### Les filières (champ `fili` de l'API)

| Sigle | Traduction |
|---|---|
| **BUT** | Bachelor universitaire de technologie (3 ans, en IUT) |
| **BTS** | Brevet de technicien supérieur (2 ans) |
| **CPGE** | Classe préparatoire aux grandes écoles |
| **Licence** | Licence universitaire (3 ans) |
| **PASS** | Parcours d'accès spécifique santé (médecine) |
| **Licence_Las** | Licence avec option « accès santé » |
| **IFSI** | Institut de formation en soins infirmiers |
| **EFTS** | École de formation en travail social |

---

## 3. Un exemple concret : le BUT Informatique d'Arles

Résultats réels obtenus avec les API :

| Année | Places | Candidats | Taux d'accès |
|---|---|---|---|
| 2022 | 56 | 1 491 | 36 % |
| 2023 | 56 | 1 470 | **59 %** |
| 2024 | 56 | 1 395 | 52 % |
| 2025 | 56 | 1 491 | 44 % |

👉 Le nombre de places ne change pas, mais la chance d'admission varie beaucoup d'une année à l'autre (de 36 % à 59 %). **Regarder une seule année ne suffit pas** : c'est l'intérêt de l'historique.

---

## 4. Les API utilisées

En réalité, il n'y a que **2 API** (IGN et Parcoursup), plus **1 API de secours**.

| | API | Ce que je lui demande | Ce qu'elle me répond | Clé ? | Limite |
|---|---|---|---|---|---|
| ✅ **Obligatoire** | **Géoplateforme IGN** | « Où est Arles ? » | Les coordonnées GPS de la ville (+ homonymes) | Non | Quelques requêtes par seconde |
| ✅ **Obligatoire** | **Open data Parcoursup 2025** | « Quelles formations à moins de 30 km de ce point ? » | Liste des formations + chiffres | Non | **5 000 requêtes par jour** |
| ⭐ **Bonus 1** | **Open data Parcoursup 2022 à 2024** (même API, seule l'année change) | « Les chiffres de cette formation les années d'avant ? » | Un jeu de données par année | Non | Même limite |
| ⭐ **Bonus 2** | **geo.api.gouv.fr** (secours) | « Où est Arles ? » | Les mêmes coordonnées, dans un autre format | Non | – |
| ⭐ **Bonus 3** | **Open data Mon Master** (même API que Parcoursup, seul le jeu de données change) | « Quels masters d'informatique dans cette région ? » | Liste des masters + chiffres | Non | Même limite que Parcoursup |

Toutes sont **gratuites, sans clé**, publiées par l'État français, et **autorisent le navigateur à lire leurs données** (CORS vérifié).

### Les adresses
- ✅ Géocodage IGN : `https://data.geopf.fr/geocodage/search?q=Arles&type=municipality&limit=5`
- ✅ Parcoursup 2025 : `https://data.enseignementsup-recherche.gouv.fr/api/explore/v2.1/catalog/datasets/fr-esr-parcoursup/records`
- ⭐ Parcoursup 2024 : même adresse avec `fr-esr-parcoursup_2024` (idem pour 2023 et 2022)
- ⭐ Secours : `https://geo.api.gouv.fr/communes?nom=Arles&fields=centre&limit=5`

### Comment les requêtes s'enchaînent

**✅ Obligatoire : 2 requêtes dépendantes**

```
"Arles" ──► 1. IGN ──► coordonnées GPS (longitude, latitude)
                             │
                             │ on réutilise les coordonnées
                             ▼
            2. Parcoursup 2025 ──► formations autour (places, candidats, taux d'accès)
```

**La requête 2 a besoin du résultat de la 1** (les coordonnées) : c'est exactement ce que demande le sujet.

**⭐ Bonus 1 : l'historique**

```
            2. Parcoursup 2025 ──► code de la formation choisie
                             │
                             ▼
            3. Parcoursup 2024, 2023, 2022 ──► historique ──► graphique d'évolution
```

La requête 3 dépend à son tour de la requête 2 : cela fait **deux niveaux de dépendance**.

**⭐ Bonus 2 : le secours**

```
     Si l'IGN ne répond pas ──► geo.api.gouv.fr prend le relais pour la requête 1
```

### Ce que ça respecte dans le sujet

| | Ce que demande le prof | Ce que fait mon projet |
|---|---|---|
| ✅ Sujet écrit | 2 requêtes qui dépendent l'une de l'autre | Ville → coordonnées → formations |
| ✅ Sujet écrit | Peut utiliser 2 API différentes | IGN + open data Parcoursup |
| ✅ Sujet écrit | Ne pas se limiter au minimum | Bonus 1 : historique sur 4 ans |
| 🗣️ Conseil oral | API gratuites, sans clé à donner au prof | Aucune clé |
| 🗣️ Conseil oral | Si une API tombe, une autre prend le relais | Bonus 2 : geo.api.gouv.fr remplace l'IGN |
| 🗣️ Conseil oral | Attention aux limites, garder les réponses en mémoire | Cache : les chiffres des années passées ne changent jamais |
| 🗣️ Conseil oral | Le code ne doit pas dépendre d'une API en particulier | Chaque réponse est convertie dans **mon** format |
| 📘 TP03 | Pas de proxy (il ne marche qu'en développement) | Les API autorisent directement le navigateur |

---

## 5. Ce que j'ai découvert en testant

1. **« Rien trouvé » n'est pas une erreur.** Une ville inconnue renvoie « OK » (code 200) avec une liste vide. Il faut vérifier si la liste est vide, pas seulement si la requête a réussi.
2. **L'ordre des coordonnées est longitude puis latitude** (l'inverse de l'habitude). Si on les inverse, le point tombe dans l'océan Indien : **0 résultat, sans aucune erreur**.
3. **Il y a des villes homonymes** : « Saint-Denis » donne 4 communes (La Réunion, Seine-Saint-Denis, Aude, Gard). L'utilisateur doit pouvoir choisir la bonne.
4. **100 résultats maximum par requête.** Au-delà, c'est une erreur 400. Pour la suite, il faut demander la page suivante (paramètre `offset`).
5. **Le taux d'accès change de format selon l'année** : `44` (nombre) en 2025, `"52"` (texte) en 2024, `59.0` (décimal) en 2023. Il faut tout convertir en nombre.
6. **Avant 2022, les noms des champs sont différents** (erreur 400). L'historique se limite donc à 2022-2025.
7. **Limite de 5 000 requêtes par jour, par adresse IP.** À l'IUT, tout le monde partage la même adresse : le cache est vraiment utile.
8. **Le centre GPS d'Arles est le centre de la commune**, qui est immense (Camargue), et non le centre-ville. Ce n'est pas grave pour un rayon de 30 km.

---

## 6. Ce que je dis au prof (environ 30 secondes)

> « Bonjour Monsieur. Mon projet s'appelle **Parcoursup Explorer** : il montre les formations post-bac autour d'une ville.
> **Pour la partie obligatoire**, j'utilise deux API publiques et sans clé. On tape une ville. **Première requête** : l'API de l'IGN me donne ses coordonnées GPS. **Deuxième requête, qui utilise ces coordonnées** : l'open data Parcoursup me donne les formations dans un rayon choisi, avec les places, les candidats et le taux d'accès.
> **En bonus**, si j'ai le temps : avec le code de la formation, je récupère les chiffres de 2022 à 2024 pour montrer l'évolution, et j'ajoute geo.api.gouv.fr en secours si l'IGN ne répond pas.
> Comme Parcoursup est limité à 5 000 requêtes par jour, je garde les réponses en cache. »

**Si le prof demande « qu'est-ce que ça apporte de plus que le site Parcoursup ? »**
→ Une recherche **par distance** autour d'une ville, une **carte**, et l'**évolution** du taux d'accès sur 4 ans (exemple de la section 3).

**Mes questions au prof :**
1. Est-ce que je peux utiliser une librairie de graphiques installée avec npm (Chart.js) pour l'évolution ?
2. Est-ce que je peux réutiliser Leaflet (la carte du TP03) ?
3. Faut-il utiliser Handlebars pour les templates, comme dans le TP03 ?

---

## 7. Démo : prouver au prof que les API marchent

Liens vérifiés le 09/10/2026 : ils répondent tous (code 200). À ouvrir dans **Firefox**, qui affiche le JSON joliment.

### Option 1 : cliquer sur les liens

**✅ Obligatoire**

1. **Géocodage IGN**, Arles → coordonnées GPS :
   https://data.geopf.fr/geocodage/search?q=Arles&type=municipality&limit=5

   👉 À montrer : `features[0].geometry.coordinates` = `[4.645086, 43.596721]`, soit la longitude puis la latitude.

2. **Parcoursup 2025**, les formations BUT à moins de 30 km de ces coordonnées :
   https://data.enseignementsup-recherche.gouv.fr/api/explore/v2.1/catalog/datasets/fr-esr-parcoursup/records?where=within_distance%28g_olocalisation_des_formations%2C%20geom%27POINT%284.645086%2043.596721%29%27%2C%2030km%29%20and%20fili%3D%27BUT%27&select=cod_aff_form%2Cg_ea_lib_vx%2Cville_etab%2Clib_for_voe_ins%2Ccapa_fin%2Cvoe_tot%2Ctaux_acces_ens&limit=100

   👉 À montrer : les **mêmes nombres** `4.645086 43.596721` sont dans l'adresse. La requête 2 utilise le résultat de la requête 1.

**⭐ Bonus 1 : l'historique du BUT Informatique d'Arles** (code de formation `2815`, trouvé dans le lien 2)
- 2024 : https://data.enseignementsup-recherche.gouv.fr/api/explore/v2.1/catalog/datasets/fr-esr-parcoursup_2024/records?where=cod_aff_form%3D%272815%27&select=session%2Clib_for_voe_ins%2Ccapa_fin%2Cvoe_tot%2Ctaux_acces_ens
- 2023 : https://data.enseignementsup-recherche.gouv.fr/api/explore/v2.1/catalog/datasets/fr-esr-parcoursup_2023/records?where=cod_aff_form%3D%272815%27&select=session%2Clib_for_voe_ins%2Ccapa_fin%2Cvoe_tot%2Ctaux_acces_ens
- 2022 : https://data.enseignementsup-recherche.gouv.fr/api/explore/v2.1/catalog/datasets/fr-esr-parcoursup_2022/records?where=cod_aff_form%3D%272815%27&select=session%2Clib_for_voe_ins%2Ccapa_fin%2Cvoe_tot%2Ctaux_acces_ens

**⭐ Bonus 2 : le secours**
- https://geo.api.gouv.fr/communes?nom=Arles&fields=nom,code,centre,departement&boost=population&limit=5

### Option 2 : la chaîne complète dans la console

Cette option prouve que **la requête 2 utilise vraiment le résultat de la requête 1**, et que le navigateur a le droit de lire les données (CORS).

1. Ouvrir le lien 1 (IGN) dans Firefox.
2. **F12**, puis l'onglet **Console**. La première fois, taper `autoriser le collage` avant de pouvoir coller du code.
3. Coller ce code, puis appuyer sur **Entrée** :

```js
const ville = 'Arles'

// Requête 1 : ville -> coordonnées
const rep1 = await fetch(`https://data.geopf.fr/geocodage/search?q=${ville}&type=municipality&limit=1`)
const geo = await rep1.json()
const [lon, lat] = geo.features[0].geometry.coordinates
console.log(`1) ${ville} : longitude ${lon}, latitude ${lat}`)

// Requête 2 : utilise lon et lat de la requête 1
const where = `within_distance(g_olocalisation_des_formations, geom'POINT(${lon} ${lat})', 30km) and fili='BUT'`
const rep2 = await fetch(`https://data.enseignementsup-recherche.gouv.fr/api/explore/v2.1/catalog/datasets/fr-esr-parcoursup/records?where=${encodeURIComponent(where)}&limit=100`)
const psup = await rep2.json()
console.log(`2) ${psup.total_count} formations BUT à moins de 30 km :`)
console.table(psup.results.map((f) => ({ etablissement: f.g_ea_lib_vx, formation: f.lib_for_voe_ins, places: f.capa_fin, candidats: f.voe_tot, taux: f.taux_acces_ens })))
```

Résultat attendu :
```
1) Arles : longitude 4.645086, latitude 43.596721
2) 2 formations BUT à moins de 30 km :
   IUT Arles – BUT Métiers du multimédia et de l'internet : 56 places, 1627 candidats, 37 %
   IUT Arles – BUT Informatique                           : 56 places, 1491 candidats, 44 %
```

Astuce : remplacer `30km` par `50km` pour voir aussi les formations de l'IUT de Nîmes.

Ce code sert uniquement à la démo. Dans le projet, il sera organisé en classes, avec la vérification des erreurs.

### Ce que je dis au prof pendant la démo

**Lien 1 :**
> « Je donne le nom d'une ville à l'API de l'IGN, elle me renvoie ses coordonnées GPS. Attention, c'est la longitude d'abord, puis la latitude. »

**Lien 2 :**
> « Je réutilise ces coordonnées dans ma deuxième requête, à l'open data Parcoursup. Elle me renvoie les formations à moins de 30 km, avec le nombre de places, de candidats et le taux d'accès. C'est ma dépendance : sans la requête 1, je ne peux pas faire la 2. »

**Console :**
> « Ici, la page est sur le site de l'IGN, et je vais chercher des données sur le site de Parcoursup. Ça passe quand même, parce que ces API autorisent le navigateur à lire leurs données (le CORS). Je n'aurai donc pas besoin de proxy, qui ne marche qu'en développement. »

**Bonus (si le prof a le temps) :**
> « Chaque formation a un code, ici 2815 pour le BUT Informatique d'Arles. Avec ce code, je retrouve la même formation les années précédentes. Le taux d'accès est passé de 36 % en 2022 à 59 % en 2023, puis 44 % en 2025. Je veux afficher cette évolution dans un graphique. »

---

## 8. Améliorations à proposer au prof

✅ **Le prof a validé le projet le 09/10/2026.** Cette section sert à lui proposer d'aller plus loin.

### 8.1 Liste des améliorations, par priorité

Chacune est rattachée à une notion du cours : c'est ce qui est évalué.

| Priorité | Amélioration | Notion du cours montrée |
|---|---|---|
| ✅ Socle | Ville → formations autour, avec gestion des erreurs (liste vide, `response.ok`) | Requêtes dépendantes, `fetch` (chapitre 5) |
| ✅ Socle | Cache des réponses avec date d'expiration | `Map` (chapitre 3), conseil oral sur les quotas |
| ⭐ 1 | **Carte** des formations avec une fenêtre d'infos par formation | Leaflet importé avec webpack (TP03) |
| ⭐ 2 | **Choix de la ville** quand il y a des homonymes, avec une attente pendant la frappe | Debounce (chapitre 5), événements (chapitre 2) |
| ⭐ 3 | **Filtres** : filière, mot-clé, rayon, et page suivante au-delà de 100 résultats | Paramètres d'URL (chapitre 5) |
| ⭐ 4 | **Historique 2022-2025 + graphique** | `Promise.all` (chapitre 5) |
| ⭐ 5 | **Tendance avec fiabilité, fourchette, rang du dernier appelé** (voir 8.2) | Logique métier dans les classes (POO) |
| ⭐ 6 | **Profil des admis** (type de bac, mentions, boursiers) | Templates, manipulation du DOM (chapitre 2) |
| ⭐ 7 | **API de secours** pour le géocodage | Conseil oral : ne pas dépendre d'une seule API |
| ⭐ 8 | **Comparateur** de 2 ou 3 formations, **favoris** gardés dans le navigateur | `localStorage` |
| ⭐ 9 | Vérification du style du code avec **StandardJS** | Bonus du TP03 |

**Règle :** le socle d'abord, fonctionnel et commité, puis les améliorations dans l'ordre.

### 8.2 Peut-on prédire l'avenir ? (« probabilités futures »)

#### Ce qu'on ne peut PAS faire
- **Prédire les chances d'admission d'un élève.** Le taux d'accès est une **moyenne sur tous les candidats**. Les vraies chances dépendent du dossier (notes, bac, lettre de motivation), et ces données ne sont pas publiques.
- **Faire une prévision fiable pour 2026.** On n'a que 4 années, et les chiffres varient beaucoup.

Calcul fait sur le BUT Informatique d'Arles :

| | 2022 | 2023 | 2024 | 2025 | Calcul pour 2026 |
|---|---|---|---|---|---|
| Taux d'accès | 36 % | 59 % | 52 % | 44 % | droite de tendance → **52 %** |

La droite de tendance (une « régression linéaire ») n'explique que **5 %** des variations : son coefficient de fiabilité, appelé **R²**, vaut **0,05 sur 1**. Le chiffre de 52 % ne veut donc presque rien dire. L'afficher comme une prévision serait **trompeur**.

#### Ce qu'on peut faire honnêtement
1. **Une tendance avec son indice de fiabilité.** L'appli calcule la droite de tendance **et** le R², puis affiche par exemple :
   - *« Tendance : stable · fiabilité faible (4 années, fortes variations) »* ;
   - ou, si les chiffres montent régulièrement, *« en hausse · fiabilité bonne »*.

   C'est du calcul simple (moyennes et sommes), à écrire moi-même.
2. **Une fourchette plutôt qu'un chiffre :** *« Ces 4 dernières années : entre 36 % et 59 %, en moyenne 48 % »*.
3. **Le rang du dernier appelé** (champ `ran_grp1`) : la place du dernier candidat qui a reçu une proposition.

   | 2022 | 2023 | 2024 | 2025 |
   |---|---|---|---|
   | 785ᵉ | 712ᵉ | 547ᵉ | 450ᵉ |

   👉 **La formation devient de plus en plus sélective.** Cette information est plus parlante que le taux seul.
4. **Le profil des admis** (ce n'est pas une prédiction, mais une aide pour se comparer). Exemple pour 2025 :
   - type de bac : 60 % général, 40 % technologique ;
   - mentions : 33 % sans mention, 56 % Assez bien, 9 % Bien, 2 % Très bien ;
   - 26 % de boursiers et 25 % de filles.

   Champs utiles : `pct_bg`, `pct_bt`, `pct_bp`, `pct_sansmention`, `pct_ab`, `pct_b`, `pct_tb`, `pct_bours`, `pct_f`.

⚠️ **Piège :** `ran_grp1` change lui aussi de format selon l'année (`450`, `"547"`, `712.0`). C'est une raison de plus pour tout convertir dans **mon** format, une seule fois.

### 8.3 Ce que je dis au prof

> « Merci pour la validation. Je voudrais aller plus loin que le minimum, voici mes idées par ordre de priorité : une carte Leaflet comme au TP03, le choix de la ville avec debounce, l'historique sur 4 ans avec un graphique, et une tendance pour l'année suivante.
> Pour la tendance, **je ne veux pas afficher une fausse prédiction** : avec seulement 4 années et de fortes variations, j'afficherai une fourchette et un indice de fiabilité.
> J'ajouterai aussi le rang du dernier appelé et le profil des admis.
> Est-ce que ces ajouts vous conviennent, et lesquels vous paraissent prioritaires ? »

**Réponse du prof** (à compléter) :
- Ajouts acceptés : …
- Priorités : …
- Chart.js autorisé ? …
- Handlebars obligatoire ? …

---

## 9. ⭐ Bonus 3 : le parcours « étudiant diplômé » avec Mon Master

### 9.1 Le principe

**Mon Master** est la plateforme nationale de candidature en master (l'équivalent de Parcoursup après la licence ou le BUT). Ses données sont publiées par **le même ministère, sur la même API** que Parcoursup. On change seulement le nom du jeu de données dans l'adresse :

```
.../catalog/datasets/fr-esr-parcoursup/records   ← lycéens
.../catalog/datasets/fr-esr-mon_master/records   ← diplômés de licence ou de BUT
```

👉 **Pas de nouvelle API** : le projet garde 2 API (IGN + open data du ministère), mais répond à **deux besoins**.

### 9.2 Les nouveaux mots

| Mot | Traduction courte | C'est quoi ? |
|---|---|---|
| **Master** | Diplôme bac+5 | 2 années d'études après la licence ou le BUT |
| **Mention** | Grand domaine du master | Ex. : « Informatique », « Réseaux et télécommunications » |
| **Parcours** | Spécialité dans la mention | Ex. : « Intelligence artificielle » |
| **Académie** | Zone de l'Éducation nationale | Ex. : Aix-Marseille (à peu près un découpage régional) |

### 9.3 La chaîne de requêtes

```
"Arles" ──► 1. IGN ──► coordonnées + département (13) + région (Provence-Alpes-Côte d'Azur)
                 │
                 ├── lycéen  ──► 2. Parcoursup : formations à moins de 30 km (coordonnées)
                 │
                 └── diplômé ──► 2. Mon Master : masters de la région ou du département
                                       │
                                       │ code du master choisi (ifc)
                                       ▼
                                 3. Mon Master : historique 2024 et 2025
```

**La requête 2 dépend aussi de la requête 1** : la région vient de l'IGN. Le sujet est donc respecté sur les deux parcours.

**Où trouver la région ?** L'IGN la donne déjà, dans le champ `properties.context` :
`"13, Bouches-du-Rhône, Provence-Alpes-Côte d'Azur"` → département, nom du département, région.
Le nom de la région est **écrit exactement pareil** dans Mon Master (champ `lieu_reg_acad_lib`).

### 9.4 Les champs utiles

| Champ | Signification |
|---|---|
| `eta_nom` | Université |
| `mention` / `parcours` | Nom du master |
| `lieux` | Lieu des cours, avec le département entre parenthèses : `Faculté des sciences - MARSEILLE (13)` |
| `col` | Nombre de places |
| `n_can_pp` | Nombre de candidats |
| `n_accept_total` | Nombre d'admis |
| `rang_dernier_appele_pp` | Rang du dernier candidat appelé |
| `pct_accept_but3` | **% des admis qui viennent d'un BUT** |
| `ifc` | Code du master (pour retrouver l'historique) |
| `session` | Année (2024 ou 2025) |
| `secteur_disci_lib` | Secteur : `Informatique`, `Sciences juridiques`, `Sciences de gestion`, `Mathématiques`… (46 secteurs) |

### 9.5 Exemple concret : « Ce master accepte-t-il des étudiants de BUT ? »

Masters d'informatique à Aix-Marseille Université, session 2025 :

| Master | Candidats | Places | Admis venant d'un BUT |
|---|---|---|---|
| Réseaux et télécommunications | 434 | 15 | **52,9 %** |
| Informatique, parcours Intelligence artificielle | 656 | 21 | **0 %** |
| Informatique, parcours Science des données | 569 | 22 | **4,5 %** |

👉 Pour un étudiant de BUT, c'est une information **rare et très utile**.

### 9.6 Les liens de démo (vérifiés le 11/10/2026)

**Masters d'informatique de la région Provence-Alpes-Côte d'Azur** (24 résultats) :
https://data.enseignementsup-recherche.gouv.fr/api/explore/v2.1/catalog/datasets/fr-esr-mon_master/records?where=session%3D%272025%27%20and%20lieu_reg_acad_lib%3D%22Provence-Alpes-C%C3%B4te%20d%27Azur%22%20and%20secteur_disci_lib%3D%27Informatique%27&select=eta_nom%2Cmention%2Cparcours%2Clieux%2Ccol%2Cn_can_pp%2Cn_accept_total%2Crang_dernier_appele_pp%2Cpct_accept_but3%2Cifc&limit=100

**Masters d'informatique du département 13** (9 résultats) :
https://data.enseignementsup-recherche.gouv.fr/api/explore/v2.1/catalog/datasets/fr-esr-mon_master/records?where=session%3D%272025%27%20and%20search%28lieux%2C%20%22%2813%29%22%29%20and%20secteur_disci_lib%3D%27Informatique%27&select=eta_nom%2Cmention%2Cparcours%2Clieux%2Ccol%2Cn_can_pp%2Cn_accept_total%2Crang_dernier_appele_pp%2Cpct_accept_but3%2Cifc&limit=100

**Historique 2024-2025 du master Réseaux et télécommunications d'AMU** (code `1800815MTGPQ`) :
https://data.enseignementsup-recherche.gouv.fr/api/explore/v2.1/catalog/datasets/fr-esr-mon_master/records?where=ifc%3D%271800815MTGPQ%27&select=session%2Ceta_nom%2Cmention%2Clieux%2Ccol%2Cn_can_pp%2Cn_accept_total%2Crang_dernier_appele_pp%2Cpct_accept_but3&order_by=session

Résultat de l'historique :

| Année | Places | Candidats | Admis | Rang du dernier appelé | Admis venant d'un BUT |
|---|---|---|---|---|---|
| 2024 | 20 | 315 | 15 | 16ᵉ | 53,3 % |
| 2025 | 15 | 434 | 17 | 45ᵉ | 52,9 % |

### 9.7 Ce que j'ai découvert en testant

1. **Pas de coordonnées GPS dans Mon Master** : on filtre par **région** (`lieu_reg_acad_lib`) ou par **département** (`search(lieux, "(13)")`), pas par rayon.
2. **L'apostrophe de « Provence-Alpes-Côte d'Azur »** casse une requête écrite avec des guillemets simples. Il faut écrire `lieu_reg_acad_lib="Provence-Alpes-Côte d'Azur"`, avec des **guillemets doubles**.
3. **2024 et 2025 sont dans le même jeu de données** (champ `session`) : un seul appel suffit pour l'historique.
4. **Le code `ifc` est stable** pour environ 9 masters sur 10 entre 2024 et 2025. Les autres ont changé de code (nouvelle maquette, fusion…) et n'auront pas d'historique.
5. **Le jeu de données 2023 a d'autres noms de champs** (erreur 400) : l'historique se limite à 2024-2025.
6. **Certains masters ont des valeurs vides** (`null`) : par exemple, aucun rang ni pourcentage quand personne n'a été admis. Il faut afficher « non disponible » plutôt que planter.

### 9.8 Ce que je dis au prof

> « Pour aller plus loin, j'ajoute un deuxième profil d'utilisateur : l'étudiant diplômé qui cherche un master. Ce n'est pas une nouvelle API : Mon Master est publié par le même ministère, sur la même API que Parcoursup, je change seulement le jeu de données.
> La chaîne reste dépendante : l'IGN me donne la région de la ville, et je l'utilise pour chercher les masters de cette région.
> L'information la plus intéressante, c'est le pourcentage d'admis venant d'un BUT : à Aix-Marseille, il est de 53 % pour le master Réseaux et télécoms, mais de 0 % pour le master Intelligence artificielle. »

---

## 10. Tester moi-même dans Bruno

Bonne nouvelle : **aucun script à écrire**, tout se fait avec les onglets *Params*, *Vars* et *Assert*.

### Avant tout
**Preferences → General →** réactiver *SSL/TLS Certificate Verification* (actuellement désactivé).

### Étape 1 : regarder les données dans le navigateur
Ouvrir dans Firefox :
`https://data.geopf.fr/geocodage/search?q=Arles&type=municipality&limit=5`

Repérer `features[0].geometry.coordinates` : `[4.64, 43.59]` = **[longitude, latitude]**.

### Étape 2 : créer la collection
Barre latérale : **+** (ou *Create Collection*). Nom : `Parcoursup-Explorer`. Dossier : `~/Documents/bruno`.

### Étape 3 : créer l'environnement `dev` (les variables)
1. Réglages de la collection → **Environments** → **Create** → nom `dev`.
2. Ajouter les variables :

| Nom | Valeur |
|---|---|
| `ville` | `Arles` |
| `rayon` | `30` |
| `filiere` | `BUT` |
| `motCle` | `informatique` |
| `geoUrl` | `https://data.geopf.fr/geocodage` |
| `psupUrl` | `https://data.enseignementsup-recherche.gouv.fr/api/explore/v2.1/catalog/datasets` |
| `secoursUrl` | `https://geo.api.gouv.fr` |
| `secteur` | `Informatique` (pour Mon Master) |
| `session` | `2025` (pour Mon Master) |

3. **Ctrl+S**, puis **choisir `dev` en haut à droite** (sinon les variables restent vides).

### Étape 4 : ✅ requête 1 (obligatoire), le géocodage
1. Clic droit sur la collection → **New Request**. Nom `1 - Geocodage`, méthode **GET**, URL : `{{geoUrl}}/search`.
2. Onglet **Params** : `q` = `{{ville}}`, `type` = `municipality`, `limit` = `5`.
3. **Ctrl+Entrée** pour envoyer, puis regarder la réponse.
4. Onglet **Vars**, partie *Post Response* (on garde les coordonnées pour la requête 2) :

| Nom | Valeur |
|---|---|
| `lon` | `res.body.features[0].geometry.coordinates[0]` |
| `lat` | `res.body.features[0].geometry.coordinates[1]` |
| `departement` | `res.body.features[0].properties.context.split(', ')[0]` (pour Mon Master) |
| `region` | `res.body.features[0].properties.context.split(', ')[2]` (pour Mon Master) |

   `split(', ')` découpe `"13, Bouches-du-Rhône, Provence-Alpes-Côte d'Azur"` aux virgules : `[0]` donne `13`, `[2]` donne la région.

5. Onglet **Assert** : `res.status` `eq` `200` et `res.body.features.length` `gt` `0`.
6. **Ctrl+S**.

### Étape 5 : ✅ requête 2 (obligatoire), les formations autour (utilise la requête 1)
1. Nouvelle requête `2 - Formations`, URL : `{{psupUrl}}/fr-esr-parcoursup/records`.
2. Onglet **Params** :

| Nom | Valeur |
|---|---|
| `where` | `within_distance(g_olocalisation_des_formations, geom'POINT({{lon}} {{lat}})', {{rayon}}km) and fili='{{filiere}}'` |
| `select` | `cod_aff_form,g_ea_lib_vx,ville_etab,lib_for_voe_ins,capa_fin,voe_tot,taux_acces_ens` |
| `limit` | `100` |

   En clair, `where` veut dire : « les formations à moins de 30 km de ce point, dans la filière BUT ».
3. Envoyer **après** la requête 1.
4. Onglet **Vars**, partie *Post Response* : `codeFormation` = `res.body.results[0].cod_aff_form`.
5. Onglet **Assert** : `res.body.total_count` `gt` `0`.

🧪 **À essayer :**
- ajouter `and search(lib_for_voe_ins, "{{motCle}}")` à la fin du `where`, pour ne garder que l'informatique ;
- changer `filiere` en `BTS` ou `Licence` dans l'environnement.

> ✅ **Arrivé ici, l'obligatoire est testé** : 2 requêtes dépendantes qui fonctionnent. Les étapes 6, 7 et 8 concernent les bonus.

### Étape 6 : ⭐ requête 3 (bonus 1), l'historique (utilise la requête 2)
1. Nouvelle requête `3 - Historique 2024`, URL : `{{psupUrl}}/fr-esr-parcoursup_2024/records`.
2. Onglet **Params** :
   - `where` = `cod_aff_form='{{codeFormation}}'` ;
   - `select` = `session,lib_for_voe_ins,capa_fin,voe_tot,taux_acces_ens`.
3. Envoyer, puis regarder `taux_acces_ens` : c'est du **texte** (`"52"`).
4. Clic droit → **Clone** deux fois, en remplaçant `2024` par `2023`, puis par `2022`.

### Étape 7 : ⭐ requête 4 (bonus 2), le secours
Nouvelle requête `4 - Secours`, URL : `{{secoursUrl}}/communes`. Params : `nom` = `{{ville}}`, `fields` = `nom,centre,departement`, `limit` = `5`. Comparer avec l'IGN : mêmes informations, autre présentation.

### Étape 8 : ⭐ requêtes 5 et 6 (bonus 3), Mon Master (utilise la requête 1)
1. Nouvelle requête `5 - Masters de la region`, URL : `{{psupUrl}}/fr-esr-mon_master/records`.
2. Onglet **Params** :

| Nom | Valeur |
|---|---|
| `where` | `session='{{session}}' and lieu_reg_acad_lib="{{region}}" and secteur_disci_lib='{{secteur}}'` |
| `select` | `ifc,eta_nom,mention,parcours,lieux,col,n_can_pp,n_accept_total,rang_dernier_appele_pp,pct_accept_but3` |
| `limit` | `100` |

   ⚠️ `{{region}}` est entre **guillemets doubles**, à cause de l'apostrophe de « Côte d'Azur ».
3. Envoyer **après** la requête 1. Avec Arles, on doit obtenir **24 masters**.
4. Onglet **Vars**, partie *Post Response* : `codeMaster` = `res.body.results[0].ifc`.
5. Onglet **Assert** : `res.body.total_count` `gt` `0`.
6. Nouvelle requête `6 - Historique d'un master`, même URL. Params : `where` = `ifc='{{codeMaster}}'` et `order_by` = `session`. On obtient 2024 et 2025 en un seul appel.

🧪 **À essayer :**
- remplacer le filtre sur la région par `search(lieux, "({{departement}})")` pour ne garder que le département : 9 masters ;
- changer `secteur` en `Mathématiques` ou `Sciences de gestion` dans l'environnement.

### Étape 9 : les cas d'erreur
Clic droit sur une requête → **Clone**, puis tester :
- **Ville `zzzinconnue`** : code 200, liste vide.
- **`POINT(43.68 4.63)`**, coordonnées inversées : code 200, 0 résultat.
- **`limit` = `101`** : erreur 400.
- **Jeu de données `fr-esr-parcoursup_2021`** avec `select=taux_acces_ens` : erreur 400 (le champ n'existe pas).

- **Mon Master avec `lieu_reg_acad_lib='Provence-Alpes-Côte d'Azur'`** (guillemets simples) : erreur 400, à cause de l'apostrophe.

### Étape 10 : tout lancer d'un coup
Clic droit sur la collection → **Run**. Ici, pas besoin de délai : les limites sont larges.

---

*Fiche préparée avec l'aide de Claude (Claude Code) : tests des API, collection Bruno, rédaction. À déclarer dans la section « Usage de l'IA » du README final.*
