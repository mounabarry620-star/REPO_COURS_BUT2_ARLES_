
-- ============================================================
-- Base de données : TravelNow
-- TP Fonctions PL/pgSQL
-- Création du schéma
-- ============================================================

DROP SCHEMA IF EXISTS tp_travelnow CASCADE;
CREATE SCHEMA tp2_travelnow;

SET search_path TO tp2_travelnow;

-- ============================================================
-- TABLE CLIENTS
-- ============================================================

CREATE TABLE clients (
    id_client SERIAL PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    telephone VARCHAR(20),
    date_naissance DATE,
    date_inscription DATE DEFAULT CURRENT_DATE,
    niveau_fidelite VARCHAR(15) DEFAULT 'Bronze'  CHECK (niveau_fidelite IN ('Bronze','Argent','Or','Platine'))
);

-- ============================================================
-- TABLE DESTINATIONS
-- ============================================================

CREATE TABLE destinations (
    id_destination SERIAL PRIMARY KEY,
    nom VARCHAR(80) NOT NULL,
    pays VARCHAR(80) NOT NULL,
    continent VARCHAR(30) NOT NULL,
    prix_base NUMERIC(10,2) NOT NULL CHECK (prix_base > 0)
);

-- ============================================================
-- TABLE GUIDES
-- ============================================================

CREATE TABLE guides (
    id_guide SERIAL PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    langue VARCHAR(30) NOT NULL,
    date_embauche DATE NOT NULL,
    salaire NUMERIC(10,2) CHECK (salaire > 0),
    id_mentor INTEGER,
    CONSTRAINT fk_mentor  FOREIGN KEY (id_mentor)  REFERENCES guides(id_guide)
);

-- ============================================================
-- TABLE VOYAGES
-- ============================================================

CREATE TABLE voyages (

    id_voyage SERIAL PRIMARY KEY,
    id_destination INTEGER NOT NULL,
    id_guide INTEGER NOT NULL,
    date_depart DATE NOT NULL,
    date_retour DATE NOT NULL,
    capacite INTEGER NOT NULL  CHECK(capacite > 0),
    prix NUMERIC(10,2) NOT NULL CHECK(prix > 0),
    statut VARCHAR(20) DEFAULT 'OUVERT' CHECK(statut IN ('OUVERT','COMPLET','ANNULER','TERMINER')),
    CONSTRAINT fk_voyage_destination  FOREIGN KEY(id_destination)   REFERENCES destinations(id_destination),
    CONSTRAINT fk_voyage_guide   FOREIGN KEY(id_guide)  REFERENCES guides(id_guide),
    CONSTRAINT chk_dates    CHECK(date_retour > date_depart)
);

-- ============================================================
-- TABLE PROMOTIONS
-- ============================================================

CREATE TABLE promotions (

    id_promotion SERIAL PRIMARY KEY,
    libelle VARCHAR(80),
    pourcentage NUMERIC(5,2) CHECK(pourcentage BETWEEN 0 AND 100),
    date_debut DATE,
    date_fin DATE,
    CONSTRAINT chk_promo_dates CHECK(date_fin >= date_debut)
);

-- ============================================================
-- TABLE proposer
-- ============================================================

CREATE TABLE proposer (
    id_voyage INTEGER,
    id_promotion INTEGER,
    PRIMARY KEY(id_voyage,id_promotion),
    CONSTRAINT FK_proposer_voyage  FOREIGN KEY(id_voyage)  REFERENCES voyages(id_voyage) ON DELETE CASCADE,
    CONSTRAINT FK_proposer_promotion FOREIGN KEY(id_promotion) REFERENCES promotions(id_promotion) ON DELETE CASCADE
);

-- ============================================================
-- TABLE RESERVATIONS
-- ============================================================

CREATE TABLE reservations (
    id_reservation SERIAL PRIMARY KEY,
    id_client INTEGER NOT NULL,
    id_voyage INTEGER NOT NULL,
    date_reservation DATE DEFAULT CURRENT_DATE,
    nb_personnes INTEGER CHECK(nb_personnes>0),
    montant NUMERIC(10,2) CHECK(montant>=0),
    statut VARCHAR(20) DEFAULT 'EN_ATTENTE'  CHECK(statut IN ('EN_ATTENTE','CONFIRMEE','ANNULEE')),

    CONSTRAINT FK_reserver_client FOREIGN KEY(id_client) REFERENCES clients(id_client),
    CONSTRAINT FK_reserver_voyage FOREIGN KEY(id_voyage) REFERENCES voyages(id_voyage)
);

-- ============================================================
-- TABLE PAIEMENTS
-- ============================================================

CREATE TABLE paiements (
    id_paiement SERIAL PRIMARY KEY,
    id_reservation INTEGER NOT NULL,
    date_paiement DATE   DEFAULT CURRENT_DATE,
    montant NUMERIC(10,2)  CHECK(montant>0),
    mode_paiement VARCHAR(20) CHECK(mode_paiement IN ('CB','VIREMENT','CHEQUE','ESPECES')),
    etat VARCHAR(20) DEFAULT 'VALIDE'  CHECK(etat IN ('VALIDE','REFUSE','REMBOURSE')),
    CONSTRAINT FK_paiement_resa FOREIGN KEY(id_reservation) REFERENCES reservations(id_reservation)
);

-- ============================================================
-- TABLE AVIS
-- ============================================================

CREATE TABLE avis (
    id_avis SERIAL PRIMARY KEY,
    id_client INTEGER NOT NULL,
    id_destination INTEGER NOT NULL,
    note INTEGER  CHECK(note BETWEEN 1 AND 5),
    commentaire TEXT,
    date_avis DATE  DEFAULT CURRENT_DATE,
    UNIQUE(id_client,id_destination),
    CONSTRAINT FK_avis_client FOREIGN KEY(id_client) REFERENCES clients(id_client),
    CONSTRAINT FK_avis_destination FOREIGN KEY(id_destination) REFERENCES destinations(id_destination)
);

-- ============================================================
-- INDEX
-- ============================================================

CREATE INDEX idx_client_nom
ON clients(nom);

CREATE INDEX idx_destination_nom
ON destinations(nom);

CREATE INDEX idx_voyage_depart
ON voyages(date_depart);

CREATE INDEX idx_reservation_client
ON reservations(id_client);

CREATE INDEX idx_reservation_voyage
ON reservations(id_voyage);

CREATE INDEX idx_paiement_reservation
ON paiements(id_reservation);

