# Audit de conformité — méthodes, notations, style

Code audité : `PROJET_FINAL/Image.hpp`, `Image.cpp`, `tp1.cpp` … `tp5.cpp`, `Makefile`.
Copie : `code_a_rendre/`, mêmes empreintes SHA-256. Aucune ligne de ce code n'a été modifiée.

Références : `R3.L01_CM.pdf` (diapos citées), sujets `R3.L01_TD1.pdf`, `R3.L01_TD2.pdf`, `tp1_sujet`, `TP2.txt`, `TP3.TXT`, `tp4.txt`, `tp5.txt`. Les fichiers `corrigé_TD.txt` et `corrige_prof.txt` sont des notes d'étudiant : ils ne corrigent pas le code quand ils contredisent le PDF.

Légende : **conforme** = le code suit le document cité. **écart assumé** = différence volontaire, justifiée par un autre document du module. **ambigu** = le document ne permet pas de trancher. **note fausse** = la prise de notes n'est pas compilable ou contredit le sujet ; le code ne la suit pas, et c'est voulu.

## Classe et noms

| Attendu | Source | Code | Statut |
|---|---|---|---|
| `width`, `height` const `uint16_t`, `array`, `= delete`, copie, destructeur | CM diapos 26-27 | `Image.hpp` | conforme |
| `getWidth`, `getHeight`, `pixel` inline, version `const`, indice `y * width + x` | CM diapos 25 et 28 | `Image.hpp` | conforme. Le CM n'a pas de test de bornes. Le TP1 demande des exceptions : le code lance `out_of_range`. Écart assumé vis-à-vis de la diapo, conforme au sujet. |
| `clear`, `rectangle`, `fillRectangle` | `tp1_sujet`, `TP2.txt` | `Image.cpp` | conforme. `w == 0` ou `h == 0` : retour sans rien dessiner. Le sujet ne précise pas ce cas. Ambigu, sans effet sur les tests. |
| `Color` publique, `==`, `*`, `+` | CM diapo 38 | `Image.hpp` | conforme. `operator!=` est en plus. Inutile au sujet, sans effet sur les tests. |
| Pas de `template Image<T>` | CM diapo 39, « merci de ne pas » sauf 1 ou 2 étudiants | pas de template | conforme au choix par défaut |
| Mêmes fichiers `Image.hpp` / `Image.cpp` | `TP2.txt`, `TP3.TXT` | un seul couple | conforme. Le TP3 écrit aussi `image.hpp` en minuscules : le code suit la casse de `TP2.txt`. |
| Commentaire « Image sauvegardée par XXX pour les TP de RepCod. » | TD1 p.1, TD2 p.1 | `AUTEUR` dans `Image.cpp` | conforme si XXX = Mamadou Bailo BARRY. À confirmer. |

## PGM, PPM

| Attendu | Source | Statut |
|---|---|---|
| `writePGM(ostream&) const`, `readPGM` static | TD1 questions 2 et 5, `tp1_sujet` | conforme |
| `skip_line`, `skip_comments` + `putback` | TD1 questions 3 et 4 | conforme. Les notes `corrigé_TD.txt` ont une syntaxe fausse (`is.get(c)` utilisé comme une valeur, `uint12_t`, `new GrayImage(lenght, lenght)`). Le code suit le PDF, pas ces notes. |
| `ws` avant `skip_comments` | nécessaire pour `chat.pgm` (commentaires après les dimensions) et pour `PGM.txt` (« be as lenient as possible ») | conforme. Test : en-têtes sur une ligne et CR LF, pixels 10 et 35. |
| Un seul `get()` après 255 | piège du cours, octet 10 dans `chat.pgm` | conforme. Comparaison `chat_lunettes.pgm` : 0 pixel différent. |
| P2 et P3 | bonus des sujets TP1 et TP2 | fait, testé sur `Rafale30000` |
| `ios::binary` dans les `main` | CM diapo 9 | conforme |
| `static_assert(sizeof(Color)==3)` | CM diapo 14, écriture par bloc diapos 20-21 | conforme |

## Rééchantillonnage

