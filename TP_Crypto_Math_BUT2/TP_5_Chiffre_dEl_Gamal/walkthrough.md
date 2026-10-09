# Compte-Rendu & Walkthrough Détaillé — TP 5 : Problème du logarithme discret & Chiffre d'El Gamal (R3.09)

**Enseignant :** M. Bruno Colombel  
**Module :** R3.09 — Cryptographie et Sécurité (BUT Informatique, 2e année)  
**Étudiant :** Mamadou-Bailo BARRY  
**Fichiers du TP :** `BARRY_Mamadou-Bailo-TP5.ipynb`, `TP5.ipynb`, `tp5_crypto.py`

---

## Sommaire
1. [Contexte et Rappels Théoriques](#1-contexte-et-rappels-th%C3%A9oriques)
2. [Exercice 1 : Analyse des Cycles Modulo 31](#2-exercice-1--analyse-des-cycles-modulo-31)
3. [Exercice 2 : Test de Racine Primitive](#3-exercice-2--test-de-racine-primitive)
4. [Exercice 3 : Recherche et Liste des Racines Primitives](#4-exercice-3--recherche-et-liste-des-racines-primitives)
5. [Le Logarithme Discret](#5-le-logarithme-discret)
6. [Exercice 4 : Génération des Paires de Clés El Gamal](#6-exercice-4--g%C3%A9n%C3%A9ration-des-paires-de-cl%C3%A9s-el-gamal)
7. [Exercice 5 : Chiffrement El Gamal](#7-exercice-5--chiffrement-el-gamal)
8. [Exercice 6 : Déchiffrement El Gamal & Preuve Mathématique](#8-exercice-6--d%C3%A9chiffrement-el-gamal--preuve-math%C3%A9matique)
9. [Exercice 7 : Encodage et Décodage de Textes ASCII](#9-exercice-7--encodage-et-d%C3%A9codage-de-textes-ascii)
10. [Exercice 8 : Simulation d'un Échange entre Voisins](#10-exercice-8--simulation-dun-%C3%A9change-entre-voisins)
11. [Exercice 9 (Bonus) : Chiffrement par Blocs pour Textes Longs](#11-exercice-9-bonus--chiffrement-par-blocs-pour-textes-longs)

---

## 1. Contexte et Rappels Théoriques

Contrairement au TP 4 où nous utilisions du chiffrement symétrique (AES, où la même clé sert à chiffrer et déchiffrer), le cryptosystème d'**El Gamal** (conçu par Taher Elgamal en 1984) est un **système asymétrique à clé publique**, à l'instar de RSA.

Il repose sur une fonction à sens unique basée sur l'arithmétique modulaire :
- **Facile dans un sens :** l'exponentiation modulaire $x \mapsto g^x \pmod p$ se calcule en temps logarithmique grâce à l'algorithme d'exponentiation rapide (algorithme des carrés).
- **Difficile dans l'autre sens :** connaissant $y = g^x \pmod p$, retrouver $x$ (le **logarithme discret**) est un problème calculatoirement intraitable pour de grands nombres premiers $p$.

### 1.1 Fonction indicatrice d’Euler et Inverse modulaire
- $\varphi(n)$ désigne le nombre d'entiers dans $\{1, \dots, n-1\}$ premiers avec $n$.
- Si $p$ est premier, tout entier non nul est inversible dans $\mathbb{Z}/p\mathbb{Z}$, donc $\varphi(p) = p - 1$.
- **Théorème d'Euler / Petit théorème de Fermat :**  
  Si $\text{pgcd}(a, n) = 1$, alors :  
  $$a^{\varphi(n)} \equiv 1 \pmod n$$
- **Conséquence directe sur l'inverse modulaire :**  
  $$a \times a^{\varphi(n) - 1} \equiv 1 \pmod n \implies a^{-1} \equiv a^{\varphi(n) - 1} \pmod n$$  
  En particulier, si $p$ est premier :  
  $$a^{-1} \equiv a^{p - 2} \pmod p$$

### 1.2 Algorithme des carrés (Exponentiation rapide récursive)
Fourni par le professeur dans le sujet :
```python
def puissance(a, x, n):
    """Méthode récursive, rapide de calcul de a^x mod n (algorithme des carrés)."""
    if x == 0:
        return 1
    elif x == 1:
        return a
    elif x % 2 == 0:
        return puissance(a**2 % n, x // 2, n) % n
    elif x != 1:
        return a * puissance(a**2 % n, (x - 1) // 2, n) % n
```

---

## 2. Exercice 1 : Analyse des Cycles Modulo 31

On prend le nombre premier $p = 31$. On s'intéresse à la suite des puissances $a^0, a^1, a^2, \dots, a^{p-1} \pmod p$ générées par `cycle(a, p)` :
```python
def cycle(a, p):
    """Retourne la liste des puissances a**0, a**1, ... a**(p-1) modulo p."""
    resultat = []
    for d in range(p - 1):
        resultat.append(puissance(a, d, p))
    return resultat
```

### Résultats obtenus :
- **Pour $a = 2$ :**  
  `[1, 2, 4, 8, 16, 1, 2, 4, 8, 16, 1, 2, 4, 8, 16, 1, 2, 4, 8, 16, 1, 2, 4, 8, 16, 1, 2, 4, 8, 16]`  
  $\implies$ Le cycle contient seulement **5 valeurs distinctes** ($2^5 = 32 \equiv 1 \pmod{31}$).
- **Pour $a = 4$ :**  
  `[1, 4, 16, 2, 8, ...]`  
  $\implies$ Cycle de **5 valeurs distinctes** ($4^5 \equiv 1 \pmod{31}$).
- **Pour $a = 5$ :**  
  `[1, 5, 25, 1, 5, 25, ...]`  
  $\implies$ Cycle de **3 valeurs distinctes** ($5^3 = 125 \equiv 1 \pmod{31}$).
- **Pour $a = 3$ :**  
  `[1, 3, 9, 27, 19, 26, 16, 17, 20, 29, 25, 13, 8, 24, 10, 30, 28, 22, 4, 12, 5, 15, 14, 11, 2, 6, 18, 23, 7, 21]`  
  $\implies$ Le cycle contient l'ensemble des **30 valeurs distinctes** de $\{1, \dots, 30\}$.

### Réponses rédigées aux questions :
1. **Que se passe-t-il pour $a = 2$ ? La fonction $x \mapsto 2^x$ est-elle bijective ?**  
   Pour $a = 2$, la suite des puissances boucle sur 5 valeurs seulement : $[1, 2, 4, 8, 16]$. Comme l'image de la fonction ne contient que 5 éléments distincts alors que l'ensemble d'arrivée $(\mathbb{Z}/31\mathbb{Z})^*$ en compte 30, la fonction n'est pas surjective, ni injective (par exemple $2^0 \equiv 2^5 \equiv 1$). Elle n'est donc **pas bijective**.
2. **Pour quelles autres valeurs de $a$ observe-t-on le même comportement ?**  
   On observe un comportement similaire pour $a = 4$ (période 5) et $a = 5$ (période 3).
3. **Quelle est la seule valeur de $a$ parmi celles testées pour laquelle la fonction est bijective ?**  
   C'est **$a = 3$**. Les 30 puissances successives parcourent l'intégralité du groupe multiplicatif $(\mathbb{Z}/31\mathbb{Z})^*$. On dit que $3$ engendre le groupe, ou que **$3$ est une racine primitive modulo 31**.

---

## 3. Exercice 2 : Test de Racine Primitive

### Définition 3 du cours
Un entier $a$ ($1 < a < p$) est une **racine primitive** modulo $p$ ($p$ premier) si :
- $a$ est premier avec $p$ ;
- pour tout entier $d$ tel que $1 \le d < p - 1$, on a :  
  $$a^d \not\equiv 1 \pmod p$$

### Implantation Python :
```python
def primitive(a, p):
    """Teste si a est une racine primitive modulo p avec p premier."""
    val = 1
    for d in range(1, p - 1):
        val = (val * a) % p
        if val == 1:
            return False
    return True
```

### Validation sur les exemples du sujet :
- `primitive(3, 31)` $\to$ `True` (conforme au sujet `Out[10]: True`).
- `primitive(4, 31)` $\to$ `False` (conforme au sujet `Out[11]: False`).

---

## 4. Exercice 3 : Recherche et Liste des Racines Primitives

### 1. Fonction `racine_primitive(p)`
Cette fonction cherche la plus petite racine primitive de $p$ en incrémentant $a$ à partir de 2 :
```python
def racine_primitive(p):
    """Recherche la plus petite racine primitive de p (p premier)."""
    a = 2
    while not primitive(a, p):
        a += 1
    return a
```

### 2. Fonction `liste_racines_primitives(p)`
```python
def liste_racines_primitives(p):
    """Retourne la liste de toutes les racines primitives de p (p premier)."""
    return [a for a in range(2, p) if primitive(a, p)]
```

### Validation sur les exemples du sujet :
- `racine_primitive(4999)` $\to$ **`3`** (conforme à `Out[14]: 3`).
- `racine_primitive(1000021)` $\to$ **`11`** (conforme à `Out[15]: 11`).
- `liste_racines_primitives(31)` $\to$ **`[3, 11, 12, 13, 17, 21, 22, 24]`** (conforme à `Out[19]`).

> **Remarque mathématique sur $p = 1000021$ :**  
> L'entier $1000021 = 11 \times 90911$ n'est en réalité pas premier ($11$ en est un diviseur). Comme $\text{pgcd}(11, 1000021) = 11 \ne 1$, les puissances successives de 11 sont toutes des multiples de 11 modulo 1000021 et ne peuvent mathématiquement jamais valoir 1. Par conséquent, la condition d'arrêt `val == 1` n'est jamais déclenchée pour $a = 11$, ce qui conduit la fonction du sujet à renvoyer `11`.

---

## 5. Le Logarithme Discret

Puisque pour une racine primitive $a$, l'application $x \mapsto a^x \pmod p$ est bijective de $\{0, \dots, p-2\}$ dans $(\mathbb{Z}/p\mathbb{Z})^*$, elle admet une application réciproque :
$$\log_a(y) \pmod p = x \iff a^x \equiv y \pmod p$$
- **Exemple 1 du sujet :** $3$ est racine primitive de 31.  
  $$3^4 = 81 = 2 \times 31 + 19 \equiv 19 \pmod{31} \implies \log_3(19) \equiv 4 \pmod{31}$$

---

## 6. Exercice 4 : Génération des Paires de Clés El Gamal

Alice génère ses clés :
1. Choisit un nombre premier $p$ compris entre $2^k$ et $2^{k+1} - 1$ grâce à `randprime` de `sympy`.
2. Choisit un générateur $g = \text{racine\_primitive}(p)$.
3. Choisit sa clé privée $a$ au hasard dans $\{1, \dots, p - 2\}$.
4. Calcule sa clé publique $A = g^a \pmod p$.
5. Publie la clé publique $(p, g, A)$ et conserve secrète sa clé privée $a$.

```python
from random import randint
from sympy import randprime

def clefs(k):
    """
    Génère une paire de clefs El Gamal avec un module p compris entre 2^k et 2^(k+1) - 1.
    Retourne ((p, g, A), a).
    """
    p = randprime(2**k, 2**(k + 1))
    g = racine_primitive(p)
    a = randint(1, p - 2)
    A = puissance(g, a, p)
    public_key = (p, g, A)
    private_key = a
    return public_key, private_key
```

*Exemple d'exécution avec $k = 16$ :*
```python
public_key, private_key = clefs(16)
# Exemple : public_key = (80363, 2, 66518), private_key = 64972
```

---

## 7. Exercice 5 : Chiffrement El Gamal

Pour chiffrer un message $m \in \{0, \dots, p - 1\}$ avec la clé publique $(p, g, A)$ :
1. Bob choisit un nombre aléatoire secret $b \in \{1, \dots, p - 2\}$ (clé éphémère).
2. Bob calcule la composante publique éphémère :  
   $$B = g^b \pmod p$$
3. Bob masque le message avec le secret partagé $A^b \pmod p$ :  
   $$c = m \times (A^b \pmod p)$$
4. Bob transmet le couple $(c, B)$ à Alice.

```python
def chiffrer(m, public_key):
    """
    Chiffre un nombre m compris entre 0 et p - 1 avec la clé public_key = (p, g, A).
    Retourne le couple chiffré (c, B).
    """
    p, g, A = public_key
    b = randint(1, p - 2)
    B = puissance(g, b, p)
    c = m * puissance(A, b, p)
    return c, B
```

*Propriété essentielle :* Le chiffrement d'El Gamal est **probabiliste**. Chiffrer deux fois le même clair $m$ produira deux cryptogrammes $(c, B)$ totalement différents car l'aléa $b$ change à chaque exécution.

---

## 8. Exercice 6 : Déchiffrement El Gamal & Preuve Mathématique

### Preuve mathématique du déchiffrement :
Alice reçoit $(c, B)$ et utilise sa clé privée $a$.  
Alice calcule d'abord le secret partagé à partir de $B$ :
$$B^a \equiv (g^b)^a \equiv g^{ab} \equiv (g^a)^b \equiv A^b \pmod p$$
Puis, Alice multiplie le chiffré $c$ par l'inverse modulaire $(B^a)^{-1} \pmod p$ :
$$c \times (B^a)^{-1} \equiv (m \cdot A^b) \times (A^b)^{-1} \equiv m \times 1 \equiv m \pmod p$$
D'après le Théorème 2 d'Euler/Fermat, cet inverse se calcule directement par :
$$(B^a)^{-1} \equiv (B^a)^{p - 2} \pmod p$$

### Implantation Python :
```python
def dechiffrer(c, B, private_key, p=None):
    """
    Déchiffre le couple (c, B) avec la clé privée a.
    Formule : m = c * (B^a)^(-1) mod p avec (B^a)^(-1) = (B^a)^(p-2) mod p.
    """
    if isinstance(p, (tuple, list)):
        p = p[0]
    elif p is None:
        p = globals().get('p', None)
        if p is None:
            raise ValueError("Le module p est requis pour déchiffrer")
            
    a = private_key
    Ba = puissance(B, a, p)
    inv_Ba = puissance(Ba, p - 2, p)
    m = (c * inv_Ba) % p
    return m
```

### Validation :
```python
(p, g, A) = public_key
m = randint(0, p - 1)
c, B = chiffrer(m, public_key)
res = dechiffrer(c, B, private_key, p)
print(res == m)  # Affiche : True !
```

---

## 9. Exercice 7 : Encodage et Décodage de Textes ASCII

El Gamal manipule des entiers modulo $p$. Pour chiffrer du texte, le professeur spécifie la méthode suivante :
1. Chaque caractère $c$ est représenté par son code ASCII `ord(c)` (ex: `'B'` $\to 66$).
2. Ce code est écrit sur **3 chiffres** en ajoutant des zéros à gauche (`str(ord(c)).zfill(3)` $\to$ `'066'`).
3. Les blocs de 3 chiffres sont concaténés et convertis en un entier `int`.
4. Réciproquement, le décodage extrait les codes de droite à gauche grâce à `% 1000` et `// 1000`, puis convertit en caractère avec `chr()`.

```python
def encode(texte):
    """Convertit un texte en grand entier via ses codes ASCII sur 3 chiffres."""
    chaine = ""
    for c in texte:
        chaine += str(ord(c)).zfill(3)
    return int(chaine) if chaine else 0

def decode(nombre):
    """Reconstitue le texte à partir de l'entier via % 1000 et // 1000."""
    texte = ""
    while nombre > 0:
        code = nombre % 1000
        texte = chr(code) + texte
        nombre = nombre // 1000
    return texte
```

*Test :*  
Pour tout texte $m$, on a bien `decode(encode(m)) == m`.

---

## 10. Exercice 8 : Simulation d'un Échange entre Voisins

Scénario complet entre Alice et Bob :
1. **Alice** génère sa paire de clés avec $k = 24$ (de sorte que $p > 2^{24} \approx 16 \times 10^6$, suffisant pour un mot court) :  
   `cle_pub_Alice, cle_priv_Alice = clefs(24)`
2. **Bob** prépare son message secret court :  
   `texte = "OK"`
3. **Bob** encode le texte en nombre :  
   `m = encode("OK")` $\implies m = 79075$ (vérification : $m < p$ est bien respecté).
4. **Bob** chiffre le nombre avec la clé publique d'Alice :  
   `c, B = chiffrer(m, cle_pub_Alice)`
5. **Bob** transmet le cryptogramme `(c, B)` à Alice.
6. **Alice** déchiffre avec sa clé privée :  
   `m_recu = dechiffrer(c, B, cle_priv_Alice, p)` $\implies 79075$.
7. **Alice** décode le nombre en texte :  
   `texte_retrouve = decode(m_recu)` $\implies$ `"OK"`.

---

## 11. Exercice 9 (Bonus) : Chiffrement par Blocs pour Textes Longs

Si le texte est long (ex: une phrase complète), son entier encodé dépassera le module $p$. Pour y remédier, on découpe le texte en blocs de taille adaptée :
- Chaque caractère prend 3 chiffres décimaux.
- Pour que chaque bloc $m_i$ vérifie $m_i < p$, on choisit une taille de bloc de $\lfloor (\text{nb\_chiffres}(p) - 1) / 3 \rfloor$ caractères.

```python
def chiffrer_texte_long(texte, public_key):
    """Découpe le texte en blocs et chiffre chaque bloc avec El Gamal."""
    p, g, A = public_key
    taille_bloc = max(1, (len(str(p)) - 1) // 3)
    blocs_chiffres = []
    for i in range(0, len(texte), taille_bloc):
        morceau = texte[i:i + taille_bloc]
        m_i = encode(morceau)
        c_i, B_i = chiffrer(m_i, public_key)
        blocs_chiffres.append((c_i, B_i))
    return blocs_chiffres

def dechiffrer_texte_long(blocs_chiffres, private_key, p):
    """Déchiffre chaque bloc chiffré et reconstitue le message complet."""
    texte_reconstitue = ""
    for c_i, B_i in blocs_chiffres:
        m_i = dechiffrer(c_i, B_i, private_key, p)
        texte_reconstitue += decode(m_i)
    return texte_reconstitue
```

*Test de validation :*  
Un message de 89 caractères `"Félicitations ! Le protocole asymétrique d'El Gamal fonctionne parfaitement sur texte long."` est découpé, chiffré bloc par bloc, puis déchiffré et reconstitué intégralement avec 100% de fidélité.