CREATE INDEX idx_avis_destination
ON avis(id_destination);


-- ============================================================
-- DONNÉES POUR LA TABLE DESTINATIONS 
-- ============================================================

INSERT INTO destinations (nom, pays, continent, prix_base) VALUES
('Paris', 'France', 'Europe', 899.99),
('Tokyo', 'Japon', 'Asie', 1499.99),
('New York', 'États-Unis', 'Amérique du Nord', 1299.99),
('Rome', 'Italie', 'Europe', 799.99),
('Sydney', 'Australie', 'Océanie', 1799.99),
('Marrakech', 'Maroc', 'Afrique', 599.99),
('Barcelona', 'Espagne', 'Europe', 699.99),
('Dubai', 'Émirats Arabes Unis', 'Asie', 1199.99),
('Cape Town', 'Afrique du Sud', 'Afrique', 999.99),
('Rio de Janeiro', 'Brésil', 'Amérique du Sud', 1099.99),
('Pékin', 'Chine', 'Asie', 1399.99),
('Moscou', 'Russie', 'Europe', 849.99),
('Istanbul', 'Turquie', 'Asie', 749.99),
('Londres', 'Royaume-Uni', 'Europe', 949.99),
('Bangkok', 'Thaïlande', 'Asie', 699.99),
('Lisbonne', 'Portugal', 'Europe', 549.99),
('Toronto', 'Canada', 'Amérique du Nord', 1149.99),
('Le Caire', 'Égypte', 'Afrique', 649.99),
('Auckland', 'Nouvelle-Zélande', 'Océanie', 1699.99),
('Mexico', 'Mexique', 'Amérique du Nord', 799.99);

-- ============================================================
-- DONNÉES POUR LA TABLE CLIENTS 
-- ============================================================

INSERT INTO clients (nom, prenom, email, telephone, date_naissance, niveau_fidelite) VALUES
('Martin', 'Jean', 'jean.martin@email.com', '+33123456789', '1985-03-15', 'Or'),
('Dupont', 'Marie', 'marie.dupont@email.com', '+33123456788', '1990-07-22', 'Argent'),
('Bernard', 'Pierre', 'pierre.bernard@email.com', '+33123456787', '1978-11-30', 'Platine'),
('Durand', 'Sophie', 'sophie.durand@email.com', '+33123456786', '1982-05-10', 'Bronze'),
('Leroy', 'Thomas', 'thomas.leroy@email.com', '+33123456785', '1995-09-18', 'Argent'),
('Roux', 'Camille', 'camille.roux@email.com', '+33123456784', '1988-12-04', 'Or'),
('Moreau', 'Luc', 'luc.moreau@email.com', '+33123456783', '1975-06-25', 'Platine'),
('Fournier', 'Élodie', 'elodie.fournier@email.com', '+33123456782', '1992-08-14', 'Bronze'),
('Girard', 'Nicolas', 'nicolas.girard@email.com', '+33123456781', '1980-02-28', 'Argent'),
('Lefevre', 'Amélie', 'amelie.lefevre@email.com', '+33123456780', '1987-04-07', 'Or'),
('Robin', 'Julien', 'julien.robin@email.com', '+33234567890', '1993-10-12', 'Bronze'),
('Clement', 'Laura', 'laura.clement@email.com', '+33234567891', '1984-01-20', 'Argent'),
('Gauthier', 'Hugo', 'hugo.gauthier@email.com', '+33234567892', '1991-03-03', 'Or'),
('Chevalier', 'Manon', 'manon.chevalier@email.com', '+33234567893', '1989-07-16', 'Platine'),
('Legrand', 'Antoine', 'antoine.legrand@email.com', '+33234567894', '1979-11-08', 'Bronze'),
('Perrot', 'Cécilia', 'cecilia.perrot@email.com', '+33234567895', '1996-05-22', 'Argent'),
('Rousseau', 'Baptiste', 'baptiste.rousseau@email.com', '+33234567896', '1983-09-30', 'Or'),
('Blanc', 'Emma', 'emma.blanc@email.com', '+33345678901', '1994-02-14', 'Bronze'),
('Muller', 'Paul', 'paul.muller@email.com', '+33345678902', '1986-06-19', 'Argent'),
('Boyer', 'Chloé', 'chloe.boyer@email.com', '+33345678903', '1981-10-05', 'Platine'),
('Dubois', 'Alexandre', 'alexandre.dubois@email.com', '+33345678904', '1997-01-11', 'Bronze'),
('Faure', 'Léa', 'lea.faure@email.com', '+33345678905', '1985-04-27', 'Or'),
('Lemaitre', 'Enzo', 'enzo.lemaitre@email.com', '+33345678906', '1992-08-09', 'Argent'),
('Merci', 'Jade', 'jade.merci@email.com', '+33345678907', '1988-12-17', 'Platine'),
('Renard', 'Théo', 'theo.renard@email.com', '+33456789012', '1993-03-25', 'Bronze'),
('Vasseur', 'Zoé', 'zoe.vasseur@email.com', '+33456789013', '1980-07-02', 'Argent'),
('Bertrand', 'Louis', 'louis.bertrand@email.com', '+33456789014', '1989-11-14', 'Or'),
('Morel', 'Inès', 'ines.morel@email.com', '+33456789015', '1995-01-30', 'Bronze'),
('Leclerc', 'Gabriel', 'gabriel.leclerc@email.com', '+33456789016', '1987-05-18', 'Platine'),
('Picard', 'Lena', 'lena.picard@email.com', '+33456789017', '1990-09-06', 'Argent'),
('Guerin', 'Raphaël', 'raphael.guerin@email.com', '+33456789018', '1984-12-21', 'Or'),
('Baron', 'Alice', 'alice.baron@email.com', '+33567890123', '1991-03-08', 'Bronze'),
('Lopez', 'Maël', 'mael.lopez@email.com', '+33567890124', '1982-07-15', 'Argent'),
('Dumoulin', 'Éva', 'eva.dumoulin@email.com', '+33567890125', '1986-10-29', 'Platine'),
('Rivière', 'Noah', 'noah.riviere@email.com', '+33567890126', '1998-02-12', 'Bronze'),
('Schmitt', 'Lola', 'lola.schmitt@email.com', '+33567890127', '1983-06-04', 'Or'),
('Fleury', 'Sacha', 'sacha.fleury@email.com', '+33567890128', '1994-09-19', 'Argent'),
('Marchand', 'Capucine', 'capucine.marchand@email.com', '+33567890129', '1989-11-23', 'Platine'),
('Duval', 'Jules', 'jules.duval@email.com', '+33567890130', '1985-01-17', 'Bronze'),
('Aubert', 'Léonie', 'leonie.aubert@email.com', '+33678901234', '1990-04-30', 'Argent'),
('Vincent', 'Nathan', 'nathan.vincent@email.com', '+33678901235', '1987-08-13', 'Or'),
('Leroux', 'Céleste', 'celeste.leroux@email.com', '+33678901236', '1993-12-01', 'Platine');