| Attendu | Source | Statut |
|---|---|---|
| `simpleScale` : parcours de l'arrivée, `x = x' * width / w` entier | `corrige_prof.txt` (notes TD3), sujet TP2 | conforme, aussi pour `GrayImage` |
| `bilinearScale` terminé au tableau | `corrige_prof.txt` s'arrête au prototype | **ambigu**. Le code applique la formule standard citée par `TP2_explications.pdf` et par la fiche `REVISION_CONTROLE_TD_R3L01.pdf` p.15. Ce n'est pas une copie d'un corrigé de tableau. |
| Demi-pixel | sujet TP2 : facultatif, « pratiquement tous les points » sans lui | fait dans `bilinear_coord`. Écart assumé par rapport à la formule entière du tableau. À savoir réécrire **sans** le 0,5 si on le demande. |
| Opérateurs pour ne pas changer la formule | `TP2.txt` | conforme pour `Color`. L'arrondi dans `operator*` peut décaler un niveau de gris d'une unité par rapport à un calcul resté en `double`. La version `GrayImage::bilinearScale` arrondit une seule fois à la fin. Les deux sont dans le code. |

## JPEG

| Attendu | Source | Statut |
|---|---|---|
| `extern "C"` et `-ljpeg` | `TP3.TXT` | conforme (`Image.cpp`, `Makefile`) |
| `writeJPEG(const char*, unsigned int quality)` défaut 75 | `TP3.TXT` | conforme |
| `jpeg_set_quality` avant la compression, pas de `setjmp` | `TP3.TXT` | conforme : `error_exit` lance `runtime_error` |
| Boucle 0…100 pas 5, `out_000.jpg` | `TP3.TXT` | `tp3.cpp` recopie la boucle |
| Qualité 75 = défaut | `TP3.TXT` | mesuré 18 908 = 18 908 sur cette libjpeg |
| `readJPEG`, JPEG gris | pas dans le sujet TP3 ; le TP1 annonce un `writeFormat` JPEG pour le gris | bonus / annonce du TP1. `readJPEG` couleur n'est pas demandé. |

## TGA et Bresenham

| Attendu | Source | Statut |
|---|---|---|
| 24 bits seulement, exception sinon | `tp4.txt` | conforme (`runtime_error`, qui dérive de `std::exception`) |
| `writeTGA(ostream&) const` sous-format 2, puis `writeTGA(ostream&, bool rle=true)` | `tp4.txt` | conforme. Défaut `true` = sous-format 10. |
| `readTGA` sous-format 2, puis 1 (palette → RGB) | `tp4.txt` | conforme. Lecture du 10 : le sujet ne la demande pas explicitement ; elle sert à vérifier l'écriture et à lire `chanel.tga` (type 10). Écart assumé, testé (0 pixel après réécriture). |
| Little endian par masques | TD2 ex. 2, CM diapos 15-19 | `write_uint16_le` / `read_uint16_le` |
| Ordre b,g,r ; bit 5 | `TGA.pdf`, code commenté | conforme sur les fichiers testés (`chat.tga` bit 5 = 1, `chanel.tga` bit 5 = 0, relecture 0 différence) |
| `palette_bl` et `palette_tl` identiques | non écrit dans le sujet | **ambigu**. 1 646 pixels diffèrent après lecture. Un miroir vertical en crée davantage. Pas corrigé, faute d'une consigne qui dirait « ces deux fichiers sont la même image ». |
| `line` avec le pseudo-code octant 1 puis 1-2 puis 8 octants | `tp5.txt` | conforme. Signature en `uint16_t` plutôt que le mot `ushort` du sujet. Voir la fiche. |
| Figures 400×400 | `tp5.txt`, `tp5_im1.png`, `tp5_im2.png` | 0 pixel différent |
| Figure cercle | `tp5.txt` ne fixe pas l'arrondi de `cos`/`sin` | **ambigu**. 7 190 pixels diffèrent de `tp5_im3.png`, les points blancs restent à au plus 1 pixel. `lround` n'est pas dans le sujet. Non modifié. |

## Notes de TD à ne pas recopier telles quelles

Fichier `TP1_TD1/corrigé_TD.txt` : `uint12_t` n'existe pas ; `string` et `getline` ne correspondent pas au PDF ; dimensions en `lenght` deux fois ; `read` avec trois arguments. Le code de `readPGM` ne reprend pas ce brouillon.

Fichier `TP2_TD2/corrige_prof.txt` : `swap_bytes` est le bon algorithme, avec des fautes de frappe (`stuct`, `data a`). `string('X', str_size)` est le mauvais ordre : le code d'entraînement `td2_endianness.cpp` écrit `string(taille, ' ')`. `if (*ptr = 0x34)` est une affectation. L'exercice 3 est une esquisse de calcul, pas un résultat. Les nombres utilisés dans la fiche de révision (36 578 304 octets, 11,9 Gbit/s) ont été revérifiés dans le rapport : ils collent au sujet TD2.

Fichier `TP3_TD3/corrige_prof.txt` : `simpleScale` correspond au code (à la coquille `y_prime = a` près). `bilinearScale` n'a pas de corps.

## Ce qui n'a pas été « amélioré »

Pas de `template`, pas de gestionnaire JPEG autre que l'exception demandée, pas de format hors PGM/PPM/JPEG/TGA, pas de changement d'arrondi pour coller à `tp5_im3.png`. Le style reste celui du CM : types de `<cstdint>`, accès `pixel`, flux, exceptions de `<stdexcept>`.
