# Rapport — préparation du contrôle pratique R3.L01

Contrôle pratique (TP) indiqué dans les supports : **vendredi 6 novembre 2026**.
Périmètre strict : `TP_R3_L01_Immagerie_Numérique` (orthographe du dossier : **Immagerie_Numérique**, avec accent).
Dossier de travail, créé pour cette préparation, sans modification des originaux :

`TP_R3_L01_Immagerie_Numérique/Preparation_Controle_Imagerie_2026-11-06/`

Archive à recopier sur le PC :

`/opt/cursor/artifacts/Preparation_Controle_Imagerie_2026-11-06.zip`

Ce rapport ne garantit pas une note, ni une identité pixel à pixel avec une figure dont le mode d'arrondi n'est pas écrit dans le sujet. Les points ambigus sont listés tels quels.

## 1. Dossier local non synchronisé

Le chemin indiqué

`/home/nene_goto/Documents/REPO_COURS_BUT2_ARLES_/TP_R3_L01_Immagerie_Numérique`

**n'existe pas** dans cet environnement. Aucun fichier « de l'ordinateur » en plus du dépôt n'a pu être lu. Tout ce qui suit repose uniquement sur le dépôt Git. S'il reste des photos de tableau, un énoncé de séance ou une consigne VDI seulement sur le PC, ils ne sont pas dans cette préparation.

## 2. Couverture réelle des documents

Présents et lus (PDF extraits en texte, sujets et notes lus en entier, code de `PROJET_FINAL/` lu en entier) :

| Document | Rôle | Pages ou volume |
|---|---|---|
| `R3.L01_CM.pdf` | Cours E. Remy | 87 pages |
| `REVISION_CONTROLE_TD_R3L01.pdf` | Fiche déjà rédigée pour le contrôle de TD du 14/10/2026 | 26 pages |
| `TP1_TD1/R3.L01_TD1.pdf` | Sujet officiel TD1 (PGM), 13 septembre 2023 | 2 pages |
| `TP1_TD1/tp1_sujet` | Sujet TP1 | texte |
| `TP1_TD1/PGM.txt` | Spécification PGM | texte |
| `TP1_TD1/corrigé_TD.txt` | Notes prises en TD, pas un corrigé officiel propre | texte |
| `TP1_TD1/note.txt` | Modalités notées par l'étudiant | 12 lignes |
| `TP1_TD1/TP1_explications.pdf` | Explications déjà produites | 14 pages |
| `TP2_TD2/R3.L01_TD2.pdf` | Sujet officiel TD2, 22 septembre 2025 | 2 pages |
| `TP2_TD2/TP2.txt` | Sujet TP2 | texte |
| `TP2_TD2/PPM.txt` | Spécification PPM | texte |
| `TP2_TD2/corrige_prof.txt` | Notes de tableau TD2 (endianness, tailles) et début du TD3 | texte incomplet |
| `TP2_TD2/td2_endianness.cpp` | Programme d'entraînement TD2, marqué « pas à rendre » | source |
| `TP2_TD2/TP2_explications.pdf` | Explications | 13 pages |
| `TP3_TD3/TP3.TXT` | Sujet TP3 JPEG, en-tête « facultatif », modifié le 17/10/2020 | texte |
| `TP3_TD3/corrige_prof.txt` | Notes de tableau du rééchantillonnage ; le bilinéaire s'arrête au prototype | texte |
| `TP3_TD3/libjpeg.txt`, `jpeg_example.c`, `jpegsrc.v10/` | Documentation et sources libjpeg, pour référence | volumineux |
| `TP3_TD3/TP3_explications.pdf` | Explications | 9 pages |
| `TP4/tp4.txt` | Sujet TP4 TGA | texte |
| `TP4/TGA.pdf`, `tgaffs.pdf`, `Opérateurs_logiques.pdf` | Docs format et rappel bits | 8, 29 et 2 pages |
| `TP4/TP4_explications.pdf` | Explications | 13 pages |
| `TP5/tp5.txt` | Sujet TP5 Bresenham, en-tête « facultatif », 4 janvier 2017 | texte |
| `TP5/TP5_explications.pdf` | Explications | 7 pages |
| `TP5/IMAGE_doit_etre_obtenu_tp5.png` | Figure du sujet (aussi `PROJET_FINAL/images/tp5_im1/2/3.png`) | images |
| `PROJET_FINAL/` | Code rassemblé TP1 à TP5 | `Image.hpp`, `Image.cpp`, `tp1.cpp` … `tp5.cpp`, `Makefile`, `images/` |
| `README.md`, `SUITE_CONVERSATION_CLAUDE.md`, `_sources_pdf/` | Guide et sources des PDF d'explication | texte / HTML |
| `_ARCHIVE_GEMINI/` | Ancienne version. Pas le code à rendre. Non modifié. | archive |

