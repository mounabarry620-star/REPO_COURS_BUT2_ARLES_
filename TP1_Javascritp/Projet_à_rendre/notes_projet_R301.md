# Projet R3.01 – Développement web : notes de travail

Récapitulatif de ma séance de préparation du 09/10/2026.

---

## 1. Le sujet en bref

**Objectif** : développer une application client-riche (dans le navigateur) qui montre la maîtrise des techniques vues en cours R3.01.

**Contraintes techniques obligatoires**
- Programmation orientée objet (classes ES6).
- Application empaquetée avec **webpack**.
- Compatible avec au moins les **3 dernières versions des navigateurs** (Babel + `browserslist`).
- **Toutes** les dépendances gérées par webpack : pas de CDN, pas de `<script>` écrit à la main, une image = un `import`.
- Au moins **2 requêtes XHR ou fetch dépendantes** : la 2ᵉ utilise le résultat de la 1ʳᵉ. Elles peuvent être faites sur 2 API différentes.

**Dates**
- Validation du choix d'application par le prof : **avant la fin de la séance du 09/10/2026**.
- Rendu : **23/10/2026 avant 23h59** sur AMETICE. Retard = **−1 point par heure**.

**Git (obligatoire, l'historique fait partie du rendu)**
- `git init`, puis `git config user.name "Prénom Nom"` et `git config user.email "prenom.nom@etu.univ-amu.fr"` (sans `--global` sur les machines de l'IUT).
- `.gitignore` : `node_modules/`, `dist/`, `.env`.
- Commiter souvent, avec des messages explicites, un commit = une modification cohérente.
- Dépôt distant (GitHub/GitLab) : **privé** obligatoirement.

**Contenu de l'archive**
- Le projet **sans** `node_modules`.
- Le dossier **`.git`** (dossier caché : vérifier qu'il est bien dans l'archive).
- Un README avec :
  - nom, prénom, mail universitaire ;
  - description complète du projet ;
  - commandes d'installation et d'exécution ;
  - section « Usage de l'IA » ;
  - section « Choix de conception » qui répond à : Pourquoi ce découpage en classes ? Comment l'enchaînement des 2 requêtes dépendantes est-il géré ? Quelle difficulté principale et comment je l'ai résolue ?

**Évaluation (sur 20, travail individuel, pas de présentation orale)**
- Conception (un diagramme de classes peut être fourni).
- Qualité de la mise en œuvre.
- Respect des contraintes techniques.
- Justification des choix et traçabilité (historique git, README).

---

## 2. Mes notes du prof, expliquées

| Ce que le prof a dit | Ce que ça veut dire concrètement |
|---|---|
| API libre mais à valider avec lui | Choisir une API publique, gratuite, sans clé, puis la faire valider |
| Premier jour : savoir consommer l'API | Tester les URL dans le navigateur ou dans Bruno avant de coder |
| Ne pas laisser le prof mettre les clés API | Choisir des API **sans clé** |
| Dépendre de la structure, pas des API | Mon code ne doit pas connaître les détails d'une API : chaque réponse est convertie dans **mon propre format** |
| Si une API meurt, l'autre prend le relais | Prévoir une **API de secours** qui fournit le même type de données |
| Attention au quota, faire un cache | Garder les réponses en mémoire (`Map`, `localStorage`) avec une durée de validité |
| Possible d'utiliser 2 API complémentaires | Exemple : météo + météo historique |
| Bien vérifier le dossier `.git` | Ouvrir l'archive avant le dépôt pour vérifier qu'il y est |

---

## 3. Ce que j'ai retenu des cours

- **TP03 (Vélib)**
  - Fichier `.env` + `dotenv` / `dotenv-webpack` pour les variables d'environnement. Ne pas versionner `.env` : versionner un `.env.example` à la place.
  - **CORS** : le navigateur bloque la lecture d'une réponse venant d'une autre origine si le serveur ne l'autorise pas (en-tête `Access-Control-Allow-Origin`).
  - Le **proxy** de webpack contourne ce blocage, mais **seulement avec `npm start`**. Il n'existe plus après `npm run build`. ⇒ Choisir des API qui acceptent le CORS.
  - Leaflet : l'importer avec webpack (`import * as L from 'leaflet'`) et corriger les icônes de marqueurs.
- **Chapitre 05 (requêtes HTTP)**
  - Méthodes HTTP, codes de statut, JSON, XHR, `fetch`, `async`/`await`.
  - Piège : `fetch` **ne rejette pas** sur une 404 ou une 500, il faut tester `response.ok`.
  - `Promise.all` pour lancer des requêtes en parallèle.
  - **Debounce** (attendre que l'utilisateur ait fini de taper) et **throttle**.
- **Chapitre 04** : modules ES2015 et principes de webpack (entry, output, loaders, plugins).

---

## 4. API testées depuis le navigateur (CORS)

✅ **Fonctionnent**
- Open-Meteo (géocodage, prévisions, historique)
- geo.api.gouv.fr, API Adresse, Géoplateforme IGN
- Open data Parcoursup, annuaire de l'éducation
- USGS et EMSC (séismes), iNaturalist et GBIF (biodiversité), wheretheiss.at
- PokéAPI, Tyradex, TVmaze, Lichess, Chess.com, Jolpica F1
- **Cyber** : NVD, EPSS (FIRST), KEV (dépôt GitHub de la CISA), CIRCL Vulnerability-Lookup, CVE.org, OSV.dev, Have I Been Pwned (Pwned Passwords), Mozilla HTTP Observatory, Shodan InternetDB, RIPEstat

❌ **Bloquées ou sans réponse** : Vélib (CORS), le site cisa.gov (CORS), REST Countries, Jikan, crt.sh

---

## 5. Les idées de projet étudiées

1. **Météo « aujourd'hui vs il y a un an »** (Open-Meteo). Simple et efficace, mais beaucoup d'étudiants vont la prendre.
2. **SismoWatch** : les séismes autour d'une adresse. Géocodage IGN → USGS, avec EMSC en secours. Carte Leaflet.
3. **Explorateur Parcoursup** : les formations autour d'une ville. Géocodage IGN (geo.api.gouv en secours) → open data Parcoursup dans un rayon.
4. **VulnRadar** 🛡️ : tableau de bord de priorisation des vulnérabilités. NVD → EPSS + KEV, avec CIRCL en secours.

---

## 6. Comparaison finale : Parcoursup vs VulnRadar

| Critère | Parcoursup | VulnRadar |
|---|---|---|
| Richesse des données | Bonne, mais mises à jour une fois par an | Très bonne : 3 sources complémentaires, mises à jour chaque jour |
| Requêtes dépendantes | Ville → coordonnées → formations | Logiciel → numéros CVE → EPSS / KEV (dépendance plus évidente) |
| API de secours | Faible : seul le géocodage en a une | Forte : CIRCL contient les mêmes CVE |
| Quota et cache | Cache peu justifié | Cache indispensable (5 requêtes / 30 s) |
| Public touché | Très large, compris par tous | Spécialisé |
| Ambition possible | Moyenne | Élevée |
| Risque de ne pas finir | Faible | Moyen (JSON complexe) |

**Verdict** : VulnRadar colle mieux aux attentes du prof (secours, quota, API complémentaires) et permet d'aller plus loin. Condition : construire d'abord un socle minimal qui marche (NVD → EPSS → cache), le commiter, puis ajouter le reste. Si le temps manque, Parcoursup est le choix raisonnable. Pour le rendre plus ambitieux : comparer l'évolution des taux d'accès sur plusieurs années.

---

## 7. VulnRadar en détail

### Le principe
L'utilisateur tape un logiciel (nginx, apache, wordpress…). L'appli affiche ses failles connues et les **classe par priorité** en croisant gravité, probabilité d'attaque et exploitation réelle.

```
nom du logiciel → [NVD : liste des CVE] → numéros CVE → [EPSS : probabilité d'attaque]
                                                       → [KEV : déjà exploitée ?]
                                                       → score de priorité + tableau de bord
```

### Les sigles
| Sigle | C'est quoi | Rôle dans le projet |
|---|---|---|
| **CVE** | Numéro unique d'une faille (ex. `CVE-2021-44228` = Log4Shell) | La donnée qui relie toutes les API |
| **NIST** | Organisme public américain de normalisation | Gère la NVD |
| **NVD** | Base de données de toutes les CVE | Requête 1 : les failles d'un logiciel |
| **CVSS** | Gravité de 0 à 10 (faible, moyen, élevé, critique) | Fourni par la NVD |
| **FIRST** | Association mondiale des équipes de réponse aux incidents | Fournit l'EPSS |
| **EPSS** | Probabilité (%) que la faille soit exploitée dans les 30 jours | Requête 2 : risque d'attaque |
| **CISA** | Agence cyber américaine (équivalent français : ANSSI) | Publie le KEV |
| **KEV** | Liste des failles **déjà** exploitées par des attaquants | Vérification « exploitée : oui ou non » |
| **CIRCL** | Équipe cyber publique du Luxembourg (un CERT) | API de secours si la NVD tombe |

Pourquoi croiser les trois ? Une faille notée CVSS 9,8 avec un EPSS de 0,1 % et absente du KEV est **moins urgente** qu'une faille CVSS 7,5 avec un EPSS de 95 % qui est dans le KEV.

### Vérifications faites
- Toutes les API sont **gratuites et sans clé**, et le CORS a été testé : OK.
- Quotas officiels :
  - **NVD** : 5 requêtes par fenêtre glissante de 30 s sans clé (50 avec une clé gratuite). Le NIST conseille d'attendre quelques secondes entre deux requêtes.
  - **EPSS** : 1 000 requêtes par minute, pas d'authentification.
  - **KEV** : un fichier téléchargé une fois par jour.
  - **CIRCL** : pas de limite publiée.
- Test réel : nginx = **411 CVE en une seule requête** (`resultsPerPage=2000`), en 1,3 s, toutes avec un score.
- ⚠️ Depuis avril 2026, le NIST n'analyse plus lui-même toutes les CVE (analyse complète réservée aux failles prioritaires, dont celles du KEV). Pour les autres, la NVD affiche le score fourni par l'organisme qui a déclaré la faille. ⇒ Prévoir le cas « score absent ».
- EPSS : on peut envoyer plusieurs CVE séparées par des virgules. Les paquets d'environ 100 sont un choix prudent (longueur d'URL), pas une limite officielle.

### Le quota, expliqué
- **Quota (rate limit)** : nombre maximum de requêtes acceptées sur une période donnée. Il protège le serveur (anti-DDoS) et partage l'accès équitablement.
- **Fenêtre glissante** : à chaque instant, le serveur compte tes requêtes des 30 dernières secondes.
- Si tu dépasses : erreur **403** ou **429**, et parfois un blocage temporaire de ton IP. Attention, à l'IUT tout le monde partage souvent la même IP.
- Les solutions :
  - **cache** avec date d'expiration ;
  - tout récupérer en une requête (`resultsPerPage=2000`) ;
  - **regrouper** les CVE dans une requête EPSS ;
  - **debounce** sur le champ de recherche ;
  - télécharger le KEV une seule fois ;
  - basculer sur **CIRCL** en cas d'erreur.

### Les niveaux d'ambition
1. **Socle (obligatoire)** : recherche, CVE, EPSS, KEV, score de priorité, cache, secours CIRCL.
2. **Visualisation** : graphiques (répartition par gravité, évolution par année), fiche détaillée d'une CVE.
3. **Audit de projet** : glisser un `package.json` → dépendances vulnérables (OSV.dev + registre npm).
4. **Bonus** : vérifier si un mot de passe a fuité sans l'envoyer (k-anonymat, Have I Been Pwned), note de sécurité d'un site (Mozilla Observatory).

Éthique : l'appli **consulte des bases publiques**. Elle ne scanne et n'attaque aucun système.

### URL de démo
- CVE de nginx : `https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=nginx&resultsPerPage=5`
- EPSS de Log4Shell : `https://api.first.org/data/v1/epss?cve=CVE-2021-44228`
- Catalogue KEV : `https://raw.githubusercontent.com/cisagov/kev-data/develop/known_exploited_vulnerabilities.json`
- Secours CIRCL : `https://vulnerability.circl.lu/api/vulnerability/CVE-2021-44228`

### Phrase pour le prof
> « VulnRadar est un tableau de bord de priorisation des vulnérabilités. J'interroge la NVD du NIST pour obtenir les CVE d'un logiciel. Avec les identifiants obtenus, je récupère le score EPSS et je vérifie dans le catalogue KEV de la CISA si la faille est déjà exploitée. NVD est limité à 5 requêtes toutes les 30 secondes, donc je mets en place un cache, et j'ai la base CIRCL en secours. Toutes les API sont gratuites et sans clé. »

---

## 8. Parcoursup en détail (plan B)

- Géocodage : `https://data.geopf.fr/geocodage/search?q=Arles&limit=1`. Les coordonnées sont dans `features[0].geometry.coordinates`, au format **[lon, lat]**.
- Secours : `https://geo.api.gouv.fr/communes?nom=Arles&fields=centre&limit=1`
- Formations dans un rayon : jeu de données `fr-esr-parcoursup` avec
  `where=within_distance(g_olocalisation_des_formations, geom'POINT(lon lat)', 50km) and fili='BUT'`
  (attention : **longitude d'abord**).
- Champs utiles :
  - `g_ea_lib_vx` : établissement ;
  - `lib_for_voe_ins` : formation ;
  - `ville_etab` : ville ;
  - `fili` : filière ;
  - `taux_acces_ens` : taux d'accès ;
  - `capa_fin` : nombre de places ;
  - `voe_tot` : nombre de candidats ;
  - `lien_form_psup` : lien vers la fiche Parcoursup.

---

## 9. Tester une API avec Bruno (méthode générale)

1. Installer Bruno (usebruno.com/downloads, ou `winget install Bruno.Bruno`).
2. Créer une collection dans un dossier `bruno/` du projet. Les fichiers `.bru` se versionnent avec git.
3. Créer un environnement (ex. `dev`) avec des variables (`ville`, `logiciel`…) et **le sélectionner** en haut à droite.
4. Requête 1 : GET + URL, paramètres dans l'onglet **Params**, puis **Send** (Ctrl+Entrée).
5. Récupérer une valeur de la réponse : onglet **Vars**, partie **Post Response**, par exemple `lat` = `res.body.features[0].geometry.coordinates[1]`.
6. Requête 2 : utiliser `{{lat}}` / `{{lon}}` dans l'URL ou dans les paramètres.
7. Onglet **Assert** : `res.status` `eq` `200`, etc.
8. Clic droit sur la collection, puis **Run** pour exécuter la chaîne complète.
9. Tester les cas d'erreur (valeur introuvable, aucun résultat) pour savoir quoi gérer dans le code.

---

## 10. Planning prévisionnel

| Date | À faire |
|---|---|
| 09/10 | Faire valider l'idée par le prof, tester les API dans Bruno |
| 10–12/10 | `npm init`, config webpack (reprise du TP03), `git init`, `.gitignore`, premier commit |
| 13/10 | Dessiner le diagramme de classes |
| 14–17/10 | Requête 1 → commit, requête 2 dépendante → commit, cache → commit, gestion des erreurs |
| 18–20/10 | Interface, API de secours, debounce |
| 21–22/10 | `npm run build`, tests sur plusieurs navigateurs, README complet |
| 23/10 avant 23h59 | Archive sans `node_modules`, avec `.git` (à vérifier), dépôt sur AMETICE |

---

## Sources
- Sujet du projet R3.01 et TP03 (AMETICE), chapitres 04 et 05 du cours de B. Desbenoit
- NVD – Developers, Start Here : https://nvd.nist.gov/developers/start-here
- API FIRST : https://api.first.org/ et EPSS : https://www.first.org/epss/api
- CSA, refonte de l'enrichissement NVD (avril 2026) : https://labs.cloudsecurityalliance.org/research/csa-research-note-nist-nvd-enrichment-overhaul-20260429-csa/
- Transfert de l'API Adresse à l'IGN : https://www.data.gouv.fr/posts/lapi-adresse-de-la-base-adresse-nationale-est-transferee-a-lign-10

