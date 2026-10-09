# TP1 & TD1 : GrayImage et format PGM

Explications complètes (avec schémas) : [TP1_explications.pdf](TP1_explications.pdf)

## Où est le code ?

Tout le code des TP est dans un seul projet, comme le demande le sujet du TP2 :
`../PROJET_FINAL/Image.hpp`, `../PROJET_FINAL/Image.cpp` et le programme de test `../PROJET_FINAL/tp1.cpp`.

```bash
cd ../PROJET_FINAL
make tp1 && ./tp1
eog images/chat.pgm tp1_chat_lunettes.pgm
```

## Fonctions du TP1 / TD1

| Fonction | Rôle |
|---|---|
| `GrayImage(w, h)`, copie, `~GrayImage()` | allocation du tableau à plat de `w × h` octets |
| `getWidth()`, `getHeight()`, `pixel(x, y)` | accesseurs (pixel à l'indice `y × width + x`) |
| `clear(gray = 0)`, `rectangle(...)`, `fillRectangle(...)` | dessin |
| `writePGM(ostream&) const` | en-tête texte avec `<<`, pixels binaires avec `write` |
| `skip_line(istream&)`, `skip_comments(istream&)` | TD1 questions 3 et 4 |
| `static readPGM(istream&)` | crée l'image (P5, et P2 en bonus) |

## Ce que le test vérifie

- image non carrée 400 × 250 avec rectangles → `tp1_rectangles.pgm` ;
- lecture de `chat.pgm`, dessin des lunettes → `tp1_chat_lunettes.pgm`, **identique pixel pour pixel** à l'image fournie `chat_lunettes.pgm` ;
- lecture d'un PGM « P2 » (bonus) ;
- deux exceptions attendues (pixel hors de l'image, fichier qui n'est pas un PGM).

## Corrections par rapport à la version de Gemini

- `skip_comments` réécrite comme le demande le TD1, avec `skip_line` après les dimensions pour gérer les commentaires de `chat.pgm`.
- Commentaire « Image sauvegardée par *nom* pour les TP de RepCod. » (demandé au TD).
- Taille du tableau calculée en `size_t` (pas de débordement d'`int`).
- Valeurs P2 > 255 refusées.

L'ancienne version est conservée dans `../_ARCHIVE_GEMINI/TP1_TD1/`.
