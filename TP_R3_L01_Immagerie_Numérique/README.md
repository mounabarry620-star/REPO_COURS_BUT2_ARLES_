# R3.L01 — Représentations et codages des images

Guide du dossier : où trouver quoi, ce qui a été fait pour chaque question des sujets,
comment compiler et tester, et comment réviser TP par TP et TD par TD.

- Contrôle théorique (TD) : **14/10/2026**
- Contrôle pratique (TP) : **06/11/2026** (ou 21/10)
- Rendu : à la 5ᵉ séance, **tout le code des 5 séances** (`note.txt`)

---

## 1. Organisation du dossier

```
TP_R3_L01_Immagerie_Numérique/
├── README.md                       ← ce guide
├── R3.L01_CM.pdf                   ← le cours d'E. Remy
├── REVISION_CONTROLE_TD_R3L01.pdf  ← fiche de révision du contrôle de TD (cours + TD1, TD2, TD3 + exercices)
├── PROJET_FINAL/                   ← LE CODE À RENDRE (tous les TP)
├── TP1_TD1/ … TP5/                 ← un dossier par séance : sujets, TD, corrigés, explications
├── _ARCHIVE_GEMINI/                ← ancienne version faite avec Gemini (peut être supprimée)
└── _sources_pdf/                   ← sources des PDF d'explication (pour les régénérer)
```

### `PROJET_FINAL/` : le code

```
PROJET_FINAL/
├── Image.hpp     ← déclarations : GrayImage, Color, ColorImage, skip_line, skip_comments
├── Image.cpp     ← le code de toutes les fonctions, rangé par TP (titres « // TP1 », « // TP2 »…)
├── tp1.cpp       ← programme de test du TP1 (un main par TP)
├── tp2.cpp       ← … du TP2
├── tp3.cpp       ← … du TP3
├── tp4.cpp       ← … du TP4
├── tp5.cpp       ← … du TP5
├── Makefile      ← la recette de compilation
├── .gitignore    ← fichiers produits à ne pas mettre dans git
└── images/       ← images d'ENTRÉE fournies par le prof (jamais modifiées)
```

**Pourquoi un seul `Image.hpp` / `Image.cpp` ?** Parce que les sujets le demandent :

- sujet du TP2 : « *Dans les mêmes fichiers Image.hpp et Image.cpp, implanter les classes Color et ColorImage* » ;
- sujet du TP3 : « *Modifier maintenant dans les fichiers image.hpp et image.cpp la fonction membre writeJPEG()* ».

C'est **la même classe** qui reçoit de nouvelles fonctions à chaque séance :

```
GrayImage  ← TP1 (dessin, PGM), TP2/TD3 (rééchantillonnage), + TGA et JPEG en gris (annoncés au TP1)
ColorImage ← TP2 (dessin, PPM, rééchantillonnage), TP3 (JPEG), TP4 (TGA), TP5 (line)
```

Une classe ne peut avoir qu'une seule déclaration dans un programme : on ne peut donc pas
garder une « ColorImage du TP3 » et une « ColorImage du TP4 » séparées.

**Pourquoi un `.hpp` et un `.cpp` ?** Le `.hpp` dit **ce qui existe** (le sommaire), le `.cpp`
dit **comment ça marche** (les chapitres). Chaque `tpN.cpp` fait `#include "Image.hpp"` pour
utiliser les classes sans recopier leur code.

**Pourquoi 5 fichiers `tpN.cpp` ?** Un programme n'a qu'un seul `main`. Chaque TP a ses tests,
donc 5 petits programmes qui utilisent tous la même bibliothèque `Image`.

### Le dossier `images/`