INSERT INTO clients (nom, prenom, email, telephone, date_naissance, niveau_fidelite) VALUES
('Simon', 'Enzo', 'enzo.simon@email.com', '+33789012345', '1993-07-12', 'Argent'),
('Fabre', 'Manon', 'manon.fabre@email.com', '+33789012346', '1988-09-25', 'Or'),
('Mercier', 'Théo', 'theo.mercier@email.com', '+33789012347', '1995-02-18', 'Bronze'),
('Lejeune', 'Camille', 'camille.lejeune@email.com', '+33789012348', '1986-11-08', 'Platine'),
('Dumas', 'Lucas', 'lucas.dumas@email.com', '+33789012349', '1990-04-30', 'Argent'),
('Giraud', 'Emma', 'emma.giraud@email.com', '+33789012350', '1992-01-14', 'Or'),
('Bénard', 'Hugo', 'hugo.benard@email.com', '+33789012351', '1989-06-22', 'Bronze'),
('Perrier', 'Chloé', 'chloe.perrier@email.com', '+33789012352', '1987-03-10', 'Platine'),
('Roussy', 'Gabriel', 'gabriel.roussy@email.com', '+33789012353', '1994-08-17', 'Argent'),
('Delacroix', 'Inès', 'ines.delacroix@email.com', '+33789012354', '1985-12-05', 'Or'),
('Dubos', 'Louis', 'louis.dubos@email.com', '+33789012355', '1991-10-12', 'Bronze'),
('Guichard', 'Jade', 'jade.guichard@email.com', '+33789012356', '1988-05-20', 'Platine'),
('Pichon', 'Noah', 'noah.pichon@email.com', '+33789012357', '1996-02-03', 'Argent'),
('Brouard', 'Léa', 'lea.brouard@email.com', '+33789012358', '1984-07-19', 'Or'),
('Charpentier', 'Sacha', 'sacha.charpentier@email.com', '+33789012359', '1993-09-28', 'Bronze'),
('Lemoine', 'Capucine', 'capucine.lemoine@email.com', '+33789012360', '1987-11-14', 'Platine'),
('Marchal', 'Jules', 'jules.marchal@email.com', '+33789012361', '1990-01-08', 'Argent'),
('Fouquet', 'Alice', 'alice.fouquet@email.com', '+33789012362', '1989-04-22', 'Or'),
('Berthelot', 'Maël', 'mael.berthelot@email.com', '+33789012363', '1995-08-11', 'Bronze'),
('Leveque', 'Eva', 'eva.leveque@email.com', '+33789012364', '1986-12-17', 'Platine'),
('Carmibox','Claude','claude.carmibox@email.com','+330563251036','1963-01-15','Bronze');

-- ============================================================
-- DONNÉES POUR LA TABLE GUIDES
-- ============================================================

INSERT INTO guides (nom, prenom, langue, date_embauche, salaire, id_mentor) VALUES
('Dupuis', 'François', 'Français', '2018-05-10', 3500.00, NULL),
('Martin', 'Claire', 'Anglais', '2019-03-15', 3200.00, 1),
('Bernard', 'Marc', 'Espagnol', '2017-11-20', 3800.00, NULL),
('Rousseau', 'Isabelle', 'Italien', '2020-01-10', 2900.00, 3),
('Lefèvre', 'Jean-Paul', 'Allemand', '2016-09-05', 4200.00, NULL),
('Girard', 'Sophie', 'Français', '2021-07-22', 2800.00, 5),
('Morel', 'Pierre', 'Japonais', '2015-04-30', 4500.00, NULL),
('Dubois', 'Anne', 'Chinois', '2022-02-14', 3100.00, 7),
('Fontaine', 'Thomas', 'Arabe', '2018-12-01', 3300.00, 1),
('Blanc', 'Élodie', 'Russe', '2020-05-18', 3000.00, 3),
('Renaud', 'Luc', 'Portugais', '2019-08-25', 3400.00, 5),
('Legrand', 'Camille', 'Anglais', '2021-10-12', 2700.00, 2),
('Mercier', 'Nicolas', 'Espagnol', '2022-06-08', 2950.00, 3),
('Leroy', 'Amélie', 'Italien', '2023-01-15', 2600.00, 4),
('Chevalier', 'Hugo', 'Allemand', '2023-03-20', 2850.00, 5);

-- ============================================================
-- DONNÉES POUR LA TABLE PROMOTIONS 
-- ============================================================

INSERT INTO promotions VALUES (3, 'Début d''année 2026', 10.00, '2026-01-01', '2026-01-31');
INSERT INTO promotions VALUES (5, 'Last Minute', 30.00, '2025-09-01', '2025-09-30');
INSERT INTO promotions VALUES (6, 'Vacances de Pâques', 12.00, '2026-04-05', '2026-04-20');
INSERT INTO promotions VALUES (7, 'Échappée Hivernale', 18.00, '2025-11-15', '2025-12-15');
INSERT INTO promotions VALUES (10, 'Promo Afrique', 25.00, '2025-10-01', '2025-10-31');
INSERT INTO promotions VALUES (4, 'Fidélité Or', 25.00, '2026-07-10', '2026-10-30');
INSERT INTO promotions VALUES (2, 'Noël 2025', 20.00, '2026-09-05', '2026-10-30');
INSERT INTO promotions VALUES (1, 'Promo Été 2025', 15.00, '2026-08-15', '2026-10-30');
INSERT INTO promotions VALUES (8, 'Duo', 10.00, '2026-08-15', '2026-12-30');
INSERT INTO promotions VALUES (9, 'Early Bird', 22.00, '2026-10-15', '2026-12-15');

SELECT pg_catalog.setval('promotions_id_promotion_seq', 10, true);
-- ============================================================
-- DONNÉES POUR LA TABLE VOYAGES 
-- ============================================================

