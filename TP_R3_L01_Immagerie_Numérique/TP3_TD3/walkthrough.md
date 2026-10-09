# TP3 : JPEG avec libjpeg

Explications complètes (avec schémas) : [TP3_explications.pdf](TP3_explications.pdf).
Le TD3 (rééchantillonnage) est traité dans les explications du TP2 et dans la fiche de révision.

## Code

`ColorImage::writeJPEG(const char* fname, unsigned int quality = 75) const` et le bonus
`static ColorImage* ColorImage::readJPEG(const char*)` dans `../PROJET_FINAL/Image.cpp` ; test dans `../PROJET_FINAL/tp3.cpp`.

```bash
sudo apt install libjpeg-dev   # si besoin
cd ../PROJET_FINAL
make tp3 && ./tp3              # produit tp3_chat.jpg et out_000.jpg ... out_100.jpg
```

## Points importants

- `extern "C" { #include <jpeglib.h> }` et édition de liens avec `-ljpeg`.
- Les 6 étapes de `libjpeg.txt` : création, destination, paramètres (`jpeg_set_defaults` après `in_color_space`, puis `jpeg_set_quality`), `start_compress`, une scanline à la fois, `finish_compress` puis `destroy_compress`.
- Le gestionnaire d'erreur de libjpeg (qui appelle `exit()`) est remplacé par une fonction qui **lève une exception**, comme le demande le sujet.

## Corrections par rapport à la version de Gemini

- Erreurs libjpeg transformées en exceptions, avec libération de l'objet libjpeg et fermeture du fichier.
- Qualité vérifiée (0 à 100).
- Cadres à 5, 10 et 15 pixels comme sur la figure du sujet.

Ancienne version : `../_ARCHIVE_GEMINI/TP3_TD3/`.
