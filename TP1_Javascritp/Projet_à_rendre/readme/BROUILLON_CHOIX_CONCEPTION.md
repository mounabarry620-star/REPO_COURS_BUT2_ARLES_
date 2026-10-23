# Brouillon : "Choix de conception"

Ce fichier ne va **pas** dans le projet. Ce sont des notes en vrac : à toi de les réécrire avec tes mots, en phrases, dans la section "Choix de conception" du README.

Conseils :
- Ne recopie pas tout : choisis ce que tu sais expliquer à l'oral.
- Garde les références au code (fichier, ligne, commit) : le correcteur pourra vérifier, et le sujet demande un "lien direct avec votre code".
- Pour la question 3, le sujet demande **une** difficulté principale. Choisis-en une (je te propose la A), et cite éventuellement les autres en une ligne.

---

## Question 1 : pourquoi ces classes ?

Idée générale : **une classe = une seule responsabilité**. On sépare :
- ce qui va chercher les données (les **services**) ;
- ce qui représente les données (les **modèles**) ;
- ce qui touche à la page (les **vues**) ;
- ce qui décide de l'ordre des actions (l'**Application**, le contrôleur).

**Services**
- `ServiceApi` est la **classe mère** : `fetch`, vérification de `response.ok` (chapitre 5) et cache sont écrits **une seule fois**.
- `ServiceGeocodage`, `ServiceParcoursup` et `ServiceMonMaster` en **héritent** (`extends`, chapitre 1). Ajouter Mon Master n'a demandé aucune ligne de `fetch` en plus.
- `Cache` est **une seule instance**, partagée par les 3 services et créée dans `app.js`. Une réponse déjà reçue n'est jamais redemandée, ce qui protège aussi du blocage par les API.

**Modèles** (`Ville`, `Suggestion`, `Formation`, `Master`, `StatistiqueAnnuelle`, `StatistiqueMaster`, `Historique`)
- Les champs sont **privés** (`#`) et lus par des **getters** : le reste du code ne peut pas modifier une formation par erreur.
- Certains getters **calculent** au lieu de stocker :
  - `candidatsParPlace` ;
  - `tauxProposition`, `tauxPropositionLicence3`, `tauxPropositionBut3` ;
  - `libelle` ("Arles (13)").
- Les données brutes de l'API (noms de champs comme `g_ea_lib_vx` ou `n_can_pp`) sont traduites en modèles **dans les services**, à la frontière. Le reste du code ne voit que des noms clairs.

**Vues** (`VueRecherche`, `VueResultats`, `VueCarte`, `VueHistorique`, `VueTheme`)
- Elles seules touchent au DOM, avec les templates Handlebars (TP 3).
- Elles ne font aucune requête : elles **préviennent** l'Application par des callbacks (`quandRecherche`, `quandFiltre`, `quandHistorique`).

**Application**
- Le chef d'orchestre : elle reçoit les demandes des vues, appelle les services dans le bon ordre et renvoie les résultats aux vues.
- Elle reçoit services et vues **dans son constructeur** (créés dans `app.js`). Au début du projet, je l'ai donc testée avec de **fausses vues** qui écrivaient dans la console (commit `c9ab42d`).

**Polymorphisme** (même idée que Forme, Ellipse et Cercle au chapitre 1)
- `Formation` et `Master` ont chacun leur méthode `correspond(recherche)`. `Application.filtrer` l'appelle sans savoir si c'est une formation ou un master.
- `ServiceParcoursup` et `ServiceMonMaster` ont chacun leur méthode `historique(code)`. La même fenêtre d'historique sert aux deux.

**`outils.js`**
- Petites fonctions sans état, partagées par plusieurs classes : `normaliser`, `contientTousLesMots`, `pourcentage`, `versNombre`.
- Elles ne sont pas en classe, parce qu'elles n'ont pas de données à garder (commit `f6097fa`).

---

## Question 2 : comment l'enchaînement des deux requêtes est géré

Tout se passe dans `Application.rechercher` (`src/scripts/application.js`, lignes 97 à 124). C'est une méthode `async`, donc chaque `await` attend la réponse avant de continuer (chapitre 5).

1. **Requête 1 :** `await this.#geocodage.chercherVilles(nomVille, codePostal)` (ligne 104). L'IGN renvoie la ville avec ses coordonnées, son département et sa région.
2. Si aucune commune n'est trouvée, on affiche un message et **on s'arrête** : la requête 2 n'est pas lancée.
3. **Requête 2**, avec ce que la requête 1 a donné (lignes 112 à 117) :
   - **Parcoursup** (`#rechercherFormations`) : les coordonnées de la ville sont mises dans la condition
     `within_distance(g_olocalisation_des_formations, geom'POINT(lon lat)', 30km)` (`serviceParcoursup.js`, ligne 21) ;
   - **Mon Master** (`#rechercherMasters`) : la **région** de la ville filtre la requête (`lieu_reg_acad_lib="..."`). Pour "mon département", on garde ensuite les masters du département de la ville, sans nouvelle requête.
4. **Un seul `try/catch`** entoure les deux requêtes. Si l'une échoue (réseau coupé, API en panne), l'utilisateur voit un message au lieu d'une page bloquée.
5. **Le problème des recherches qui se croisent** (commit `c358944`) : si on lance une 2e recherche avant la fin de la 1re, la 1re pouvait arriver après et écraser les bons résultats. Solution : chaque recherche prend un **numéro** (`#numeroRecherche`, lignes 98-99). Après chaque `await`, on vérifie qu'on est toujours la dernière recherche, sinon on ignore la réponse (lignes 105, 128, 147).
6. **Au contraire, l'historique** lance ses requêtes (une par session) **en parallèle** avec `Promise.all` (`serviceParcoursup.js`, ligne 40). Elles ne dépendent pas les unes des autres, donc inutile de les attendre une par une.

---

## Question 3 : difficulté principale (en choisir une)

**A. (proposée) Les résultats limités à 100 formations**
- Problème : la route `records` de l'API ne renvoie que 100 résultats au maximum. Paris à 10 km renvoyait 100 formations au lieu de 1 473, sans aucune erreur.
- Solution trouvée dans la documentation Opendatasoft : la route `exports/json` renvoie **tout** en une requête, et `select` ne demande que les champs utiles. Paris à 200 km renvoie 4 456 formations.

**B. L'ordre des coordonnées**
- Problème : l'IGN et la condition `POINT(...)` attendent **longitude puis latitude**. Inversées, la requête ne trouvait **aucune** formation, sans erreur.
- Solution : modèle `Ville` avec `lon` et `lat` nommés clairement.

**C. Les recherches qui se croisent**
- Le numéro de recherche, voir la question 2, point 5.

**D. Les données Mon Master différentes selon l'année**
- 2023 n'a pas les mêmes noms de champs (`n_can` au lieu de `n_can_pp`), ni de chiffres pour les BUT 3. Solution : un tableau `JEUX_HISTORIQUE` qui donne, pour chaque session, son jeu de données et ses noms de champs.
- La Corse s'appelle "20" chez Mon Master, mais "2A" et "2B" chez l'IGN.
- Les villes d'outre-mer n'avaient pas de région : l'IGN renvoie un contexte en 2 morceaux au lieu de 3 (commit `3323008`).

**E. Handlebars et les getters**
- Handlebars refuse de lire les getters d'une classe, par sécurité. Les vues recopient donc chaque modèle dans un objet simple avant de l'envoyer au template (`#ligneFormation`, `vueResultats.js`, ligne 99).
