# Guide du TP noté R3.L01 (vendredi 06/11/2026)

Compiler, ajouter un exercice, justifier chaque outil, réviser chaque TP.
Le code à rendre est dans `PROJET_FINAL/`.

**Abréviations** : CM n = diapo n de `R3.L01_CM.pdf`. TD1 Qn = question n de `R3.L01_TD1.pdf`.
« Corrigé TD1 » = `TP1_TD1/corrigé_TD.txt`, « corrigé TD2 » = `TP2_TD2/corrige_prof.txt`,
« corrigé TD3 » = `TP3_TD3/corrige_prof.txt`.

---

## 1. Compiler

### Une seule fois : installer le compilateur et libjpeg

```bash
sudo apt install g++ make libjpeg-dev
```

Sans `libjpeg-dev`, la compilation s'arrête sur `jpeglib.h: Aucun fichier ou dossier`.
Le sujet du TP3 écrit `libjpeg62 libjpeg62-dev` : sous Ubuntu récent, `libjpeg-dev` fait le même travail.

### Le plus simple : le Makefile

Toujours **depuis `PROJET_FINAL/`**, car les tests ouvrent `images/...` en chemin relatif.

```bash
cd PROJET_FINAL
make            # compile les 5 programmes
make test       # compile puis lance les 5 tests
make tp3        # compile seulement le TP3
./tp3           # lance le TP3
make clean      # supprime les fichiers produits (jamais le code ni images/)
```

### À la main, comme dans le sujet du TP3

Le sujet donne deux étapes : la compilation (`-c`), puis l'édition de liens (`-ljpeg`).

```bash
g++ -std=c++11 -Wall -Wextra -c Image.cpp      # fabrique Image.o
g++ -std=c++11 -Wall -Wextra -c tp1.cpp        # fabrique tp1.o
g++ -o tp1 tp1.o Image.o -ljpeg                # assemble le programme tp1
./tp1
```

`-ljpeg` est nécessaire pour **tous** les TP, car `Image.cpp` contient le code JPEG.
`-std=c++11` : le cours utilise le C++ 2011 (CM 12, CM 26).

### Si ça ne compile pas

| Message | Cause | Solution |
|---|---|---|
| `jpeglib.h: Aucun fichier ou dossier` | libjpeg-dev manquant | installer, ou plan B ci-dessous |
| `undefined reference to jpeg_...` | `-ljpeg` oublié | l'ajouter à la fin de la ligne d'édition de liens |
| `undefined reference to ColorImage::...` | fonction déclarée dans le `.hpp` mais absente du `.cpp`, ou `Image.o` oublié | écrire la fonction, ou ajouter `Image.o` |
| `'...' is not a member of 'ColorImage'` | fonction absente du `.hpp` | la déclarer dans la classe |
| `missing separator` (Makefile) | espaces au lieu d'une tabulation | mettre une tabulation |
| `impossible d'ouvrir images/...` à l'exécution | lancé depuis le mauvais dossier | `cd PROJET_FINAL` |
| `M_PI was not declared` (possible sous Windows, **non testé**) | `-std=c++11` strict | compiler avec `-std=gnu++11` |

### Plan B : libjpeg absente du VDI et pas de droits root

On compile la bibliothèque fournie dans `TP3_TD3/jpegsrc.v10/jpeg-10`. Testé sur ce PC, sans root :
les 5 TP passent. `tp3_chat.jpg` fait alors 19 022 octets au lieu de 18 908, car la version de la
bibliothèque diffère. Les fichiers qualité défaut et qualité 75 restent de même taille.

```bash
cd TP3_TD3/jpegsrc.v10/jpeg-10
sh ./configure --prefix=$HOME/jpeg --disable-shared
make && make install
cd ../../../PROJET_FINAL
make test CXXFLAGS="-std=c++11 -Wall -Wextra -I$HOME/jpeg/include" LDLIBS="-L$HOME/jpeg/lib -ljpeg"
```

Sous Windows, le sujet du TP3 donne les options à utiliser avec le disque réseau (**non testé**) :

```
g++ -Wall -IL:\GnuWin32\include -c programme.cpp
g++ -Wall -LL:\GnuWin32\lib -o programme programme.o -ljpeg
```

Il faut aussi ajouter `L:\GnuWin32\bin` au `PATH`.

---

## 2. Ajouter un exercice du prof

Trois endroits à modifier, toujours dans le même ordre (`note.txt`, sujet du TP2 : mêmes fichiers).
Exemple testé : le négatif d'une image.

**1. `Image.hpp`, dans la partie `public:` de la classe : la déclaration**

```cpp
void invert();
```

**2. `Image.cpp`, à la fin : le code, avec `ColorImage::` devant le nom**

