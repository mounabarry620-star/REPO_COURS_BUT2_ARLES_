# R2.09 / R3.09 - Cryptographie et Sécurité
# TP3 : Le Cryptosystème RSA
# BUT Informatique 2 - Site d'Arles
# Étudiant : Mamadou-Bailo BARRY

import math
import random
import sympy

# ==============================================================================
# 1. Calcul de puissances modulaires (Algorithme des carrés)
# ==============================================================================

def expo_mod(a, r, m):
    """
    Exercice 1 :
    Calcule (a^r) mod m par l'algorithme des carrés répétés.
    Correspond exactement au tableau à 3 colonnes (r, a, p) vu en cours.
    """
    p = 1
    while r > 0:
        if r % 2 == 1:
            p = (p * a) % m
            r = (r - 1) // 2
        else:
            r = r // 2
        a = (a * a) % m
    return p


# ==============================================================================
# Euclide étendu pour trouver l'inverse modulaire
# (comme vu au tableau pour la remontée de Bézout)
# ==============================================================================

def inverse_modulaire(a, m):
    """
    Calcule l'inverse de a modulo m par l'algorithme d'Euclide étendu.
    Renvoie d tel que (a * d) % m == 1.
    """
    r0, r1 = a, m
    u0, u1 = 1, 0
    while r1 != 0:
        q = r0 // r1
        r0, r1 = r1, r0 - q * r1
        u0, u1 = u1, u0 - q * u1
    return u0 % m


# ==============================================================================
# 5.1 Algorithme de Fermat (Exercice 4)
# ==============================================================================

def factorisation_fermat(n):
    """
    Factorise n lorsque p et q sont proches en utilisant t^2 - s^2 = n.
    """
    t = math.isqrt(n) + 1
    z = t * t - n
    while True:
        s = math.isqrt(z)
        if s * s == z:
            break
        t += 1
        z = t * t - n
    
    p = t + s
    q = t - s
    return p, q


# ==============================================================================
# 5.2 Attaque de Wiener (Exercice 5)
# ==============================================================================

def fractions_continues(num, den):
    """
    Quotients successifs du développement en fraction continue de num / den.
    """
    quotients = []
    while den != 0:
        q = num // den
        quotients.append(q)
        num, den = den, num - q * den
    return quotients

def calculer_reduites(quotients):
    """
    Calcule les réduites (convergents p_k / q_k).
    """
    reduites = []
    p0, q0 = quotients[0], 1
    reduites.append((p0, q0))
    if len(quotients) > 1:
        p1 = quotients[0] * quotients[1] + 1
        q1 = quotients[1]
        reduites.append((p1, q1))
        for a in quotients[2:]:
            pk = a * reduites[-1][0] + reduites[-2][0]
            qk = a * reduites[-1][1] + reduites[-2][1]
            reduites.append((pk, qk))
    return reduites


# ==============================================================================
# EXÉCUTION PAS À PAS DU TP
# ==============================================================================

