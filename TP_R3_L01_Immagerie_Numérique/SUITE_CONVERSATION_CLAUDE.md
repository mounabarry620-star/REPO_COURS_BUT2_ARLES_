# Suite de la conversation avec Claude — R3.L01 Imagerie numérique

Résumé du travail fait avec Claude Code pour continuer sur un autre PC.
Pour reprendre, ouvre Claude Code dans ce dossier et colle le texte de la section 7.

---

## 1. Contexte

- Étudiant en BUT2 Informatique, IUT d'Arles. Module **R3.L01 — Représentations et codages des images**, prof **Eric Remy**.
- Les TP1 à TP5 avaient d'abord été faits avec Gemini. Il était demandé de :
  - relire tout le dossier (CM, sujets, TD, corrigés pris au tableau, images) ;
  - vérifier et corriger ce que Gemini avait produit ;
  - tout rendre **conforme à la lettre** au cours, aux TD et aux sujets, et **pédagogique** (le pourquoi, avec des schémas).
- Modalités (`TP1_TD1/note.txt`) :
  - TP noté à la 5ᵉ séance, on rend **tout le code des 5 séances** ;
  - les noms de fonctions comptent ;
  - contrôle de TD le 14/10/2026 ; contrôle pratique le 06/11/2026 (ou 21/10).
- Nom de l'étudiant, confirmé : **Mamadou Bailo BARRY**. Il est dans la constante `AUTEUR` en haut de `PROJET_FINAL/Image.cpp`.
- Le prof **n'a pas corrigé au tableau** la partie bilinéaire du TD3 ; il a demandé de chercher à partir de ce qui a été vu en cours. Il n'y a pas d'autres TD (TD4/TD5).

---

## 2. Ce qui a été fait

### Verdict sur le travail de Gemini

- Le code de base était correct, mais **le travail se perdait d'un TP à l'autre** : chaque dossier avait sa propre `ColorImage`, différente. GrayImage avait disparu au TP2 ; le rééchantillonnage et le JPEG avaient disparu au TP4.
- **Prototype non conforme** : `line(int16_t…)` au lieu de `ushort` (TP5).
- **`skip_comments`** ne correspondait pas à la question 4 du TD1.
- **Bugs** :
  - `Color + Color` débordait (200 + 100 = 44) ;
  - libjpeg appelait `exit()` au lieu de lever une exception ;
  - TGA : lectures non vérifiées et fuite mémoire.
- **PDF trompeurs** : « E. Remy » en pied de page, citations du prof inventées.

### Code final : `PROJET_FINAL/`

- Un seul `Image.hpp` / `Image.cpp` avec GrayImage, Color et ColorImage. C'est ce qu'exigent les sujets : TP2 « *dans les mêmes fichiers Image.hpp et Image.cpp* », TP3 « *image.hpp et image.cpp* ».
- Un programme de test par TP : `tp1.cpp` … `tp5.cpp`.
- Un `Makefile` : `make`, `make tp2`, `make test`, `make clean`.
- Les images d'entrée sont dans `PROJET_FINAL/images/`.
- Fonctions :
  - **TP1** : dessin, `writePGM`, `skip_line`, `skip_comments`, `static readPGM` (P5 + bonus P2) ;
  - **TP2** : Color (`==`, `!=`, `double*Color` arrondi, `Color+Color` saturé), ColorImage, `writePPM`, `readPPM` (P6 + bonus P3), `simpleScale` et `bilinearScale` **pour les deux classes**, avec la correction du demi-pixel ;
  - **TP3** : `writeJPEG(const char*, unsigned int quality = 75)` et `readJPEG`, les erreurs libjpeg devenant des exceptions ;
  - **TP4** : `writeTGA(ostream&, bool rle = true)` (sous-formats 2 / 10) et `readTGA` (sous-formats 1, 2, 10 ; origine en haut ou en bas) ;
  - **TP5** : `line(uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2, const Color)`, Bresenham sur les 8 octants ;
  - **en plus** (le sujet du TP1 annonce `writeFormat` « PGM, TGA, JPEG » pour les gris) : `GrayImage::writeJPEG`/`readJPEG` et `writeTGA`/`readTGA` (sous-formats 3 et 11).
- Lecture d'en-tête PGM/PPM tolérante (`is >> std::ws` avant `skip_comments`), comme le demande PGM.txt (« *as lenient as possible* ») : elle gère les commentaires après les dimensions de `chat.pgm`, les fins de ligne Windows et un en-tête sur une seule ligne.

### Vérifications faites

| Test | Résultat |
|---|---|
| TP1, chat à lunettes | **identique pixel pour pixel** à `chat_lunettes.pgm` du prof |
| TP5, octant 1 et octants 1 + 2 | **identiques** à l'image du sujet |
| TP5, cercle | quelques extrémités à ±1 pixel (arrondi de cos/sin) |
| TGA écrits (couleur et gris) | relus identiques par notre code **et** par ImageMagick |
| JPEG qualité 75 % | même taille que la qualité par défaut (18 908 octets), comme l'annonce le sujet |
| AddressSanitizer + UBSan | aucune erreur |
| Compilation `-Wall -Wextra` | aucun avertissement |

### Documents de révision

