# Corrigés des exercices type

À ouvrir après les énoncés de `02_Exercices_type_enonces.md`. Les formules sont celles du CM, des sujets de TD et de `tp5.txt`. Quand le tableau n'a pas été corrigé (bilinéaire), c'est indiqué.

## A

A1. `50 35 0a` = `P5` + LF. `23 20 6f 6b 0a` = `# ok` + LF. `33 20 32 0a` = `3 2` + LF → largeur 3, hauteur 2. `23 20 78 0a` = `# x`. `32 35 35 0a` = `255` + LF. Pixels : `0a 20 ff 00 80 10`, soit 10, 32, 255, 0, 128, 16. Six pixels, 3×2 : c'est cohérent. Le premier pixel vaut 10 : un `>>` l'aurait pris pour un blanc.

A2. Voir la fiche, section PGM. `get` puis `putback` si le caractère n'est pas `#`. Répéter tant que la ligne commence par `#`.

A3.

```cpp
void GrayImage::writePGM(std::ostream& os) const
{
  os << "P5\n"
     << "# Image sauvegardée par XXX pour les TP de RepCod.\n"
     << width << " " << height << "\n"
     << 255 << "\n";
  os.write((const char*)array, size_t(width) * height);
  if (!os)
    throw std::runtime_error("writePGM : erreur d'écriture");
}
```

Lecture P5, schéma :

```cpp
std::string magic;
is >> magic;
if (magic != "P5")
  throw std::runtime_error("readPGM : pas un P5");
is >> std::ws;
skip_comments(is);
unsigned int w, h;
if (!(is >> w >> h))
  throw std::runtime_error("readPGM : dimensions");
is >> std::ws;
skip_comments(is);
unsigned int maxval;
if (!(is >> maxval) || maxval != 255)
  throw std::runtime_error("readPGM : maxval");
GrayImage* res = new GrayImage(uint16_t(w), uint16_t(h));
is.get();
is.read((char*)res->array, size_t(w) * h);
if (!is) { delete res; throw std::runtime_error("readPGM : pixels"); }
return res;
```

A4. Une méthode d'instance a besoin d'un objet. `readPGM` fabrique cet objet. Le TD1 dit qu'on se mordrait la queue. `static` attache la fonction à la classe : on l'appelle par `GrayImage::readPGM(flux)`, avec quand même le droit d'accéder à `array`.

## B

`operator>>` s'arrête avant le LF. `skip_comments` lit ce LF, voit qu'il n'est pas `#`, le remet avec `putback`, et s'arrête. Le `# encore` n'est pas sauté. Ensuite `is >> maxval` échoue sur `#`. Il manque `is >> std::ws` **avant** `skip_comments` (blancs : espace, tabulation, CR, LF). C'est aussi ce qui permet un en-tête Windows `CR LF` et un en-tête tenu sur une seule ligne (`PGM.txt` : être souple).

## C

C1.

```cpp
template <typename T>
void swap_bytes(T& t)
{
  uint8_t* ptr = reinterpret_cast<uint8_t*>(&t);
  for (size_t i = 0; i < sizeof(T) / 2; i++) {
    uint8_t tmp = ptr[i];
    ptr[i] = ptr[sizeof(T) - 1 - i];
    ptr[sizeof(T) - 1 - i] = tmp;
  }
}
```

Le cast des notes `reinterpret_cast<uint8_t>(&t)` oublie l'étoile : il faut un pointeur. `uint8_t` plutôt que `int8_t` pour un octet brut.

C2.

```cpp
uint8_t o[2];
is.read((char*)o, 2);
data.a = int16_t((o[0] << 8) | o[1]); // o[0] = poids fort

uint8_t p[8];
is.read((char*)p, 8);
uint64_t bits = 0;
for (int i = 0; i < 8; i++)
  bits = (bits << 8) | p[i];
std::memcpy(&data.b, &bits, 8);

is.read(data.fourcc, 4); // pas de swap : 4 octets isolés

uint8_t taille = 0;
is.read((char*)&taille, 1);
data.d = std::string(taille, ' ');
if (taille > 0)
  is.read(&data.d[0], taille);
```

