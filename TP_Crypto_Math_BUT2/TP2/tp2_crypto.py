# R3.09 - Cryptographie et Sécurité
# TP2 : Chiffrement par flot (Vernam, LFSR et GSA)
# B. Colombel - BUT Informatique

# ==============================================================================
# 1. Quelques fonctions utiles (fournies dans le sujet)
# ==============================================================================

def stringToBinary(msg):
    msg_bin = ""
    for i in bytearray(msg, encoding='ascii'):
        msg_bin = msg_bin + format(i, '08b')
    return msg_bin

def binaryToString(binary):
    msg = ""
    for i in range(0, len(binary), 8):
        byte_int = int(binary[i:i+8], 2)
        byte_char = chr(byte_int)
        msg = msg + byte_char
    return msg

print("En binaire :", stringToBinary("message en clair"))
print("En ascii :", binaryToString(stringToBinary("message en clair")))


# ==============================================================================
# 2. Chiffrement de Vernam – masque jetable
# ==============================================================================

# Exercice 1
def chiffrementVernam(msgBinaire, clef):
    chiffre = ""
    for i in range(len(msgBinaire)):
        bit_m = int(msgBinaire[i])
        bit_k = int(clef[i])
        bit_c = bit_m ^ bit_k
        chiffre = chiffre + str(bit_c)
    return chiffre

# Test Exercice 1
try:
    assert chiffrementVernam(stringToBinary("vernam"), \
    "110011001100110011001100110011001100110011001100") == \
    "101110101010100110111110101000101010110110100001"
    print("chiffrementVernam : OK")
except:
    print("chiffrementVernam : ERREUR")


# Exercice 2
# Le déchiffrement s'opère en exécutant la même opération : m = c ^ k
chiffre = "1010001010101101101010011011111010111000"
clef    = "1100110011001100110011001100110011001100"
msg_clair_binaire = chiffrementVernam(chiffre, clef)
msg_clair_ascii = binaryToString(msg_clair_binaire)
print("Exercice 2 - Message déchiffré en clair :", msg_clair_ascii)


# ==============================================================================
# 3. Registre à décalage à rétroaction linéaire (LFSR)
# ==============================================================================

# Exercice 3
def etatSuivant(etat, coeff):
    # Le bit de sortie est le premier bit du registre (le plus à gauche)
    sortie = etat[0]
    
    # On calcule le nouveau bit inséré à droite par XOR des bits indiqués par coeff
    nouveau_bit = 0
    for i in coeff:
        nouveau_bit = nouveau_bit ^ etat[i]
        
    # On décale vers la gauche et on insère le nouveau bit à la fin
    nouvel_etat = etat[1:] + [nouveau_bit]
    return (nouvel_etat, sortie)

# Test Exercice 3
try:
    assert etatSuivant([1,0,0,1],[0,2,3]) == ([0, 0, 1, 0], 1) # Exemple précédent t1
    assert etatSuivant(etatSuivant([1,0,0,1],[0,2,3])[0],[0,2,3]) == ([0, 1, 0, 1], 0) # Exemple précédent t2
    print("etatSuivant : OK")
except:
    print("etatSuivant : ERREUR")


# Exercice 4
# Quelle sera la suite chiffrante à t14 ? Que remarquez vous ?
# (Cette analyse est détaillée dans le walkthrough et vérifiée avec suite_LFSR)


# Exercice 5
def suite_LFSR(graine, coeff, n):
    suite = ""
    etat = graine
    for i in range(n):
        etat, sortie = etatSuivant(etat, coeff)
        suite = suite + str(sortie)
    return suite

# Test Exercice 5
try:
    assert suite_LFSR([1,0,0,1],[0,2,3], 14) == "10010111001011"
    print("suite_LFSR : OK")
except:
    print("suite_LFSR : ERREUR")


# Exercice 6
def chiffrementLFSR(msgAscii, graine, coeff):
    msgBinaire = stringToBinary(msgAscii)
    clef = suite_LFSR(graine, coeff, len(msgBinaire))
    return chiffrementVernam(msgBinaire, clef)

# Test Exercice 6
try:
    assert chiffrementLFSR("naert", [1,0,0,1], [0,2,3]) == "1111100101001111001110011100101100000110"
    print("chiffrementLFSR : OK")
except:
    print("chiffrementLFSR : ERREUR")


# Exercice 7
def dechiffrementLFSR(msgChiffBinary, graine, coeff):
    clef = suite_LFSR(graine, coeff, len(msgChiffBinary))
    msgBinaire = chiffrementVernam(msgChiffBinary, clef)
    return binaryToString(msgBinaire)

# Test Exercice 7
try:
    assert dechiffrementLFSR("1111100101001111001110011100101100000110", [1,0,0,1], [0,2,3]) == "naert"
    print("dechiffrementLFSR : OK")
except:
    print("dechiffrementLFSR : ERREUR")


# ==============================================================================
# 4. Générateur à signal d'arrêt (GSA)
# ==============================================================================

# Exercice 8
def suite_gsa(graineR1, coeffR1, graineR2, coeffR2, n):
    suite = ""
    etat1 = graineR1
    etat2 = graineR2
    sortie1 = etat1[0]
    sortie2 = etat2[0]
    
    for i in range(n):
        # R2 ne change d'état que si la sortie de R1 à l'instant t-1 valait 1
        if sortie1 == 1:
            etat2, sortie2 = etatSuivant(etat2, coeffR2)
        # Si sortie1 == 0, R2 n'est pas décalé, sortie2 reste celle de l'instant précédent
        
        suite = suite + str(sortie2)
        
        # R1 est un LFSR normal cadencé par l'horloge
        etat1, sortie1 = etatSuivant(etat1, coeffR1)
        
    return suite

# Test Exercice 8
print("10 premiers termes de la suite chiffrante : ", \
suite_gsa([1,0,1,0,1,1,0,0],[0, 3, 5],[1,0,1,0,1,0,1,0], [0, 2, 5, 6], 10))

try:
    assert suite_gsa([1,0,1,0,1,1,0,0],[0, 3, 5],[1,0,1,0,1,0,1,0], [0, 2, 5, 6], 10) == \
    "1001101111"
    print("suite_gsa : OK")
except:
    print("suite_gsa : ERREUR")