INSERT INTO voyages (id_destination, id_guide, date_depart, date_retour, capacite, prix, statut) VALUES
-- Voyages en Europe
(1, 1, '2026-09-15', '2026-09-22', 20, 850.00, 'OUVERT'),
(4, 2, '2026-10-05', '2026-10-12', 15, 750.00, 'OUVERT'),
(7, 3, '2026-08-20', '2026-08-27', 25, 650.00, 'COMPLET'),
(12, 4, '2026-11-10', '2026-11-17', 18, 800.00, 'OUVERT'),
(14, 5, '2026-09-30', '2026-10-07', 22, 900.00, 'OUVERT'),
(16, 6, '2026-10-20', '2026-10-27', 12, 600.00, 'ANNULER'),
-- Voyages en Asie
(2, 7, '2026-11-25', '2026-12-02', 15, 1400.00, 'OUVERT'),
(3, 8, '2026-09-10', '2026-09-17', 20, 1200.00, 'COMPLET'),
(8, 9, '2026-10-15', '2026-10-22', 18, 1100.00, 'OUVERT'),
(11, 10, '2026-12-05', '2026-12-12', 14, 1300.00, 'OUVERT'),
(13, 11, '2026-08-25', '2026-09-01', 22, 700.00, 'TERMINER'),
-- Voyages en Afrique
(6, 12, '2026-10-01', '2026-10-08', 16, 550.00, 'OUVERT'),
(9, 13, '2026-11-05', '2026-11-12', 20, 950.00, 'OUVERT'),
(18, 14, '2026-09-20', '2026-09-27', 12, 600.00, 'COMPLET'),
-- Voyages en Amérique
(3, 15, '2026-12-10', '2026-12-17', 18, 1200.00, 'OUVERT'),
(10, 1, '2026-10-25', '2026-11-01', 25, 1000.00, 'OUVERT'),
(19, 2, '2026-09-05', '2026-09-12', 14, 750.00, 'ANNULER'),
-- Voyages en Océanie
(5, 3, '2026-11-20', '2026-11-27', 10, 1700.00, 'OUVERT'),
(20, 4, '2026-12-15', '2026-12-22', 15, 1600.00, 'OUVERT'),
-- Voyages supplémentaires
(1, 5, '2026-08-10', '2026-08-17', 20, 850.00, 'TERMINER'),
(4, 6, '2026-09-01', '2026-09-08', 15, 750.00, 'TERMINER'),
(7, 7, '2026-08-05', '2026-08-12', 25, 650.00, 'TERMINER'),
(2, 8, '2026-11-01', '2026-11-08', 15, 1400.00, 'OUVERT'),
(8, 9, '2026-10-05', '2026-10-12', 18, 1100.00, 'OUVERT'),
(11, 10, '2026-12-01', '2026-12-08', 14, 1300.00, 'OUVERT'),
(6, 11, '2026-09-15', '2026-09-22', 16, 550.00, 'OUVERT'),
(9, 12, '2026-10-20', '2026-10-27', 20, 950.00, 'OUVERT'),
(5, 13, '2026-11-10', '2026-11-17', 10, 1700.00, 'OUVERT'),
(20, 14, '2026-12-05', '2026-12-12', 15, 1600.00, 'OUVERT');

-- 10 NOUVEAUX VOYAGES 
INSERT INTO voyages (id_destination, id_guide, date_depart, date_retour, capacite, prix, statut) VALUES
-- Europe
(1, 1, '2026-11-05', '2026-11-12', 25, 875.00, 'OUVERT'),
(16, 10, '2026-11-15', '2026-11-22', 25, 530.00, 'OUVERT'),
-- Asie
(2, 2, '2026-11-25', '2026-12-02', 20, 1450.00, 'ANNULER'),
(11, 11, '2026-12-10', '2026-12-17', 16, 1350.00, 'OUVERT'),
(15, 13, '2027-01-15', '2027-01-22', 18, 680.00, 'OUVERT'),
-- Afrique
(6, 12, '2026-10-20', '2026-10-27', 14, 580.00, 'OUVERT'),
(18, 14, '2027-02-05', '2027-02-12', 12, 630.00, 'OUVERT'),
-- Amérique
(3, 5, '2026-12-01', '2026-12-08', 20, 1250.00, 'COMPLET'),
(10, 9, '2026-12-01', '2026-12-08', 20, 1050.00, 'COMPLET'),
-- Océanie
(5, 7, '2027-02-10', '2027-02-17', 15, 1750.00, 'OUVERT'),
(19, 15, '2027-03-05', '2027-03-12', 12, 1650.00, 'OUVERT');
-- ============================================================
-- DONNÉES POUR LA TABLE proposer
-- ============================================================

INSERT INTO proposer VALUES (1, 1);
INSERT INTO proposer VALUES (2, 1);
INSERT INTO proposer VALUES (3, 5);
INSERT INTO proposer VALUES (4, 8);
INSERT INTO proposer VALUES (5, 1);
INSERT INTO proposer VALUES (6, 6);
INSERT INTO proposer VALUES (7, 2);
INSERT INTO proposer VALUES (8, 1);
INSERT INTO proposer VALUES (9, 8);
INSERT INTO proposer VALUES (10, 7);
INSERT INTO proposer VALUES (11, 10);
INSERT INTO proposer VALUES (12, 3);
INSERT INTO proposer VALUES (13, 4);
INSERT INTO proposer VALUES (14, 9);
INSERT INTO proposer VALUES (15, 5);
INSERT INTO proposer VALUES (16, 10);
INSERT INTO proposer VALUES (17, 1);
INSERT INTO proposer VALUES (18, 2);
INSERT INTO proposer VALUES (19, 6);
INSERT INTO proposer VALUES (20, 10);
INSERT INTO proposer VALUES (21, 4);
INSERT INTO proposer VALUES (1, 8);
INSERT INTO proposer VALUES (1, 4);
INSERT INTO proposer VALUES (2, 5);
INSERT INTO proposer VALUES (2, 2);
INSERT INTO proposer VALUES (3, 1);
INSERT INTO proposer VALUES (4, 6);
INSERT INTO proposer VALUES (4, 9);
INSERT INTO proposer VALUES (5, 2);
INSERT INTO proposer VALUES (5, 7);
INSERT INTO proposer VALUES (6, 1);
INSERT INTO proposer VALUES (7, 4);
INSERT INTO proposer VALUES (7, 8);
INSERT INTO proposer VALUES (8, 5);
INSERT INTO proposer VALUES (8, 3);
INSERT INTO proposer VALUES (22, 1);
INSERT INTO proposer VALUES (22, 3);
INSERT INTO proposer VALUES (22, 9);