```cpp
void ColorImage::invert()
{
  for (uint16_t y = 0; y < height; y++)
    for (uint16_t x = 0; x < width; x++) {
      Color& c = pixel(x, y);
      c = Color(255 - c.r, 255 - c.g, 255 - c.b);
    }
}
```

**3. `tp6.cpp`, nouveau fichier : le test, sur le modèle des autres `tpN.cpp`**

```cpp
#include "Image.hpp"
#include <fstream>
int main()
{
  try {
    std::ifstream ifs("images/chat.ppm", std::ios::binary);
    ColorImage* im = ColorImage::readPPM(ifs);
    im->invert();
    std::ofstream ofs("tp6_negatif.ppm", std::ios::binary);
    im->writePPM(ofs);
    delete im;
  } catch (const std::exception& e) {
    std::cerr << "Erreur : " << e.what() << std::endl;
    return 1;
  }
  return 0;
}
```

**4. Compiler et lancer** : rien à changer dans le Makefile.

```bash
make tp6 && ./tp6
```

`make clean` ne supprime pas `tp6` ni `tp6_*` : `rm tp6 tp6_*`.

**Réflexes :**

- Respecter **exactement** le nom et le prototype donnés par le prof (`note.txt`).
- Ajouter `const` si la fonction ne modifie pas l'image (`simpleScale`, `writePPM`).
- `static` si elle fabrique une image sans en avoir déjà une (TD1, Rappel).
- Si elle crée une image : `new`, on renvoie l'adresse, et le test fait `delete`.
- Vérifier les paramètres et lever une exception si c'est impossible (sujet du TP1).
- Coller les messages d'erreur à ce qui existe déjà : `throw std::runtime_error("...")`.

---

## 3. Justification de chaque outil

### Base commune

| Outil | Où dans le code | Source |
|---|---|---|
| `uint8_t`, `uint16_t`, `uint32_t`, `<cstdint>` | partout | CM 12 |
| `size_t` pour la taille des tableaux | constructeurs, boucles | CM 10, CM 27 |
| `std::ofstream` / `std::ifstream` avec `std::ios::binary`, fermeture par le destructeur | tests | CM 9 |
| `os.put(char)` | TGA | CM 18 |
| `is.get(char&)` | `skip_*`, `read_byte` | CM 19, TD1 Q4 |
| `is.get()` sans argument | après 255 | corrigé TD1 (`c = is.get()`) |
| `os.write` / `is.read` | pixels PGM, PPM | CM 20, CM 21 |
| `<<` pour l'en-tête, `>>` qui saute les blancs | PGM, PPM | CM 8, corrigés TD1 |
| `is.putback(c)` | `skip_comments`, `skip_blanks` | TD1 Q4 |
| Tableau à plat `y * width + x` | `pixel()` | CM 25 |
| `(unsigned int)` avant d'afficher un `uint8_t` | tests | CM 13 |
| `throw std::runtime_error` | partout | corrigé TD1 |
| Exceptions : toutes les fonctions, classes bien choisies (`out_of_range`, `invalid_argument`, `runtime_error`) | partout | sujet TP1, sujet TP2, sujet TP4 |
| `std::string` | `magic`, messages | corrigés TD1 et TD2 |

### TP1 / TD1

