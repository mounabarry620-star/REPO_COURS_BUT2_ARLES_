-- ==============================================================================
-- BUT 2 INFORMATIQUE - MODULE R3.07 : SQL DANS UN LANGAGE DE PROGRAMMATION
-- TP 1 : LES FONCTIONS EN PL/PGSQL
-- Schéma : TP1_Dep_Emp (Tables: departement, employes)
-- ==============================================================================

-- Sélection du schéma de travail
SET search_path = TP1_Dep_Emp, public;
SET CLIENT_ENCODING TO 'utf8';


-- ==============================================================================
-- 1. CALCUL DU SALAIRE MOYEN
-- ==============================================================================

-- A. Fonction moySalaire sans paramètre
CREATE OR REPLACE FUNCTION moySalaire() RETURNS NUMERIC AS $$
DECLARE
    v_moyenne NUMERIC;
BEGIN
    SELECT AVG(salaire) INTO v_moyenne
    FROM employes;

    RETURN v_moyenne;
END; $$ 
LANGUAGE plpgsql;

-- B. Test direct de la fonction (Résultat attendu : 22700)
SELECT moySalaire() AS salaire_moyen;

-- C. Requête : Noms et salaires des employés gagnant plus que le salaire moyen
SELECT nom, prenom, salaire
FROM employes
WHERE salaire > moySalaire()
ORDER BY salaire DESC;

-- D. Requête : Noms et salaires des employés dont le salaire est égal au salaire moyen à 10% près
-- Utilisation de la fonction ABS(valeur) comme conseillé dans le sujet :
SELECT nom, prenom, salaire
FROM employes
WHERE ABS(salaire - moySalaire()) <= 0.10 * moySalaire()
ORDER BY salaire;


-- ==============================================================================
-- 2. RECHERCHE NOM DEPARTEMENT
-- ==============================================================================

-- A. Fonction departement(noemp) renvoyant le nom du département de l'employé
CREATE OR REPLACE FUNCTION departement(p_noemp NUMERIC) RETURNS VARCHAR AS $$
DECLARE
    v_nom_dept departement.nom%TYPE;
BEGIN
    SELECT d.nom INTO v_nom_dept
    FROM departement d
    JOIN employes e ON e.nodept = d.nodept
    WHERE e.noemp = p_noemp;

    RETURN v_nom_dept;
END; $$ 
LANGUAGE plpgsql;

-- Tests de la fonction :
SELECT departement(1) AS dept_emp_1;  -- Administration
SELECT departement(2) AS dept_emp_2;  -- Distribution
SELECT departement(4) AS dept_emp_4;  -- Finance


-- ==============================================================================
-- 3. RETOURNER LES COLLEGUES
-- ==============================================================================

-- A. Fonction collegues(noemp)
-- Note : même département = même nodept (attention aux régions différentes).
-- L'employé lui-même est exclu (noemp <> p_noemp).
CREATE OR REPLACE FUNCTION collegues(p_noemp NUMERIC) RETURNS SETOF RECORD AS $$
DECLARE
    v_nodept employes.nodept%TYPE;
    rec_collegue RECORD;
BEGIN
    -- Récupération du numéro de département de l'employé
    SELECT nodept INTO v_nodept
    FROM employes
    WHERE noemp = p_noemp;

    -- Parcours de tous les collègues du même département
    FOR rec_collegue IN 
        SELECT nom, prenom
        FROM employes
        WHERE nodept = v_nodept 
          AND noemp <> p_noemp
        ORDER BY nom
    LOOP
        RETURN NEXT rec_collegue;
    END LOOP;

    RETURN;
END; $$ 
LANGUAGE plpgsql;

-- Test de la fonction avec description obligatoire des colonnes (AS (col type, ...))
SELECT * FROM collegues(16) AS (nom VARCHAR, prenom VARCHAR);


-- ==============================================================================
-- 4. NOM ET PRENOM DES SUPERIEURS
-- ==============================================================================

-- Étape 1 (Conseil) : Supérieur direct
CREATE OR REPLACE FUNCTION superieur_direct(p_noemp NUMERIC) RETURNS RECORD AS $$
DECLARE
    rec_supr RECORD;
BEGIN
    SELECT supr.nom, supr.prenom INTO rec_supr
    FROM employes e
    JOIN employes supr ON e.nosupr = supr.noemp
    WHERE e.noemp = p_noemp;

    RETURN rec_supr;
END; $$ 
LANGUAGE plpgsql;

-- Test du supérieur direct
SELECT * FROM superieur_direct(16) AS (nom VARCHAR, prenom VARCHAR);


-- Étape 2 : Tous les supérieurs hiérarchiques (boucle WHILE)
CREATE OR REPLACE FUNCTION superieurs(p_noemp NUMERIC) RETURNS SETOF RECORD AS $$
DECLARE
    v_current_supr employes.nosupr%TYPE;
    rec_supr RECORD;
BEGIN
    -- 1. Initialisation avec le supérieur direct
    SELECT nosupr INTO v_current_supr
    FROM employes
    WHERE noemp = p_noemp;

    -- 2. Remontée de la hiérarchie jusqu'au sommet (nosupr IS NULL)
    WHILE v_current_supr IS NOT NULL LOOP
        SELECT nom, prenom INTO rec_supr
        FROM employes
        WHERE noemp = v_current_supr;

        RETURN NEXT rec_supr;

        -- On remonte au chef du chef
        SELECT nosupr INTO v_current_supr
        FROM employes
        WHERE noemp = v_current_supr;
    END LOOP;

    RETURN;
END; $$ 
LANGUAGE plpgsql;

-- Test de tous les supérieurs pour l'employée Samira Traibien (noemp = 16)
SELECT * FROM superieurs(16) AS (nom VARCHAR, prenom VARCHAR);
