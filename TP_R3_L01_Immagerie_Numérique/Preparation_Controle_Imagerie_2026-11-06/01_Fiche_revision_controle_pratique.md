# Fiche ciblée — contrôle pratique du 6 novembre 2026

Module : représentations et codages des images, E. Remy, IUT d'Arles.
Le contrôle de TD du 14 octobre est déjà passé. Cette fiche sert le **TP noté** : noms de fonctions, code à réécrire, pièges des sujets. La culture du cours (Huffman, YUV, débits) reste dans `REVISION_CONTROLE_TD_R3L01.pdf` si une question orale ou un petit calcul est ajouté pendant la séance.

Les notes de TD (`corrigé_TD.txt`, `corrige_prof.txt`) sont des prises de notes, avec des erreurs de transcription. En cas de conflit, le sujet PDF et le CM priment. Détail dans `06_Audit_conformite.md`.

## Signatures à savoir écrire

Le `note.txt` de séance insiste sur les noms. Les prototypes ci-dessous sont ceux des sujets et du CM (diapos 26 à 28 et 38).

```text
void skip_line(std::istream&);
void skip_comments(std::istream&);

void GrayImage::clear(uint8_t gray = 0);
void GrayImage::rectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint8_t gray);
void GrayImage::fillRectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint8_t gray);
void GrayImage::writePGM(std::ostream&) const;
static GrayImage* GrayImage::readPGM(std::istream&);

void ColorImage::clear(Color color = Color());
void ColorImage::rectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h, Color color);
void ColorImage::fillRectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h, Color color);
void ColorImage::writePPM(std::ostream&) const;
static ColorImage* ColorImage::readPPM(std::istream&);
ColorImage* ColorImage::simpleScale(uint16_t w, uint16_t h) const;
ColorImage* ColorImage::bilinearScale(uint16_t w, uint16_t h) const;

void ColorImage::writeJPEG(const char* fname, unsigned int quality = 75) const;
void ColorImage::writeTGA(std::ostream& f, bool rle = true) const;
static ColorImage* ColorImage::readTGA(std::istream& f);

void ColorImage::line(ushort x1, ushort y1, ushort x2, ushort y2, const Color pixel_value);
```

`ushort` est le mot du sujet TP5. Le CM et le code utilisent `uint16_t` (`<cstdint>`, diapo 12). Sur les machines du cours, `uint16_t` est un `unsigned short`. Si un squelette du contrôle écrit `ushort`, ajouter en tête :

```cpp
using ushort = uint16_t;
```

Fichiers imposés par le sujet du TP2 : les classes `Color` et `ColorImage` vont dans les **mêmes** `Image.hpp` et `Image.cpp`. Le TP3 dit de modifier `writeJPEG` dans ces fichiers. Un seul `main` par programme : `tp1.cpp` … `tp5.cpp`.

Commentaire obligatoire, première ligne de commentaire (TD1 question 2, TD2 question 2) :

```text
Image sauvegardée par XXX pour les TP de RepCod.
```

`XXX` est le nom. Dans le code actuel, `XXX` vaut `Mamadou Bailo BARRY`.

## GrayImage, tel que le CM l'écrit

Diapos 26-28. À pouvoir réécrire.

- `const uint16_t width, height` : la taille ne change pas, pas de réallocation.
- `uint8_t* array` : tableau à plat. Indice `t = y * width + x` (diapo 25).
- `GrayImage() = delete` et `operator=(const GrayImage&) = delete`.
- Constructeur : liste d'initialisation `width(w), height(h), array(nullptr)`, puis `array = new uint8_t[width * height]`. Les pixels ne sont pas initialisés : `clear` ou la lecture s'en charge.
- Copie profonde : un `new` et une boucle. Sinon deux destructeurs font `delete[]` sur le même tableau.
- `getWidth` / `getHeight` : `inline`, retournent `const uint16_t&`.
- `pixel` : deux versions, une `const`. Retour par référence, pour écrire `im.pixel(x,y) = 255`.

Le sujet du TP1 ajoute des exceptions dans toutes les fonctions. Le CM, lui, n'en met pas dans `pixel`. Le code du rendu vérifie les bornes avec `std::out_of_range`. C'est le sujet du TP, pas une invention.

`Color` (diapo 38) : `r, g, b` **publics**, constructeur inline à 0 par défaut, `operator==`, `operator*(double, Color)`, `operator+(Color, Color)`. Le prof dit que `==` est indispensable à la correction.

`ColorImage` : le même schéma en remplaçant `uint8_t` par `Color` (diapo 39). Le CM propose un `template` et l'héritage, et demande de ne pas le faire sauf un ou deux étudiants motivés. Le rendu ne le fait pas : c'est le choix demandé par défaut.

## PGM / PPM — la méthode du TD

Magic number : `P5` gris binaire, `P2` gris texte (bonus), `P6` couleur binaire, `P3` couleur texte (bonus). Puis des commentaires `#` jusqu'au LF, largeur hauteur, encore des commentaires, `255`, un séparateur, les pixels de gauche à droite et de haut en bas.

