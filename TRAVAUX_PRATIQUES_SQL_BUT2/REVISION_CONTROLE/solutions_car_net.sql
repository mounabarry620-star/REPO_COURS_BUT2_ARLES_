-- =====================================================================
--  Solutions des exercices d'entraînement — base bdd_car_net
--  Révision contrôle « Les fonctions PL/pgSQL » (R3.07)
--  Toutes les fonctions ont été testées sur le script create_table_car_net.sql
--  Usage : lancer d'abord create_table_car_net.sql, puis coller les blocs un par un.
--  ATTENTION phppgadmin : exécutez chaque test "-- ERREUR" SEUL dans la fenêtre SQL.
--  Une exception annule toutes les instructions envoyées en même temps qu'elle
--  (y compris le CREATE FUNCTION qui la précède dans le même envoi).
-- =====================================================================

SET search_path = bdd_car_net;

-- ============ Exercice 1 ============
CREATE OR REPLACE FUNCTION nb_vehicules() RETURNS integer AS $$
DECLARE
    v_nb integer;
BEGIN
    SELECT count(*) INTO v_nb FROM vehicule;
    RETURN v_nb;
END;
$$ LANGUAGE plpgsql;

SELECT nb_vehicules();                     -- 16

-- ============ Exercice 2 ============
CREATE OR REPLACE FUNCTION prix_vehicule(p_code integer) RETURNS numeric AS $$
DECLARE
    v_prix vehicule.prix_jour%TYPE;
BEGIN
    SELECT prix_jour INTO v_prix FROM vehicule WHERE code_vehicule = p_code;
    -- SELECT INTO positionne FOUND : pas besoin d'un PERFORM séparé ici
    IF NOT FOUND THEN
        RAISE EXCEPTION 'le véhicule % n''existe pas', p_code;
    END IF;
    RETURN v_prix;
END;
$$ LANGUAGE plpgsql;

SELECT prix_vehicule(1);                   -- 33.00
SELECT prix_vehicule(99);                  -- ERREUR: le véhicule 99 n'existe pas
SELECT exemple, prix_jour FROM vehicule WHERE prix_jour > prix_vehicule(4);   -- 11 lignes

-- ============ Exercice 3 ============
CREATE OR REPLACE FUNCTION nb_jours_resa(p_resa integer) RETURNS integer AS $$
DECLARE
    v_nb integer;
BEGIN
    SELECT extract(day FROM (date_heure_retour - date_heure_depart)) INTO v_nb
    FROM reservation WHERE num_resa = p_resa;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'la réservation % n''existe pas', p_resa;
    END IF;
    RETURN v_nb;
END;
$$ LANGUAGE plpgsql;

SELECT nb_jours_resa(78);                  -- 2
SELECT nb_jours_resa(100);                 -- 4
SELECT nb_jours_resa(9999);                -- ERREUR: la réservation 9999 n'existe pas

-- ============ Exercice 4 ============
CREATE OR REPLACE FUNCTION montant_resa(p_resa integer) RETURNS numeric AS $$
DECLARE
    v_prix numeric;
BEGIN
    SELECT prix_jour INTO v_prix
    FROM reservation JOIN vehicule USING (code_vehicule)
    WHERE num_resa = p_resa;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'la réservation % n''existe pas', p_resa;
    END IF;
    RETURN v_prix * nb_jours_resa(p_resa);     -- réutilisation de la fonction précédente
END;
$$ LANGUAGE plpgsql;

SELECT montant_resa(78);                   -- 262.00
SELECT montant_resa(100);                  -- 580.00

-- ============ Exercice 5 ============
CREATE OR REPLACE FUNCTION est_fidele(p_num integer) RETURNS boolean AS $$
DECLARE
    v_type client.type_client%TYPE;
BEGIN
    SELECT type_client INTO v_type FROM client WHERE num_client = p_num;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'le client % n''existe pas', p_num;
    END IF;
    RETURN v_type = 'Fidéle';        -- attention à l'orthographe exacte dans la base
END;
$$ LANGUAGE plpgsql;

