# TP4 : format Targa (TGA) et RLE

Explications complètes (avec schémas) : [TP4_explications.pdf](TP4_explications.pdf)

## Code

`ColorImage::writeTGA(std::ostream&, bool rle = true) const` et `static ColorImage* ColorImage::readTGA(std::istream&)`
dans `../PROJET_FINAL/Image.cpp` ; test dans `../PROJET_FINAL/tp4.cpp`.

```bash
cd ../PROJET_FINAL
make tp4 && ./tp4
```

## Ce qui est fait

- Écriture : sous-format 2 (brut) ou 10 (RLE, paquets limités à une ligne), origine en haut à gauche.
- Lecture : sous-formats 1 (palette 24 bits, indices 8 bits), 2 et 10 ; origine en bas ou en haut (bit 5 du descripteur).
- Entiers 16 bits en little endian écrits et relus avec des décalages et des masques (portable).
- Toute image non gérée (16/32 bits, autre sous-format, droite à gauche, entrelacée, fichier tronqué) lève une exception.

Vérifications : chaque TGA écrit est relu à l'identique par notre `readTGA` et par ImageMagick ;
`palette_bl.tga` et `palette_tl.tga` donnent la même image à l'endroit.

## Corrections par rapport à la version de Gemini

- La version TP4 de Gemini avait **perdu** `simpleScale`, `bilinearScale`, `writeJPEG`, `readJPEG` et les contrôles de `readPPM`.
- Lectures non vérifiées (fichier tronqué = image remplie au hasard), fuite mémoire en cas d'exception, paquet RLE trop long non détecté, bits 4/6/7 du descripteur ignorés.

Ancienne version : `../_ARCHIVE_GEMINI/TP4/`.
