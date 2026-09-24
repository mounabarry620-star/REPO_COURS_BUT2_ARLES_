# Walkthrough TD2 : Imagerie Numérique — Format PPM (P6), Endianness & Débits de Données
**Enseignement : R3.L01 — Représentations et codages des images (BUT 2 Informatique, IUT d'Arles — Enseignant : Éric Rémy)**

---

## 1. Vue d'ensemble du TD2 & Objectifs pédagogiques

Le **TD n°2** approfondit les concepts fondamentaux de la représentation numérique d'images et de la manipulation matérielle des données binaires en C++ :
1. **Extension à la couleur (RGB 24 bits)** : passage du modèle en niveaux de gris (`GrayImage`) au modèle couleur avec les classes `Color` et `ColorImage`, et prise en main du format standardisé **PPM** (*Portable PixMap*, variante P6 binaire).
2. **Gestion de l'Endianness (Gros-boutiste vs Petit-boutiste)** : comprendre comment les données binaires sont physiquement stockées en mémoire selon le processeur, implanter un patron de fonction générique `swap_bytes` et concevoir un parseur de fichiers binaire 100% portable.
3. **Ordres de grandeur et débits vidéo** : calculer l'empreinte mémoire d'images volumiques et démontrer pourquoi la compression d'images et vidéo est une nécessité absolue dans l'industrie informatique.

---

## 2. Exercice 1 : Le Format PPM (P6) & Les Classes Couleur

### 2.1 Fondations du cours (CM Diapos 38, 39 et 57)

#### La classe `Color` (CM Diapo 38)
Une couleur est représentée par le triplet additif **RGB** (Rouge, Vert, Bleu) sur 24 bits (8 bits par composante, soit $2^{24} \approx 16,7$ millions de couleurs possibles, souvent appelé *TrueColor*) :
```cpp
class Color {
public:
    uint8_t r, g, b; // Données membres publiques

    inline Color(uint8_t _r = 0, uint8_t _g = 0, uint8_t _b = 0)
        : r(_r), g(_g), b(_b) {}

    friend bool operator==(const Color& c1, const Color& c2) {
        return c1.r == c2.r && c1.g == c2.g && c1.b == c2.b;
    }

    friend Color operator*(double alpha, const Color& color) {
        return Color((uint8_t)(alpha * color.r), 
                     (uint8_t)(alpha * color.g), 
                     (uint8_t)(alpha * color.b));
    }

    friend Color operator+(const Color& c1, const Color& c2) {
        return Color(c1.r + c2.r, c1.g + c2.g, c1.b + c2.b);
    }
};
```

> [!IMPORTANT]
> **Pas de padding mémoire dans `Color` :**  
> `sizeof(uint8_t)` vaut 1 octet. L'alignement mémoire de `uint8_t` étant de 1, la structure `Color` occupe exactement **3 octets consécutifs** en RAM (`sizeof(Color) == 3`), sans aucun trou d'alignement.  
> Un tableau dynamique `Color* array` est donc une suite ininterrompue d'octets : $R_0, G_0, B_0, R_1, G_1, B_1, \dots$

#### La classe `ColorImage` (CM Diapo 39)
Elle reprend l'architecture exacte de `GrayImage` vue au TD1 (implantation à plat 1D, dimensions constantes, interdictions C++11, RAII), en substituant `uint8_t*` par `Color*` :
- Dimensions : `const uint16_t width, height;`
- Tableau dynamique : `Color* array;` alloué par `array = new Color[width * height];`
- Taille totale du tableau en mémoire vive : $\text{width} \times \text{height} \times 3$ octets.

---

### 2.2 Question 1 : Analyse et décodage hexadécimal de l'image de test (Figure 1 du TD)

L'énoncé présente une image de dimensions $3 \times 3$ pixels.

```
                  x = 0               x = 1               x = 2
             +-------------------+-------------------+-------------------+
    y = 0    |  Noir (00 00 00)  |  Gris (80 80 80)  |  Blanc (ff ff ff) |
             +-------------------+-------------------+-------------------+
    y = 1    |  Rouge (ff 00 00) |  Vert (00 ff 00)  |  Bleu (00 00 ff)  |
             +-------------------+-------------------+-------------------+
    y = 2    |  Cyan (00 ff ff)  | Magenta (ff 00 ff)|  Jaune (ff ff 00) |
             +-------------------+-------------------+-------------------+
```

#### Décodage exhaustif du dump hexadécimal / ASCII :
```text
Offset    Octets Hexadécimaux           Interprétation ASCII / Rôle
---------------------------------------------------------------------------------------------------------
00000000  50 36 0a                      "P6\n"                -> Magic Number (PPM Binaire)
          23 20 4d 61 64 65 20 62 79    "# Made by "          -> Début commentaire créateur
00000010  45 2e 20 52 65 6d 79 0a       "E. Remy\n"           -> Fin commentaire créateur
          33 20 33 0a                   "3 3\n"               -> Dimensions : width=3, height=3
          32 35 35 0a                   "255\n"               -> Dynamique maximale (1 octet / composante)
          00 00 00                      (R=0,   G=0,   B=0)   -> Pixel (0,0) : Noir
00000020  80 80 80                      (R=128, G=128, B=128) -> Pixel (1,0) : Gris moyen
          ff ff ff                      (R=255, G=255, B=255) -> Pixel (2,0) : Blanc pur
          ff 00 00                      (R=255, G=0,   B=0)   -> Pixel (0,1) : Rouge pur
          00 ff 00                      (R=0,   G=255, B=0)   -> Pixel (1,1) : Vert pur
          00 00 ff                      (R=0,   G=0,   B=255) -> Pixel (2,1) : Bleu pur
          00 ff ff                      (R=0,   G=255, B=255) -> Pixel (0,2) : Cyan
00000030  ff 00 ff                      (R=255, G=0,   B=255) -> Pixel (1,2) : Magenta
          ff ff 00                      (R=255, G=255, B=0)   -> Pixel (2,2) : Jaune
---------------------------------------------------------------------------------------------------------
Bilan : 29 octets d'en-tête ASCII + 27 octets de données binaires = 56 octets (0x38 en hexadécimal).
```

---

### 2.3 Question 2 : Écriture PPM — `void ColorImage::writePPM(std::ostream& os) const`

```cpp
void ColorImage::writePPM(std::ostream& os) const {
    // 1. En-tête ASCII conventionnel
    os << "P6\n";
    os << "# Image sauvegardee par un etudiant pour les TP de RepCod.\n";
    os << width << " " << height << "\n";
    os << 255 << "\n";

    // 2. Écriture en un seul bloc binaire rapide (CM Diapo 20)
    // Chaque pixel comporte 3 octets consécutifs (r, g, b).
    os.write((const char*)array, width * height * 3);
}
```

#### Le POURQUOI :
* **Pourquoi `width * height * 3` ?** Une image de $W \times H$ pixels couleur possède 3 canaux indépendants par pixel. Le nombre total d'octets à écrire sur le disque est donc $3 \times W \times H$.
* **Pourquoi un appel unique à `os.write()` avec `(const char*)array` ?** Comme `sizeof(Color) == 3`, les triplets RGB sont rigoureusement consécutifs en mémoire vive. Effectuer un seul appel système d'écriture par bloc est infiniment plus rapide que de faire des millions d'appels `os.put()` pixel par pixel.

---

### 2.4 Question 3 : Lecture PPM — `static ColorImage* ColorImage::readPPM(std::istream& is)`

```cpp
ColorImage* ColorImage::readPPM(std::istream& is) {
    // 1. Contrôle du Magic Number
    std::string magic = "";
    if (!(is >> magic)) {
        throw std::runtime_error("Fichier vide ou illisible");
    }
    if (magic != "P6" && magic != "P3") {
        throw std::runtime_error("Format non PPM (doit etre P6 binaire ou P3 ASCII)");
    }

    skip_comments(is);

    // 2. Lecture des dimensions de l'image
    uint16_t w = 0, h = 0;
    if (!(is >> w >> h)) {
        throw std::runtime_error("Erreur de lecture des dimensions");
    }

    skip_comments(is);

    // 3. Lecture de la dynamique
    int dyn = 0;
    if (!(is >> dyn) || dyn != 255) {
        throw std::runtime_error("Dynamique invalide (doit etre egale a 255)");
    }

    // 4. Instanciation dynamique sur le tas
    ColorImage* res = new ColorImage(w, h);

    if (magic == "P6") {
        // Règle d'or de la norme Netpbm (PGM.txt) :
        // Consommer STRICTEMENT le seul et unique séparateur blanc qui suit 255
        char sep = ' ';
        is.get(sep);

        // Lecture du flux binaire en un seul bloc
        is.read((char*)res->array, w * h * 3);
        if (!is) {
            delete res;
            throw std::runtime_error("Erreur lors de la lecture des donnees binaires");
        }
    } else { // Format Bonus P3 (ASCII)
        for (size_t t = 0; t < size_t(w * h); ++t) {
            int r, g, b;
            if (!(is >> r >> g >> b)) {
                delete res;
                throw std::runtime_error("Erreur lors de la lecture des triplets ASCII P3");
            }
            res->array[t] = Color((uint8_t)r, (uint8_t)g, (uint8_t)b);
        }
    }

    return res;
}
```

#### Le POURQUOI :
* **Pourquoi la méthode est `static` ?** Comme au TD1, cela résout le paradoxe de la création : sans méthode statique, il faudrait déjà posséder une instance en mémoire pour pouvoir appeler la méthode chargée d'en fabriquer une.
* **Pourquoi `is.get(sep)` après 255 ?** Si l'on utilisait `is >> ...`, et que la composante Rouge du premier pixel était `10` (`\n`) ou `32` (espace), ce premier octet de pixel serait avalé par erreur, ce qui décalerait et corromprait la totalité de l'image !

---

## 3. Exercice 2 : Endianness, Byte Swapping et Portabilité

### 3.1 Fondations du cours (CM Diapos 14 à 20)

Pour un nombre codé sur plusieurs octets (ex: entier 32 bits `0x12345678`), il existe deux conventions d'ordonnancement en mémoire :
* **Little-Endian (« petit-boutiste ») :** On commence par stocker l'octet de **poids faible** à l'adresse mémoire la plus basse. Utilisé par Intel x86, AMD64, ARM (par défaut).
* **Big-Endian (« gros-boutiste ») :** On commence par stocker l'octet de **poids fort** à l'adresse la plus basse (sens de lecture naturelle humaine). Utilisé par le réseau IP, les anciens processeurs Motorola 68000 et PowerPC.

```text
Entier 32 bits : 0x12345678
Adresse relative :       +0       +1       +2       +3
Big-Endian       :     [ 12 ]   [ 34 ]   [ 56 ]   [ 78 ]   (Poids fort en tête)
Little-Endian    :     [ 78 ]   [ 56 ]   [ 34 ]   [ 12 ]   (Poids faible en tête)
```

**Problématique du TD2 :** Le fichier `data.dat` a été généré sur une machine **Big-Endian**. En le lisant directement sur notre PC Intel (**Little-Endian**), les octets se retrouvent inversés.

---

### 3.2 Question 1 : Le patron de fonction `swap_bytes`

```cpp
template <typename T>
void swap_bytes(T& val) {
    char* ptr = (char*)&val;
    size_t n = sizeof(T);
    for (size_t i = 0; i < n / 2; ++i) {
        char tmp = ptr[i];
        ptr[i] = ptr[n - 1 - i];
        ptr[n - 1 - i] = tmp;
    }
}
```

#### Le POURQUOI :
1. **Généricité complète (`template <typename T>`) :** `sizeof(T)` s'adapte automatiquement à n'importe quel type reçu (2 octets pour `int16_t`, 4 octets pour `int32_t`, 8 octets pour `double`, etc.).
2. **Permutation miroir :** On échange l'octet $i$ avec son symétrique $n - 1 - i$. Dès qu'on atteint la moitié $n / 2$, tous les octets ont été inversés.
   ```text
   Avant swap :  [ Octet 0 ]  [ Octet 1 ]  [ Octet 2 ]  [ Octet 3 ]
                      \            \            /            /
                       \____________\__________/____________/
                                     \        /
   Après swap :  [ Octet 3 ]  [ Octet 2 ]  [ Octet 1 ]  [ Octet 0 ]
   ```

---

### 3.3 Question 2 : Lecture des données de `data.dat` sur PC Little-Endian

```cpp
#include <fstream>
#include <cstdint>
#include <string>
#include <iostream>

void lire_data_dat(std::istream& is) {
    // 1. Entier signé 16 bits codé en complément à deux (2 octets)
    int16_t entier16 = 0;
    is.read((char*)&entier16, sizeof(int16_t));
    swap_bytes(entier16); // Inversion nécessaire de Big vers Little

    // 2. Réel flottant IEEE 754 double précision (8 octets = 64 bits)
    double reel64 = 0.0;
    is.read((char*)&reel64, sizeof(double));
    swap_bytes(reel64); // Inversion des 8 octets

    // 3. Marqueur FourCC : tableau de 4 caractères ASCII (4 octets)
    char fourcc[4];
    is.read(fourcc, 4); // ATTENTION : PAS DE SWAP_BYTES !

    // 4. Chaîne Pascal : 1 octet de longueur suivi des caractères
    uint8_t taille = 0;
    is.read((char*)&taille, 1); // 1 octet atomique : pas d'endianness !
    std::string str(taille, '\0');
    is.read(&str[0], taille);  // Suite de caractères : PAS DE SWAP_BYTES !
}
```

#### Le POURQUOI (Question piège d'examen très fréquente) :
* **Pourquoi `swap_bytes` sur l'entier et le réel IEEE 754 ?**  
  Ce sont des **grandeurs scalaires atomiques réparties sur plusieurs octets**. Leur signification numérique découle du poids respectif de chaque octet. Si on ne permute pas les 8 octets du `double`, l'exposant et la mantisse sont mélangés et la valeur devient absurde.
* **Pourquoi SURTOUT PAS de `swap_bytes` sur le FourCC ou la chaîne de texte ?**  
  Une chaîne de caractères ou un tableau `char[4]` est une **séquence ordonnée d'octets individuels** d'un octet chacun (`sizeof(char) == 1`).  
  Si le fichier contient `"JPEG"` (octets `'J'`, `'P'`, `'E'`, `'G'`) :
  - La lecture séquentielle lit bien `'J'` puis `'P'` puis `'E'` puis `'G'`.
  - Appliquer `swap_bytes` inverserait les lettres et produirait `"GEPJ"`, ce qui est faux !  
  > **Règle fondamentale : L'endianness ne concerne QUE les types scalaires de taille strictement supérieure à 1 octet.**

---

### 3.4 Question 3 : Conception d'un code totalement portable

Pour que le programme s'exécute avec exactitude sur n'importe quel ordinateur au monde (qu'il soit Little-Endian ou Big-Endian), on automatise la détection à l'exécution :

```cpp
// Détection matérielle de l'architecture hôte
inline bool is_little_endian() {
    uint16_t test = 0x0001;
    // Si l'octet de poids faible (1) se trouve à l'adresse basse, la machine est Little-Endian
    return *((char*)&test) == 1;
}

// Fonction de conversion conditionnelle portable
template <typename T>
void from_big_endian(T& val) {
    if (is_little_endian()) {
        swap_bytes(val); // On ne permute que si la machine hôte est Little-Endian
    }
    // Si la machine est déjà Big-Endian, l'ordre est déjà parfait !
}
```

La lecture portable devient limpide :
```cpp
is.read((char*)&entier16, sizeof(int16_t));
from_big_endian(entier16);

is.read((char*)&reel64, sizeof(double));
from_big_endian(reel64);
```

---

## 4. Exercice 3 : Tailles de Données & Débits Vidéo

### 4.1 Question 1 : Tailles en mémoire vive des images

#### a. Smartphone couleur 24 bits ($4032 \times 3024$)
* **Nombre de pixels :** $4032 \times 3024 = 12\,192\,768$ pixels ($\approx 12,2\text{ Mpixels}$).
* **Taille brute du tableau :** $12\,192\,768 \times 3\text{ octets} = 36\,578\,304\text{ octets}$.
  - En Mégaoctets décimaux ($10^6$) : $\mathbf{36,58\text{ Mo}}$.
  - En Mébioctets informatiques ($2^{20} = 1\,048\,576$) : $\mathbf{34,88\text{ Mio}}$.
* **Différence PC 32 bits vs 64 bits :**
  - Sur 32 bits : l'objet `ColorImage` occupe 8 octets en mémoire (2 o de `width` + 2 o de `height` + 4 o de pointeur `array`).
  - Sur 64 bits : l'objet occupe 16 octets (2 o de `width` + 2 o de `height` + 4 octets de padding d'alignement + 8 o de pointeur `array`).
  - **Conclusion :** L'écart de 8 octets pour les attributs de la classe est **totalement négligeable** devant les 36,5 Mo du tableau alloué sur le tas.

#### b. Reflex numérique 24 bits ($7360 \times 4912$)
* **Nombre de pixels :** $7360 \times 4912 = 36\,152\,320$ pixels ($\approx 36,15\text{ Mpixels}$).
* **Taille brute du tableau :** $36\,152\,320 \times 3\text{ octets} = 108\,456\,960\text{ octets}$.
  - Soit $\mathbf{108,46\text{ Mo}}$ ($\mathbf{103,43\text{ Mio}}$).

#### c. Scanner à rayons X volumique 3D ($512 \times 512 \times 512$ voxels sur 16 bits)
* **Nombre de voxels :** $512^3 = (2^9)^3 = 2^{27} = 134\,217\,728$ voxels.
* **Taille par voxel :** 16 bits = 2 octets (`uint16_t`).
* **Taille en mémoire :** $134\,217\,728 \times 2\text{ octets} = 268\,435\,456\text{ octets}$.
  - Soit pile : $\frac{268\,435\,456}{1024 \times 1024} = \mathbf{256\text{ Mio}}$ ($\mathbf{268,44\text{ Mo}}$).

---

### 4.2 Question 2 : Débit brut Ultra HD (4K) à 60 fps & Confrontation aux réseaux

#### 1. Calcul du débit brut
* **Résolution :** Ultra HD = $3840 \times 2160 = 8\,294\,400$ pixels par trame.
* **Taille d'une seule image non compressée :**
  $$8\,294\,400 \times 3\text{ octets} = 24\,883\,200\text{ octets} \approx \mathbf{24,88\text{ Mo / image}}$$
* **Débit en octets par seconde à 60 fps :**
  $$24\,883\,200 \times 60 = 1\,492\,992\,000\text{ octets/s} \approx \mathbf{1,493\text{ Go/s}} \text{ (soit } 1,39\text{ Gio/s)}$$
* **Débit en bits par seconde (grandeur réseau) :**
  $$\text{Débit} = 3840 \times 2160 \times 24\text{ bits} \times 60 = 11\,943\,936\,000\text{ bit/s} \approx \mathbf{11,94\text{ Gbit/s}}$$

#### 2. Tableau comparatif avec les infrastructures réseau

| Connexion Réseau | Débit maximal | Débit 4K brut (11,94 Gbit/s) |
| :--- | :--- | :--- |
| **ADSL** | 20 Mbit/s | Le flux brut est **~600 fois supérieur** |
| **TNT (Télévision numérique)** | 25 Mbit/s | Le flux brut est **~478 fois supérieur** |
| **4G / 5G mesurée moyenne** | ~100 Mbit/s | Le flux brut est **~120 fois supérieur** |
| **Fibre optique (FTTH 100M)** | 100 Mbit/s | Le flux brut est **~120 fois supérieur** |
| **Fibre Gigabit standard** | 1 000 Mbit/s (1 Gbit/s) | Le flux brut est **~12 fois supérieur** |
| **5G théorique de pointe** | 2 100 Mbit/s (2,1 Gbit/s) | Le flux brut est encore **~5,7 fois supérieur** |

#### 3. La conclusion fondamentale du cours (CM Diapo 58-60)
Sans algorithmes de compression d'images et vidéo (JPEG, MPEG-4, H.264, H.265/HEVC, AV1), **aucun streaming vidéo, aucune émission télévisée et aucun stockage sur disque ne seraient envisageables**. La compression réduit le débit nécessaire d'un facteur 100 à 500 tout en restant imperceptible pour l'œil humain.

---

## 5. Synthèse & Fiche de Révision pour le Contrôle TD (14/10/2026)

| Question d'examen potentielle | Réponse synthétique attendue |
| :--- | :--- |
| **Pourquoi `Color` n'a-t-elle pas de padding ?** | Parce que ses membres sont 3 `uint8_t` (alignement 1). `sizeof(Color) == 3`. |
| **Pourquoi `writePPM` écrit $W \times H \times 3$ octets ?** | Chaque pixel couleur contient 3 canaux (R, G, B) de 1 octet chacun. |
| **Quand doit-on utiliser `swap_bytes` ?** | Uniquement sur les grandeurs scalaires atomiques multibytes (`int16_t`, `int32_t`, `float`, `double`) provenant d'une machine d'endianness opposée. |
| **Pourquoi ne fait-on pas de swap sur les tableaux de caractères ?** | Une chaîne ASCII est une suite d'octets élémentaires (`sizeof(char) == 1`). L'endianness ne concerne que les types $> 1$ octet. |
| **Comment tester l'endianness en C++ ?** | En créant un `uint16_t test = 0x0001` et en inspectant son premier octet `*((char*)&test) == 1`. |