| Image | Utilisée par | Pour quoi |
|---|---|---|
| `chat.pgm` | tp1, tp3, tp4 | PGM avec des commentaires « pièges » après les dimensions |
| `chat_lunettes.pgm` | tp1 | image de référence du prof : notre résultat est comparé avec elle |
| `Rafale30000.pgm` / `.ppm` | tp1, tp2 | bonus P2 / P3 (pixels écrits en texte) |
| `chat.ppm` | tp2, tp3 | PPM, rectangles, JPEG |
| `chat_petit.ppm` / `.pgm` | tp2 | agrandissement 80 × 60 → 823 × 400 |
| `chat.tga` | tp4 | TGA sous-format 2 |
| `palette_bl.tga`, `palette_tl.tga`, `chat010couleurs.tga` | tp4 | TGA sous-format 1 (palette), origine en bas / en haut |
| `chanel.tga` | tp4 | TGA sous-format 10 (RLE) écrit par un autre logiciel |
| `tp5_im1/2/3.png` | toi | résultats attendus du TP5, pour comparer à l'œil |

### Les dossiers `TP1_TD1/` à `TP5/`

Ils ne contiennent **plus de code** (tout est dans `PROJET_FINAL/`), mais tout ce qui sert à réviser :

| Dossier | Contenu |
|---|---|
| `TP1_TD1/` | `tp1_sujet`, `R3.L01_TD1.pdf`, `PGM.txt`, `corrigé_TD.txt` (tes notes), `note.txt` (modalités), `chat.pgm`, `chat_lunettes.pgm`, **`TP1_explications.pdf`**, `walkthrough.md` |
| `TP2_TD2/` | `TP2.txt`, `R3.L01_TD2.pdf`, `PPM.txt`, `corrige_prof.txt`, image attendue, **`TP2_explications.pdf`**, `walkthrough.md`, **`td2_endianness.cpp`** (exercice 2 du TD2, à compiler pour t'entraîner) |
| `TP3_TD3/` | `TP3.TXT`, `corrige_prof.txt` (corrigé du TD3), `libjpeg.txt`, `jpeg_example.c`, image attendue, **`TP3_explications.pdf`**, `walkthrough.md`, `jpegsrc.v10/` (sources de la libjpeg, pour référence seulement) |
| `TP4/` | `tp4.txt`, `TGA.pdf`, `tgaffs.pdf`, `Opérateurs_logiques.pdf`, `images/` (toutes les images d'exemple), **`TP4_explications.pdf`**, `walkthrough.md` |
| `TP5/` | `tp5.txt`, image attendue, **`TP5_explications.pdf`**, `walkthrough.md` |

### `_ARCHIVE_GEMINI/` et `_sources_pdf/`

- `_ARCHIVE_GEMINI/` : l'ancien code et les anciens PDF de Gemini, déplacés et pas supprimés. Inutile pour réviser, à effacer quand tu veux.
- `_sources_pdf/` : les PDF écrits en HTML (`tp1.html` … `revision.html`), la mise en page (`style.css`), les images des schémas (`img/`) et le script `build.py`. Commande : `python3 build.py`, il faut Chromium. Inutile pour réviser.

---

## 2. Conformité aux consignes, question par question

Légende : ✅ fait et testé · ➕ bonus du sujet, fait · ℹ️ remarque

### TP1 / TD1 : GrayImage et PGM

| Demandé (sujet / TD / cours) | Où | État |
|---|---|---|
| Classe du CM : `const uint16_t width, height`, `uint8_t* array`, `GrayImage() = delete`, `operator= = delete`, constructeurs, copie, destructeur (CM 26-27) | `Image.hpp`, `Image.cpp` | ✅ |
| `getWidth()`, `getHeight()`, `pixel(x,y)` en modification et en consultation `const` (CM 28) | `Image.hpp` | ✅ |
| Gestion d'erreur par exceptions dans toutes les fonctions | partout | ✅ `invalid_argument`, `out_of_range`, `runtime_error` |
| `void clear(uint8_t gray = 0)` | `Image.cpp` | ✅ |
| `void rectangle(x,y,w,h,gray)` : cadre d'un pixel | `Image.cpp` | ✅ |
| `void fillRectangle(x,y,w,h,gray)` | `Image.cpp` | ✅ |
| TD1 Q2 : `void writePGM(std::ostream&) const`, 1ʳᵉ ligne de commentaire « Image sauvegardée par XXX pour les TP de RepCod. » | `Image.cpp` | ✅ avec ton nom (constante `AUTEUR`) |
| TD1 Q3 : `void skip_line(std::istream&)` | `Image.cpp` | ✅ |
| TD1 Q4 : `void skip_comments(std::istream&)` avec `putback` | `Image.cpp` | ✅ écrite comme le TD la décrit |
| TD1 Q5 : `static GrayImage* readPGM(std::istream&)` | `Image.cpp` | ✅ |
| Test : image non carrée, `clear`, rectangles, `writePGM` | `tp1.cpp` | ✅ `tp1_rectangles.pgm` (400 × 250) |
| Test : lire `chat.pgm`, dessiner, réécrire **sous un autre nom** | `tp1.cpp` | ✅ `tp1_chat_lunettes.pgm`, **identique pixel pour pixel** à `chat_lunettes.pgm` |
| Bonus : lecture P2 (ASCII pur) | `Image.cpp` | ➕ testé avec `Rafale30000.pgm` |
| « `writeFormat` … PGM, TGA, JPEG » pour les gris (sujet TP1) | `Image.cpp` | ➕ `writeJPEG`/`readJPEG` et `writeTGA`/`readTGA` (sous-formats 3 et 11) pour GrayImage |

### TP2 / TD2 : Color, ColorImage, PPM, rééchantillonnage

| Demandé | Où | État |
|---|---|---|
| Color et ColorImage **dans les mêmes fichiers** `Image.hpp`/`Image.cpp` | `Image.*` | ✅ |
| Color du CM : `r, g, b` publics, constructeur `inline` à 0 par défaut, `operator==` (indispensable à la correction), `operator*(double, Color)`, `operator+(Color, Color)` | `Image.*` | ✅ arrondi et saturation à 255 |
| Mêmes fonctions élémentaires que GrayImage, `clear(Color color = Color())` (noir par défaut) | `Image.*` | ✅ |
| TD2 Q2 : `writePPM` avec la ligne « Image sauvegardée par XXX… » | `Image.cpp` | ✅ |
| TD2 Q3 : `static ColorImage* readPPM(std::istream&)` (P6) | `Image.cpp` | ✅ |
| Bonus : lecture P3 | `Image.cpp` | ➕ testé avec `Rafale30000.ppm` |
| Test : `chat.ppm` + rectangles colorés → `tp2_chat.ppm` | `tp2.cpp` | ✅ |
| `ColorImage* simpleScale(uint16_t w, uint16_t h) const`, programme **`tp2.cpp`**, `chat_petit.ppm` → 823 × 400 → `tp2_simple.ppm` | `Image.cpp`, `tp2.cpp` | ✅ formule du corrigé du TD3 |
| `ColorImage* bilinearScale(uint16_t w, uint16_t h) const` → `tp2_bilinear.ppm`, avec les opérateurs de Color pour garder la formule du TD | `Image.cpp`, `tp2.cpp` | ✅ |
| Correction du décalage d'un demi-pixel (facultative) | `Image.cpp` (`bilinear_coord`) | ➕ faite : simple et bilinéaire sont alignés |
| Même chose sur GrayImage (`chat_petit.pgm`) | `Image.cpp`, `tp2.cpp` | ✅ (le corrigé du TD3 est écrit pour GrayImage) |
| Exceptions, en particulier en lecture et écriture | `Image.cpp` | ✅ |
| TD2 ex. 2 (`swap_bytes`, lecture big endian, version portable) | `REVISION_CONTROLE_TD_R3L01.pdf`, `TP2_TD2/td2_endianness.cpp` | ✅ corrigé et programme testable |
| TD2 ex. 3 (tailles en mémoire, débit UHD) | `REVISION_CONTROLE_TD_R3L01.pdf` | ✅ calculs détaillés |

### TD3 : rééchantillonnage

| Demandé | Où | État |
|---|---|---|
| `simpleScale` (plus proche voisin) | `Image.cpp`, fiche de révision | ✅ comme le corrigé pris en TD |
| `bilinearScale` | `Image.cpp`, `TP2_explications.pdf`, fiche de révision | ✅ ℹ️ le prof ne l'a pas corrigé au tableau : c'est la formule bilinéaire standard (deux interpolations horizontales puis une verticale), celle qu'attend le sujet du TP2 |

### TP3 : JPEG avec libjpeg

| Demandé | Où | État |
|---|---|---|
| `extern "C" { #include <jpeglib.h> }`, compilation avec `-ljpeg` | `Image.cpp`, `Makefile` | ✅ |
| `void writeJPEG(const char* fname) const`, puis avec `unsigned int quality`, `jpeg_set_quality(&cinfo, quality, TRUE)` juste avant la compression | `Image.cpp` | ✅ |
| Valeur par défaut 75 dans le `.hpp` | `Image.hpp` | ✅ |
| **Pas** de gestionnaire d'erreur `setjmp` comme dans l'exemple C : utiliser les exceptions | `Image.cpp` (`jpeg_error_to_exception`) | ✅ testé : un PPM lu comme un JPEG lève une exception au lieu d'arrêter le programme |
| Test : PPM + rectangles colorés → JPEG | `tp3.cpp` | ✅ `tp3_chat.jpg`, mêmes cadres que la figure du sujet |
| Boucle des 21 qualités (`out_000.jpg` … `out_100.jpg`) avec `<iomanip>` et `<sstream>` | `tp3.cpp` | ✅ code du sujet recopié tel quel |
| Observation : taille à 75 % = taille par défaut | — | ✅ 18 908 octets dans les deux cas |
| Lecture JPEG | `Image.cpp` | ➕ `readJPEG` (couleur et gris) |

### TP4 : Targa (TGA)

| Demandé | Où | État |
|---|---|---|
| Seulement les couleurs 24 bits ; tout cas non géré → exception dérivée de `std::exception` | `Image.cpp` | ✅ 16/32 bits, autre sous-format, droite à gauche, entrelacé, fichier tronqué, indice de palette invalide |
| `void writeTGA(ostream& f) const` en sous-format 2 | `Image.cpp` | ✅ |
| `static ColorImage* readTGA(istream& f)` en sous-format 2 ; relire n'importe quelle image et la réécrire | `Image.cpp`, `tp4.cpp` | ✅ |
| Lecture du sous-format 1 (palette 24 bits), convertie en RGB | `Image.cpp` | ✅ `palette_bl`, `palette_tl`, `chat010couleurs` |
| `void writeTGA(ostream& f, bool rle = true) const` : sous-format 10 si vrai | `Image.*` | ✅ |
| Vérification | `tp4.cpp` | ✅ chaque fichier écrit est relu identique par notre code **et** par ImageMagick |
| Lecture du sous-format 10 | `Image.cpp` | ➕ (nécessaire pour vérifier l'écriture) |

### TP5 : Bresenham

| Demandé | Où | État |
|---|---|---|
| `void ColorImage::line(ushort x1, ushort y1, ushort x2, ushort y2, const Color pixel_value)` | `Image.*` | ✅ `ushort` = `uint16_t` |
| Test octant 1 : 400 × 400, fond rouge, segments verts de (0,0) vers le bord droit tous les 10 pixels | `tp5.cpp` | ✅ **identique** à l'image du sujet |
| Test octants 1 et 2 : en plus, vers le bord bas | `tp5.cpp` | ✅ **identique** à l'image du sujet |
| Généralisation (`incX`/`incY` = ±1, longueurs positives, boucle sur un compteur) | `Image.cpp` | ✅ |
| Test complet : 500 × 500 noir, centre (250,250), rayon 200, pas de 5°, `<cmath>`, `M_PI`, radians | `tp5.cpp` | ✅ ℹ️ quelques extrémités diffèrent d'1 pixel de la figure (arrondi de cos/sin) |

### Points de cours appliqués dans le code

| Cours | Dans le code |
|---|---|
| `ios::binary` à l'ouverture (CM 9) | tous les `ifstream`/`ofstream` des tests |
| `write`/`read` par bloc (CM 20-21) | pixels PGM/PPM |
| Padding (CM 14) | `static_assert(sizeof(Color) == 3)` avant d'écrire le tableau de Color en bloc |
| Endianness (CM 15-19, TD2) | TGA : entiers 16 bits little endian écrits et lus avec décalages et masques (portable) |
| Piège `cout << uint8_t` (CM 13) | conversion `(unsigned int)` dans les affichages |
| `<cstdint>` (CM 12) | `uint8_t`, `uint16_t`, `uint32_t` partout |
| Tableau à plat `y × width + x` (CM 25) | `pixel()` |

---

## 3. Compiler, tester, nettoyer

Il faut `g++` et la bibliothèque JPEG (`sudo apt install libjpeg-dev` sur Debian/Ubuntu).

### Avec le Makefile

```bash
cd PROJET_FINAL
make            # compile les 5 programmes
make tp2        # compile seulement le TP2
./tp2           # lance le test du TP2
make test       # compile tout puis lance les 5 tests
make -n tp1     # AFFICHE les commandes sans les lancer (pour comprendre)
make clean      # supprime tout ce qui a été produit
```

### À la main (ce que tu feras en TP)

```bash
cd PROJET_FINAL
g++ -std=c++11 -Wall -Wextra Image.cpp tp1.cpp -o tp1 -ljpeg
./tp1
```

Pour un autre TP, remplace `tp1` par `tp2`, `tp3`… Le `-ljpeg` est nécessaire à chaque fois
(le code JPEG est dans `Image.cpp`).

### Les deux étapes de la compilation

```
          ÉTAPE 1 : compilation (g++ -c)        ÉTAPE 2 : édition de liens
Image.cpp ───────────────► Image.o ──┐
                                     ├──► g++ -o tp1 tp1.o Image.o -ljpeg ──► tp1
tp1.cpp   ───────────────► tp1.o  ───┘                       ▲
                                                             └── libjpeg
```

- **Étape 1** : chaque `.cpp` est traduit seul en fichier objet `.o`. Erreurs typiques : syntaxe, type, fonction non déclarée.
- **Étape 2** : on assemble les `.o` et les bibliothèques en un exécutable. Erreur typique : `undefined reference to jpeg_…` si on oublie `-ljpeg`.
- `Image.o` est fabriqué une seule fois et sert aux 5 programmes : si tu modifies seulement `tp3.cpp`, seul `tp3.o` est recompilé.

| Option | Rôle |
|---|---|
| `-std=c++11` | norme du cours (`= delete`, `nullptr`, `<cstdint>`) |
| `-Wall -Wextra` | affiche les avertissements |
| `-c` | compiler sans édition de liens (produit un `.o`) |
| `-o nom` | nom du fichier produit |
| `-ljpeg` | lier avec libjpeg |

### Le Makefile expliqué

```makefile
CXX      = g++                       # le compilateur
CXXFLAGS = -std=c++11 -Wall -Wextra  # options de l'étape 1
LDLIBS   = -ljpeg                    # bibliothèques de l'étape 2
PROGS    = tp1 tp2 tp3 tp4 tp5

all: $(PROGS)                        # 1re règle = ce que fait « make » tout court

tp%: tp%.o Image.o                   # étape 2, pour tp1 … tp5 (% = joker)
	$(CXX) -o $@ $^ $(LDLIBS)        # $@ = la cible (tp3), $^ = les dépendances (tp3.o Image.o)

%.o: %.cpp Image.hpp                 # étape 1 ; si Image.hpp change, tout est recompilé
	$(CXX) $(CXXFLAGS) -c $<         # $< = la 1re dépendance (le .cpp)

test: all                            # compile, puis lance les 5 tests
	./tp1 && ./tp2 && ./tp3 && ./tp4 && ./tp5

clean:                               # supprime ce qui est produit, jamais le code ni images/
	rm -f *.o $(PROGS) tp1_*.pgm tp2_*.p?m tp3_* out_*.jpg tp4_* tp5_*.ppm

.PHONY: all test clean               # ce sont des actions, pas des fichiers
.PRECIOUS: %.o                       # garder les .o
```

`make` ne refait que ce qui est plus ancien que ses dépendances. Les lignes de commande
commencent par une **tabulation** (sinon : erreur `missing separator`).

### Ce que produit chaque test

| Programme | Fichiers produits | Ce qu'il faut voir |
|---|---|---|
| `./tp1` | `tp1_rectangles.pgm`, `tp1_chat_lunettes.pgm`, `tp1_rafale.pgm` | « 0 pixel(s) différent(s) », en-têtes souples « 10 35 et 10 35 », 2 exceptions attendues |
| `./tp2` | `tp2_chat.ppm`, `tp2_simple.ppm/.pgm`, `tp2_bilinear.ppm/.pgm`, `tp2_rafale.ppm` | blocs (simple) contre dégradés (bilinéaire) ; `0.5*(…) + 0.5*(…) = (150,100,129)` |
| `./tp3` | `tp3_chat.ppm`, `tp3_chat.jpg`, `tp3_chat_gris.jpg`, `out_000.jpg` … `out_100.jpg` | taille et qualité des JPEG ; l'exception libjpeg |
| `./tp4` | `tp4_chat_brut.tga`, `tp4_chat_rle.tga`, `tp4_chat_bandeau_rle.tga`, `tp4_palette_*.tga`, `tp4_chat10_*.tga`, `tp4_chanel.ppm`, `tp4_chat_gris_*.tga` | tailles affichées ; toutes les relectures « identique : oui » |
| `./tp5` | `tp5_octant1.ppm`, `tp5_octants12.ppm`, `tp5_cercle.ppm` | comparer à `images/tp5_im1/2/3.png` |

Pour voir les images : `eog fichier.ppm`, ou `eog *.ppm` puis les flèches gauche/droite pour les faire alterner.

### Avant de rendre

```bash
cd PROJET_FINAL
make test      # tout doit passer
make clean     # ne rendre que le code
```

On rend `Image.hpp`, `Image.cpp`, `tp1.cpp` … `tp5.cpp`, `Makefile` (et `images/` si le prof
veut pouvoir lancer les tests).

---

## 4. Méthode de révision

### Pour chaque TP, dans cet ordre

1. Lire le **sujet** et le **TD** du dossier `TPx/`.
2. Lire **`TPx/TPx_explications.pdf`** : le pourquoi de chaque choix, des schémas, ce qui était faux dans la version de Gemini, et les questions possibles au contrôle (dernière page).
3. Ouvrir **`PROJET_FINAL/Image.cpp`** à la partie du TP (titres `// TP1`, `// TP2`…) et relier le code au PDF.
4. **Compiler et lancer** `./tpN`, regarder les images produites.
5. **Modifier, casser, recompiler** dans une **copie** du projet (voir ci-dessous).
6. **Réécrire sur papier, de mémoire,** les fonctions du TD : c'est ce que demande le contrôle.

### Planning conseillé avant le 14/10

| Jour | Quoi | Documents |
|---|---|---|
| 1 | TP1 + TD1 : GrayImage, PGM, lire un dump hexadécimal | `TP1_TD1/R3.L01_TD1.pdf`, `TP1_explications.pdf`, `tp1.cpp` |
| 2 | TP2 + TD2 ex. 1 : Color, PPM, rééchantillonnage (TD3) | `TP2_explications.pdf`, `tp2.cpp` |
| 2 bis | TD2 ex. 2 et 3 : endianness, `swap_bytes`, tailles, débits | fiche de révision, `TP2_TD2/td2_endianness.cpp` |
| 3 | Le reste du cours : couleurs, palette, échantillonnage, compression, formats, vectoriel | `REVISION_CONTROLE_TD_R3L01.pdf` |
| 4 | TP3 (JPEG) et TP4 (TGA, RLE) | `TP3_explications.pdf`, `TP4_explications.pdf` |
| 5 (veille) | TP5, puis les **exercices** de la fin de la fiche, sans regarder le corrigé | `TP5_explications.pdf`, fiche de révision |

Les TP3 à TP5 servent surtout au **contrôle pratique**, mais RLE, les octets d'un en-tête TGA
et la chaîne JPEG peuvent tomber au contrôle de TD.

### S'entraîner sans abîmer le rendu

```bash
cp -r PROJET_FINAL ~/Documents/entrainement_R3L01
cd ~/Documents/entrainement_R3L01
```

Idées d'exercices dans la copie :

| Exercice | Comment vérifier |
|---|---|
| Vider `readPGM` et la réécrire | `./tp1` doit afficher « 0 pixel(s) différent(s) » |
| Remplacer `is >> std::ws` par rien | `./tp1` échoue sur `chat.pgm` : tu vois le piège des commentaires |
| Remplacer `is.get()` après 255 par `is >> std::ws` | le test « en-têtes souples » n'affiche plus « 10 35 » : le pixel 10 (= LF) a été avalé |
| Réécrire `simpleScale` / `bilinearScale` | comparer avec les images produites avant |
| Retirer la saturation de `operator+` | des pixels clairs deviennent sombres |
| Réécrire `writeTGA` en RLE | `./tp4` : « relecture RLE identique : oui » |
| Réécrire `line` | comparer avec `images/tp5_im1.png` et `tp5_im2.png` |

### Le TD2 en pratique

```bash
cd TP2_TD2
g++ -std=c++11 -Wall -Wextra td2_endianness.cpp -o td2 && ./td2
od -An -tx1 data.dat    # les octets du fichier big endian fabriqué (fb 2e = -1234)
```

---

## 5. Pièges à connaître (cours, TD, sujets)

| Piège | Bonne pratique |
|---|---|
| Oublier `std::ios::binary` | toujours en 2ᵉ argument de `ifstream`/`ofstream` (CM 9) |
| Écrire les pixels avec `<<` | `<<` pour l'en-tête texte, `write` pour les pixels |
| `>>` après 255 | **un seul** `is.get()` : un pixel peut valoir 10 (LF) ou 32 (espace) |
| `is >> w >> h` laisse le LF | sauter les blancs avant `skip_comments`, sinon les commentaires de `chat.pgm` cassent la lecture |
| `cout << u` avec `uint8_t u` | affiche un caractère : `cout << (unsigned int)u` |
| `for (uint8_t i = 0; i <= 255; i++)` | boucle infinie |
| `width * height` en `int` | `size_t(width) * height` |
| Écrire une structure d'un bloc | padding et endianness recopiés : lire/écrire champ par champ |
| `std::string('X', n)` | l'ordre est `std::string(n, ' ')` |
| Copier une image sans constructeur de copie | double `delete[]` : copie profonde obligatoire |
| `readPGM` non `static` | elle crée l'image : `static` |
| TGA : RGB | l'ordre est **b, g, r** ; entiers 16 bits en little endian ; bit 5 du descripteur = origine en haut |
| libjpeg : gestionnaire par défaut | il appelle `exit()` : le remplacer par une exception |
| `jpeg_set_defaults` avant `in_color_space` | régler l'espace de couleur **avant** |
| `cos(5)` | en **radians** : `5 * M_PI / 180` |
| Rééchantillonnage en parcourant l'image de départ | parcourir l'image **d'arrivée**, sinon des trous |
| `Color + Color` en `uint8_t` | 200 + 100 = 44 : saturer à 255 |

---

## 6. Limites connues

- **TD3, partie bilinéaire** : pas corrigée au tableau ; la formule utilisée est la formule standard.
- **TP5, cercle** : quelques extrémités diffèrent d'un pixel de la figure du sujet, à cause de l'arrondi de cos/sin ; les deux autres tests sont identiques au pixel près.
- **Figures du CM** (arbre de Huffman, schémas JPEG) : à relire dans `R3.L01_CM.pdf`, elles ne sont pas reprises telles quelles.
