# Checklist poste IUT — ce que les documents disent, et ce qui n'a pas été testé

## Ce que les supports disent du poste

Dans le commit `7473d1c` (641 octets), `TP1_TD1/note.txt` ne contient pas le mot VDI. La copie locale actuelle (942 octets) ajoute deux phrases : tester les TP sur les VDI de l'IUT, parce que le professeur envisage d'ajouter des exercices pour noter la compréhension, et vérifier que ça compile avant le contrôle du vendredi. Cette note ne dit pas si le VDI est un bureau distant ou une image VirtualBox. Aucun test n'a été lancé sur un VDI. Ne pas inventer d'adresse, de login ou de mot de passe.

Ce qui est écrit :

| Source | Poste décrit |
|---|---|
| `TP1_TD1/tp1_sujet` | Linux : `eog` ou `qiv`. Windows : XnView. Éviter Gimp ou Photoshop pour un simple aperçu. |
| `TP3_TD3/TP3.TXT` | Linux Debian/Ubuntu : `apt-get install libjpeg62 libjpeg62-dev`, puis `-ljpeg`. Windows, machines de l'IUT : MinGW et la libjpeg du disque réseau `L:\GnuWin32` (`include`, `lib`, `bin`). |
| `TP4/tp4.txt` | Linux : Eye of Gnome, gThumb. Windows : XnView ou IrfanView. |
| `TP1_TD1/note.txt` (dépôt, 641 octets) | Le TP est noté, à rendre en fin de séance ; les noms de fonctions comptent ; cinq séances au total. | 
| `TP1_TD1/note.txt` (copie locale, 942 octets) | Même texte, plus : compiler sur les VDI de l'IUT ; le professeur peut ajouter des exercices le jour du contrôle. Pas de mode d'emploi du VDI. |
| CM diapo 9 | `std::ios::binary`, parce que Windows transforme les fins de ligne. |

Le cloud où cette préparation a été compilée est un Linux x86_64 avec g++ 13.3 et `libjpeg-dev`. Ce n'est pas une validation IUT.

## Le jour du contrôle, dans l'ordre

1. Ouvrir le bon dossier de travail. Le code à rendre est celui de `PROJET_FINAL/` (identique à `code_a_rendre/` au moment de cette préparation).
2. Vérifier que `images/chat.pgm`, `chat.ppm`, `chat_petit.ppm`, `chat.tga` sont à côté des programmes, dans `images/`. Les `main` ouvrent `images/chat.pgm`, pas un chemin absolu.
3. Compiler **un** TP à la main (les deux lignes `g++` ci-dessus), pas seulement avec `make`, au cas où le Makefile n'est pas celui qu'on croit.
4. Lancer `./tp1`. Il faut la ligne `0 pixel(s) différent(s)` et les deux exceptions attendues.
5. Ouvrir `tp1_chat_lunettes.pgm` et `images/chat_lunettes.pgm` dans le visualiseur du poste et alterner. Le test numérique ne remplace pas cette vérification si le professeur la demande.
6. Refaire au moins `./tp2`, `./tp4` et `./tp5`. Pour le JPEG, `./tp3` seulement si `-ljpeg` est disponible sur le poste. Sous Windows IUT, les options `-IL:\GnuWin32\include` et `-LL:\GnuWin32\lib` sont celles du sujet, si ce disque est bien monté ce jour-là.
7. Contrôler le commentaire de `tp1_rectangles.pgm` : la première ligne `#` doit contenir le nom voulu et la phrase « pour les TP de RepCod. ».
8. `make clean` avant de copier le rendu, pour ne pas rendre les `.o` ni les images produites, sauf si on demande les images.

## Déjà fait ici / pas fait ici

| Fait dans le cloud | Pas fait, à faire à l'IUT |
|---|---|
| `g++ -Wall -Wextra -std=c++11`, cinq programmes, code de retour 0 | Recompiler sur le g++ de la salle |
| Comparaison pixel à pixel PGM, TGA relu par le même code, PNG des deux premiers tests TP5 | Ouvrir les fichiers dans `eog`, `qiv`, XnView ou IrfanView |
| Tailles JPEG 75 % = défaut = 18 908 octets sur cette libjpeg | La taille exacte peut bouger avec une autre version de libjpeg ; l'égalité défaut / 75 % est le point du sujet |
| `td2_endianness.cpp` | Idem, c'est un entraînement, pas le rendu |
| | ImageMagick (le README le cite ; `tp4.cpp` ne l'appelle pas) |
| | Chemin `L:\GnuWin32`, DLL, `PATH` Windows |
| | Tout fichier qui ne serait que sur le PC et pas dans le dépôt |

Si une commande échoue, noter le message exact (`undefined reference`, `No such file`, `Not a JPEG file`). Ne pas « réparer » en changeant les noms de fonctions demandés par le sujet.