-- ============================================================
-- DONNÉES POUR LA TABLE RESERVATIONS 
-- ============================================================

-- Réservations pour les voyages 1 à 10
INSERT INTO reservations (id_client, id_voyage, date_reservation, nb_personnes, montant, statut) VALUES
(1, 1, '2026-01-15', 2, 1700.00, 'CONFIRMEE'),
(2, 1, '2026-02-20', 1, 850.00, 'CONFIRMEE'),
(3, 1, '2026-03-10', 3, 2550.00, 'EN_ATTENTE'),
(4, 2, '2026-01-25', 2, 1500.00, 'CONFIRMEE'),
(5, 2, '2026-02-18', 1, 750.00, 'CONFIRMEE'),
(6, 3, '2026-03-05', 4, 2600.00, 'CONFIRMEE'),
(7, 3, '2026-03-12', 2, 1300.00, 'CONFIRMEE'),
(8, 4, '2026-04-01', 1, 800.00, 'EN_ATTENTE'),
(9, 5, '2026-01-30', 3, 2700.00, 'CONFIRMEE'),
(10, 5, '2026-02-15', 2, 1800.00, 'CONFIRMEE'),
(11, 6, '2026-03-20', 1, 650.00, 'ANNULEE'),
(12, 7, '2026-01-10', 2, 2800.00, 'CONFIRMEE'),
(13, 7, '2026-02-05', 1, 1400.00, 'EN_ATTENTE'),
(14, 8, '2026-03-15', 3, 3600.00, 'CONFIRMEE'),
(15, 8, '2026-04-10', 2, 2400.00, 'CONFIRMEE'),
(16, 9, '2026-01-20', 1, 1100.00, 'CONFIRMEE'),
(17, 9, '2026-02-25', 2, 2200.00, 'EN_ATTENTE'),
(18, 10, '2026-03-08', 1, 1300.00, 'CONFIRMEE'),
(19, 10, '2026-04-15', 3, 3900.00, 'CONFIRMEE'),
(20, 11, '2026-01-12', 2, 1400.00, 'CONFIRMEE'),

-- Réservations pour les voyages 11 à 20
(21, 12, '2026-02-14', 1, 950.00, 'CONFIRMEE'),
(22, 12, '2026-03-22', 2, 1900.00, 'EN_ATTENTE'),
(23, 13, '2026-01-05', 3, 1650.00, 'CONFIRMEE'),
(24, 13, '2026-02-28', 1, 550.00, 'ANNULEE'),
(25, 14, '2026-03-18', 2, 2000.00, 'CONFIRMEE'),
(26, 14, '2026-04-22', 1, 1000.00, 'EN_ATTENTE'),
(27, 15, '2026-01-18', 1, 1700.00, 'CONFIRMEE'),
(28, 15, '2026-02-24', 2, 3400.00, 'CONFIRMEE'),
(29, 16, '2026-03-10', 1, 1600.00, 'ANNULEE'),
(30, 16, '2026-04-05', 2, 3200.00, 'CONFIRMEE'),

-- Réservations pour les voyages 17 à 30
(31, 17, '2026-01-22', 2, 1700.00, 'CONFIRMEE'),
(32, 17, '2026-02-10', 1, 850.00, 'EN_ATTENTE'),
(33, 18, '2026-03-01', 3, 2250.00, 'CONFIRMEE'),
(34, 18, '2026-03-15', 2, 1500.00, 'ANNULEE'),
(35, 19, '2026-01-28', 1, 750.00, 'CONFIRMEE'),
(36, 20, '2026-02-08', 2, 1600.00, 'CONFIRMEE'),
(37, 21, '2026-01-08', 1, 850.00, 'CONFIRMEE'),
(38, 21, '2026-02-12', 2, 1700.00, 'EN_ATTENTE'),
(39, 22, '2026-03-20', 1, 750.00, 'ANNULEE'),
(40, 22, '2026-04-25', 3, 2250.00, 'CONFIRMEE'),

-- Réservations supplémentaires pour varier
(41, 23, '2026-01-14', 2, 1300.00, 'CONFIRMEE'),
(42, 23, '2026-02-19', 1, 650.00, 'EN_ATTENTE'),
(43, 24, '2026-03-03', 3, 1950.00, 'CONFIRMEE'),
(44, 24, '2026-03-28', 2, 1300.00, 'ANNULEE'),
(45, 25, '2026-01-24', 1, 1400.00, 'CONFIRMEE'),
(46, 25, '2026-02-22', 2, 2800.00, 'CONFIRMEE'),
(47, 26, '2026-03-12', 1, 1100.00, 'EN_ATTENTE'),
(48, 26, '2026-04-18', 2, 2200.00, 'CONFIRMEE'),
(49, 27, '2026-01-16', 1, 1300.00, 'ANNULEE'),
(50, 27, '2026-02-20', 3, 3900.00, 'CONFIRMEE'),