`chat.pgm` a des commentaires **après** les dimensions (`# Encore du bordel`). C'est le piège.

```cpp
void skip_line(std::istream& is)
{
  char c;
  while (is.get(c) && c != '\n') {}
}

void skip_comments(std::istream& is)
{
  char c;
  while (is.get(c) && c == '#')
    skip_line(is);
  if (is)
    is.putback(c);
}
```

`readPGM`, dans l'ordre qui marche sur `chat.pgm` :

1. `is >> magic` puis refuser si ce n'est ni `P5` ni, pour le bonus, `P2`.
2. `is >> std::ws` **puis** `skip_comments`. Sans le `ws`, le LF laissé par `>>` est relu, ce n'est pas un `#`, et les commentaires ne sont pas sautés.
3. `is >> w >> h`, encore `ws` puis `skip_comments`.
4. `is >> maxval`. Pour les TP, seulement 255.
5. `new GrayImage(w, h)`.
6. P5 : **un seul** `is.get()` (le blanc après 255), puis `is.read` du tableau. Un pixel peut valoir 10 (LF) ou 32 (espace). Un `>>` les avalerait. Le test du code affiche `10 35`.
7. P2 : des entiers en texte, séparés par des blancs.

`writePGM` : l'en-tête avec `<<`, les pixels avec `write` d'un bloc. Ouvrir le fichier avec `std::ios::binary` (CM diapo 9), sinon Windows réécrit les octets 10.

`readPGM` est `static` : elle crée l'image. Le TD1 appelle ça « le serpent qui se mord la queue » si on en fait une méthode d'instance.

PPM : même enchaînement, magic `P6`/`P3`, et `w*h*3` octets dans l'ordre r, g, b. `static_assert(sizeof(Color) == 3)` avant d'écrire le tableau d'un bloc : le CM (diapo 14) rappelle que le padding empêcherait cet écriture.

## Rééchantillonnage — ce qui a été écrit au tableau

Notes `TP3_TD3/corrige_prof.txt` et rappel du sujet TP2. On parcourt **l'image d'arrivée**, sinon des trous.

```cpp
GrayImage* GrayImage::simpleScale(uint16_t w, uint16_t h) const
{
  GrayImage* res = new GrayImage(w, h);
  for (uint16_t y_prime = 0; y_prime < h; y_prime++)
    for (uint16_t x_prime = 0; x_prime < w; x_prime++) {
      uint16_t x = uint16_t(uint32_t(x_prime) * width / w);
      uint16_t y = uint16_t(uint32_t(y_prime) * height / h);
      res->pixel(x_prime, y_prime) = pixel(x, y);
    }
  return res;
}
```

Le `uint32_t` évite le débordement de `x_prime * width` (le produit de deux `uint16_t` est calculé en `int` 32 bits sur les PC du cours ; le cast rend l'intention lisible). Exemple de la fiche : 80×60 vers 823×400, pixel d'arrivée (500, 200) → source (500×80/823, 200×60/400) = (48, 30).

Bilinéaire : le prof **n'a pas fini** le corrigé au tableau (le fichier s'arrête au prototype). La formule utilisée dans le code, et décrite dans `TP2_explications.pdf` comme la formule standard, est :

```text
haut   = (1 - ax) * P(x0, y0) + ax * P(x1, y0)
bas    = (1 - ax) * P(x0, y1) + ax * P(x1, y1)
valeur = (1 - ay) * haut + ay * bas
```

Pour `Color`, le sujet demande de ne pas changer cette formule : d'où `operator*` et `operator+`. Ces opérateurs arrondissent et saturent à 255, parce qu'une `Color` est en `uint8_t`. Conséquence : un résultat peut différer de 1 du calcul laissé en `double` jusqu'au bout. La version gris du code, elle, reste en `double` et arrondit à la fin (`v + 0.5`). Les deux respectent le cours ; elles ne donnent pas toujours le même arrondi.

Demi-pixel, **facultatif** (sujet TP2 : sans lui, « pratiquement tous les points ») :

```text
s = (p + 0.5) * src / dst - 0.5
```

Le code le fait. Si on demande la formule du tableau, écrire d'abord la division entière de `simpleScale`, puis la formule bilinéaire sans le 0,5.

## JPEG — le minimum du sujet TP3

```cpp
extern "C" {
#include <jpeglib.h> /* Ce sont des déclarations relatives à des fonctions C ! */
}
```

Compilation séparée de l'édition de liens, comme le sujet l'écrit :

```bash
g++ -Wall -c programme.cpp
g++ -Wall -o programme programme.o -ljpeg
```

`writeJPEG(const char* fname, unsigned int quality) const`, défaut **75** dans le `.hpp`. `jpeg_set_quality(&cinfo, quality, TRUE)` juste avant la compression. `in_color_space = JCS_RGB` **avant** `jpeg_set_defaults`.

Le sujet interdit le `setjmp` de l'exemple C : une exception à la place. Le code remplace `jerr.error_exit`. Sans ça, libjpeg appelle `exit()`.