| Élément | Source |
|---|---|
| `const uint16_t width, height`, `uint8_t* array`, `= delete` | CM 26 |
| Constructeurs, copie, destructeur, `nullptr`, `delete[]` | CM 27 |
| `getWidth`, `getHeight`, `pixel` (2 versions), `inline` | CM 28 |
| Contrôle `x >= width` dans `pixel` | sujet TP1 : exceptions « dans toutes ses fonctions » |
| `clear`, `rectangle`, `fillRectangle` | sujet TP1 |
| `writePGM` et le commentaire « Image sauvegardée par XXX pour les TP de RepCod. » | TD1 Q2 |
| `skip_line` | TD1 Q3 |
| `skip_comments` | TD1 Q4 |
| `skip_blanks` (blancs de l'en-tête) | PGM.txt « Whitespace (blanks, TABs, CRs, LFs) » et « as lenient as possible ». Écrite seulement avec `get` et `putback` (TD1 Q4). Nécessaire : `chat.pgm` a des commentaires après les dimensions |
| `static readPGM` | TD1 Q5 et Rappel |
| Un seul `is.get()` après 255 | corrigé TD1, PGM.txt « only a single character of whitespace » |
| Seul 255 accepté | TD1 « pour nos TP, ce sera 255 » |
| Lecture P2 | sujet TP1 (points supplémentaires), CM 58 |

### TP2 / TD2 / TD3

| Élément | Source |
|---|---|
| Classe `Color`, `friend`, `==`, `*`, `+` | CM 38 |
| `ColorImage` : même code que `GrayImage` | CM 39, sujet TP2 |
| `clear(Color color = Color())` | sujet TP2 |
| `writePPM`, `readPPM` | TD2 ex. 1 Q2 et Q3, PPM.txt |
| Écriture du tableau de `Color` d'un bloc | CM 20, CM 14 : trois `uint8_t`, donc pas de remplissage |
| Lecture P3 | sujet TP2 (points supplémentaires) |
| `simpleScale` : parcours de l'arrivée, `x = x' * width / w` | corrigé TD3 |
| `uint32_t` dans ce calcul | CM 12 : évite le débordement |
| `bilinearScale`, `double * Color`, `Color + Color` | sujet TP2, CM 38 (voir limites) |
| Correction du demi-pixel `-0,5` / `+0,5` | sujet TP2 |

### TP3

| Élément | Source |
|---|---|
| `extern "C" { #include <jpeglib.h> }`, `-ljpeg` | sujet TP3 |
| `writeJPEG(const char*, unsigned int quality)`, défaut 75 dans le `.hpp` | sujet TP3 |
| `<cstdio>` avant `jpeglib.h` | `libjpeg.txt` l. 738, `jpeg_example.c` l. 16 |
| `fopen(..., "wb")` | `jpeg_example.c` l. 111-114 |
| `jpeg_create_compress`, `jpeg_stdio_dest` | `libjpeg.txt` l. 269, 301 |
| `image_width`, `input_components`, `in_color_space`, avant `jpeg_set_defaults` | `libjpeg.txt` l. 324-354 |
| `jpeg_set_quality(&cinfo, quality, TRUE)` | sujet TP3 |
| Boucle sur `next_scanline`, `JSAMPROW`, `row_pointer` | `libjpeg.txt` l. 397-411 |
| `jpeg_finish_compress`, `jpeg_destroy_compress` | `libjpeg.txt` l. 314, 467 |
| Remplacer `error_exit`, sans `setjmp` | sujet TP3 + `jpeg_example.c` l. 235-263, `libjpeg.txt` l. 1312 |
| `format_message` pour le texte de l'erreur | `libjpeg.txt` l. 1326 |
| `<iomanip>`, `<sstream>`, boucle des 21 qualités | sujet TP3, recopié |
| `readJPEG` (bonus) | `libjpeg.txt` l. 509 et suivantes, `jpeg_example.c` l. 332-372 |

### TP4

| Élément | Source |
|---|---|
| En-tête 18 octets, entiers « lo-hi » | `TGA.pdf` p. 1 |
| Écriture little endian avec décalages | CM 15, CM 18, `Opérateurs_logiques.pdf` p. 1 |
| Ordre bleu, vert, rouge ; descripteur | `TGA.pdf` p. 2 |
| Sous-format 1 (palette) | `TGA.pdf` p. 1, CM 40, sujet TP4 |
| Palette dans un tableau `new Color[...]` | CM 27 |
| Sous-format 2 | `TGA.pdf` p. 3 |
| Sous-format 10, paquets limités à une ligne | `TGA.pdf` p. 6, CM 59 |
| Paquets RLE | `tgaffs.pdf` p. 27 |
| Sous-formats 3 et 11 pour les gris | `tgaffs.pdf` p. 3, sujet TP1 (« TGA ») |
| `writeTGA(ostream&, bool rle = true)` | sujet TP4 |
| Exception pour tout cas non géré | sujet TP4 |

### TP5

| Élément | Source |
|---|---|
| `c1`, `c2`, `critère`, octants 1 et 2 | sujet TP5, pseudo-code recopié |
| `incX`, `incY`, longueurs positives, boucle sur un compteur | sujet TP5, généralisation |
| `<cmath>`, `cos`, `sin`, `M_PI`, radians | sujet TP5 |
| `uint16_t` à la place de `ushort` | même type (16 bits non signé), CM 12 |
| `+ 0.5` pour arrondir | le sujet n'impose pas d'arrondi (voir limites) |

---

## 4. Ce qui ne vient pas directement d'un document

À connaître si le prof pose la question.

1. **Formule bilinéaire.** Le corrigé du TD3 s'arrête au prototype, et le prof ne l'a pas corrigée au
   tableau. Le code utilise la formule standard (2 interpolations horizontales, 1 verticale). Le sujet
   du TP2 exige seulement de ne pas changer « la formule vue en TD ». **Si un camarade a une autre
   version du TD3, compare.**
2. **Arrondi et saturation dans `Color`.** Le CM 38 demande les opérateurs sans fixer ce détail.
   Choix fait : arrondi au plus proche, et 200 + 100 donne 255 (plage de `uint8_t`, CM 12).
3. **`catch (...)` et `throw;`** pour libérer la mémoire puis relancer. Le sujet TP4 renvoie au
   « cours de C++ », qui n'est pas dans ce dossier : non vérifiable ici.
4. **Lancer une exception depuis `error_exit`.** Le sujet demande les exceptions, sans donner le code.
   Ça marche ici (`./tp3` affiche « exception attendue »). **À vérifier sur le VDI.**
5. **`operator!=`.** Pas demandé (le CM 38 se termine par « ... »). Utile aux tests.
6. **Non demandé, ajouté** : `readJPEG`, JPEG et TGA pour les gris (annoncés au TP1), lecture du
   sous-format 10 (pour vérifier l'écriture).
7. **Le Makefile.** Pas demandé. Il lance les mêmes commandes que le sujet du TP3.
8. **Bases du langage** (`if`, `for`, fonctions, `new`, `static` dans un `.cpp`) : prérequis (TD1 :
   « Révisez votre C++ »).

### Écarts connus

- **TP5, cercle** : différent de `tp5_im3.png` (7 190 pixels sur 250 000). Le sujet ne dit pas comment
  arrondir. Les deux autres images du TP5 sont identiques au pixel près.
- **TP3 et TP5** portent la mention « facultatif » dans leur sujet, mais `note.txt` dit de tout rendre.
  Les deux sont faits.
- **VDI** : rien n'a été testé dessus.

---

## 5. Réviser chaque TP (environ 15 min par TP)

Pour chaque TP : lire le PDF, lancer le test, réécrire les fonctions clés **sans regarder**.
Pour t'entraîner sans abîmer le rendu : `cp -r PROJET_FINAL ~/Documents/entrainement_R3L01`.

### TP1 : GrayImage, PGM

- **Lire** : `TP1_TD1/TP1_explications.pdf`.
- **Lancer** : `./tp1`. Attendu : `0 pixel(s) différent(s)` et `10 35 et 10 35`.
- **Réécrire** : `rectangle`, `skip_comments`, `readPGM`.
- **Savoir dire** : pourquoi `readPGM` est `static` ; pourquoi un seul `get()` après 255 (un pixel peut
  valoir 10) ; pourquoi `ios::binary` ; pourquoi `operator=` est interdit.

### TP2 : Color, PPM, rééchantillonnage

- **Lire** : `TP2_TD2/TP2_explications.pdf`.
- **Lancer** : `./tp2`. Attendu : `(150,100,129)`. Faire alterner `tp2_simple.ppm` et `tp2_bilinear.ppm`.
- **Réécrire** : `operator+`, `operator*`, `simpleScale`, `bilinearScale`.
- **Savoir dire** : pourquoi parcourir l'image d'**arrivée** (sinon des trous) ; à quoi sert le
  demi-pixel ; pourquoi 200 + 100 poserait problème en `uint8_t`.

### TP3 : JPEG

- **Lire** : `TP3_TD3/TP3_explications.pdf`.
- **Lancer** : `./tp3`, puis `ls -l tp3_chat.jpg out_075.jpg` : **même taille**.
- **Réécrire** : les étapes de `writeJPEG`, dans l'ordre.
- **Savoir dire** : `extern "C"` ; le rôle de `-ljpeg` ; `in_color_space` avant `jpeg_set_defaults` ;
  pourquoi remplacer `error_exit` (par défaut, `exit()`).

### TP4 : TGA

- **Lire** : `TP4/TP4_explications.pdf`.
- **Lancer** : `./tp4` (tout à `oui`), puis `ls -l tp4_*` : `tp4_chat_brut.tga` 230 418 octets,
  `tp4_chat_rle.tga` 207 106 octets.
- **Réécrire** : l'en-tête de `writeTGA`, un paquet RLE, `store_tga_pixel`.
- **Savoir dire** : ordre b, g, r ; little endian avec `v & 0xFF` et `v >> 8` ; bit 7 du paquet et
  nombre - 1 ; bit 5 du descripteur ; 18 + 320 × 240 × 3 = 230 418.

### TP5 : Bresenham

- **Lire** : `TP5/TP5_explications.pdf`.
- **Lancer** : `./tp5`, puis comparer à `images/tp5_im1.png`, `tp5_im2.png`, `tp5_im3.png`.
- **Réécrire** : `line`, d'abord octant 1, puis généralisée.
- **Savoir dire** : le rôle de `critère` ; pourquoi `longX`, `longY` restent positives ; pourquoi un
  compteur ; pourquoi les radians.

### Le jour même, sur le VDI

```bash
cd PROJET_FINAL
make test
```

Puis vérifier les cinq « attendu » ci-dessus, et ouvrir une image avec `eog` ou `qiv`.
Avant de rendre : `make clean`, et rendre `Image.hpp`, `Image.cpp`, tous les `tpN.cpp`, le `Makefile`.