`string(n, ' ')` : le nombre d'abord. `d.data()` est `const` avant C++17 ; on écrit dans `&data.d[0]`. On ne lit pas la structure d'un coup : padding après l'entier, et `std::string` ne contient pas les caractères dans l'objet.

C3. Pixels : 4032 × 3024 × 3 = 36 578 304 octets (environ 34,9 Mio, avec 1 Mio = 1024×1024). L'objet `ColorImage` en plus : 8 octets sur un PC 32 bits, 16 sur un PC 64 bits (deux `uint16_t`, du padding, un pointeur). Négligeable devant les pixels.

Une image UHD : 3840 × 2160 × 3 = 24 883 200 octets. × 60 = 1 492 992 000 octets/s ≈ 11,94 Gbit/s. ADSL 20 Mbit/s et fibre 100 Mbit/s sont très en dessous. Le TD conclut qu'une vidéo brute ne passe pas : elle est compressée.

## D

D1. `x = 7 * 4 / 10 = 2`, `y = 3 * 4 / 10 = 1`. Pixel source (2, 1). Division entière.

D2. Même boucle que `simpleScale` dans la fiche, avec `Color` et `new ColorImage(w, h)`.

D3.

```cpp
Color haut   = (1 - ax) * pixel(x0, y0) + ax * pixel(x1, y0);
Color bas    = (1 - ax) * pixel(x0, y1) + ax * pixel(x1, y1);
Color valeur = (1 - ay) * haut + ay * bas;
```

En `double`, avant d'arrondir : haut = 0,75×10 + 0,25×20 = 12,5 ; bas = 0,75×30 + 0,25×40 = 32,5 ; valeur = 0,5×12,5 + 0,5×32,5 = 22,5. Cette valeur est celle de la fiche de révision. Avec des `Color` en `uint8_t`, chaque `operator*` arrondit avant l'addition : le résultat peut s'écarter de 1. Le sujet demande quand même ces opérateurs.

Le demi-pixel `(p + 0.5) * src / dst - 0.5` n'est pas dans les notes de tableau. Le sujet TP2 le laisse facultatif.

D4.

```cpp
static uint8_t to_byte(double v)
{
  if (v <= 0)   return 0;
  if (v >= 255) return 255;
  return uint8_t(v + 0.5);
}

Color operator+(const Color& c1, const Color& c2)
{
  return Color(to_byte(double(c1.r) + c2.r),
               to_byte(double(c1.g) + c2.g),
               to_byte(double(c1.b) + c2.b));
}
```

200+100 = 300 → 255, pas 44. Le passage par `double` évite le modulo 256 de `uint8_t`.

## E

E1. Dix-huit octets :

```text
00          id length
00          pas de palette
02          sous-format 2
00 00       origine palette
00 00       longueur palette
00          bits palette
00 00       X origine
00 00       Y origine
40 01       largeur 0x0140, little endian
F0 00       hauteur 0x00F0, little endian
18          24 bits
20          bit 5 = origine en haut
```

E2. `83` = 1000 0011 : bit 7 à 1, nombre = 3+1 = 4, couleur BGR `FF 00 00` → RGB (0, 0, 255), quatre fois. `00` = paquet brut d'un pixel, BGR `00 FF 00` → RGB (0, 255, 0). `81` = répété, nombre = 1+1 = 2, BGR `00 00 FF` → RGB (255, 0, 0) deux fois. Total 7 pixels.

E3. `longX = 6`, `longY = 2`, `c2 = 4`, `c1 = 4 - 12 = -8`, `critère = 4 - 6 = -2`. Départ (0,0).

| x avant | y | critère avant | décision | critère après | x après |
|---|---|---|---|---|---|
| 0 | 0 | -2 | < 0, critère += 4 | 2 | 1 |
| 1 | 0 | 2 | ≥ 0, y++, critère += -8 | -6 | 2 |
| 2 | 1 | -6 | += 4 | -2 | 3 |
| 3 | 1 | -2 | += 4 | 2 | 4 |
| 4 | 1 | 2 | y++, += -8 | -6 | 5 |
| 5 | 2 | -6 | += 4 | -2 | 6 |
| 6 | 2 | -2 | += 4 | 2 | 7 |

