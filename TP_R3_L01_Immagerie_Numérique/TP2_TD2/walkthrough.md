# TP2 & TD2 : ColorImage, PPM et rééchantillonnage

Explications complètes (avec schémas) : [TP2_explications.pdf](TP2_explications.pdf).
Les exercices 2 et 3 du TD2 (endianness, `swap_bytes`, tailles mémoire, débits) sont corrigés dans
[../REVISION_CONTROLE_TD_R3L01.pdf](../REVISION_CONTROLE_TD_R3L01.pdf).

## Code

`../PROJET_FINAL/Image.hpp` / `Image.cpp` (classes `Color` et `ColorImage`, **dans les mêmes fichiers que `GrayImage`** comme le demande le sujet) et `../PROJET_FINAL/tp2.cpp`.

```bash
cd ../PROJET_FINAL
make tp2 && ./tp2
eog tp2_simple.ppm tp2_bilinear.ppm
```

## Ce qui est fait

- `Color` : `==`, `!=`, `double * Color` (arrondi), `Color + Color` (saturé à 255).
- `ColorImage` : mêmes fonctions que `GrayImage`, `writePPM`, `static readPPM` (P6, et P3 en bonus).
- `simpleScale` (plus proche voisin, formule du corrigé du TD3) et `bilinearScale` (avec la correction du demi-pixel citée par le sujet), **pour GrayImage et ColorImage**.

## Corrections par rapport à la version de Gemini

- GrayImage avait disparu du TP2 : tout est maintenant dans `Image.hpp/.cpp`.
- `Color + Color` débordait (200 + 100 = 44) ; `double * Color` tronquait.
- `static_assert(sizeof(Color) == 3)` avant d'écrire le tableau de pixels d'un bloc.
- Rééchantillonnage ajouté à GrayImage (le corrigé du TD3 est écrit pour GrayImage).

Ancienne version : `../_ARCHIVE_GEMINI/TP2_TD2/`.