Absents, alors que le travail les aurait utilisés s'ils existaient :

- le dossier PC cité plus haut ;
- un sujet de TD3 en PDF (seulement les notes `TP3_TD3/corrige_prof.txt`, bilinéaire non terminé) ;
- un autre `note.txt` que `TP1_TD1/note.txt` ;
- toute consigne nommant un VDI, une image VirtualBox ou un bureau distant.

Écart de libellé dans les PDF du professeur lui-même : les sujets de TD impriment **L3.01** en en-tête, le dossier et le cours utilisés ici sont **R3.L01**. Ce n'est pas une coquille du dépôt.

`note.txt` a été lu comme une donnée, pas comme une consigne à exécuter. Il dit : 5 séances ; rendre tout le code le jour du 5ᵉ TP noté ; faire attention aux noms des fonctions ; environ 50 % fait à la maison et 50 % fait en classe ; contrôle théorique TD le 14/10/2026 ; contrôle pratique le 06/11/2026 (ou le 21/10 si le groupe l'avait préféré). Les sujets TP3 et TP5 portent encore la mention « facultatif » : les notes de séance, elles, demandent de rendre les cinq séances. Les deux sont conservés ici sans trancher à la place du professeur.

## 3. Décision sur le code

Les sources de `code_a_rendre/` sont **une copie byte à byte** de `PROJET_FINAL/` (`Image.hpp`, `Image.cpp`, `tp1.cpp` à `tp5.cpp`, `Makefile`). Aucune correction de code n'a été appliquée : l'audit n'a pas trouvé d'écart qui contredise une méthode écrite dans le cours ou dans un sujet, au point de justifier une réécriture.

Le nom dans les commentaires PGM/PPM est la constante `AUTEUR = "Mamadou Bailo BARRY"` (`Image.cpp`). Le TD1 demande « votre nom ». À confirmer sur la copie que c'est bien le nom attendu. Il n'a pas été changé.

Détail des écarts, des conformités et des ambiguïtés : `06_Audit_conformite.md`.

## 4. Compilation et tests réalisés ici

Environnement : Linux x86_64, `g++ (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`, `libjpeg-dev` 8c-2ubuntu11. Ce n'est **pas** le VDI de l'IUT, **pas** un poste Windows avec `L:\GnuWin32`, **pas** le PC de l'étudiant.

Commande, dans `code_a_rendre/` après copie des images de `PROJET_FINAL/images/` :

`make test`

Résultat : **les cinq programmes se terminent avec le code 0**, sans avertissement `-Wall -Wextra`. Journal : `resultats_tests_cloud.txt`.

| Contrôle | Résultat mesuré |
|---|---|
| `tp1` vs `chat_lunettes.pgm` | 0 pixel différent |
| En-têtes souples (pixel 10 = LF, pixel 35) | `10 35 et 10 35` |
| P2 `Rafale30000.pgm` et P3 `Rafale30000.ppm` | lus puis réécrits |
| Opérateurs `Color` | `(150,100,129)` comme dans le README |
| JPEG qualité par défaut et qualité 75 | **18 908 octets** les deux |
| `out_000.jpg` / `out_100.jpg` | 3 005 / 73 468 octets |
| Exception si un PPM est lu comme JPEG | oui (`Not a JPEG file: starts with 0x50 0x36`) |
| TGA `chat` brut / RLE, relecture par le code | identique ; 230 418 et 207 106 octets |
| `chat010couleurs` brut et RLE, `chanel.tga` réécrit en RLE | 0 pixel différent à la relecture |
| TGA gris sous-formats 3 et 11 | relecture identique |
| Sous-format non géré | exception |
| TP5 octant 1 et octants 1-2 vs `tp5_im1.png` / `tp5_im2.png` | **0 pixel différent** |
| TP5 cercle vs `tp5_im3.png` | **7 190 pixels différents** sur 250 000. Les 72 points blancs sont tous à au plus **1 pixel** du point blanc de la figure (décalage de Tchebychev max 1). Les autres écarts sont des pixels bleus/noirs : le segment de Bresenham change de chemin quand l'extrémité bouge d'un pixel. `std::lround` n'est pas imposé par le sujet. Un essai avec troncature `(uint16_t)(250+200*cos)` donne encore 6 637 pixels différents : la figure n'est pas retrouvée. Les tests 1 et 2, eux, valident l'algorithme du sujet. |
| `palette_bl.tga` vs `palette_tl.tga` après lecture | 1 646 pixels différents, dans une zone intérieure, pas un simple miroir vertical (un retournement en crée 5 333). Les deux fichiers ne sont pas une preuve que le bit 5 est faux : les coins se correspondent, et un retournement éloigne les images. On ne peut pas dire qu'ils « doivent » être identiques : aucune phrase du sujet ne l'exige. |
| `TP2_TD2/td2_endianness.cpp` | little endian ; `swap_bytes(0x1234) = 0x3412` ; les deux lectures retrouvent `a = -1234`, `b = 3.14159`, `fourcc = JFIF`, `d = "Bonjour R3.L01"`. `od` : premier mot 16 bits `fb 2e` (big endian de -1234). |

ImageMagick n'est pas installé ici. La phrase du README « relu identique par ImageMagick » n'a **pas** été rejouée. `tp4.cpp` compare avec sa propre relecture, pas avec ImageMagick. À refaire sur le poste de l'IUT si le professeur ouvre les TGA avec un visualiseur.

## 5. Ce qui reste à vérifier à l'IUT

Voir `05_Checklist_VDI.md`. En bref : recompiler sur la machine de l'IUT, ouvrir les images avec le visualiseur du poste (`eog` / `qiv` sous Linux, XnView ou IrfanView sous Windows, d'après les sujets), et confirmer le nom dans le commentaire PGM/PPM. Aucun login, aucun mot de passe, aucun chemin privé au-delà de `L:\GnuWin32` déjà écrit dans `TP3.TXT` n'a été inventé.

## 6. Contenu du dossier

| Fichier | Usage |
|---|---|
| `RAPPORT.md` | Ce rapport |
| `01_Fiche_revision_controle_pratique.md` | À relire pour le TP noté : signatures, méthodes, pièges |
| `02_Exercices_type_enonces.md` | Exercices du même type, sans corrigé |
| `03_Exercices_type_corriges.md` | Corrigés séparés |
| `04_Commandes_compilation_et_tests.md` | Commandes et ce qu'il faut voir |
| `05_Checklist_VDI.md` | Poste IUT, limites de ce qui a été testé |
| `06_Audit_conformite.md` | Tableau sujet / cours / code, avec fichier |
| `resultats_tests_cloud.txt` | Sortie mesurée |
| `code_a_rendre/` | Copie des sources. Images : script `copier_images.sh` |
| `exercices_code/corrige_fonctions_ajoutees.cpp` | Corrigé compilable des fonctions « ajoutées », à part du rendu |