-- Réservations pour les clients 21 à 50
(21, 28, '2026-03-01', 2, 1600.00, 'CONFIRMEE'),
(22, 28, '2026-03-10', 1, 800.00, 'EN_ATTENTE'),
(23, 29, '2026-01-30', 3, 2400.00, 'CONFIRMEE'),
(24, 29, '2026-02-14', 2, 1600.00, 'ANNULEE'),
(25, 30, '2026-03-25', 1, 1600.00, 'CONFIRMEE'),
(26, 30, '2026-04-10', 2, 3200.00, 'EN_ATTENTE'),
(27, 1, '2026-01-05', 1, 850.00, 'CONFIRMEE'),
(28, 2, '2026-02-20', 2, 1500.00, 'CONFIRMEE'),
(29, 3, '2026-03-15', 3, 1950.00, 'ANNULEE'),
(30, 4, '2026-01-10', 1, 800.00, 'EN_ATTENTE'),
(31, 5, '2026-02-25', 2, 1800.00, 'CONFIRMEE'),
(32, 6, '2026-03-08', 1, 650.00, 'CONFIRMEE'),
(33, 7, '2026-01-12', 2, 2800.00, 'EN_ATTENTE'),
(34, 8, '2026-02-18', 1, 1200.00, 'ANNULEE'),
(35, 9, '2026-03-22', 3, 3300.00, 'CONFIRMEE'),
(36, 10, '2026-01-18', 2, 2600.00, 'CONFIRMEE'),
(37, 11, '2026-02-22', 1, 1400.00, 'EN_ATTENTE'),
(38, 12, '2026-03-10', 2, 1900.00, 'ANNULEE'),
(39, 13, '2026-01-25', 1, 550.00, 'CONFIRMEE'),
(40, 14, '2026-02-28', 3, 3000.00, 'CONFIRMEE'),
(41, 15, '2026-03-12', 2, 3400.00, 'EN_ATTENTE'),
(42, 16, '2026-01-30', 1, 1600.00, 'ANNULEE'),
(43, 17, '2026-02-15', 2, 1700.00, 'CONFIRMEE'),
(44, 18, '2026-03-20', 1, 750.00, 'EN_ATTENTE'),
(45, 19, '2026-01-08', 3, 2250.00, 'CONFIRMEE'),
(46, 20, '2026-02-22', 2, 3200.00, 'ANNULEE'),
(47, 21, '2026-03-05', 1, 850.00, 'CONFIRMEE'),
(48, 22, '2026-01-20', 2, 1500.00, 'EN_ATTENTE'),
(49, 23, '2026-02-10', 1, 650.00, 'ANNULEE'),
(50, 24, '2026-03-15', 3, 1650.00, 'CONFIRMEE');


INSERT INTO reservations (id_client, id_voyage, date_reservation, nb_personnes, montant, statut) VALUES
-- Réservations pour les nouveaux clients (61-80) et nouveaux voyages (31-40)
(61, 31, '2026-01-20', 2, 1750.00, 'CONFIRMEE'),
(62, 32, '2026-02-15', 1, 530.00, 'EN_ATTENTE'),
(50, 33, '2026-03-10', 3, 4350.00, 'ANNULEE'),
(54, 34, '2026-04-05', 2, 2700.00, 'CONFIRMEE'),
(55, 35, '2026-05-12', 1, 680.00, 'EN_ATTENTE'),
(56, 36, '2026-06-18', 2, 1160.00, 'CONFIRMEE'),
(57, 37, '2026-07-22', 1, 630.00, 'EN_ATTENTE'),
(58, 38, '2026-01-30', 2, 2500.00, 'CONFIRMEE'),
(59, 39, '2026-02-25', 1, 1050.00, 'ANNULEE'),
(60, 40, '2026-03-20', 2, 3300.00, 'CONFIRMEE'),

-- Réservations pour les nouveaux clients sur des voyages existants
(41, 1, '2026-04-10', 3, 2625.00, 'EN_ATTENTE'),
(42, 5, '2026-05-05', 1, 1799.99, 'CONFIRMEE'),
(43, 10, '2026-06-15', 2, 2199.98, 'ANNULEE'),
(44, 15, '2026-07-10', 1, 699.99, 'EN_ATTENTE'),
(45, 20, '2026-01-15', 2, 1599.98, 'CONFIRMEE'),

-- Réservations pour des clients existants sur les nouveaux voyages
(1, 31, '2026-02-20', 1, 875.00, 'CONFIRMEE'),
(5, 34, '2026-03-25', 2, 2700.00, 'EN_ATTENTE'),
(10, 37, '2026-04-18', 1, 630.00, 'CONFIRMEE'),
(15, 39, '2026-05-18', 3, 3150.00, 'ANNULEE'),
(20, 40, '2026-06-22', 2, 3300.00, 'CONFIRMEE');

-- ============================================================
-- DONNÉES POUR LA TABLE PAIEMENTS (150 entrées)
-- ============================================================

