# ==============================================================================
# R3.09 - Cryptographie et Sécurité : TP 4 - Chiffrement par bloc
# Enseignant : B. Colombel
# Étudiant : Mamadou-Bailo BARRY
# ==============================================================================

from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes
from Crypto.Random.random import randrange
from Crypto.Util.strxor import strxor as xor
from Crypto.Util.number import bytes_to_long, long_to_bytes
from hashlib import md5, sha3_256, sha1

# ------------------------------------------------------------------------------
# Fonctions fournies par le sujet (Chiffrement / Déchiffrement AES d'un bloc de 16 octets)
# ------------------------------------------------------------------------------

def Enc(bloc, clef):
    if not isinstance(bloc, bytes) or not isinstance(clef, bytes):
        raise TypeError("le bloc et la clef doivent être de type bytes")
    if len(bloc) != 16 or len(clef) != 16:
        raise ValueError("le bloc et la clef doivent faire 16 octets")
    return AES.new(clef, AES.MODE_ECB).encrypt(bloc)


def Dec(bloc, clef):
    if not isinstance(bloc, bytes) or not isinstance(clef, bytes):
        raise TypeError("le bloc et la clef doivent être de type bytes")
    if len(bloc) != 16 or len(clef) != 16:
        raise ValueError("le bloc et la clef doivent faire 16 octets")
    return AES.new(clef, AES.MODE_ECB).decrypt(bloc)


# ------------------------------------------------------------------------------
# Exercice 2 : Padding et Unpadding (ISO/IEC 9797-1 / Bit padding)
# ------------------------------------------------------------------------------

def pad(s):
    """
    Ajoute un padding à la bytestring s pour que sa taille soit un multiple de 16 octets (128 bits).
    On ajoute un bit '1' (octet 0x80) puis des bits '0' (octets 0x00).
    On ajoute toujours au moins un octet (donc un bloc complet de 16 octets si s est déjà multiple de 16).
    """
    if not isinstance(s, bytes):
        raise TypeError("s doit être de type bytes")
    
    # Nombre d'octets à ajouter pour atteindre le prochain multiple de 16
    nb_octets = 16 - (len(s) % 16)
    
    # Le premier octet est 10000000_2 = 0x80 (128), suivi de nb_octets - 1 octets nuls 0x00
    padding = b'\x80' + b'\x00' * (nb_octets - 1)
    return s + padding


def unpad(s):
    """
    Retire le padding d'une bytestring s.
    Lève ValueError("message non correctement paddé") si le padding est invalide.
    """
    if not isinstance(s, bytes) or len(s) == 0 or len(s) % 16 != 0:
        raise ValueError("message non correctement paddé")
    
    # On parcourt depuis la fin pour passer tous les octets nuls 0x00
    i = len(s) - 1
    while i >= 0 and s[i] == 0:
        i -= 1
    
    # Le premier octet rencontré doit être 0x80 (valeur entière 128)
    # Et la longueur du padding ne peut pas dépasser 16 octets
    if i < 0 or s[i] != 0x80 or (len(s) - i) > 16:
        raise ValueError("message non correctement paddé")
    
    return s[:i]


# ------------------------------------------------------------------------------
# Exercice 3 : Mode ECB (Electronic Codebook)
# ------------------------------------------------------------------------------

def Enc_ECB(clair, clef):
    """
    Chiffre une bytestring clair de taille quelconque avec AES en mode ECB.
    Le message clair est d'abord paddé, puis découpé en blocs de 16 octets chiffrés indépendamment.
    """
    clair_padde = pad(clair)
    chiffre = b""
    for i in range(0, len(clair_padde), 16):
        bloc = clair_padde[i:i+16]
        chiffre += Enc(bloc, clef)
    return chiffre


def Dec_ECB(chiffre, clef):
    """
    Déchiffre une bytestring chiffre avec AES en mode ECB, puis retire le padding.
    """
    if len(chiffre) % 16 != 0:
        raise ValueError("la taille du chiffré doit être un multiple de 16")
    
    clair_padde = b""
    for i in range(0, len(chiffre), 16):
        bloc = chiffre[i:i+16]
        clair_padde += Dec(bloc, clef)
    return unpad(clair_padde)


# ------------------------------------------------------------------------------
# Exercice 4 : Mode CBC (Cipher Block Chaining)
# ------------------------------------------------------------------------------

def Enc_CBC(clair, clef):
    """
    Chiffre une bytestring clair avec AES en mode CBC.
    Génère un IV aléatoire de 16 octets, puis effectue le chaînage XOR : C_i = Enc(P_i XOR C_{i-1}).
    Renvoie IV + C_1 + C_2 + ... + C_m.
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
    Déchiffre une bytestring chiffre chiffrée avec AES en mode CBC.
    Le premier bloc de 16 octets est l'IV.
    P_i = Dec(C_i) XOR C_{i-1}.
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


# ------------------------------------------------------------------------------
# Exercice 5 : Révélation de l'image mystère (image.ecb.ppm)
# ------------------------------------------------------------------------------

def reveler_image_ecb(fichier_entree="image.ecb.ppm", fichier_sortie="velo-revele.ppm"):
    """
    Reconstruit l'image PPM à partir du fichier chiffré en ECB.
    Dimensions trouvées : L = 3979, H = 2392 pixels.
    Taille du corps = 3979 * 2392 * 3 = 28 553 304 octets.
    En-tête PPM : b'P6\\n3979 2392\\n255\\n' (17 octets).
    """
    L, H = 3979, 2392
    taille_pixels = L * H * 3
    en_tete = f"P6\n{L} {H}\n255\n".encode("ascii")
    
    with open(fichier_entree, "rb") as f:
        data = f.read()
    
    # Les 17 premiers octets correspondent au chiffrement de l'en-tête original
    # On prend les octets de pixels chiffrés directement après
    donnees_ppm = en_tete + data[17:17+taille_pixels]
    
    with open(fichier_sortie, "wb") as f:
        f.write(donnees_ppm)
    
    print(f"[+] Image révélée avec succès dans '{fichier_sortie}' !")
    print(f"    Dimensions : {L}x{H} pixels (Contenu : Un vélo)")


if __name__ == "__main__":
    print("--- Test des fonctions du TP4 ---")
    clef = get_random_bytes(16)
    
    # 1. Test Padding
    msg = b"Message secret pour le TP4 de crypto"
    p = pad(msg)
    u = unpad(p)
    assert u == msg
    print("[OK] Test Exercice 2 (pad / unpad)")
    
    # 2. Test ECB
    c_ecb = Enc_ECB(msg, clef)
    d_ecb = Dec_ECB(c_ecb, clef)
    assert d_ecb == msg
    print("[OK] Test Exercice 3 (Enc_ECB / Dec_ECB)")
    
    # 3. Test CBC
    c_cbc = Enc_CBC(msg, clef)
    d_cbc = Dec_CBC(c_cbc, clef)
    assert d_cbc == msg
    print("[OK] Test Exercice 4 (Enc_CBC / Dec_CBC)")
    
    # 4. Révélation de l'image mystère
    reveler_image_ecb()