if __name__ == "__main__":
    print("=================================================================")
    print("TP3 - CRYPTOGRAPHIE RSA (Mamadou-Bailo BARRY)")
    print("=================================================================")

    # --- Exercice 1 : expo_mod ---
    print("\n--- Exercice 1 : expo_mod ---")
    test_1 = expo_mod(13, 5, 8)
    print("expo_mod(13, 5, 8) =", test_1)

    # --- Section 3 : Exemple simple ---
    print("\n--- Section 3 : Exemple simple ---")
    p = 47
    q = 59
    n = p * q
    phi = (p - 1) * (q - 1)
    e = 17
    d = inverse_modulaire(e, phi)

    print("n =", n)
    print("phi =", phi)
    print("e =", e)
    print("d =", d)
    print("(d * e) % phi =", (d * e) % phi)

    # Chiffrement / Déchiffrement du bloc 920 ("IT")
    m1 = 920
    c1 = expo_mod(m1, e, n)
    print("Message 920 chiffré :", c1)
    m1_retrouve = expo_mod(c1, d, n)
    print("Message déchiffré   :", m1_retrouve)

    # --- Section 4 : Grandeur nature ---
    print("\n--- Section 4 : Grandeur nature ---")
    p_310 = int(
        "5171580075478931594509360412348407766342210294522059751636118270640506099833200190938948490555"
        "2094870375598598430016472322509555705267350496700893495163926881229099888666976749337348684008"
        "2512338933731996459237216480672992658123322297095622665270892135162788565075722225050864864633"
        "7166668774289018643141435141"
    )
    print("Nombre de chiffres de p :", len(str(p_310)))

    # Tirage de q
    while True:
        candidat = random.randrange(10**309, 10**311)
        if candidat % 2 == 1 and sympy.isprime(candidat):
            q_310 = candidat
            break

    print("Nombre de chiffres de q :", len(str(q_310)))
    n_grand = p_310 * q_310
    print("Nombre de chiffres de n :", len(str(n_grand)))

    phi_grand = (p_310 - 1) * (q_310 - 1)
    print("Nombre de chiffres de phi(n) :", len(str(phi_grand)))

    # Test avec un message numérique aléatoire
    e_grand = 65537
    d_grand = inverse_modulaire(e_grand, phi_grand)
    m_test = random.randrange(1, n_grand)
    c_test = expo_mod(m_test, e_grand, n_grand)
    m_recu = expo_mod(c_test, d_grand, n_grand)
    print("Déchiffrement réussi sur grand nombre :", m_recu == m_test)

    # --- Exercice 4 : Fermat ---
    print("\n--- Exercice 4 : Factorisation de Fermat ---")
    n_f = 4840015169768242918240815055699674259180276588222516131662837
    e_f = 65537
    c_f = 2336273333675885101548598149697595180856150539608777837370662

    p_f, q_f = factorisation_fermat(n_f)
    print("p =", p_f)
    print("q =", q_f)
    print("Vérification p * q == n :", p_f * q_f == n_f)

    phi_f = (p_f - 1) * (q_f - 1)
    d_f = inverse_modulaire(e_f, phi_f)
    print("d =", d_f)

    K = expo_mod(c_f, d_f, n_f)
    print("Clé secrète K =", K)
    print("Taille de K :", K.bit_length(), "bits")

    # --- Exercice 5 : Wiener ---
    print("\n--- Exercice 5 : Attaque de Wiener ---")
    n_w = int(
        "72607690796382219533855601574226979839358925894783012264746192242312064761807469686556032798997767218652403849992784150982852102067195784924553481000061931627100261501090420476819158891107478865521004842594565621865761568219736813805495036064204106467048980512337940858538750651798890768604018328115165005573"
    )
    e_w = int(
        "67715972340573783647161184330298178393906701963991927108027628141059072148144735004419413509389838752160732172897464811380398084788206901478376077107638769067644093024789666701558654700521392247661822616688334643664821383484032774980431792606135434693625403907803225216173220349070640509336914301659248439067"
    )
    mc_w = int(
        "7838294556988410460801911618474336965523762977662313406559253659252836897207399214461066284783654038457202403830044504376648763024360414206299770836089618910088109871939838200354548125816096570413755061613485229318236280200904889067968609369568142098062420460396137162769658214493917660515828417381339578346"
    )

    # Réduites
    quots = fractions_continues(e_w, n_w)
    cvgts = calculer_reduites(quots)

    # Recherche de d avec m = 12345
    m_temoin = 12345
    c_temoin = expo_mod(m_temoin, e_w, n_w)
    d_trouve = None

    for _, qk in cvgts:
        if qk > 0 and expo_mod(c_temoin, qk, n_w) == m_temoin:
            d_trouve = qk
            break

    print("Clé d trouvée :", d_trouve)

    # Déchiffrement
    m_dechiffre = expo_mod(mc_w, d_trouve, n_w)
    print("Nombre déchiffré :", m_dechiffre)

    # Décodage en texte (espace = 10, A = 11, B = 12, ..., Z = 36)
    s_m = str(m_dechiffre)
    texte = ""
    for i in range(0, len(s_m), 2):
        code = int(s_m[i:i+2])
        if code == 10:
            texte += " "
        elif 11 <= code <= 36:
            texte += chr(ord('A') + (code - 11))

    print("\nMessage secret déchiffré :", texte)
    print("=================================================================")
