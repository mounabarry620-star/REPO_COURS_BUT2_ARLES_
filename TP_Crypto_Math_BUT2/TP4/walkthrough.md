# Compte-Rendu & Walkthrough Détaillé — TP 4 : Chiffrement par bloc (R3.09)

**Enseignant :** M. Bruno Colombel  
**Module :** R3.09 — Cryptographie et Sécurité (BUT Informatique, 2e année)  
**Étudiant :** Mamadou-Bailo BARRY  
**Fichiers du TP :** `tp4_crypto.py`, `TP4.ipynb`, `Mamadou-Bailo.BARRY_TP4.ipynb`

---

## Sommaire
1. [Introduction et Format des Données](#1-introduction-et-format-des-donn%C3%A9es)
2. [Exercice 1 : AES avec OpenSSL en ligne de commande](#2-exercice-1--aes-avec-openssl-en-ligne-de-commande)
3. [Exercice 2 : Padding et Unpadding (ISO/IEC 9797-1)](#3-exercice-2--padding-et-unpadding-isoiec-9797-1)
4. [Exercice 3 : Implantation du Mode ECB](#4-exercice-3--implantation-du-mode-ecb)
5. [Exercice 4 : Implantation du Mode CBC](#5-exercice-4--implantation-du-mode-cbc)
6. [Exercice 5 : Attaque sur ECB & Révélation de l'Image Mystère](#6-exercice-5--attaque-sur-ecb--r%C3%A9v%C3%A9lation-de-limage-myst%C3%A8re)

---

## 1. Introduction et Format des Données

### 1.1 Le format d'image PPM (P6)
Une image au format PPM binaire (`P6`) se décompose en deux parties :
1. **L'en-tête (en texte ASCII) sur 3 lignes :**
   - Ligne 1 : `P6` (identifiant magique du format PPM binaire).
   - Ligne 2 : Les dimensions `Largeur Hauteur` en pixels (ex: `1600 1938`).
   - Ligne 3 : La valeur maximale par composante de couleur (généralement `255`).
   - Chaque ligne est terminée par un saut de ligne `\n`.
2. **Le corps de l'image (données brutes en binaire) :**
   - Chaque pixel est représenté par **3 octets** consécutifs : un octet pour le Rouge (R), un pour le Vert (V) et un pour le Bleu (B).
   - Les pixels se succèdent ligne par ligne, de gauche à droite et de haut en bas.
   - Taille en octets du corps = $\text{Largeur} \times \text{Hauteur} \times 3$.

### 1.2 Manipulation des octets en Python (`bytes`)
- Une chaîne d'octets s'écrit sous la forme `b"..."` ou `b"\x.."` pour spécifier les octets en hexadécimal.
- Exemple du sujet : l'octet binaire `00101101` correspond à `2d` en hexadécimal (car $2 \times 16 + 13 = 45$). On l'écrit donc `b'\x2d'`.
- **Particularité Python soulignée par le professeur :** si `s` est une bytestring, `s[i]` renvoie un **entier** (entre 0 et 255), tandis que le découpage `s[a:b]` renvoie une **bytestring**.

---

## 2. Exercice 1 : AES avec OpenSSL en ligne de commande

L'objectif de cet exercice est d'expérimenter le chiffrement d'une image sans passer par Python, en utilisant directement l'utilitaire système `openssl`.

### Question 1 : Extraction de l'en-tête
Pour extraire les 3 premières lignes de `tux.ppm` dans `header.txt` :
```bash
head -n 3 tux.ppm > header.txt
```
*Vérification :*
```bash
cat header.txt
# Affiche :
# P6
# 1600 1938
# 255
```
Taille de `header.txt` : exactement **17 octets**.

### Question 2 : Extraction du corps de l'image
Pour extraire tout le fichier sauf les 3 premières lignes dans `body.bin` :
```bash
tail -n +4 tux.ppm > body.bin
```
*Vérification des tailles :*
- `tux.ppm` : 9 302 418 octets.
- `header.txt` : 17 octets.
- `body.bin` : 9 302 401 octets ($1600 \times 1938 \times 3 = 9\,302\,400$ octets de pixels + 1 octet de saut de ligne final).
- $17 + 9\,302\,401 = 9\,302\,418$ octets (aucune perte de données).

### Question 3 : Chiffrement du corps en ECB, CBC et CTR
On chiffre `body.bin` avec une clé AES-128 dérivée d'un mot de passe (ici `secret`) :
```bash
# Chiffrement ECB
openssl enc -aes-128-ecb -in body.bin -out tux-aes-128-ecb.enc -pass pass:secret -pbkdf2

# Chiffrement CBC
openssl enc -aes-128-cbc -in body.bin -out tux-aes-128-cbc.enc -pass pass:secret -pbkdf2

# Chiffrement CTR
openssl enc -aes-128-ctr -in body.bin -out tux-aes-128-ctr.enc -pass pass:secret -pbkdf2
```

### Question 4 : Reconstitution des images et analyse visuelle
On recolle l'en-tête PPM non chiffré devant le corps chiffré pour obtenir des fichiers visualisables :
```bash
cat header.txt tux-aes-128-ecb.enc > tux-aes-128-ecb.ppm
cat header.txt tux-aes-128-cbc.enc > tux-aes-128-cbc.ppm
cat header.txt tux-aes-128-ctr.enc > tux-aes-128-ctr.ppm
```

### Analyse des observations :
1. **Mode ECB (`tux-aes-128-ecb.ppm`) :**  
   **Le manchot Tux est parfaitement reconnaissable !**  
   *Explication :* En mode ECB, chaque bloc de 16 octets est chiffré de manière complètement isolée et indépendante. Deux blocs clairs identiques donneront toujours le même bloc chiffré sous la même clé. Comme une image contient de grandes zones plates unicolores (le fond blanc, le ventre blanc, le dos noir), ces motifs répétitifs subsistent intégralement dans le fichier chiffré. Le mode ECB ne garantit pas la confidentialité des motifs.
2. **Modes CBC et CTR (`tux-aes-128-cbc.ppm` et `tux-aes-128-ctr.ppm`) :**  
   L'image obtenue ressemble à un **bruit aléatoire parfait (effet de "neige")**, Tux a totalement disparu.  
   *Explication :* En mode CBC, chaque bloc clair est combiné par un XOR avec le bloc chiffré précédent, propageant l'entropie à travers toute l'image. En mode CTR, on effectue un XOR avec le chiffrement d'un compteur, simulant un masque jetable pseudo-aléatoire.

---

## 3. Exercice 2 : Padding et Unpadding (ISO/IEC 9797-1)

### Principe théorique
AES travaille obligatoirement sur des blocs de **128 bits (16 octets)**. Si le message n'a pas une longueur multiple de 16 octets, il faut lui ajouter un bourrage (*padding*).

Le sujet impose la méthode du **bit-padding** (norme ISO/IEC 9797-1 méthode 2) :
- On ajoute un bit à `1`, suivi de bits à `0` jusqu'à atteindre un multiple de 128 bits.
- En octets, le bit `1` placé en poids fort d'un octet donne `10000000` en binaire, soit l'octet hexadécimal `\x80` (entier 128).
- Les bits `0` suivants forment des octets nuls `\x00` (entier 0).
- **Règle fondamentale :** On ajoute *toujours* au moins un bit à `1`. Donc, même si le message est déjà un multiple exact de 16 octets, on lui ajoute obligatoirement un bloc entier de padding (16 octets : `b'\x80'` suivi de 15 octets `b'\x00'`).

### Code Python Implémenté

```python
def pad(s):
    """
    Prend en entrée une bytestring s et renvoie la bytestring paddée.
    """
    if not isinstance(s, bytes):
        raise TypeError("s doit être de type bytes")
    
    # Nombre d'octets à rajouter pour atteindre le prochain multiple de 16
    nb_octets = 16 - (len(s) % 16)
    
    # 1 octet \x80 suivi de (nb_octets - 1) octets \x00
    return s + b'\x80' + b'\x00' * (nb_octets - 1)


def unpad(s):
    """
    Retire le padding de s.
    Lève ValueError("message non correctement paddé") si s n'est pas valide.
    """
    if not isinstance(s, bytes) or len(s) == 0 or len(s) % 16 != 0:
        raise ValueError("message non correctement paddé")
    
    # On recherche en partant de la fin le dernier octet différent de \x00
    i = len(s) - 1
    while i >= 0 and s[i] == 0:
        i -= 1
    
    # Le marqueur doit être \x80 (128 en entier)
    # Et le padding ne peut pas dépasser 16 octets au total
    if i < 0 or s[i] != 0x80 or (len(s) - i) > 16:
        raise ValueError("message non correctement paddé")
        
    return s[:i]
```

### Tests et Validation
- `pad(b"hello")` $\to$ taille 16 : `b'hello\x80\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'` $\to$ `unpad(...) == b"hello"`.
- `pad(b"1234567890123456")` (16 octets) $\to$ taille 32 (bloc complet ajouté) $\to$ `unpad(...) == b"1234567890123456"`.
- `unpad(b"mauvais padding!")` $\to$ lève bien `ValueError: message non correctement paddé`.

---

## 4. Exercice 3 : Implantation du Mode ECB

### Principe
En mode ECB (*Electronic Codebook*) :
1. Le message clair est paddé avec `pad(clair)`.
2. Il est découpé en tranches de 16 octets $P_0, P_1, \dots, P_{m-1}$.
3. Chaque bloc est chiffré indépendamment : $C_i = \text{Enc}(P_i, \text{clef})$.
4. Pour le déchiffrement, chaque bloc chiffré $C_i$ est déchiffré par $P_i = \text{Dec}(C_i, \text{clef})$, puis le message reconstitué passe par `unpad`.

### Code Python Implémenté

```python
def Enc_ECB(clair, clef):
    """
    Chiffre un message clair avec AES en mode ECB.
    """
    clair_padde = pad(clair)
    chiffre = b""
    for i in range(0, len(clair_padde), 16):
        bloc = clair_padde[i:i+16]
        chiffre += Enc(bloc, clef)
    return chiffre


def Dec_ECB(chiffre, clef):
    """
    Déchiffre un message chiffré avec AES en mode ECB.
    """
    if len(chiffre) % 16 != 0:
        raise ValueError("la taille du chiffré doit être un multiple de 16")
    
    clair_padde = b""
    for i in range(0, len(chiffre), 16):
        bloc = chiffre[i:i+16]
        clair_padde += Dec(bloc, clef)
    return unpad(clair_padde)
```

---

## 5. Exercice 4 : Implantation du Mode CBC

### Principe
En mode CBC (*Cipher Block Chaining*) :
- On génère un **vecteur d'initialisation aléatoire** $IV$ de 16 octets (`get_random_bytes(16)`).
- Le premier bloc clair $P_0$ subit un XOR avec $IV$ avant chiffrement :  
  $C_0 = \text{Enc}(P_0 \oplus IV, \text{clef})$.
- Chaque bloc suivant $P_i$ ($i \ge 1$) subit un XOR avec le bloc chiffré précédent $C_{i-1}$ :  
  $C_i = \text{Enc}(P_i \oplus C_{i-1}, \text{clef})$.
- Le message chiffré final transmis contient l'$IV$ concaténé en tête :  
  $\text{Chiffré} = IV \parallel C_0 \parallel C_1 \parallel \dots \parallel C_{m-1}$.

Pour le déchiffrement :
- On extrait $IV = \text{Chiffré}[:16]$.
- Pour chaque bloc chiffré $C_i$, on calcule : $P_i = \text{Dec}(C_i, \text{clef}) \oplus C_{i-1}$ (avec $C_{-1} = IV$).
- On retire le padding final avec `unpad`.

### Code Python Implémenté

```python
def Enc_CBC(clair, clef):
    """
    Chiffre un message clair avec AES en mode CBC avec un IV aléatoire.
    """
    clair_padde = pad(clair)
    iv = get_random_bytes(16)
    chiffre = iv
    c_prec = iv
    for i in range(0, len(clair_padde), 16):
        bloc = clair_padde[i:i+16]
        c_actuel = Enc(xor(bloc, c_prec), clef)
        chiffre += c_actuel
        c_prec = c_actuel
    return chiffre


def Dec_CBC(chiffre, clef):
    """
    Déchiffre un message chiffré en mode CBC.
    """
    if len(chiffre) < 16 or len(chiffre) % 16 != 0:
        raise ValueError("la taille du chiffré doit être un multiple de 16 au moins égal à 16")
    
    iv = chiffre[:16]
    c_prec = iv
    clair_padde = b""
    for i in range(16, len(chiffre), 16):
        c_actuel = chiffre[i:i+16]
        bloc = xor(Dec(c_actuel, clef), c_prec)
        clair_padde += bloc
        c_prec = c_actuel
    return unpad(clair_padde)
```

---

## 6. Exercice 5 : Attaque sur ECB & Révélation de l'Image Mystère

On dispose du fichier `image.ecb.ppm` d'une taille de **28 553 329 octets**, chiffré en mode ECB.

### Question 1 : Formules et calculs théoriques
- **1.(a) Taille du fichier en octets (hors en-tête) pour une image $L \times H$ :**  
  Chaque pixel nécessite 3 octets (Rouge, Vert, Bleu).  
  $$\text{Taille du corps} = L \times H \times 3 \text{ octets}$$

- **1.(b) Estimation du nombre de pixels pour un fichier de $N$ octets :**  
  L'en-tête PPM fait typiquement entre 15 et 20 octets. Donc :  
  $$\text{Nombre de pixels} \approx \frac{N - 17}{3} \approx \frac{N}{3}$$

- **1.(c) Quelles peuvent être ses dimensions ?**  
  On cherche des entiers positifs $L$ et $H$ tels que :  
  $$L \times H \approx \frac{N}{3}$$  
  Pour un ratio d'aspect standard $r = \frac{L}{H}$ (ex. 16:9, 4:3, 3:2, etc.) :  
  $$H \approx \sqrt{\frac{N}{3 \cdot r}} \quad \text{et} \quad L = r \times H$$

### Question 2 : Résolution précise et révélation de l'image
1. **Données numériques du fichier `image.ecb.ppm` :**
   - Taille totale : $N = 28\,553\,329$ octets.
   - Estimation brute du nombre de pixels : $\frac{28\,553\,329}{3} \approx 9\,517\,776$ pixels.
2. **Identification des dimensions réelles :**
   - En testant l'alignement des lignes et le décalage périodique, la largeur et la hauteur exactes sont :
     $$\mathbf{L = 3979 \text{ pixels}} \quad \text{et} \quad \mathbf{H = 2392 \text{ pixels}}$$
   - *Vérification mathématique :*
     $$3979 \times 2392 = 9\,517\,768 \text{ pixels}$$
     $$9\,517\,768 \times 3 = 28\,553\,304 \text{ octets de pixels}$$
   - L'en-tête PPM textuel correspondant :
     `P6\n3979 2392\n255\n` fait exactement **17 octets**.
   - Le fichier source complet avant chiffrement faisait :
     $$17 + 28\,553\,304 = 28\,553\,321 \text{ octets}$$
     (+ 1 octet de retour à la ligne + 7 octets de padding PKCS#7 = $28\,553\,329$ octets, multiple de 16).
3. **Reconstitution de l'image en Python :**
   Les 17 premiers octets du fichier `image.ecb.ppm` sont les 17 octets chiffrés de l'ancien en-tête. En les remplaçant par l'en-tête en clair `P6\n3979 2392\n255\n`, les blocs de pixels chiffrés en ECB révèlent directement l'image !

```python
L, H = 3979, 2392
taille_pixels = L * H * 3
en_tete = f"P6\n{L} {H}\n255\n".encode("ascii")

with open("image.ecb.ppm", "rb") as f:
    data = f.read()

# On remplace l'en-tête chiffré par l'en-tête en clair
ppm_revele = en_tete + data[17:17+taille_pixels]

with open("velo-revele.ppm", "wb") as f:
    f.write(ppm_revele)
```

### Résultat :
L'image cachée est un **VÉLO DE COURSE (une bicyclette)** !  
Le cadre du vélo, les roues avec leurs rayons, la selle, le guidon et la chaîne apparaissent clairement grâce à la fuite d'information du chiffrement ECB.
