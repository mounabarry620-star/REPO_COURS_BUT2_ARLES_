# Commandes de compilation, d'exécution et de test

Les commandes du sujet TP3 sont en deux étapes. Le `Makefile` de `PROJET_FINAL` fait la même chose. Les essais de ce dossier ont été faits sur une machine Linux cloud, pas sur le poste de l'IUT : voir `05_Checklist_VDI.md` et `resultats_tests_cloud.txt`.

## Préparer la copie

```bash
cd TP_R3_L01_Immagerie_Numérique/Preparation_Controle_Imagerie_2026-11-06/code_a_rendre
bash copier_images.sh
```

`copier_images.sh` recopie `../../PROJET_FINAL/images` si le dossier `images/` n'est pas déjà là. Les images du professeur ne sont pas modifiées.

## À la main, comme en séance

Depuis `code_a_rendre/` (ou depuis `PROJET_FINAL/`, c'est le même source) :

```bash
g++ -std=c++11 -Wall -Wextra -c Image.cpp
g++ -std=c++11 -Wall -Wextra -c tp1.cpp
g++ -o tp1 tp1.o Image.o -ljpeg
./tp1
```

Pour un autre TP, remplacer `tp1` par `tp2`, `tp3`, `tp4` ou `tp5`. `-ljpeg` est nécessaire à chaque édition de liens : le code JPEG est dans `Image.cpp`. Oublier `-ljpeg` donne `undefined reference to jpeg_…` à l'édition de liens, pas à la compilation.

`-std=c++11` : le CM utilise `= delete`, `nullptr`, `<cstdint>`.

Le sujet TP3 écrit aussi, pour un seul fichier :

```bash
g++ -Wall -c programme.cpp
g++ -Wall -o programme programme.o -ljpeg
```

Sous Windows, sur les machines de l'IUT, le sujet TP3 donne (bibliothèque déjà sur le disque `L:`) :

```bash
g++ -Wall -IL:\GnuWin32\include -c programme.cpp
g++ -Wall -LL:\GnuWin32\lib -o programme programme.o -ljpeg
```

Le `PATH` doit voir `L:\GnuWin32\bin`, ou la DLL est à côté du programme. Rien d'autre n'est documenté dans le dépôt.

## Avec le Makefile

```bash
make            # compile tp1 … tp5
make tp3        # compile seulement tp3
make -n tp1     # affiche les commandes, ne les lance pas
make test       # compile puis ./tp1 && ./tp2 && ./tp3 && ./tp4 && ./tp5
make clean      # enlève objets, exécutables et images produites
```

Les recettes commencent par une tabulation. Un espace à la place donne `missing separator`.

## TD2, à part (pas à rendre)

```bash
cd TP_R3_L01_Immagerie_Numérique/TP2_TD2
g++ -std=c++11 -Wall -Wextra td2_endianness.cpp -o td2
./td2
od -An -tx1 data.dat
```

Attendu sur un PC little endian : `swap_bytes(0x1234) = 0x3412`, `a = -1234`, et les deux premiers octets du fichier `fb 2e`.

## Exercice ajouté (pas le rendu)

```bash
cd TP_R3_L01_Immagerie_Numérique/Preparation_Controle_Imagerie_2026-11-06
g++ -std=c++11 -Wall -Wextra -I code_a_rendre \
    exercices_code/corrige_fonctions_ajoutees.cpp code_a_rendre/Image.cpp \
    -o /tmp/ex_ajout -ljpeg
/tmp/ex_ajout
```

Attendu : `Y(200,100,50) = 124` et le programme se termine sans `ERREUR`.

## Ce que chaque `./tpN` doit afficher

| Programme | À lire à l'écran | Fichiers |
|---|---|---|
| `./tp1` | `0 pixel(s) différent(s)` ; `10 35 et 10 35` ; deux lignes `exception attendue` | `tp1_rectangles.pgm`, `tp1_chat_lunettes.pgm`, `tp1_rafale.pgm` |
| `./tp2` | tailles, puis `(150,100,129)` | `tp2_chat.ppm`, `tp2_simple.ppm`, `tp2_bilinear.ppm`, versions `.pgm`, `tp2_rafale.ppm` |
| `./tp3` | `out_000.jpg ... out_100.jpg` ; exception libjpeg | `tp3_chat.jpg` et `out_075.jpg` de même taille (18 908 octets sur le test cloud) |
| `./tp4` | `relecture brut identique : oui` et `relecture RLE identique : oui` ; gris `oui` ; une exception | `tp4_*.tga`, `tp4_chanel.ppm` |
| `./tp5` | trois lignes `écrit` | comparer à l'œil `tp5_octant1.ppm` avec `images/tp5_im1.png`, `tp5_octants12.ppm` avec `tp5_im2.png`. Le cercle `tp5_im3.png` peut différer d'un pixel en bout de segment : mesuré dans le rapport. |

Voir les images, d'après les sujets : Linux `eog` ou `qiv` ; Windows XnView ou IrfanView. Faire alterner deux images (flèches ou espace) pour voir un décalage.

```bash
eog images/chat.pgm tp1_chat_lunettes.pgm
eog tp2_simple.ppm tp2_bilinear.ppm
```

`eog` n'a pas été lancé ici (pas de session graphique de l'IUT). La comparaison des pixels PGM/PPM/PNG a été faite par programme, pas à l'œil.

## Avant de rendre

```bash
cd PROJET_FINAL
make test
make clean
```

On rend `Image.hpp`, `Image.cpp`, `tp1.cpp` … `tp5.cpp`, `Makefile`, et `images/` si le professeur veut relancer les tests. Le dossier `Preparation_Controle_…` et `_ARCHIVE_GEMINI/` ne font pas partie du rendu.
