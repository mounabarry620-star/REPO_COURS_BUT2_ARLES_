# ==============================================================================
# R3.09 - Cryptographie et Sécurité : TP 5
# Problème du logarithme discret & Chiffre d'El Gamal
# Enseignant : M. Bruno Colombel
# Étudiant : Mamadou-Bailo BARRY
# ==============================================================================

from random import randint
from sympy import randprime

# ------------------------------------------------------------------------------
# 1.2 Fonctions données dans le sujet
# ------------------------------------------------------------------------------

def puissance(a, x, n):
    """methode récursive, rapide de calcul de a^x mod n
    Attention au cas x == 0"""
    if x == 0:
        return 1
    elif x == 1:
        return a
    elif x % 2 == 0:
        return puissance(a**2 % n, x // 2, n) % n
    elif x != 1:
        return a * puissance(a**2 % n, (x-1) // 2, n) % n


def cycle(a, p):
    """retourne a**0, a**1, a**2, ...a**(p-1) modulo p """
    resultat = []
    for d in range(p-1):
        resultat.append(puissance(a, d, p))
    return resultat


# ------------------------------------------------------------------------------
# Exercice 2 : racine primitive (Définition 3)
# ------------------------------------------------------------------------------

def primitive(a, p):
    """teste si a est une racine primitive de p avec p premier"""
    x = 1
    for d in range(1, p-1):
        x = x * a % p          # a^d = a^(d-1) * a
        if x == 1:
            return False
    return True


# ------------------------------------------------------------------------------
# Exercice 3 : recherche et liste des racines primitives
# ------------------------------------------------------------------------------

def racine_primitive(p):
    """recherche une racine primitive de p avec p premier"""
    a = 2
    while not primitive(a, p):
        a = a + 1
    return a


def liste_racines_primitives(p):
    """retourne la liste des racines primitives de p avec p premier"""
    resultat = []
    for a in range(2, p):
        if primitive(a, p):
            resultat.append(a)
    return resultat


# ------------------------------------------------------------------------------
# Exercice 4 : génération des clés El Gamal
# ------------------------------------------------------------------------------

def clefs(k):
    """génère une paire de clefs El Gamal avec un module p entre 2**k et 2**(k+1) - 1"""
    p = randprime(2**k, 2**(k+1))
    g = racine_primitive(p)
    a = randint(0, p-2)
    A = puissance(g, a, p)
    public_key = (p, g, A)
    private_key = a
    return public_key, private_key


# ------------------------------------------------------------------------------
# Exercice 5 : chiffrement (c = m * A^b, B = g^b)
# ------------------------------------------------------------------------------

def chiffrer(m, public_key):
    """chiffre le nombre m (0 <= m <= p-1) avec la clé publique (p, g, A)"""
    (p, g, A) = public_key
    b = randint(0, p-2)
    c = m * puissance(A, b, p)
    B = puissance(g, b, p)
    return c, B


# ------------------------------------------------------------------------------
# Exercice 6 : déchiffrement (m = c * (B^a)^(-1) mod p)
# Théorème 2 avec p premier : (B^a)^(-1) = (B^a)^(p-2) mod p
# ------------------------------------------------------------------------------

def dechiffrer(c, B, private_key, public_key):
    """déchiffre le message chiffré (c, B) avec la clé privée a"""
    (p, g, A) = public_key
    a = private_key
    Ba = puissance(B, a, p)
    inverse = puissance(Ba, p-2, p)
    return c * inverse % p


# ------------------------------------------------------------------------------
# Exercice 7 : encodage / décodage d'un texte (codes ASCII sur 3 chiffres)
# ------------------------------------------------------------------------------

def encode(texte):
    """transforme le texte en un nombre entier"""
    chaine = ""
    for c in texte:
        code = str(ord(c))
        while len(code) < 3:
            code = "0" + code
        chaine = chaine + code
    return int(chaine)


def decode(nombre):
    """retrouve le texte représenté par le nombre entier"""
    texte = ""
    while nombre > 0:
        num = nombre % 1000
        texte = chr(num) + texte
        nombre = nombre // 1000
    return texte


# ------------------------------------------------------------------------------
# Exercice 9 (Bonus) : découpage des entiers trop longs
# ------------------------------------------------------------------------------

def decouper(nombre, taille):
    """découpe le nombre en blocs de taille caractères (3*taille chiffres)"""
    blocs = []
    while nombre > 0:
        blocs = [nombre % 1000**taille] + blocs
        nombre = nombre // 1000**taille
    return blocs


def recoller(blocs, taille):
    """opération réciproque de decouper"""
    nombre = 0
    for bloc in blocs:
        nombre = nombre * 1000**taille + bloc
    return nombre


def chiffrer_texte(texte, public_key):
    """chiffre un texte de longueur quelconque, bloc par bloc"""
    (p, g, A) = public_key
    taille = (len(str(p)) - 1) // 3
    resultat = []
    for bloc in decouper(encode(texte), taille):
        resultat.append(chiffrer(bloc, public_key))
    return resultat


def dechiffrer_texte(cryptogramme, private_key, public_key):
    """déchiffre la liste des couples (c, B) et retrouve le texte"""
    (p, g, A) = public_key
    taille = (len(str(p)) - 1) // 3
    blocs = []
    for (c, B) in cryptogramme:
        blocs.append(dechiffrer(c, B, private_key, public_key))
    return decode(recoller(blocs, taille))


if __name__ == "__main__":
    # Exercice 1
    p = 31
    for a in [2, 3, 4, 5]:
        print("a =", a, ":", cycle(a, p))

    # Exercices 2 et 3
    print(primitive(3, 31), primitive(4, 31))
    print(racine_primitive(4999), racine_primitive(1000021))
    print(liste_racines_primitives(31))

    # Exercices 4, 5 et 6
    public_key, private_key = clefs(16)
    print(public_key, private_key)
    (p, g, A) = public_key
    m = randint(0, p-1)
    c, B = chiffrer(m, public_key)
    print(c, B)
    print(dechiffrer(c, B, private_key, public_key) == m)

    # Exercice 7
    for message in ["Bob", "Alice", "Chiffre d'El Gamal", "R3.09 - TP5"]:
        print(message, ":", decode(encode(message)) == message)

    # Exercice 8 (message de 2 caractères avec k = 20)
    ma_cle_publique, ma_cle_privee = clefs(20)
    c, B = chiffrer(encode("OK"), ma_cle_publique)
    print(decode(dechiffrer(c, B, ma_cle_privee, ma_cle_publique)))

    # Exercice 9 (Bonus)
    texte = "Le chiffre d'El Gamal repose sur le probleme du logarithme discret."
    cryptogramme = chiffrer_texte(texte, ma_cle_publique)
    print(len(cryptogramme), "blocs :", dechiffrer_texte(cryptogramme, ma_cle_privee, ma_cle_publique) == texte)
