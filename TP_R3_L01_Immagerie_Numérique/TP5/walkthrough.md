# TP5 : tracé de segments (Bresenham entier)

Explications complètes (avec schémas et un déroulé pas à pas) : [TP5_explications.pdf](TP5_explications.pdf)

## Code

`void ColorImage::line(uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2, const Color pixel_value)`
(prototype du sujet, `ushort` = `uint16_t`) dans `../PROJET_FINAL/Image.cpp` ; test dans `../PROJET_FINAL/tp5.cpp`.

```bash
cd ../PROJET_FINAL
make tp5 && ./tp5
eog tp5_octant1.ppm tp5_octants12.ppm tp5_cercle.ppm
```

## Résultats

- Octant 1 et octants 1 + 2 : **identiques pixel pour pixel** aux images du sujet (`images/tp5_im1.png`, `tp5_im2.png`).
- Cercle (8 octants) : quelques extrémités diffèrent d'un pixel, à cause de l'arrondi de `cos`/`sin`.

## Corrections par rapport à la version de Gemini

- Prototype `line(int16_t, ...)` remplacé par celui du sujet.
- Extrémité hors de l'image : exception au lieu d'un oubli silencieux.
- Commentaire PPM « TP5 Bresenham - Eric Remy » remplacé par le nom de l'étudiant.
- Points du cercle dessinés en blanc comme sur la figure.

Ancienne version : `../_ARCHIVE_GEMINI/TP5/`.