La boucle des 21 fichiers est à recopier telle que le sujet la donne (`iomanip`, `sstream`, `quality` de 0 à 100 par pas de 5, noms `out_000.jpg` …). Taille mesurée ici : qualité 75 = qualité par défaut = 18 908 octets sur `chat.ppm` avec les trois cadres.

`readJPEG` n'est pas demandé par le sujet. C'est un bonus du code. Ne pas le présenter comme obligatoire.

## TGA — ce qu'il faut pouvoir refaire

En-tête 18 octets. Entiers 16 bits **little endian** (poids faible d'abord), par décalages, pas par `write` de l'entier : le TD2 exercice 2 demande un code portable. Pixels 24 bits en ordre **b, g, r**.

Octet 2 : sous-format 2 (RGB brut), 10 (RGB RLE), 1 (palette), 3 (gris), 11 (gris RLE). Le sujet couleur demande 2, puis lecture 1, puis écriture 10. Les gris 3 et 11 viennent de la phrase du TP1 « writeFormat … PGM, TGA, JPEG ».

Octet 16 : 24 ou 8. Octet 17 : bit 5 à 1 → la première ligne du fichier est le **haut** (`0x20` dans l'écriture du code). Bit 4 (droite à gauche) et bits 6-7 (entrelacé) : le sujet demande une exception dérivée de `std::exception` pour tout cas non géré. Idem 16 bits et 32 bits.

Paquet RLE : un octet d'en-tête. Bit 7 à 1 → une couleur répétée ; bit 7 à 0 → pixels bruts. Les 7 bits faibles valent `nombre - 1` (donc 1 à 128 pixels). Exemple de la fiche de révision : `R R R R V B B` → `83 R`, `00 V`, `81 B`.

`writeTGA(ostream&, bool rle = true)` : le défaut du sujet est `true` (sous-format 10).

## Bresenham — recopier le sujet, puis généraliser

Octant 1, tel que `tp5.txt` : `c2 = 2*(y2-y1)`, `c1 = c2 - 2*(x2-x1)`, `critère = c2 - (x2-x1)`, tant que `x <= x2`. Si `critère >= 0` alors `y++` et `critère += c1`, sinon `critère += c2`, puis `x++`.

Octants 1 et 2 : si `longY < longX`, la version horizontale, sinon on échange les rôles de x et de y. Le sujet utilise `<`, donc l'égalité va dans la branche verticale. Les deux branches tracent la même diagonale.

Huit octants : `incX` et `incY` valent +1 ou -1, `longX` et `longY` restent positives, la boucle compte les points de 0 à `longX` inclus (ou `longY`), parce qu'on ne peut plus tester `x <= x2` quand x diminue.

Pièges du test complet, écrits dans le sujet : `#include <cmath>`, `M_PI`, argument en **radians** (`degres * M_PI / 180`). Image 500×500 noire, centre (250, 250), rayon 200, pas de 5°.

Le code utilise `std::lround` pour le point du cercle. La figure `tp5_im3.png` ne coïncide pas au pixel près (voir le rapport). Les deux premières figures, oui. En contrôle, suivre le pseudo-code du sujet pour le segment ; pour le cercle, écrire la formule demandée et dire comment l'extrémité est arrondie.

## Pièges qui font perdre des points

| Piège | Réflexe du cours |
|---|---|
| Oublier `std::ios::binary` | 2ᵉ argument de `ifstream` / `ofstream` |
| Pixels avec `<<` | `<<` pour l'en-tête, `write` / `read` pour les octets |
| `>>` après 255 | un seul `get()` |
| Commentaires de `chat.pgm` | `>> std::ws` avant `skip_comments` |
| `cout << uint8_t` | affiche un caractère : caster en `unsigned int` (diapo 13) |
| `for (uint8_t i = 0; i <= 255; i++)` | boucle infinie |
| `string('X', n)` dans les notes de TD | l'ordre du CM pratique est `string(n, ' ')` |
| `if (*ptr = 0x34)` dans les notes | c'est une affectation ; il faut `==` |
| Lire une `struct` d'un bloc | padding et `std::string` : champ par champ |
| TGA en RGB | le fichier est BGR ; 16 bits en little endian |
| `jpeg_set_defaults` avant la couleur | régler `in_color_space` avant |
| `cos(5)` | 5 degrés → radians |
| Parcourir l'image de départ pour agrandir | parcourir l'arrivée |
| `uint8_t` 200+100 | 44 si on n'écrit pas la saturation ; les opérateurs du code saturent à 255 |

## Ordre de révision le plus court

1. Réécrire `skip_comments`, `writePGM`, `readPGM` sur papier (exercices 1 à 3).
2. Réécrire `simpleScale` sans document.
3. Relire la formule bilinéaire et les deux lignes d'opérateurs `Color`.
4. En-tête TGA : 18 octets, BGR, RLE sur un exemple de 4 pixels.
5. Pseudo-code octant 1, puis la phrase « incX, incY, longueurs positives, compteur ».
6. Une compilation à la main, pas seulement `make` (la séance peut être sans Makefile).
