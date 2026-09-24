# Walkthrough TP1 : Imagerie Numérique — Classe `GrayImage` & Format PGM
**Enseignement : R3.L01 — Représentations et codages des images (BUT 2 Informatique, IUT d'Arles — Enseignant : Éric Rémy)**

---

## 1. Comprendre les enjeux du TP et les fondations du cours

### 1.0 Modalités d'évaluation, Calendrier & Supports de Référence
> [!IMPORTANT]
> **Deux supports complémentaires sont disponibles dans votre répertoire de travail :**
> 1. 📄 [**TP1_GrayImage_Cours_Remy.pdf**](file:///home/nene_goto_/Documents/REPO_COURS_BUT2_ARLES_/TP_R3_L01_Immagerie_Num%C3%A9rique/TP1_TD1/TP1_GrayImage_Cours_Remy.pdf) : Présentation de 17 diapositives au format LaTeX Beamer 16:9 widescreen (schémas vectoriels, encadrés « POURQUOI », correspondances de diapos et 4 diapositives d'annexes avec le code intégral).
> 2. 📋 [**walkthrough.md**](file:///home/nene_goto_/Documents/REPO_COURS_BUT2_ARLES_/TP_R3_L01_Immagerie_Num%C3%A9rique/TP1_TD1/walkthrough.md) : Le présent guide détaillé d'étude, d'analyse des notes et d'implémentation C++.

D'après les consignes relevées dans [note.txt](file:///home/nene_goto_/Documents/REPO_COURS_BUT2_ARLES_/TP_R3_L01_Immagerie_Num%C3%A9rique/TP1_TD1/note.txt) :
- **Rigueur absolue sur le nommage des fonctions et prototypes** : Tout sera évalué et testé automatiquement par scripts lors de la 5ème séance. Les noms imposés (`getWidth`, `getHeight`, `pixel`, `clear`, `rectangle`, `fillRectangle`, `writePGM`, `readPGM`) et leurs types doivent être respectés à la lettre.
- **Organisation des séances** :
  - 5 séances au total (4 séances de préparation et progression, et la 5ème séance notée).
  - Rendu global de l'intégralité des 5 séances lors de la dernière séance.
  - Importance du travail personnel : 50% du travail se fait chez soi en amont, 50% en classe. Il est impératif d'arriver au contrôle avec une base de code 100% fonctionnelle, testée et maîtrisée pour répondre rapidement aux questions.
- **Dates des contrôles** :
  - **Contrôle théorique (TD)** : **14/10/2026** (axé sur la compréhension des formats d'image, le découpage binaire, les structures de données, la logique des flux).
  - **Contrôle pratique (TP)** : **06/11/2026** (ou **21/10/2026** selon le choix de la promotion).

---

Le but de ce TP est de poser les bases de la manipulation d'images numériques matricielles en C++.

Une image numérique en niveaux de gris est une grille bidimensionnelle de $W$ colonnes par $H$ lignes.
Chaque case (pixel) contient une valeur d'intensité lumineuse comprise entre 0 (noir absolu) et 255 (blanc pur).

### 1.1 Représentation mémoire « à plat » (Row-Major) — CM Diapo 25
Plutôt que d'allouer un tableau de pointeurs de lignes (`uint8_t**`), ce qui créerait une fragmentation de la mémoire et des défauts de cache processeur, le cours préconise une **implantation à plat** sur un tableau 1D continu alloué sur le tas (*heap*) :
- Taille totale allouée : $\text{width} \times \text{height}$ octets.
- Formule de conversion de coordonnées 2D $(x, y)$ vers l'indice 1D $t$ :
  $$t = y \times \text{width} + x$$
  - $x$ est la colonne : $0 \le x < \text{width}$
  - $y$ est la ligne : $0 \le y < \text{height}$

**Le POURQUOI :**
1. **Localité spatiale de cache (L1/L2)** : les pixels contigus d'une même ligne sont voisins en RAM, ce qui permet au CPU de précharger la ligne très rapidement.
2. **Entrées/Sorties rapides** : l'écriture et la lecture sur disque s'effectuent en un seul appel système `os.write()` / `is.read()` pour la totalité des pixels.

### 1.2 Principes de conception C++ imposés par le cours (CM Diapos 26 à 28)
M. Rémy applique rigoureusement les principes de base de la POO C++ (norme C++11) et l'idiome **RAII** (*Resource Acquisition Is Initialization*) :

1. **Constance des dimensions** :
   ```cpp
   const uint16_t width, height;
   ```
   La largeur et la hauteur de l'image ne doivent pas changer pendant la vie de l'objet. Cela évite d'avoir à réallouer le tableau en cours de route et garantit l'intégrité de la zone mémoire.

2. **Suppression du constructeur par défaut et de l'opérateur d'affectation (C++11)** :
   ```cpp
   GrayImage() = delete;
   GrayImage& operator=(const GrayImage& b) = delete;
   ```
   - Créer une image sans dimensions n'a pas de sens physique en mémoire (diapo 26).
   - Affecter une image à une autre (`im1 = im2`) exigerait de changer la taille de `im1` pour adopter celle de `im2`, ce qui est impossible car `width` et `height` sont `const`. On l'interdit donc explicitement.

3. **Constructeur de copie explicite** :
   On alloue un nouveau tableau distinct et on recopie chaque pixel un par un (copie profonde / *deep copy*).

4. **Destructeur** :
   Libère le tableau dynamique avec `delete[] array;`.

5. **Accesseurs `inline` et Left-Value** :
   Pour que l'écriture naturelle `im.pixel(x, y) = 255;` soit possible en C++, la fonction renvoie une **référence non-constante** (`uint8_t&`).
   Une seconde surcharge constante `const uint8_t& pixel(...) const` assure la consultation sur des instances constantes.

---

## 2. Analyse des formats, du TD1 et de la norme `PGM.txt`

### 2.1 Structure du format PGM P5 (Binaire RAW)
1. **Magic Number** : la chaîne `"P5"` suivie d'un retour chariot `\n` (ou espace blanc).
2. **Commentaires** : zéro ou plusieurs lignes commençant par le caractère `'#'`.
3. **Dimensions** : la largeur $W$ puis la hauteur $H$ écrites en décimal ASCII, séparées par un espace, puis `\n`.
4. **Commentaires éventuels** : d'autres commentaires peuvent se trouver ici (comme dans `chat.pgm` !).
5. **Dynamique max** : le texte `"255"` (valeur max du pixel), suivi d'un unique séparateur blanc.
6. **Données des pixels** : exactement $W \times H$ octets binaires bruts, ligne par ligne du haut vers le bas.

---

### 2.2 Éclairages apportés par la spécification officielle ([`PGM.txt`](file:///home/nene_goto_/Documents/REPO_COURS_BUT2_ARLES_/TP_R3_L01_Immagerie_Num%C3%A9rique/TP1_TD1/PGM.txt))
Le fichier `PGM.txt` est la page de manuel UNIX originelle (`man 5 pgm`) rédigée par **Jef Poskanzer** (créateur des formats Netpbm). Ce texte apporte 4 garanties fondamentales pour le code et les examens :

1. **Règle d'or de l'unique séparateur après 255 (Lignes 66-68) :**
   > *« No whitespace is allowed in the grays section, and only a single character of whitespace (typically a newline) is allowed after the maxval. »*
   
   **Conséquence :** après avoir lu `255`, il faut lire **strictement un seul octet** avec `is.get(sep)` avant de basculer en lecture binaire brute. Si on utilisait un saut de blanc automatique (`is >> ...`), et que le premier pixel de l'image valait 10 (`\n`) ou 32 (`' '`), ce pixel serait détruit et toute l'image serait décalée !

2. **Définition officielle des blancs / Whitespace (Ligne 15) :**
   > *« Whitespace (blanks, TABs, CRs, LFs). »*
   
   Cela justifie les 4 caractères testés dans `skip_comments` sans bibliothèque externe :
   - `c == ' '` (espace / blank)
   - `c == '\t'` (tabulation)
   - `c == '\r'` (Carriage Return)
   - `c == '\n'` (Line Feed)

3. **Principe de robustesse / permissivité (Lignes 53-55) :**
   > *« Programs that read this format should be as lenient as possible, accepting anything that looks remotely like a graymap. »*
   
   Justifie la présence de commentaires intercalaires `# Encore du bordel` après les dimensions dans `chat.pgm`.

4. **Différence P2 (ASCII) vs P5 (Binaire RAW) :**
   - **P2** : valeurs stockées sous forme de texte décimal ASCII (lisible par l'humain, limité à 70 caractères par ligne, lourd et lent).
   - **P5** : valeurs stockées sous forme d'octets binaires bruts (1 octet par pixel, compact, chargement instantané).

---

### 2.3 Analyse et correction des notes de cours (`corrigé_TD.txt`)

Comparons vos notes prises au vol avec le code exact attendu par M. Rémy :

#### A. Écriture : `writePGM`
- **Dans vos notes :**
  ```cpp
  void grayImage: PGM (std:: ostream& f) const {
      os << "P5 \n" << this -> _width << " " << this -> length
      << "\n" << "# Bonjour" << "\n" << 255 << "\n";
      os.write((const char *), this -> array);
  }
  ```
- **Correction et explication :**
  * Le prototype est `void GrayImage::writePGM(std::ostream& os) const`.
  * Les membres du cours sont `width` et `height` (pas `_width` ou `length`).
  * `os.write` prend deux arguments : le pointeur `(const char*)array` et le nombre d'octets `width * height` :
    ```cpp
    os.write((const char*)array, width * height); // Cast (const char*) exact du prof
    ```

#### B. Saut de ligne : `skip_line`
- **Dans vos notes :**
  ```cpp
  void skip_line (std::istream &){
      char c = '';
      while (c != '\n'){
          c = is.get();
      }
  }
  ```
- **Correction et explication :**
  * En C++, `char c = '';` est une erreur de syntaxe.
  * On lit caractère par caractère jusqu'à rencontrer `'\n'` (Line Feed) :
    ```cpp
    void GrayImage::skip_line(std::istream& is) {
        char c = ' ';
        while (c != '\n' && is.get(c)) {}
    }
    ```

#### C. Saut de commentaires : `skip_comments` et le piège de `chat.pgm`
- **Dans vos notes :**
  ```cpp
  void skip_comments (std::istream&) {
      char c = is.get(c);
      while (c == '#'){
          skip_line(is);
          is.get(c);
      }
      is.putback(c);
  }
  ```
- **Le piège subtil de `chat.pgm` :**
  Regardez l'en-tête de `chat.pgm` :
  ```text
  P5
  # CREATOR: The GIMP's PNM Filter Version 1.0
  # Un commentaire...
  320 240
  # Encore du bordel
  # après les dimensions
  255
  ```
  Quand on lit les dimensions avec `is >> width >> height`, le curseur du flux s'arrête **juste après le `240`**, c'est-à-dire sur le `\n` !
  Si `skip_comments` ne consomme pas ce `\n`, le premier caractère lu par `is.get(c)` sera `'\n'`.
  Comme `'\n' != '#'`:
  1. `skip_comments` croit à tort qu'il n'y a pas de commentaire et remet le `'\n'` dans le flux (`putback`).
  2. L'instruction suivante `is >> dyn` saute le `\n`, mais tombe sur `# Encore du bordel` !
  3. Comme `'#'` n'est pas un chiffre, la lecture de `dyn` échoue (`failbit`).
  
  **Solution 100% conforme au cours :**
  ```cpp
  void GrayImage::skip_comments(std::istream& is) {
      char c;
      while (is.get(c)) {
          // Saut des blancs (espace, tabulation, retours chariot)
          if (c == ' ' || c == '\t' || c == '\n' || c == '\r') {
              continue;
          }
          if (c == '#') {
              skip_line(is); // Ignore la ligne de commentaire
          } else {
              is.putback(c); // Caractère utile retrouvé : replacé sur le flux
              break;
          }
      }
  }
  ```

#### D. Lecture de l'image : `readPGM`
- **Pourquoi la méthode est `static` ? (Rappel TD1 p. 2/2)**
  Si `readPGM` était une méthode d'instance, il faudrait déjà posséder un objet `GrayImage` alloué en mémoire pour pouvoir appeler la méthode qui va charger le fichier et créer l'image : c'est le serpent qui se mord la queue !
  En la déclarant `static` :
  ```cpp
  static GrayImage* readPGM(std::istream& is);
  ```
  Elle s'appelle directement sur la classe sans instance préalable :
  ```cpp
  GrayImage* img = GrayImage::readPGM(fichier);
  ```

---

## 3. Conception complète du TP1 selon le sujet

### 3.1 Gestion d'erreurs par exceptions C++
Le sujet impose l'utilisation de classes d'exceptions judicieusement choisies (`<stdexcept>`) :
- `std::invalid_argument` : dimensions nulles ($w=0$ ou $h=0$).
- `std::out_of_range` : coordonnées hors limites dans `pixel(x, y)` ou rectangle dépassant de l'image.
- `std::runtime_error` : flux invalide, magic number non reconnu, données corrompues.

### 3.2 Méthodes géométriques
- **`clear(uint8_t gray = 0)`** : efface l'image en affectant `gray` à l'ensemble des pixels en parcours 1D séquentiel.
- **`rectangle(x, y, w, h, gray)`** : trace le cadre d'1 pixel d'épaisseur en dessinant les 4 segments (haut, bas, gauche, droite).
- **`fillRectangle(x, y, w, h, gray)`** : remplit la surface rectangulaire par double boucle imbriquée.

---

## 4. Code Source Complet (Syntaxe 100% M. Rémy)

### 4.1 `GrayImage.hpp`
```cpp
#ifndef GRAYIMAGE_HPP
#define GRAYIMAGE_HPP

#include <cstdint>
#include <iostream>
#include <stdexcept>
#include <string>

class GrayImage {
private:
    const uint16_t width, height; // Largeur et hauteur de l'image (constantes)
    uint8_t * array;              // Pointeur vers le tableau 1D alloué dynamiquement

    // Construction sans paramètre interdite (C++11)
    GrayImage() = delete;

public:
    // Affectation interdite (les dimensions sont const)
    GrayImage& operator=(const GrayImage& b) = delete;

    // Constructeurs et destructeur (CM Diapo 27)
    GrayImage(uint16_t w, uint16_t h);
    GrayImage(const GrayImage& orig);
    ~GrayImage();

    // Accesseurs de dimensions (CM Diapo 28)
    inline const uint16_t& getWidth() const { return width; }
    inline const uint16_t& getHeight() const { return height; }

    // Accesseurs de pixels (modification & consultation) avec contrôle des bornes
    inline uint8_t& pixel(uint16_t x, uint16_t y) {
        if (x >= width || y >= height) {
            throw std::out_of_range("Coordonnees du pixel en dehors de l'image");
        }
        return array[y * width + x];
    }

    inline const uint8_t& pixel(uint16_t x, uint16_t y) const {
        if (x >= width || y >= height) {
            throw std::out_of_range("Coordonnees du pixel en dehors de l'image");
        }
        return array[y * width + x];
    }

    // Méthodes de dessin géométrique (TP1)
    void clear(uint8_t gray = 0);
    void rectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint8_t gray);
    void fillRectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint8_t gray);

    // Entrées / Sorties PGM (TD1)
    void writePGM(std::ostream& os) const;

    // Fonctions utilitaires statiques
    static void skip_line(std::istream& is);
    static void skip_comments(std::istream& is);

    // Fonction de classe (statique) pour la lecture
    static GrayImage* readPGM(std::istream& is);
};

#endif // GRAYIMAGE_HPP
```

---

### 4.2 `GrayImage.cpp`
```cpp
#include "GrayImage.hpp"

// Construction à partir des dimensions (CM Diapo 27)
GrayImage::GrayImage(uint16_t w, uint16_t h)
    : width(w), height(h), array(nullptr)
{
    if (w == 0 || h == 0) {
        throw std::invalid_argument("Les dimensions de l'image doivent etre strictement positives");
    }
    array = new uint8_t[width * height];
}

// Construction de copie profonde (CM Diapo 27)
GrayImage::GrayImage(const GrayImage& o)
    : width(o.width), height(o.height), array(nullptr)
{
    array = new uint8_t[o.width * o.height];
    for (size_t t = 0; t < size_t(width * height); t++) {
        array[t] = o.array[t];
    }
}

// Destructeur (CM Diapo 27)
GrayImage::~GrayImage() {
    delete[] array;
}

// Effacer l'image (remplir avec la nuance gray)
void GrayImage::clear(uint8_t gray) {
    for (size_t t = 0; t < size_t(width * height); t++) {
        array[t] = gray;
    }
}

// Tracer un contour de rectangle (1 pixel d'épaisseur)
void GrayImage::rectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint8_t gray) {
    if (w == 0 || h == 0) return;

    if (x + w > width || y + h > height) {
        throw std::out_of_range("Le rectangle depasse des limites de l'image");
    }

    // Ligne haute et ligne basse
    for (uint16_t i = 0; i < w; i++) {
        pixel(x + i, y) = gray;
        pixel(x + i, y + h - 1) = gray;
    }

    // Bord gauche et bord droit
    for (uint16_t j = 0; j < h; j++) {
        pixel(x, y + j) = gray;
        pixel(x + w - 1, y + j) = gray;
    }
}

// Tracer un rectangle plein
void GrayImage::fillRectangle(uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint8_t gray) {
    if (w == 0 || h == 0) return;

    if (x + w > width || y + h > height) {
        throw std::out_of_range("Le rectangle plein depasse des limites de l'image");
    }

    for (uint16_t j = 0; j < h; j++) {
        for (uint16_t i = 0; i < w; i++) {
            pixel(x + i, y + j) = gray;
        }
    }
}

// Écriture au format PGM binaire (P5) - TD1 Question 2 & corrigé_TD.txt
void GrayImage::writePGM(std::ostream& os) const {
    os << "P5\n";
    os << "# Image sauvegardee par un etudiant pour les TP de RepCod.\n";
    os << width << " " << height << "\n";
    os << 255 << "\n";
    os.write((const char*)array, width * height); // Cast direct (const char*) vu au TD
}

// Sauter une ligne jusqu'au Line Feed (corrigé_TD.txt)
void GrayImage::skip_line(std::istream& is) {
    char c = ' ';
    while (c != '\n' && is.get(c)) {}
}

// Sauter les commentaires et blancs intercalaires (gestion de chat.pgm)
void GrayImage::skip_comments(std::istream& is) {
    char c;
    while (is.get(c)) {
        // Saut des caractères blancs conformes à la norme Netpbm (PGM.txt)
        if (c == ' ' || c == '\t' || c == '\n' || c == '\r') {
            continue;
        }
        if (c == '#') {
            skip_line(is); // Ignore la ligne de commentaire
        } else {
            is.putback(c); // Caractère utile retrouvé : replacé dans le flux
            break;
        }
    }
}

// Lecture PGM (TD1 Question 5 & corrigé_TD.txt - support P5 binaire et P2 ASCII)
GrayImage* GrayImage::readPGM(std::istream& is) {
    std::string magic = "";
    if (!(is >> magic)) {
        throw std::runtime_error("Pas de magic number");
    }

    if (magic != "P5" && magic != "P2") {
        throw std::runtime_error("Ce n'est pas du format PGM");
    }

    skip_comments(is);

    uint16_t width = 0, height = 0;
    if (!(is >> width >> height)) {
        throw std::runtime_error("Pas de largeur ni de hauteur valide");
    }

    skip_comments(is);

    int dyn = 0;
    if (!(is >> dyn) || dyn != 255) {
        throw std::runtime_error("Dynamique invalide (doit valoir 255)");
    }

    // Instanciation dynamique à la taille lue
    GrayImage* res = new GrayImage(width, height);

    if (magic == "P5") {
        char sep = ' ';
        is.get(sep); // Règle d'or de PGM.txt : consomme strictement l'unique séparateur après 255

        is.read((char*)res->array, width * height); // Cast direct (char*) exact vu au TD
        if (!is) {
            delete res;
            throw std::runtime_error("Erreur lors de la lecture des pixels binaires");
        }
    } else { // Format P2 ASCII (Bonus)
        for (size_t t = 0; t < size_t(width * height); t++) {
            int val = 0;
            if (!(is >> val)) {
                delete res;
                throw std::runtime_error("Erreur lors de la lecture des pixels ASCII P2");
            }
            res->array[t] = (uint8_t)val;
        }
    }

    return res;
}
```

---

### 4.3 `main.cpp` (Validation complète)
```cpp
#include "GrayImage.hpp"
#include <iostream>
#include <fstream>

int main() {
    try {
        std::cout << "=== Test 1 : Creation d'une image non-carree et dessin ===" << std::endl;
        GrayImage testImage(400, 250);
        
        // 1. Fond gris moyen
        testImage.clear(180);

        // 2. Dessiner des cadres et des rectangles pleins
        testImage.rectangle(20, 20, 100, 60, 0);         // Cadre noir 1px
        testImage.fillRectangle(150, 40, 80, 80, 50);    // Rectangle plein gris fonce
        testImage.fillRectangle(270, 50, 60, 120, 255);  // Rectangle plein blanc pur

        // 3. Sauvegarder dans un fichier PGM
        std::ofstream fileOut("test_rectangles.pgm", std::ios::binary);
        if (!fileOut) {
            throw std::runtime_error("Impossible de creer test_rectangles.pgm");
        }
        testImage.writePGM(fileOut);
        fileOut.close();
        std::cout << "-> 'test_rectangles.pgm' genere avec succes !" << std::endl;

        std::cout << "\n=== Test 2 : Lecture de chat.pgm, modifications et sauvegarde ===" << std::endl;
        std::ifstream fileChat("chat.pgm", std::ios::binary);
        if (!fileChat) {
            throw std::runtime_error("Impossible d'ouvrir 'chat.pgm'");
        }

        // Lecture statique
        GrayImage* chat = GrayImage::readPGM(fileChat);
        fileChat.close();

        std::cout << "-> 'chat.pgm' charge avec succes ! Dimensions : " 
                  << chat->getWidth() << "x" << chat->getHeight() << std::endl;

        // Dessiner sur le chat
        chat->rectangle(10, 10, 60, 40, 255);                      // Cadre blanc
        chat->fillRectangle(chat->getWidth() - 70, 10, 50, 50, 0); // Carre noir

        // Sauvegarde sous un autre nom
        std::ofstream fileChatOut("chat_modifie.pgm", std::ios::binary);
        if (!fileChatOut) {
            delete chat;
            throw std::runtime_error("Impossible de creer 'chat_modifie.pgm'");
        }
        chat->writePGM(fileChatOut);
        fileChatOut.close();
        delete chat; // Libération mémoire indispensable !
        std::cout << "-> 'chat_modifie.pgm' cree avec succes !" << std::endl;

        std::cout << "\n=== Test 3 : Verification des exceptions ===" << std::endl;
        try {
            testImage.pixel(999, 999); // Doit declencher out_of_range
            std::cerr << "ERREUR : L'exception n'a pas ete levee !" << std::endl;
        } catch (const std::out_of_range& e) {
            std::cout << "-> Succes : exception capturee correctement : " << e.what() << std::endl;
        }

        std::cout << "\nTOUS LES TESTS SONT VALIDES !" << std::endl;

    } catch (const std::exception& e) {
        std::cerr << "ERREUR FATALE : " << e.what() << std::endl;
        return 1;
    }

    return 0;
}
```

---

## 5. Compilation et visualisations sous Linux

Pour compiler avec la norme C++11 et tous les avertissements activés :
```bash
g++ -std=c++11 -Wall -Wextra GrayImage.cpp main.cpp -o tp1
./tp1
```

Pour visualiser et comparer le résultat dans la visionneuse recommandée par le professeur :
```bash
eog test_rectangles.pgm &
eog chat.pgm chat_modifie.pgm &
```
*(En ouvrant `chat.pgm` et `chat_modifie.pgm` ensemble dans `eog`, basculez avec les touches fléchées gauche/droite pour vérifier immédiatement le positionnement exact de vos tracés).*