-- Paiements pour les réservations 1 à 20
INSERT INTO paiements VALUES (3, 3, '2026-03-11', 1275.00, 'CB', 'REFUSE');
INSERT INTO paiements VALUES (4, 3, '2026-03-12', 1275.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (19, 19, '2026-04-16', 3900.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (20, 20, '2026-01-13', 1400.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (23, 23, '2026-01-06', 1650.00, 'CHEQUE', 'VALIDE');
INSERT INTO paiements VALUES (31, 33, '2026-03-02', 2250.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (32, 35, '2026-01-29', 750.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (33, 36, '2026-02-09', 1600.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (37, 41, '2026-01-15', 1300.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (38, 42, '2026-02-20', 650.00, 'ESPECES', 'VALIDE');
INSERT INTO paiements VALUES (39, 43, '2026-03-04', 1950.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (46, 24, '2026-03-01', 550.00, 'CB', 'REFUSE');
INSERT INTO paiements VALUES (49, 34, '2026-03-16', 1500.00, 'VIREMENT', 'REMBOURSE');
INSERT INTO paiements VALUES (50, 39, '2026-02-11', 550.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (51, 44, '2026-03-21', 1300.00, 'CHEQUE', 'VALIDE');
INSERT INTO paiements VALUES (53, 51, '2026-01-06', 850.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (54, 52, '2026-02-21', 1500.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (55, 53, '2026-03-16', 1950.00, 'CHEQUE', 'REFUSE');
INSERT INTO paiements VALUES (56, 53, '2026-03-17', 1950.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (57, 54, '2026-02-15', 1600.00, 'ESPECES', 'VALIDE');
INSERT INTO paiements VALUES (65, 61, '2026-03-06', 850.00, 'ESPECES', 'VALIDE');
INSERT INTO paiements VALUES (69, 65, '2026-01-13', 1900.00, 'CHEQUE', 'REFUSE');
INSERT INTO paiements VALUES (70, 65, '2026-01-14', 1900.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (71, 66, '2026-02-26', 1600.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (75, 70, '2026-03-12', 1300.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (76, 71, '2026-01-20', 1600.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (78, 73, '2026-03-01', 850.00, 'ESPECES', 'VALIDE');
INSERT INTO paiements VALUES (79, 74, '2026-01-15', 1500.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (80, 75, '2026-02-20', 1800.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (81, 76, '2026-03-08', 650.00, 'CHEQUE', 'VALIDE');
INSERT INTO paiements VALUES (83, 78, '2026-02-10', 1300.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (85, 80, '2026-01-30', 1400.00, 'ESPECES', 'VALIDE');
INSERT INTO paiements VALUES (88, 83, '2026-01-05', 1700.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (93, 88, '2026-03-18', 1650.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (95, 90, '2026-02-18', 1200.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (96, 91, '2026-03-01', 1900.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (98, 93, '2026-02-20', 2600.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (100, 95, '2026-01-20', 1500.00, 'ESPECES', 'VALIDE');
INSERT INTO paiements VALUES (104, 99, '2026-02-10', 3200.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (105, 100, '2026-03-15', 1650.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (1, 1, '2026-01-16', 1275.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (2, 2, '2026-02-21', 637.50, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (5, 4, '2026-01-26', 1200.00, 'CHEQUE', 'VALIDE');
INSERT INTO paiements VALUES (6, 6, '2026-03-06', 2210.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (7, 7, '2026-03-13', 1105.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (8, 8, '2026-04-02', 624.00, 'ESPECES', 'REFUSE');
INSERT INTO paiements VALUES (9, 8, '2026-04-03', 624.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (10, 9, '2026-01-31', 2160.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (11, 10, '2026-02-16', 1440.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (12, 12, '2026-01-11', 2520.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (13, 13, '2026-02-06', 1260.00, 'CHEQUE', 'REFUSE');
INSERT INTO paiements VALUES (14, 13, '2026-02-07', 1260.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (15, 14, '2026-03-16', 3060.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (16, 15, '2026-04-11', 2040.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (17, 16, '2026-01-21', 990.00, 'ESPECES', 'VALIDE');
INSERT INTO paiements VALUES (18, 17, '2026-02-26', 1980.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (21, 21, '2026-02-15', 550.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (22, 22, '2026-03-23', 1100.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (24, 25, '2026-03-19', 1200.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (25, 27, '2026-01-19', 1200.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (26, 28, '2026-02-25', 2400.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (27, 30, '2026-04-06', 2000.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (28, 31, '2026-01-23', 1275.00, 'ESPECES', 'VALIDE');
INSERT INTO paiements VALUES (29, 32, '2026-02-11', 637.50, 'CB', 'REFUSE');
INSERT INTO paiements VALUES (30, 32, '2026-02-12', 637.50, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (35, 38, '2026-02-13', 1125.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (34, 37, '2026-01-09', 562.50, 'CHEQUE', 'VALIDE');
INSERT INTO paiements VALUES (36, 40, '2026-04-26', 1950.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (40, 45, '2026-01-25', 1300.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (41, 46, '2026-02-23', 2600.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (42, 47, '2026-03-13', 550.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (43, 48, '2026-04-19', 1100.00, 'CHEQUE', 'VALIDE');
INSERT INTO paiements VALUES (44, 50, '2026-02-21', 2850.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (45, 21, '2026-02-16', 550.00, 'VIREMENT', 'REMBOURSE');
INSERT INTO paiements VALUES (47, 26, '2026-04-23', 600.00, 'ESPECES', 'VALIDE');
INSERT INTO paiements VALUES (48, 29, '2026-03-11', 1000.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (52, 49, '2026-02-11', 950.00, 'CB', 'REFUSE');
INSERT INTO paiements VALUES (58, 55, '2026-03-26', 875.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (59, 56, '2026-03-13', 1750.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (60, 57, '2026-01-31', 637.50, 'CB', 'REMBOURSE');
INSERT INTO paiements VALUES (61, 58, '2026-02-16', 1200.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (62, 59, '2026-01-09', 1657.50, 'CHEQUE', 'VALIDE');
INSERT INTO paiements VALUES (63, 60, '2026-02-23', 624.00, 'CB', 'REFUSE');
INSERT INTO paiements VALUES (64, 60, '2026-02-24', 624.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (66, 62, '2026-01-21', 510.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (67, 63, '2026-02-10', 2520.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (68, 64, '2026-03-11', 1020.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (72, 67, '2026-03-10', 700.00, 'ESPECES', 'VALIDE');
INSERT INTO paiements VALUES (73, 68, '2026-01-18', 1100.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (74, 69, '2026-02-28', 950.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (77, 72, '2026-02-05', 1000.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (82, 77, '2026-01-25', 562.50, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (84, 79, '2026-03-15', 1400.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (86, 81, '2026-02-14', 1060.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (87, 82, '2026-03-20', 1450.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (89, 84, '2026-02-20', 1360.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (90, 85, '2026-03-12', 580.00, 'CHEQUE', 'VALIDE');
INSERT INTO paiements VALUES (91, 86, '2026-01-10', 1260.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (92, 87, '2026-02-25', 1250.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (94, 89, '2026-01-12', 1750.00, 'ESPECES', 'VALIDE');
INSERT INTO paiements VALUES (97, 92, '2026-01-15', 720.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (99, 94, '2026-03-10', 1200.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (101, 96, '2026-02-25', 530.00, 'CB', 'VALIDE');
INSERT INTO paiements VALUES (102, 97, '2026-03-05', 1360.00, 'VIREMENT', 'VALIDE');
INSERT INTO paiements VALUES (103, 98, '2026-01-25', 1250.00, 'CB', 'VALIDE');

SELECT pg_catalog.setval('paiements_id_paiement_seq', 105, true);

-- ============================================================
-- DONNÉES POUR LA TABLE AVIS (80 entrées)
-- ============================================================

INSERT INTO avis (id_client, id_destination, note, commentaire, date_avis) VALUES
-- Avis pour les destinations 1 à 10
(1, 1, 5, 'Paris était magnifique ! Le guide était très compétent.', '2025-12-01'),
(2, 1, 4, 'Super voyage, mais un peu cher.', '2025-11-15'),
(3, 2, 5, 'Tokyo est une ville incroyable, très bien organisé.', '2025-10-20'),
(4, 2, 3, 'Beaucoup de monde, mais très intéressant.', '2025-09-10'),
(5, 3, 4, 'New York est impressionnant, surtout la nuit.', '2025-08-05'),
(6, 3, 5, 'Un voyage inoubliable, merci à toute l''équipe !', '2025-07-22'),
(7, 4, 4, 'Rome est une ville historique fascinante.', '2025-06-18'),
(8, 4, 5, 'J''ai adoré l''ambiance et la nourriture.', '2025-05-30'),
(9, 5, 5, 'Sydney est paradisiaque, les plages sont sublimes.', '2025-04-15'),
(10, 5, 4, 'Très beau pays, mais un peu loin.', '2025-03-20'),
(11, 6, 5, 'Marrakech est une ville colorée et vivante.', '2025-02-10'),
(12, 6, 3, 'Un peu trop touristique à mon goût.', '2025-01-25'),
(13, 7, 4, 'Barcelona est une ville très agréable.', '2025-12-12'),
(14, 7, 5, 'J''y retournerais sans hésiter !', '2025-11-28'),
(15, 8, 4, 'Dubai est impressionnant avec ses gratte-ciels.', '2025-10-15'),
(16, 8, 5, 'Un voyage de luxe, tout était parfait.', '2025-09-01'),
(17, 9, 4, 'Le Cap est magnifique, surtout la montagne.', '2025-08-18'),
(18, 9, 5, 'Un des plus beaux pays que j''aie visités.', '2025-07-05'),
(19, 10, 5, 'Rio de Janeiro est une ville festive et belle.', '2025-06-22'),
(20, 10, 4, 'Les plages sont superbes, mais la sécurité laisse à désirer.', '2025-05-10'),

-- Avis pour les destinations 11 à 20
(21, 11, 5, 'Pékin est une ville très riche culturellement.', '2025-04-01'),
(22, 11, 3, 'La pollution est un problème.', '2025-03-15'),
(23, 12, 4, 'Moscou est une ville surprenante.', '2025-02-28'),
(24, 12, 5, 'J''ai adoré l''architecture et les musées.', '2025-01-10'),
(25, 13, 5, 'Istanbul est à cheval entre deux continents, fascinant !', '2025-12-20'),
(26, 13, 4, 'Le Grand Bazar est impressionnant.', '2025-11-05'),
(27, 14, 4, 'Londres est une ville dynamique et historique.', '2025-10-12'),
(28, 14, 5, 'Le musée britannique est à ne pas manquer.', '2025-09-25'),
(29, 15, 4, 'Bangkok est une ville très animée.', '2025-08-20'),
(30, 15, 5, 'Les temples sont magnifiques.', '2025-07-10'),
(31, 16, 4, 'Lisbonne est une ville charmante et abordable.', '2025-06-05'),
(32, 16, 5, 'Les pasteis de nata sont délicieux !', '2025-05-20'),
(33, 17, 5, 'Toronto est une ville multiculturelle et accueillante.', '2025-04-15'),
(34, 17, 4, 'Le CN Tower offre une vue imprenable.', '2025-03-30'),
(35, 18, 5, 'Le Caire est une ville historique fascinante.', '2025-02-10'),
(36, 18, 3, 'Un peu chaotique, mais très intéressant.', '2025-01-25'),
(37, 19, 5, 'Auckland est entourée de paysages magnifiques.', '2025-12-18'),
(38, 19, 4, 'Les Maoris sont très accueillants.', '2025-11-03'),
(39, 20, 5, 'Mexico est une ville vibrante et colorée.', '2025-10-10'),
(40, 20, 4, 'La nourriture est excellente et épicée.', '2025-09-22'),

-- Avis supplémentaires pour les clients 41 à 50
(41, 1, 5, 'Paris est toujours aussi magique.', '2025-12-10'),
(42, 2, 4, 'Tokyo est une expérience unique.', '2025-11-25'),
(43, 3, 5, 'New York ne déçoit jamais.', '2025-10-18'),
(44, 4, 4, 'Rome est un voyage dans le temps.', '2025-09-20'),
(45, 5, 5, 'Sydney est un rêve pour les amateurs de plage.', '2025-08-25'),
(46, 6, 4, 'Marrakech est une explosion de couleurs.', '2025-07-30'),
(47, 7, 5, 'Barcelona est une ville très vivante.', '2025-06-15'),
(48, 8, 4, 'Dubai est le futur.', '2025-05-20'),
(49, 9, 5, 'Le Cap est un joyau de l''Afrique.', '2025-04-10'),
(50, 10, 4, 'Rio est la ville de la samba !', '2025-03-05'),

-- Avis pour les destinations déjà notées (pour varier les notes)
(1, 2, 4, 'Tokyo est moderne et traditionnelle à la fois.', '2025-11-01'),
(2, 3, 5, 'New York est la ville qui ne dort jamais.', '2025-10-05'),
(3, 4, 4, 'Rome est un musée à ciel ouvert.', '2025-09-15'),
(4, 5, 5, 'Sydney et ses plages sont paradisiaques.', '2025-08-20'),
(5, 6, 3, 'Marrakech est un peu trop touristique.', '2025-07-10'),
(6, 7, 5, 'Barcelona est une ville très agréable.', '2025-06-01'),
(7, 8, 4, 'Dubai est impressionnante.', '2025-05-15'),
(8, 9, 5, 'Le Cap est magnifique.', '2025-04-01'),
(9, 10, 4, 'Rio est une ville festive.', '2025-03-20'),
(10, 11, 5, 'Pékin est une ville fascinante.', '2025-02-10'),

-- Avis pour les destinations 1 à 10 (suite)
(11, 12, 4, 'Moscou est une ville surprenante.', '2025-01-05'),
(12, 13, 5, 'Istanbul est une ville unique.', '2025-12-30'),
(13, 14, 4, 'Londres est une ville dynamique.', '2025-11-20'),
(14, 15, 5, 'Bangkok est une ville animée.', '2025-10-10'),
(15, 16, 4, 'Lisbonne est une ville charmante.', '2025-09-01'),
(16, 17, 5, 'Toronto est une ville multiculturelle.', '2025-08-15'),
(17, 18, 4, 'Le Caire est une ville historique.', '2025-07-20'),
(18, 19, 5, 'Auckland est entourée de paysages magnifiques.', '2025-06-10'),
(19, 20, 4, 'Mexico est une ville vibrante.', '2025-05-05'),
(20, 1, 5, 'Paris est toujours aussi beau.', '2025-04-20'),

-- Avis pour les destinations 11 à 20 (suite)
(21, 2, 4, 'Tokyo est moderne et traditionnelle.', '2025-03-10'),
(22, 3, 5, 'New York est impressionnant.', '2025-02-28'),
(23, 4, 4, 'Rome est un voyage dans le temps.', '2025-01-15'),
(24, 5, 5, 'Sydney est un rêve.', '2025-12-25'),
(25, 6, 4, 'Marrakech est colorée.', '2025-11-10'),
(26, 7, 5, 'Barcelona est vivante.', '2025-10-01'),
(27, 8, 4, 'Dubai est le futur.', '2025-09-15'),
(28, 9, 5, 'Le Cap est un joyau.', '2025-08-01'),
(29, 10, 4, 'Rio est festive.', '2025-07-20'),
(30, 11, 5, 'Pékin est fascinante.', '2025-06-05');