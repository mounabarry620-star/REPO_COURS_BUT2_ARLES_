# Walkthrough TP5 (Bonus) : Algorithme de Bresenham Entier
**Enseignement : R3.L01 — Représentations et codages des images (BUT 2 Informatique, IUT d'Arles — Enseignant : Éric Rémy)**

---

## 1. Vue d'ensemble du TP5 & Objectifs pédagogiques

Le **TP n°5** aborde l'un des algorithmes les plus célèbres et fondamentaux de l'informatique graphique : **l'algorithme de tracé de segments de Bresenham (1962)**.

1. **Maîtriser la géométrie discrète & la 8-connexité** : tracer un segment continu entre deux points quelconques $(x_1, y_1)$ et $(x_2, y_2)$ sur une grille de pixels carrés sans laisser de "trous" ou de discontinuités.
2. **Optimisation arithmétique de bas niveau** : éliminer totalement les divisions et les calculs en virgule flottante (`float`, `double`) dans la boucle de rendu pour n'utiliser que des **additions entières**, des **décalages** et des **tests de signe**.
3. **Changement d'axe directeur (Octants 1 et 2)** : comprendre pourquoi le rôle de $x$ et de $y$ doit être inversé dès que la pente dépasse 1 ($\Delta y > \Delta x$).
4. **Généralisation unifiée aux 8 octants du plan** : paramétrer les pas directionnels (`incX = ±1`, `incY = ±1`), sécuriser le nombre d'itérations via un compteur indépendant du sens de parcours, et assurer un découpage de bordure (*clipping*).

---

## 2. Théorie Mathématique : Schémas et « LE POURQUOI »

### 2.1 Le Problème Fondamental
L'équation continue d'une droite reliant $(x_1, y_1)$ à $(x_2, y_2)$ s'écrit :
$$y = m \cdot x + p \quad \text{avec} \quad m = \frac{\Delta y}{\Delta x} = \frac{y_2 - y_1}{x_2 - x_1}$$

```
Grille discrète de pixels (1er Octant : 0 <= dy <= dx)

 y + 1 ───────┼───────────● Pixel D (Diagonal : x+1, y+1)
              │          /
              │       d2/
   y_réel ────┼─────────x  Droite réelle y = m(x+1) + p
              │       d1│
     y ───────┼─────────● Pixel H (Horizontal : x+1, y)
              │
              └─────────┼──────────────► x
                       x + 1
```

À chaque pas élémentaire en $x$ ($x_{i+1} = x_i + 1$), le segment réel passe à l'ordonnée $y_{\text{réel}} = m(x_i + 1) + p$.  
L'algorithme doit choisir entre deux candidats entiers :
- Le pixel **Horizontal H** : $(x_i + 1, y_i)$
- Le pixel **Diagonal D** : $(x_i + 1, y_i + 1)$

Les distances respectives sont :
$$d_1 = y_{\text{réel}} - y_i = m(x_i + 1) + p - y_i$$
$$d_2 = (y_i + 1) - y_{\text{réel}} = y_i + 1 - [m(x_i + 1) + p]$$

La différence de distance est :
$$d_1 - d_2 = 2 m (x_i + 1) + 2p - 2 y_i - 1 = 2 \frac{\Delta y}{\Delta x}(x_i + 1) + 2p - 2y_i - 1$$

---

### 2.2 LE POURQUOI : Pourquoi multiplier par $\Delta x$ ?

> [!IMPORTANT]
> **Pourquoi l'astuce de multiplier la différence par $\Delta x$ ?**  
> Dans $d_1 - d_2$, le terme $\frac{\Delta y}{\Delta x}$ est un nombre rationnel à virgule. Or, dans le premier octant, $x_2 > x_1 \implies \Delta x > 0$.  
> Multiplier par $\Delta x$ ne change donc pas le signe de l'expression !  
> On définit le critère entier :
> $$e_i = \Delta x \cdot (d_1 - d_2)$$
> - Si $e_i < 0$ : $d_1 < d_2 \implies$ le pixel **H** est le plus proche (on conserve $y$).
> - Si $e_i \ge 0$ : $d_1 \ge d_2 \implies$ le pixel **D** est le plus proche (on incrémente $y \leftarrow y + 1$).

---

### 2.3 Dérivation Incrémentale : Les Constantes $c_1$ et $c_2$

Pour calculer $e_{i+1}$ à partir de $e_i$ :
$$e_{i+1} - e_i = 2 \Delta y - 2 \Delta x (y_{i+1} - y_i)$$

Deux cas exclusifs se présentent :
1. **Si $e_i < 0$ (choix H, $y_{i+1} = y_i$) :**
   $$e_{i+1} = e_i + 2 \Delta y \implies \mathbf{e_{i+1} = e_i + c_2} \quad \text{avec} \quad \mathbf{c_2 = 2 \Delta y}$$
2. **Si $e_i \ge 0$ (choix D, $y_{i+1} = y_i + 1$) :**
   $$e_{i+1} = e_i + 2 \Delta y - 2 \Delta x \implies \mathbf{e_{i+1} = e_i + c_1} \quad \text{avec} \quad \mathbf{c_1 = c_2 - 2 \Delta x}$$

**Valeur initiale au départ $(x_1, y_1)$ :**
$$\mathbf{crit\grave{e}re_0 = 2 \Delta y - \Delta x = c_2 - \Delta x}$$

> [!TIP]
> **Complexité :** Le pré-calcul de $c_1$, $c_2$ et $crit\grave{e}re_0$ s'effectue en $\mathcal{O}(1)$. La boucle interne n'effectue **aucune division**, **aucune multiplication** et **aucun flottant** : uniquement des additions et tests de signe entiers !

---

## 3. Évolution des 3 Versions de l'Algorithme

### 3.1 Version 1 : Premier Octant ($0 \le \Delta y \le \Delta x$)
- **Condition géométrique :** $x_1 \le x_2$ et $0 \le (y_2 - y_1) \le (x_2 - x_1)$. Secteur angulaire de $0^\circ$ à $45^\circ$.
- **Validation (Test 1) :** Image 400×400 sur fond rouge, tracé en vert depuis $(0,0)$ vers les points $(399, y)$ espacés de 10 pixels sur le bord droit.

```cpp
void ColorImage::lineOctant1(uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2, const Color col) {
  const int c2 = 2 * (y2 - y1);
  const int c1 = c2 - 2 * (x2 - x1);
  int critere = c2 - (x2 - x1);
  uint16_t x = x1, y = y1;
  while (x <= x2) {
    if (x < width && y < height) pixel(x, y) = col;
    if (critere >= 0) { y++; critere += c1; }
    else { critere += c2; }
    x++;
  }
}
```

---

### 3.2 Version 2 : Extension au Deuxième Octant ($\Delta y > \Delta x \ge 0$)
- **Problématique :** Quand la pente dépasse 1, incrémenter $x$ à chaque pas sauterait plusieurs pixels en $y$, créant des "trous" (rupture de connexité).
- **Solution de M. Rémy :** **Inverser les rôles de $x$ et $y$** ! L'axe directeur devient $y$. À chaque pas en $y$, on teste si $x$ doit être incrémenté.
  - $c_2 = 2 \Delta x$
  - $c_1 = c_2 - 2 \Delta y$
  - $crit\grave{e}re_0 = c_2 - \Delta y$
- **Validation (Test 2) :** Faisceau de lignes vers le bord droit (Octant 1) ET le bord bas (Octant 2). Raccordement sur la diagonale $y = x$.

---

### 3.3 Version 3 : Algorithme Généralisé aux 8 Octants
Pour tracer n'importe quel segment dans n'importe quelle direction :
1. **Sens d'incrémentation :**
   ```cpp
   int incX = (x2 >= x1) ? 1 : -1;
   int incY = (y2 >= y1) ? 1 : -1;
   ```
2. **Longueurs absolues :**
   ```cpp
   int longX = std::abs(x2 - x1);
   int longY = std::abs(y2 - y1);
   ```
3. **Sélection de l'axe directeur & Compteur de boucle :**
   - Si `longY <= longX` (Octants 1, 4, 5, 8) : on boucle sur un compteur de $0$ à `longX`.
   - Si `longY > longX` (Octants 2, 3, 6, 7) : on boucle sur un compteur de $0$ à `longY`.

> [!IMPORTANT]
> **Pourquoi utiliser un compteur indépendant plutôt qu'une boucle `while (x <= x2)` ?**  
> Dans les octants où les coordonnées décroissent ($x_2 < x_1$ ou $y_2 < y_1$), la condition `x <= x2` est fausse dès le premier tour (ou bouclerait indéfiniment si mal inversée). L'utilisation d'un compteur neutre `for (int count = 0; count <= longAxe; ++count)` élimine tout risque d'erreur de boucle.

---

## 4. Test Complet (Test 3) : Faisceau Radial 360°

Le test complet trace 72 rayons bleus partant du centre $(250, 250)$ vers un cercle de rayon $R = 200$ pixels dans une image 500×500 fond noir.

### Les Deux Pièges Signalés par M. Éric Rémy :
1. **Inclusion de `<cmath>` et constante $\pi$ :** Utiliser `M_PI` (avec garde si ANSI strict).
2. **Arguments en radians :** Les fonctions trigonométriques du C++ exigent des radians, pas des degrés :
   $$\text{rad} = \text{deg} \times \frac{\pi}{180.0}$$
   $$x = \text{round}(c_x + R \cos(\text{rad})), \quad y = \text{round}(c_y + R \sin(\text{rad}))$$

Chaque extrémité est ensuite marquée en blanc (`Color(255, 255, 255)`).

---

## 5. Fichiers et Résultats Produit dans le TP5

| Fichier | Dimensions | Format | Description |
| :--- | :--- | :--- | :--- |
| `tp5_test1.ppm` / `.png` | 400 × 400 | PPM / PNG | Faisceau vert sur fond rouge (1er octant) |
| `tp5_test2.ppm` / `.png` | 400 × 400 | PPM / PNG | Faisceau vert bord droit + bord bas (octants 1 & 2) |
| `tp5_test3.ppm` / `.png` | 500 × 500 | PPM / PNG | Cercle radial 72 rayons bleus + extrémités blanches (8 octants) |
| `TP5_Bresenham_Cours_Remy.pdf` | 16:9 Beamer | PDF (8 slides) | Présentation de cours complète style M. Rémy |
| `ColorImage.hpp` & `.cpp` | C++11 | Code source | Classe complète avec constructeurs, PPM, et Bresenham |
| `tp5.cpp` | C++11 | Code source | Programme de validation automatisé |
