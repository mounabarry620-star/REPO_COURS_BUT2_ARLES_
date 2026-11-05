# Exercices type — sans corrigé

Même outillage que les sujets : classes du CM, exceptions, pas de bibliothèque hors `jpeglib` pour le JPEG. Les corrigés sont dans `03_Exercices_type_corriges.md`. Ne pas les ouvrir avant d'avoir écrit une réponse.

Les exercices A à E sont du code à savoir produire. Les exercices F à H sont du genre « le sujet de TP ajoute une question le jour même ».

## A. TD1, à la main

A1. Dans le dump suivant, donner le magic number, la largeur, la hauteur, la valeur max, puis la liste des pixels.

```text
50 35 0a 23 20 6f 6b 0a 33 20 32 0a 23 20 78 0a 32 35 35 0a 0a 20 ff 00 80 10
```

A2. Écrire `skip_line` et `skip_comments` avec `putback`, comme le TD1 questions 3 et 4.

A3. Écrire `writePGM` et le début de `readPGM` jusqu'au `read` des pixels P5. Le commentaire doit être la phrase du TD, avec un nom à la place de XXX.

A4. Pourquoi `readPGM` est `static` ? Deux phrases, le vocabulaire du TD1.

## B. Piège de `chat.pgm`

On a lu la largeur et la hauteur avec `is >> w >> h`. Le fichier continue par un LF, puis une ligne `# encore`, puis `255`. Que se passe-t-il si on appelle `skip_comments` tout de suite ? Quelle ligne du cours ou du TD manque ?

## C. TD2, endianness et tailles

C1. Écrire `template <typename T> void swap_bytes(T&)`.

C2. Le fichier big endian contient un `int16_t`, un `double`, 4 caractères, un octet de taille, puis la chaîne. Écrire la lecture **portable** (décalages), sans tester si la machine est little endian. Ne pas permuter les 4 caractères.

C3. Quelle taille mémoire pour les pixels d'une image 4032×3024 en 24 bits ? Même question pour une caméra 3840×2160, 60 images/s, en octets/s puis en Gbit/s. Les débits du TD (ADSL 20 Mbit/s, fibre 100 Mbit/s) suffisent-ils ?

## D. Rééchantillonnage

D1. Image 4×4 agrandie en 10×10 par plus proche voisin. Quel pixel source pour (x', y') = (7, 3) ?

D2. Écrire `ColorImage::simpleScale` avec la formule du tableau (sans demi-pixel).

D3. Écrire la formule bilinéaire en trois lignes (`haut`, `bas`, `valeur`) en utilisant `operator*` et `operator+`. Donner, en `double` et avant arrondi, le résultat pour P(x0,y0)=10, P(x1,y0)=20, P(x0,y1)=30, P(x1,y1)=40, ax=0,25, ay=0,5.

D4. Écrire `operator+(Color, Color)` pour que 200+100 ne donne pas 44.

## E. TGA, RLE, segment

E1. Donner les 18 octets d'en-tête (en hexadécimal) d'un TGA sous-format 2, 320×240, 24 bits, origine en haut à gauche, pas de palette, pas d'identification. Largeur 320 = 0x0140, hauteur 240 = 0x00F0.

E2. Décoder les paquets (octets en hexadécimal) : `83 FF 00 00  00 00 FF 00  81 00 00 FF`. Dire combien de pixels et leurs couleurs RGB.

E3. Octant 1 de Bresenham, segment (0,0)→(6,2). Lister les pixels dans l'ordre, en appliquant le pseudo-code du sujet (`tp5.txt`).

E4. Pour un segment du centre vers la gauche, que valent `incX`, `longX` et dans quelle branche (`longY < longX` ou l'autre) on entre si le segment est horizontal ?

## F. Fonction ajoutée possible pendant la séance

Le professeur peut demander une méthode qui n'est pas dans les cinq sujets, mais qui n'utilise que `pixel`, `getWidth`, `getHeight` et la formule de luminance du CM (diapo 32) :

```text
Y = 0,299 R + 0,587 G + 0,114 B
```

F1. Prototype et corps de `GrayImage* ColorImage::toGray() const`. Y est arrondi à l'entier le plus proche, ramené dans [0;255]. L'image couleur n'est pas modifiée.

F2. Prototype et corps de `uint32_t GrayImage::countEqual(uint8_t gray) const`, le nombre de pixels égaux à `gray`.

F3. Dans `tp1.cpp`, après la lecture de `chat.pgm`, afficher ce nombre pour la valeur 10, avec le cast de la diapo 13. Ne pas écrire la valeur 10 avec `cout << uint8_t`.

## G. On vous donne un code faux

Corriger, sans réécrire tout le fichier. Chaque fragment est du type des notes de TD ou d'un oubli fréquent.

G1.

```cpp
data.d = std::string('X', str_size);
```

G2.

```cpp
uint8_t* ptr = reinterpret_cast<uint8_t>(&var);
if (*ptr = 0x34) { /* little endian */ }
```

G3.

```cpp
for (uint8_t i = 0; i <= 255; i++)
  histogramme[i]++;
```

G4. Ouverture : `std::ofstream ofs("out.pgm");` puis `im.writePGM(ofs);` sur une machine Windows.

G5. `jpeg_set_defaults(&cinfo);` placé avant `cinfo.in_color_space = JCS_RGB;`.

## H. Noms, une dernière fois

Écrire de mémoire les prototypes de `readPGM`, `readPPM`, `simpleScale`, `bilinearScale`, `writeJPEG`, `writeTGA`, `readTGA`, `line`. Pas le corps : seulement la ligne de déclaration, `static` compris quand il le faut.
