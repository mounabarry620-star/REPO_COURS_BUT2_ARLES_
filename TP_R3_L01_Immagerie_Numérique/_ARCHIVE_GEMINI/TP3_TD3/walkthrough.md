# Walkthrough TP3 : Format JPEG & Bibliothèque libjpeg (IJG)
**Enseignement : R3.L01 — Représentations et codages des images (BUT 2 Informatique, IUT d'Arles — Enseignant : Éric Rémy)**

---

## 1. Vue d'ensemble du TP3 & Objectifs pédagogiques

Le **TP n°3** permet de franchir un cap majeur dans le traitement d'images :
1. **Passage de la théorie à la pratique industrielle** : comprendre pourquoi coder soi-même un décodeur/encodeur JPEG complet est hors de portée dans un TP (mathématiques lourdes de la DCT, quantification psycho-visuelle, codage de Huffman) et apprendre à interfacer son code C++ avec une bibliothèque C de référence mondiale (**`libjpeg`** de l'Independent JPEG Group).
2. **Interfaçage C / C++** : maîtriser la directive `extern "C"` pour neutraliser le *name mangling* de g++, et lier un programme avec une bibliothèque système via l'option `-ljpeg`.
3. **Comprendre la compression avec pertes (*lossy*)** : observer expérimentalement la chute spectaculaire du poids de l'image (de **226 Ko** en PPM brut à **19 Ko** en JPEG, soit plus de 91 % de réduction) et analyser l'impact du facteur de qualité (de 0 % à 100 %).

---

## 2. La Chaîne de Compression JPEG : Schéma et Explications du « POURQUOI »

```
┌─────────────┐     ┌────────────────┐     ┌──────────────┐
│  Image RGB  │ ──► │ Espace YCbCr   │ ──► │ Sous-échant. │
│ (24 bits)   │     │ (Luminance Y / │     │ Chrominance  │
└─────────────┘     │  Chrominance)  │     │ 4:2:0 (-50%) │
                    └────────────────┘     └──────────────┘
                                                  │
┌─────────────┐     ┌────────────────┐     ┌──────▼───────┐
│ Fichier JPG │ ◄── │ Parcours       │ ◄── │ Blocs 8x8 &  │
│ (Huffman)   │     │ Zig-Zag & RLE  │     │ 2D - DCT     │
└─────────────┘     └────────────────┘     └──────────────┘
                            ▲
                            │ (SEULE ÉTAPE AVEC PERTE)
                    ┌───────┴────────┐
                    │ Quantification │
                    │ Division par Q │
                    │  (quality %)   │
                    └────────────────┘
```

### 2.1 Étape 1 : Conversion d'Espace Colorimétrique (RGB $\to$ YCbCr)
- **Le POURQUOI de la séparation Luminance / Chrominance :**  
  Dans l'œil humain, la rétine contient environ **120 millions de bâtonnets** (extrêmement sensibles aux contrastes de lumière et à la netteté) mais seulement **6 à 7 millions de cônes** (responsables de la perception des couleurs).  
  En conservant le format RGB, chaque couleur primaire est traitée avec la même importance. En convertissant vers l'espace **YCbCr**, on isole la composante achromatique $Y$ (la lumière) des composantes $Cb$ et $Cr$ (les nuances de couleur).

### 2.2 Étape 2 : Le Sous-échantillonnage Chromatique (Chroma Subsampling 4:2:0)
- **Le POURQUOI du ratio 4:2:0 :**  
  Comme l'œil est presque aveugle aux variations spatiales rapides de couleur, on ne stocke qu'un seul échantillon $Cb$ et $Cr$ pour un groupe de **$2 \times 2 = 4$ pixels**.  
  - Pour 4 pixels en RGB : $4 \times 3 = 12$ octets.  
  - Pour 4 pixels en YCbCr 4:2:0 : 4 octets de $Y$ + 1 octet de $Cb$ + 1 octet de $Cr$ = **6 octets**.  
  - **Gain immédiat de 50 %** en volume de données sans perte perceptible pour un observateur humain !
- **Pourquoi les rectangles colorés sont plus ternes même à 100 % de qualité ?**  
  Les bords vifs et nets de nos cadres rouge, vert et bleu subissent ce sous-échantillonnage 4:2:0 : les frontières colorées sont légèrement moyennées avec les pixels voisins.

### 2.3 Étape 3 : Le Découpage en Blocs $8 \times 8$ & la DCT 2D
- **Le POURQUOI de la DCT (Discrete Cosine Transform) :**  
  Dans une image naturelle, des pixels voisins ont des valeurs très proches (forte corrélation spatiale). La DCT transforme ce bloc spatial en un bloc de **fréquences spatiales** :
  - **Coefficient DC $(0,0)$ :** Fréquence nulle = moyenne globale de luminosité du bloc.
  - **63 Coefficients AC :** Variations fines et textures.  
  La DCT réalise une **concentration d'énergie** phénoménale : plus de 90 % de l'information utile se retrouve concentrée dans le coin supérieur gauche du bloc fréquentiel.
- **Pourquoi des blocs $8 \times 8$ ?**  
  Un bloc trop grand ($64 \times 64$) demanderait des calculs lourds et ferait baver les artéfacts visuels. Un bloc trop petit ($2 \times 2$) n'apporterait aucun gain de corrélation. La taille $8 \times 8$ est le compromis universel optimal.

### 2.4 Étape 4 : La Quantification Psycho-visuelle (Division par la Matrice Q)
- **Le POURQUOI : C'est la SEULE et UNIQUE étape qui perd de l'information !**  
  Chaque coefficient fréquentiel est divisé par la case correspondante d'une matrice psycho-visuelle $Q$ :
  $$F_Q(u, v) = \text{round}\left( \frac{\text{DCT}(u, v)}{Q(u, v)} \right)$$
  Comme l'œil ne discerne pas les très hautes fréquences, la matrice $Q$ contient des diviseurs très élevés pour ces composantes. En divisant par 50 ou 80 et en arrondissant à l'entier, **la quasi-totalité des coefficients de haute fréquence deviennent 0**.
- **Rôle du paramètre `quality` (0 à 100) :**  
  L'appel `jpeg_set_quality(&cinfo, quality, TRUE)` multiplie la matrice $Q$ par un facteur d'échelle :
  - À **$0$ %** : $Q$ est gigantesque, presque tout est écrasé à 0 (fichier minuscule de 2,9 Ko, fort effet de pavés).
  - À **$75$ % (défaut)** : compromis d'excellence où la compression atteint un facteur 12 sans artéfact visible.
  - À **$100$ %** : $Q$ est réduite à 1, préservant au maximum les coefficients.

### 2.5 Étape 5 : Parcours en Zig-Zag & Codage Entropique (Huffman / RLE)
- **Le POURQUOI du Zig-Zag :**  
  En parcourant le bloc $8 \times 8$ en diagonale de haut-gauche vers bas-droite, on classe les coefficients par ordre de fréquence croissante. Tous les zéros produits par la quantification se retrouvent **groupés à la fin du bloc**.
- **Le marqueur EOB (End Of Block) :**  
  Dès que la fin du bloc ne contient plus que des zéros, l'encodeur émet un unique code `EOB` et passe immédiatement au bloc suivant.
- **Codage de Huffman sans perte :**  
  Les symboles fréquents reçoivent des codes binaires très courts (quelques bits), compactant le fichier à la limite de l'entropie de Shannon.

---

## 3. Implantation en C++ avec `libjpeg`

### 3.1 Pourquoi la directive `extern "C"` ?
En C++, le compilateur applique le **Name Mangling** (décoration des symboles) afin de permettre la surcharge de fonctions (`foo(int)` devient `_Z3fooi`).  
La bibliothèque `libjpeg` a été compilée en C pur : ses symboles sont bruts (`jpeg_create_compress`).  
Si on écrit simplement `#include <jpeglib.h>`, `g++` cherchera le nom décoré et l'édition de liens échouera avec l'erreur :
```text
undefined reference to 'jpeg_create_compress(jpeg_compress_struct*)'
```
L'encadrement impératif neutralise le mangling :
```cpp
extern "C" {
#include <jpeglib.h>
}
```

---

### 3.2 Implantation de `ColorImage::writeJPEG`
```cpp
void ColorImage::writeJPEG(const char *fname, unsigned int quality) const {
  if (!fname)
    throw std::invalid_argument("Nom de fichier JPEG nul");

  struct jpeg_compress_struct cinfo;
  struct jpeg_error_mgr jerr;

  // 1. Initialisation du gestionnaire d'erreur et de l'objet de compression
  cinfo.err = jpeg_std_error(&jerr);
  jpeg_create_compress(&cinfo);

  // 2. Ouverture du flux de sortie en binaire ("wb")
  FILE *outfile = fopen(fname, "wb");
  if (!outfile) {
    jpeg_destroy_compress(&cinfo);
    throw std::runtime_error(std::string("Impossible d'ouvrir : ") + fname);
  }
  jpeg_stdio_dest(&cinfo, outfile);

  // 3. Définition des paramètres de l'image source
  cinfo.image_width = width;
  cinfo.image_height = height;
  cinfo.input_components = 3;
  cinfo.in_color_space = JCS_RGB;

  jpeg_set_defaults(&cinfo);
  jpeg_set_quality(&cinfo, quality, TRUE);

  // 4. Lancement de la compression
  jpeg_start_compress(&cinfo, TRUE);

  // 5. Écriture ligne par ligne (scanlines)
  JSAMPROW row_pointer[1];
  int row_stride = width * 3;
  const JSAMPLE *buffer = reinterpret_cast<const JSAMPLE *>(array);

  while (cinfo.next_scanline < cinfo.image_height) {
    row_pointer[0] = const_cast<JSAMPROW>(&buffer[cinfo.next_scanline * row_stride]);
    jpeg_write_scanlines(&cinfo, row_pointer, 1);
  }

  // 6. Finalisation et nettoyage
  jpeg_finish_compress(&cinfo);
  fclose(outfile);
  jpeg_destroy_compress(&cinfo);
}
```

---

### 3.3 Implantation de `ColorImage::readJPEG` (Décompression Bonus)
```cpp
ColorImage *ColorImage::readJPEG(const char *fname) {
  if (!fname)
    throw std::invalid_argument("Nom de fichier JPEG nul");

  FILE *infile = fopen(fname, "rb");
  if (!infile)
    throw std::runtime_error(std::string("Impossible d'ouvrir : ") + fname);

  struct jpeg_decompress_struct cinfo;
  struct jpeg_error_mgr jerr;

  cinfo.err = jpeg_std_error(&jerr);
  jpeg_create_decompress(&cinfo);
  jpeg_stdio_src(&cinfo, infile);

  // Lecture des marqueurs de l'en-tête (récupération de la géométrie de l'image)
  jpeg_read_header(&cinfo, TRUE);
  cinfo.out_color_space = JCS_RGB;
  jpeg_start_decompress(&cinfo);

  ColorImage *res = new ColorImage(cinfo.output_width, cinfo.output_height);
  int row_stride = cinfo.output_width * cinfo.output_components;
  JSAMPLE *buffer = reinterpret_cast<JSAMPLE *>(res->array);
  JSAMPROW row_pointer[1];

  while (cinfo.output_scanline < cinfo.output_height) {
    row_pointer[0] = &buffer[cinfo.output_scanline * row_stride];
    jpeg_read_scanlines(&cinfo, row_pointer, 1);
  }

  jpeg_finish_decompress(&cinfo);
  fclose(infile);
  jpeg_destroy_decompress(&cinfo);

  return res;
}
```

---

## 4. Analyse Expérimentale des 21 Taux de Qualité

Lors de l'exécution de `tp3.cpp`, 21 images ont été générées de qualité 0 % à 100 % (par pas de 5 %) :

| Fichier Produit | Qualité | Taille sur Disque | Ratio de Réduction | Constat Visuel |
| :--- | :--- | :--- | :--- | :--- |
| **`chat_rectangles.ppm`** | Non compressé | **226 Ko** (230 458 o) | 1:1 (Témoin) | Couleurs pures, bords tranchés |
| **`out_000.jpg`** | 0 % | **2,9 Ko** | **78 : 1** | Blocs 8x8 géants, image presque méconnaissable |
| **`out_020.jpg`** | 20 % | **8,5 Ko** | 26 : 1 | Artefacts de ringing visibles autour du pelage |
| **`out_050.jpg`** | 50 % | **14 Ko** | 16 : 1 | Très bon rendu, légères imprécisions de texture |
| **`chat.jpg` / `out_075.jpg`** | **75 % (Défaut)** | **19 Ko** | **12 : 1** | **Image splendide, indiscernable du PPM à l'œil** |
| **`out_090.jpg`** | 90 % | **29 Ko** | 7,8 : 1 | Qualité photographique studio |
| **`out_100.jpg`** | 100 % | **73 Ko** | 3,1 : 1 | Qualité maximale possible en JPEG |

### Les deux observations indispensables demandées par M. Rémy :
1. **Concordance du défaut 75 % :**  
   Le fichier `chat.jpg` (écrit par `im->writeJPEG("chat.jpg")` sans second argument) et le fichier `out_075.jpg` ont **rigoureusement la même taille de 19 Ko**. Cela confirme informellement que la bibliothèque `libjpeg` adopte par défaut un taux de qualité de 75 %.
2. **Couleurs plus ternes même à 100 % :**  
   Même sur `out_100.jpg`, les rectangles colorés (rouge, vert, bleu) paraissent un peu moins éclatants qu'en PPM. Cela provient du sous-échantillonnage chromatique YCbCr (4:2:0) et de la troncature des transitions à front montant infini par la DCT.

---

## 5. Support de Présentation PDF Style M. Rémy

Le support complet de cours et de TP au format PDF (17 diapositives au format Beamer 16:9 avec en-têtes bleu nuit, puces sphériques 3D, alertes rouges "LE POURQUOI", schémas vectoriels SVG et annexes de code intégral) a été généré et se trouve ici :  
📄 **[TP3_JPEG_Cours_Remy.pdf](file:///home/nene_goto_/Documents/REPO_COURS_BUT2_ARLES_/TP_R3_L01_Immagerie_Numérique/TP3_TD3/TP3_JPEG_Cours_Remy.pdf)**

---

## 6. Synthèse pour le Contrôle (14/10/2026)

| Question Piège | Réponse attendue par M. Rémy |
| :--- | :--- |
| **Quelle étape de la chaîne JPEG supprime de l'information ?** | Uniquement la **Quantification** (division entière par la matrice Q). La DCT et le codage de Huffman sont réversibles sans perte. |
| **Quel est l'intérêt du parcours en Zig-zag ?** | Il classe les coefficients par fréquence spatiale croissante afin de regrouper tous les zéros à la fin du bloc pour émettre un marqueur `EOB` (*End of Block*). |
| **Pourquoi compiler avec `extern "C"` ?** | Pour désactiver le *name mangling* de C++ et permettre à `g++` de trouver les noms des fonctions C exportées par `libjpeg`. |
| **Pourquoi l'option de compilation `-ljpeg` est-elle nécessaire ?** | Pour indiquer à l'éditeur de liens (*linker*) d'incorporer le code binaire de la bibliothèque partagée dynamique `libjpeg.so`. |