SELECT est_fidele(100);                    -- true
SELECT est_fidele(103);                    -- false
SELECT est_fidele(1);                      -- ERREUR: le client 1 n'existe pas

-- ============ Exercice 6 ============
CREATE OR REPLACE FUNCTION points_tranche(p_code integer, p_nb_jours integer) RETURNS integer AS $$
DECLARE
    v_pts integer;
BEGIN
    PERFORM * FROM vehicule WHERE code_vehicule = p_code;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'le véhicule % n''existe pas', p_code;
    END IF;
    IF p_nb_jours <= 0 THEN
        RAISE EXCEPTION 'le nombre de jours doit être positif';
    END IF;
    -- la plus grande tranche inférieure ou égale à la durée
    SELECT nb_points INTO v_pts
    FROM attribuer
    WHERE code_vehicule = p_code AND nb_jours <= p_nb_jours
    ORDER BY nb_jours DESC
    LIMIT 1;
    RETURN coalesce(v_pts, 0);       -- aucune tranche → 0 point
END;
$$ LANGUAGE plpgsql;

SELECT points_tranche(1,2), points_tranche(1,3), points_tranche(1,4),
       points_tranche(1,6), points_tranche(1,25), points_tranche(1,40);   -- 0 10 10 20 60 100
SELECT points_tranche(1,0);                -- ERREUR: le nombre de jours doit être positif

-- ============ Exercice 7 ============
CREATE OR REPLACE FUNCTION info_client(p_num integer) RETURNS record AS $$
DECLARE
    v_info record;
BEGIN
    PERFORM * FROM client WHERE num_client = p_num;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'le client % n''existe pas', p_num;
    END IF;
    SELECT nom_client, pre_client, type_client INTO v_info
    FROM client WHERE num_client = p_num;
    RETURN v_info;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM info_client(100) AS (nom varchar, prenom varchar, type_cli varchar);  -- Paul | Troy | Fidéle
SELECT * FROM info_client(1)   AS (nom varchar, prenom varchar, type_cli varchar);  -- ERREUR

-- ============ Exercice 8 ============
CREATE OR REPLACE FUNCTION vehicules_categorie(p_cat char) RETURNS SETOF record AS $$
DECLARE
    v_ligne record;
BEGIN
    PERFORM * FROM vehicule WHERE categorie = p_cat;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'aucun véhicule de catégorie %', p_cat;
    END IF;
    FOR v_ligne IN SELECT exemple, prix_jour, clim
                   FROM vehicule WHERE categorie = p_cat
                   ORDER BY prix_jour
    LOOP
        RETURN NEXT v_ligne;
    END LOOP;
    RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM vehicules_categorie('A') AS (modele varchar, prix numeric, clim boolean);  -- 4 lignes
SELECT * FROM vehicules_categorie('Z') AS (modele varchar, prix numeric, clim boolean);  -- ERREUR

-- ============ Exercice 9 ============
CREATE OR REPLACE FUNCTION agences_pays(p_pays char(2)) RETURNS SETOF agence AS $$
BEGIN
    RETURN QUERY SELECT * FROM agence WHERE pays_agence = p_pays ORDER BY nom_agence;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM agences_pays('US');                              -- 25 lignes, pas de AS (...)
SELECT nom_agence, ville_agence FROM agences_pays('US');

-- ============ Exercice 10 ============
CREATE OR REPLACE FUNCTION horaires_agence(p_nom varchar) RETURNS SETOF record AS $$
DECLARE
    v_ligne record;
BEGIN
    PERFORM * FROM agence WHERE lower(nom_agence) = lower(p_nom);
    IF NOT FOUND THEN
        RAISE EXCEPTION 'l''agence % n''existe pas', p_nom;
    END IF;
    FOR v_ligne IN SELECT libelle_jour, heure_ouverture, heure_fermeture
                   FROM agence JOIN ouverture USING (num_agence)
                               JOIN jour_semaine USING (num_jour)
                   WHERE lower(nom_agence) = lower(p_nom)
                   ORDER BY num_jour
    LOOP
        RETURN NEXT v_ligne;
    END LOOP;
    RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM horaires_agence('Lavat sud')  AS (jour varchar, ouv time, ferm time);  -- 6 lignes
