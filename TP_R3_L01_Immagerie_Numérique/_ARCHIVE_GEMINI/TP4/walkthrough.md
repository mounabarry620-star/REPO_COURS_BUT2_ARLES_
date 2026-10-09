# Walkthrough TP4 : Format TrueVision Targa (TGA) & Compression RLE
**Enseignement : R3.L01 — Représentations et codages des images (BUT 2 Informatique, IUT d'Arles — Enseignant : Éric Rémy)**

---

## 1. Vue d'ensemble du TP4 & Objectifs pédagogiques

Le **TP n°4** aborde le format historique et incontournable dans le jeu vidéo et l'infographie 3D : le format **TrueVision Targa (TGA)**.
1. **Comprendre une spécification binaire matérielle** : décoder un en-tête fixe de 18 octets conçu à l'origine pour les cartes graphiques TARGA en 1984.
2. **Gestion de l'Endianness & ordre des composantes** : manipuler des champs entiers 16 bits en *Little-Endian* et maîtriser l'ordonnancement matériel **BGR (Bleu, Vert, Rouge)** au lieu de RGB.
3. **Orientation spatiale de l'image** : identifier le bit 5 du descripteur d'image pour gérer le repère cartésien d'origine (*Bottom-Left* vers *Top-Left*).
4. **Images indexées avec palette (Sous-format 1)** : charger des tables de couleurs 24 bits et convertir les pixels 8 bits indexés en RGB 24 bits à la volée.
5. **Compression RLE sans perte (Sous-format 10)** : coder et décoder des paquets de répétition (*Run-Length Packets*) et des paquets littéraux (*Raw Packets*) limités à 128 pixels.

---

## 2. Structure du Format TGA : Schémas et « LE POURQUOI »

### 2.1 L'En-tête de 18 Octets Fixe
```
Offset  Taille   Champ                      Rôle et Valeurs Usuelles
──────────────────────────────────────────────────────────────────────────
0       1 o      ID Length                  0 (ou longueur texte descriptif)
1       1 o      Color Map Type             0 (sans palette), 1 (avec palette)
2       1 o      Image Type                 1 (Palette), 2 (RGB brut), 10 (RGB RLE)
3-4     2 o      Color Map Origin           Index de départ dans la palette (LE)
5-6     2 o      Color Map Length           Nombre d'entrées de la palette (LE)
7       1 o      Color Map Depth            24 bits (3 octets BGR par couleur)
8-9     2 o      X Origin                   Origine X (généralement 0)
10-11   2 o      Y Origin                   Origine Y (généralement 0)
12-13   2 o      Width                      Largeur en pixels (Little-Endian)
14-15   2 o      Height                     Hauteur en pixels (Little-Endian)
16      1 o      Pixel Depth                24 (RGB) ou 8 (Palette)
17      1 o      Image Descriptor           Bit 5 = 1 (Top-Left), Bit 5 = 0 (Bottom-Left)
```

---

### 2.2 Le POURQUOI de l'Ordre BGR
> [!IMPORTANT]
> **Pourquoi le format TGA stocke-t-il Bleu, puis Vert, puis Rouge ?**  
> Les premières cartes vidéo de TrueVision (1984) utilisaient des convertisseurs numérique-analogique (DAC) câblés en bus Little-Endian. Le premier octet accédé en mémoire correspondait physiquement au canal bleu. Contrairement à Netpbm (PPM P6) qui impose l'ordre naturel RGB, **TGA impose l'ordre BGR**. Écrire RGB dans un fichier TGA inverse le rouge et le bleu à l'affichage !

---

### 2.3 Le POURQUOI de l'Orientation Verticale (Bit 5)
```
          Repère Mathématique (Bit 5 = 0)         Repère Informatique (Bit 5 = 1)
          y = Height - 1 (Haut)                  y = 0 (Haut)
             ▲                                      ┌──────────────► x
             │                                      │
             │                                      │
             └──────────────► x                     ▼
          y = 0 (Bas)                            y = Height - 1 (Bas)
          Fichier : palette_bl.tga               Fichier : palette_tl.tga
```
- Si `descriptor & 0x20 == 0` : le fichier commence par la ligne du **bas** de l'image.
- Pour charger correctement l'image dans notre tableau 2D standard :
  $$\text{target\_y} = \text{top\_to\_bottom} \ ? \ y : (\text{height} - 1 - y)$$

---

### 2.4 Le Sous-format 10 : Algorithme de Compression RLE
Un flux RLE TGA est une suite de paquets de 1 à 128 pixels :
1. **Paquet Run-Length (Bit 7 = 1) :**
   - Octet d'en-tête : `0x80 | (count - 1)`.
   - Suivi d'**un seul pixel BGR** (3 octets) qui est répété `count` fois.
2. **Paquet Raw (Bit 7 = 0) :**
   - Octet d'en-tête : `(count - 1)`.
   - Suivi de `count` pixels BGR différents ($count \times 3$ octets).

---

## 3. Implantation C++ Validée

Les classes [ColorImage.hpp](file:///home/nene_goto_/Documents/REPO_COURS_BUT2_ARLES_/TP_R3_L01_Immagerie_Numérique/TP4/ColorImage.hpp) et [ColorImage.cpp](file:///home/nene_goto_/Documents/REPO_COURS_BUT2_ARLES_/TP_R3_L01_Immagerie_Numérique/TP4/ColorImage.cpp) implantent :
- `void ColorImage::writeTGA(std::ostream &f, bool rle = true) const;`
- `static ColorImage* ColorImage::readTGA(std::istream &f);`

Le programme [tp4.cpp](file:///home/nene_goto_/Documents/REPO_COURS_BUT2_ARLES_/TP_R3_L01_Immagerie_Numérique/TP4/tp4.cpp) valide :
1. Lecture de `chat.tga` (Type 2), tracé de rectangles, sauvegarde en `tp4_chat_raw.tga` (226 Ko) et `tp4_chat_rle.tga` (192 Ko).
2. Relecture avec succès du fichier compressé RLE généré.
3. Décodage et redressement de `palette_bl.tga` et `palette_tl.tga` (remises à l'endroit).
4. Décodage de `chat010couleurs.tga` (Palette 10 couleurs).

---

## 4. Support de Présentation PDF Style M. Rémy

📄 **[TP4_TGA_Cours_Remy.pdf](file:///home/nene_goto_/Documents/REPO_COURS_BUT2_ARLES_/TP_R3_L01_Immagerie_Numérique/TP4/TP4_TGA_Cours_Remy.pdf)**