- `REVISION_CONTROLE_TD_R3L01.pdf` (26 pages) : tout le CM, le TD1, le TD2 entièrement corrigé (`swap_bytes`, lecture big endian, version portable, tailles mémoire, débit UHD), le TD3, puis 13 exercices corrigés.
- `TPx/TPx_explications.pdf` (un par TP) : le code commenté, le pourquoi, des schémas, les corrections apportées à Gemini et les questions possibles au contrôle.
- `TPx/walkthrough.md` : résumé de chaque TP.
- `TP2_TD2/td2_endianness.cpp` : l'exercice 2 du TD2 en programme testable.
- `README.md` (racine) : **le guide complet** — organisation, conformité question par question, compilation, Makefile ligne par ligne, résultats attendus, méthode de révision, pièges.

---

## 3. Où est quoi

```
TP_R3_L01_Immagerie_Numérique/
├── README.md                       ← guide complet (à lire en premier)
├── SUITE_CONVERSATION_CLAUDE.md    ← ce fichier
├── R3.L01_CM.pdf                   ← cours du prof
├── REVISION_CONTROLE_TD_R3L01.pdf  ← fiche de révision
├── PROJET_FINAL/                   ← LE CODE À RENDRE
├── TP1_TD1/ … TP5/                 ← sujets, TD, corrigés, TPx_explications.pdf, walkthrough.md
├── _ARCHIVE_GEMINI/                ← ancienne version de Gemini (peut être supprimée)
└── _sources_pdf/                   ← sources HTML des PDF + build.py (régénération)
```

Tout est **commité dans git** (dernier commit vu : `af418be working_on_project`). Sur le nouveau PC, il suffit de cloner ou de faire un `git pull` du dépôt `REPO_COURS_BUT2_ARLES_`.

---

## 4. Installer sur le nouveau PC (Debian/Ubuntu)

```bash
sudo apt install g++ make libjpeg-dev     # pour compiler les TP
sudo apt install imagemagick eog          # facultatif : comparer et voir les images
sudo apt install chromium python3         # facultatif : seulement pour régénérer les PDF
```

Test rapide :

```bash
cd PROJET_FINAL
make test      # compile et lance les 5 TP : tout doit afficher « 0 pixel(s) différent(s) », « identique : oui »…
make clean     # nettoie
```

Compilation à la main :

```bash
g++ -std=c++11 -Wall -Wextra Image.cpp tp1.cpp -o tp1 -ljpeg && ./tp1
```

Régénérer les PDF après une modification d'un `.html` :

```bash
cd _sources_pdf
python3 build.py            # tous
python3 build.py tp1        # un seul
```

Le script signale les pages dont le contenu déborde.

---

## 5. Choix importants à ne pas défaire

- **Tout dans `Image.hpp`/`Image.cpp`** : c'est une consigne des sujets, ne pas re-séparer en un fichier par TP.
- **Noms et prototypes exactement ceux des sujets** : ils sont vérifiés à la notation.
- **`skip_line` / `skip_comments`** écrites comme le TD1 les décrit ; la tolérance vient de `is >> std::ws` placé avant.
- **Un seul `is.get()` après 255** : un pixel peut valoir 10 (LF) ou 32 (espace).
- **`static_assert(sizeof(Color) == 3)`** avant d'écrire le tableau de Color d'un bloc (padding, CM diapo 14).
- **TGA** : ordre b, g, r ; entiers 16 bits en little endian écrits avec des décalages (portable) ; bit 5 du descripteur = origine en haut ; paquets RLE limités à une ligne.
- **Bilinéaire** : formule standard (2 interpolations horizontales + 1 verticale) avec la correction ±0,5 du demi-pixel citée par le sujet du TP2.
- Les PDF sont présentés comme une **fiche de révision « d'après le cours d'E. Remy »**, jamais comme un document du prof.

---

## 6. Ce qui reste / pistes

- **Avant le rendu** : `make test`, puis `make clean`, et rendre `Image.hpp`, `Image.cpp`, `tp1.cpp` … `tp5.cpp`, `Makefile` (+ `images/` si le prof veut lancer les tests).
- **Si un nouveau sujet arrive** (TP6 ou TD supplémentaire) : l'ajouter dans le même `Image.hpp`/`Image.cpp`, ajouter un `tp6.cpp` et la cible dans le Makefile (`PROGS = … tp6`).
- **Préparer le contrôle pratique** : s'entraîner dans une copie (`cp -r PROJET_FINAL ~/Documents/entrainement_R3L01`) avec les exercices « casser et vérifier » du README (section 4).
- `_ARCHIVE_GEMINI/` peut être supprimé quand on n'en a plus besoin.

---

## 7. Texte à coller pour reprendre avec Claude

```
Je reprends le travail sur le module R3.L01 (imagerie numérique, prof E. Remy).
Lis d'abord SUITE_CONVERSATION_CLAUDE.md puis README.md à la racine de ce dossier :
ils résument tout ce qui a été fait (code final dans PROJET_FINAL/, PDF d'explication,
fiche de révision). Respecte à la lettre le cours, les TD et les sujets, explique-moi
toujours le pourquoi, et ne défais pas les choix de la section 5.
Ce que je veux faire maintenant : ...
```