SELECT * FROM horaires_agence('LAVAT SUD')  AS (jour varchar, ouv time, ferm time);  -- idem (lower)
SELECT * FROM horaires_agence('Nulle part') AS (jour varchar, ouv time, ferm time);  -- ERREUR

-- ============ Exercice 11 ============
CREATE OR REPLACE FUNCTION meilleur_client() RETURNS record AS $$
DECLARE
    v_info record;
BEGIN
    SELECT num_client, nom_client, pre_client, count(*) AS nb_resa INTO v_info
    FROM client JOIN reservation USING (num_client)
    GROUP BY num_client, nom_client, pre_client
    ORDER BY nb_resa DESC
    LIMIT 1;
    RETURN v_info;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM meilleur_client() AS (num int, nom varchar, prenom varchar, nb bigint);  -- 124 Rhodes Silas 13

-- ============ Exercice 12 ============
CREATE OR REPLACE FUNCTION ca_par_categorie()
RETURNS TABLE (categorie char, nb_resa bigint, chiffre_affaires numeric) AS $$
BEGIN
    RETURN QUERY
        SELECT v.categorie, count(*),
               sum(prix_jour * extract(day FROM (date_heure_retour - date_heure_depart)))
        FROM reservation r JOIN vehicule v USING (code_vehicule)
        GROUP BY v.categorie
        ORDER BY v.categorie;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM ca_par_categorie();          -- A 57 43428 | B 35 36354 | C 26 26227 | F 49 72072 | K 33 33763

-- ============ Exercice 13 (curseur paramétré) ============
CREATE OR REPLACE FUNCTION reservations_client(p_num integer) RETURNS SETOF record AS $$
DECLARE
    v_ligne record;
    curs_resa CURSOR (p_cli integer) FOR
        SELECT num_resa, exemple,
               extract(day FROM (date_heure_retour - date_heure_depart))::int AS nb_jours,
               prix_jour * extract(day FROM (date_heure_retour - date_heure_depart)) AS montant
        FROM reservation JOIN vehicule USING (code_vehicule)
        WHERE num_client = p_cli
        ORDER BY date_heure_depart;
BEGIN
    PERFORM * FROM client WHERE num_client = p_num;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'le client % n''existe pas', p_num;
    END IF;
    OPEN curs_resa(p_num);
    LOOP
        FETCH curs_resa INTO v_ligne;
        EXIT WHEN NOT FOUND;
        RETURN NEXT v_ligne;
    END LOOP;
    CLOSE curs_resa;
    RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM reservations_client(100) AS (num_resa int, vehicule varchar, nb_jours int, montant numeric);
-- 18 opel corsa 16 528 | 144 toyota yaris 10 780 | 178 citroen jumper 18 2610 | 182 ... | 358 ... | 210 ...
SELECT sum(montant) FROM reservations_client(100) AS (num_resa int, vehicule varchar, nb_jours int, montant numeric);
-- 5129  (= SommePaye(100))

-- ============ Exercice 14 ============
CREATE OR REPLACE FUNCTION majorer_prix(p_cat char, p_pct numeric) RETURNS integer AS $$
DECLARE
    v_nb integer;
BEGIN
    IF p_pct <= 0 OR p_pct > 50 THEN
        RAISE EXCEPTION 'pourcentage % invalide (doit être entre 0 et 50)', p_pct;
    END IF;
    PERFORM * FROM vehicule WHERE categorie = p_cat;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'aucun véhicule de catégorie %', p_cat;
    END IF;
    UPDATE vehicule SET prix_jour = round(prix_jour * (1 + p_pct/100), 2)
    WHERE categorie = p_cat;
    GET DIAGNOSTICS v_nb = ROW_COUNT;    -- nombre de lignes modifiées par l'UPDATE
    RETURN v_nb;
END;
$$ LANGUAGE plpgsql;