Pixels dessinés, dans l'ordre : (0,0), (1,0), (2,1), (3,1), (4,1), (5,2), (6,2). On s'arrête quand x vient de dépasser x2, sans dessiner ce x.

E4. Vers la gauche, horizontal : `incX = -1`, `longX` = distance positive, `longY = 0`. `0 < longX` est vrai : branche « plutôt horizontale ». La boucle fait `longX + 1` points. On ne compare pas `x <= x2`, puisque x diminue.

## F

Corps à ajouter dans la classe. Une version qui compile **sans** modifier `Image.hpp`, en fonctions libres sur l'interface publique, est dans `exercices_code/corrige_fonctions_ajoutees.cpp`. En séance, si le professeur donne le prototype dans le `.hpp`, c'est une méthode : le corps ne change pas.

F1.

```cpp
GrayImage* ColorImage::toGray() const
{
  GrayImage* res = new GrayImage(width, height);
  for (uint16_t y = 0; y < height; y++)
    for (uint16_t x = 0; x < width; x++) {
      const Color& c = pixel(x, y);
      double yuv = 0.299 * c.r + 0.587 * c.g + 0.114 * c.b;
      if (yuv < 0)   yuv = 0;
      if (yuv > 255) yuv = 255;
      res->pixel(x, y) = uint8_t(yuv + 0.5);
    }
  return res;
}
```

Contrôle du CM, repris par la fiche de révision : (200, 100, 50) → 0,299×200 + 0,587×100 + 0,114×50 = 124,2 → 124. Le programme d'exercice vérifie ce cas.

F2.

```cpp
uint32_t GrayImage::countEqual(uint8_t gray) const
{
  uint32_t n = 0;
  for (uint16_t y = 0; y < height; y++)
    for (uint16_t x = 0; x < width; x++)
      if (pixel(x, y) == gray)
        n++;
  return n;
}
```

F3. `std::cout << (unsigned int)chat->countEqual(10) << std::endl;`
Si on écrit `cout << uint8_t(10)`, on obtient un saut de ligne, pas le texte `10` (diapo 13).

## G

G1. `data.d = std::string(str_size, 'X');` Le caractère d'abord serait lu comme une longueur (code ASCII de `'X'`, 88).

G2. `reinterpret_cast<uint8_t*>(&var)` et `if (*ptr == 0x34)`. Avec `=`, on écrit 0x34 dans le premier octet et la condition est vraie.

G3. Pour un `uint8_t`, `i <= 255` est toujours vrai. Après 255, `i++` revient à 0 (diapo 13). La boucle ne s'arrête pas. Écrire `for (int i = 0; i <= 255; i++)`. La boucle du sujet JPEG, elle, est en `unsigned int` avec `quality <= 100` et un pas de 5 : celle-là s'arrête.

G4. `std::ofstream ofs("out.pgm", std::ios::binary);` Sans `binary`, un pixel 10 peut être réécrit `0d 0a` sous Windows.

G5. Inverser : `in_color_space` (et `input_components`, largeur, hauteur) puis `jpeg_set_defaults`, puis `jpeg_set_quality`.

## H

```text
static GrayImage* GrayImage::readPGM(std::istream&);
static ColorImage* ColorImage::readPPM(std::istream&);
ColorImage* ColorImage::simpleScale(uint16_t w, uint16_t h) const;
ColorImage* ColorImage::bilinearScale(uint16_t w, uint16_t h) const;
void ColorImage::writeJPEG(const char* fname, unsigned int quality = 75) const;
void ColorImage::writeTGA(std::ostream& f, bool rle = true) const;
static ColorImage* ColorImage::readTGA(std::istream& f);
void ColorImage::line(ushort x1, ushort y1, ushort x2, ushort y2, const Color pixel_value);
```

`writePGM` / `writePPM` ne sont pas `static`. `clear` a un défaut : 0 pour le gris, `Color()` (noir) pour la couleur.