SELECT majorer_prix('A', 10);              -- 4
SELECT code_vehicule, exemple, prix_jour FROM vehicule WHERE categorie = 'A';   -- opel corsa 36.30 ...
SELECT majorer_prix('A', 80);              -- ERREUR: pourcentage 80 invalide

-- ============ Exercice 15 ============
CREATE OR REPLACE FUNCTION crediter_points(p_num integer) RETURNS integer AS $$
DECLARE
    v_resa  record;
    v_total integer := 0;
BEGIN
    -- est_fidele lève déjà l'exception si le client n'existe pas
    IF NOT est_fidele(p_num) THEN
        RAISE EXCEPTION 'le client % n''est pas Fidéle, pas de points', p_num;
    END IF;
    FOR v_resa IN SELECT code_vehicule,
                         extract(day FROM (date_heure_retour - date_heure_depart))::int AS nbj
                  FROM reservation WHERE num_client = p_num
    LOOP
        v_total := v_total + points_tranche(v_resa.code_vehicule, v_resa.nbj);
    END LOOP;
    UPDATE client SET pts_bonus_acquis = coalesce(pts_bonus_acquis, 0) + v_total
    WHERE num_client = p_num;
    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

SELECT pts_bonus_acquis FROM client WHERE num_client = 100;   -- 220
SELECT crediter_points(100);                                   -- 233
SELECT pts_bonus_acquis FROM client WHERE num_client = 100;   -- 453
SELECT crediter_points(103);                                   -- ERREUR: le client 103 n'est pas Fidéle

-- ============ Exercice 16 (curseur + %ROWTYPE) ============
CREATE OR REPLACE FUNCTION clients_fideles_sans_points() RETURNS SETOF client AS $$
DECLARE
    v_cli client%ROWTYPE;
    curs_cli CURSOR FOR
        SELECT * FROM client
        WHERE type_client = 'Fidéle' AND coalesce(pts_bonus_acquis, 0) = 0
        ORDER BY nom_client;
BEGIN
    OPEN curs_cli;
    LOOP
        FETCH curs_cli INTO v_cli;
        EXIT WHEN NOT FOUND;
        RETURN NEXT v_cli;
    END LOOP;
    CLOSE curs_cli;
    RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT num_client, nom_client, pts_bonus_acquis FROM clients_fideles_sans_points();   -- 131 Shields NULL

-- ============ Exercice 17 (trigger) ============
CREATE OR REPLACE FUNCTION verif_dates_resa() RETURNS trigger AS $$
BEGIN
    IF NEW.date_heure_retour <= NEW.date_heure_depart THEN
        RAISE EXCEPTION 'retour (%) doit être après départ (%)', NEW.date_heure_retour, NEW.date_heure_depart;
    END IF;
    IF NEW.date_resa IS NULL THEN
        NEW.date_resa := current_date;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_verif_dates_resa BEFORE INSERT OR UPDATE ON reservation
FOR EACH ROW EXECUTE PROCEDURE verif_dates_resa();

-- refusé
INSERT INTO reservation (retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour)
VALUES (1007, 1007, 100, 1, '2024-01-01', '2024-01-10 08:00', '2024-01-05 08:00');
-- accepté
INSERT INTO reservation (retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour)
VALUES (1007, 1007, 100, 1, '2024-01-01', '2024-01-05 08:00', '2024-01-10 08:00');


-- =====================================================================
--  Correction du contrôle d'entraînement (version du prof, commentée)
-- =====================================================================
SET search_path = bdd_car_net;

-- Exercice 1 : SETOF record, jointure vehicule-proposer-agence, lower() pour la casse
CREATE OR REPLACE FUNCTION listeVehicule(p_nom_ag varchar(45)) RETURNS setof record AS $$
DECLARE
    v_ligne record;
BEGIN
    PERFORM nom_agence FROM agence WHERE lower(nom_agence) = lower(p_nom_ag);
    IF NOT FOUND THEN
        RAISE EXCEPTION 'l''agence % n''existe pas', p_nom_ag;
    END IF;
    FOR v_ligne IN SELECT exemple, prix_jour
                   FROM vehicule INNER JOIN proposer USING (code_vehicule)
                                 INNER JOIN agence USING (num_agence)
                   WHERE lower(nom_agence) = lower(p_nom_ag)
    LOOP
        RETURN NEXT v_ligne;
    END LOOP;
    RETURN;
END
$$ LANGUAGE plpgsql;

SELECT * FROM listeVehicule('Micsot') AS (nom_vehi varchar, px numeric);   -- 4 lignes
SELECT * FROM listeVehicule('Ade')    AS (nom_vehi varchar, px numeric);
SELECT * FROM listeVehicule('Micot')  AS (nom_vehi varchar, px numeric);   -- ERREUR: l'agence Micot n'existe pas

-- Exercice 2 : scalaire, extract(day FROM intervalle)
CREATE OR REPLACE FUNCTION SommePaye(p_numCli int) RETURNS real AS $$
DECLARE
    somme real;
BEGIN
    PERFORM num_client FROM client WHERE num_client = p_numCli;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'le client % n''existe pas', p_numCli;
    END IF;
    SELECT sum(prix_jour * extract(day FROM (date_heure_retour - date_heure_depart)))
    INTO somme
    FROM reservation INNER JOIN vehicule USING (code_vehicule)
    WHERE num_client = p_numCli;
    RETURN somme;
END
$$ LANGUAGE plpgsql;

SELECT SommePaye(100);   -- 5129
SELECT SommePaye(102);   -- 7402
SELECT SommePaye(103);   -- 1016
SELECT SommePaye(33);    -- ERREUR: le client 33 n'existe pas

-- Exercice 3 : record, 4 vérifications, sous-requête ORDER BY nb_jours DESC LIMIT 1
CREATE OR REPLACE FUNCTION nb_pts(NumeroClient int, Num_vehi int, date_deb date, date_fin date)
RETURNS record AS $$
DECLARE
    info record;
BEGIN
    PERFORM num_client FROM client WHERE num_client = NumeroClient;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'le client % n''existe pas', NumeroClient;
    END IF;
    PERFORM num_client FROM client WHERE type_client = 'Fidéle' AND num_client = NumeroClient;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'le client % n''est pas Fidéle', NumeroClient;
    END IF;
    PERFORM code_vehicule FROM vehicule WHERE code_vehicule = Num_vehi;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'le véhicule % n''existe pas', Num_vehi;
    END IF;
    IF date_deb > date_fin THEN
        RAISE EXCEPTION 'la date de début ne peut être plus grande que la date de fin';
    END IF;
    SELECT coalesce(pts_bonus_acquis, 0) AS pts_deja_acquis,
           (SELECT nb_points FROM attribuer
            WHERE nb_jours <= date_fin - date_deb AND code_vehicule = Num_vehi
            ORDER BY nb_jours DESC LIMIT 1) AS nb_pts_attribuer,
           coalesce(pts_bonus_acquis, 0) +
           (SELECT nb_points FROM attribuer
            WHERE nb_jours <= date_fin - date_deb AND code_vehicule = Num_vehi
            ORDER BY nb_jours DESC LIMIT 1) AS pts_total
    INTO info
    FROM client WHERE num_client = NumeroClient;
    RETURN info;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM nb_pts(300, 1, '2020-06-30', '2020-06-20') AS (deja int, attribues int, total int);  -- client 300 n'existe pas
SELECT * FROM nb_pts(100, 78, '2020-06-30', '2020-06-20') AS (deja int, attribues int, total int); -- véhicule 78 n'existe pas
SELECT * FROM nb_pts(103, 1, '2020-06-20', '2020-06-30') AS (deja int, attribues int, total int);  -- client 103 n'est pas Fidéle
SELECT * FROM nb_pts(104, 1, '2020-06-30', '2020-06-20') AS (deja int, attribues int, total int);  -- dates incohérentes
SELECT * FROM nb_pts(104, 1, '2020-06-20', '2020-06-30') AS (deja int, attribues int, total int);  -- 190 | 50 | 240
