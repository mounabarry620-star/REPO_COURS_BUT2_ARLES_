/*==============================================================*/
/* Nom de SGBD :  PostgreSQL 7.3                                */
/* Date de cr�ation :  29/04/2012 11:44:38                      */
/*==============================================================*/

create schema bdd_car_net;
SET search_path=bdd_car_net;
SET CLIENT_ENCODING TO UTF8;

/*==============================================================*/
/* Table : Agence                                               */
/*==============================================================*/
create table Agence (
num_Agence            SERIAL               not null,
nom_Agence            VARCHAR(45)          not null,
tel_Agence            VARCHAR(15)          not null,
adr_Agence            VARCHAR(75)          not null,
ville_Agence          VARCHAR(35)          not null,
cp_Agence             NUMERIC(5)           not null,
pays_Agence           CHAR(2)              not null,
constraint PK_AGENCE primary key (num_Agence)
);

/*==============================================================*/
/* Index : AGENCE_PK                                            */
/*==============================================================*/
create unique index AGENCE_PK on Agence (
num_Agence
);

/*==============================================================*/
/* Table : Client                                               */
/*==============================================================*/
create table Client (
num_Client            SERIAL               not null,
type_Client           VARCHAR(12)          not null,
civilite             VARCHAR(4)           not null,
nom_Client            VARCHAR(35)          not null,
pre_Client            VARCHAR(35)          not null,
adr_Client            VARCHAR(75)          not null,
ville_Client          VARCHAR(35)          not null,
cp_Client             DECIMAL(5)           not null,
pays_Client           CHAR(2)              not null,
tel_Client            VARCHAR(15)          not null,
mail_Client           VARCHAR(75)          null,
mode_Reglement        VARCHAR(10)          null,
date_Naissance        DATE                 null,
num_Permis            DECIMAL(14)          null,
date_Permis           DATE                 null,
pts_Bonus_Acquis       INT                  null,
num_Cb                DECIMAL(16)          null,
constraint PK_CLIENT primary key (num_Client)
);

/*==============================================================*/
/* Index : CLIENT_PK                                            */
/*==============================================================*/
create unique index CLIENT_PK on Client (
num_Client
);

/*==============================================================*/
/* Table : JourSemaine                                          */
/*==============================================================*/
create table Jour_Semaine (
num_Jour              INT                 not null,
libelle_Jour          VARCHAR(10)          not null,
constraint PK_JOURSEMAINE primary key (num_Jour)
);

/*==============================================================*/
/* Table : Ouverture                                            */
/*==============================================================*/
create table Ouverture (
num_Agence            INT                  not null,
num_Jour              INT                  not null,
heure_Ouverture       TIME                 not null,
heure_Fermeture       TIME                 not null,
constraint PK_OUVERTURE primary key (num_Agence, num_Jour)
);

/*==============================================================*/
/* Index : OUVERTURE_PK                                         */
/*==============================================================*/
create unique index OUVERTURE_PK on Ouverture (
num_Agence,
num_Jour
);

/*==============================================================*/
/* Index : __FK                                                 */
/*==============================================================*/
create  index __FK on Ouverture (
num_Agence
);

/*==============================================================*/
/* Index : __FK2                                                */
/*==============================================================*/
create  index __FK2 on Ouverture (
num_Jour
);

/*==============================================================*/
/* Table : Reservation                                          */
/*==============================================================*/
create table Reservation (
num_Resa              SERIAL               not null,
retour_agence        INT                  not null,
depart_agence        INT                  not null,
num_Client            INT                  not null,
code_Vehicule         INT                  not null,
date_Resa             DATE                 not null,
date_Heure_Depart      TIMESTAMP            not null,
date_Heure_Retour      TIMESTAMP            not null,
constraint PK_RESERVATION primary key (num_Resa)
);

/*==============================================================*/
/* Index : RESERVATION_PK                                       */
/*==============================================================*/
create unique index RESERVATION_PK on Reservation (
num_Resa
);

/*==============================================================*/
/* Index : RETOUR_FK                                            */
/*==============================================================*/
create  index RETOUR_FK on Reservation (
depart_agence
);

/*==============================================================*/
/* Index : DEPART_FK                                            */
/*==============================================================*/
create  index DEPART_FK on Reservation (
retour_agence
);

/*==============================================================*/
/* Index : CONCERNER_FK                                         */
/*==============================================================*/
create  index CONCERNER_FK on Reservation (
num_Client
);

/*==============================================================*/
/* Index : RESERVER_FK                                          */
/*==============================================================*/
create  index RESERVER_FK on Reservation (
code_Vehicule
);

/*==============================================================*/
/* Table : TrancheLocation                                      */
/*==============================================================*/
create table Tranche_Location (
nb_Jours              INT                  not null,
constraint PK_TRANCHELOCATION primary key (nb_Jours)
);

/*==============================================================*/
/* Table : Vehicule                                             */
/*==============================================================*/
create table Vehicule (
code_Vehicule         SERIAL               not null,
exemple              VARCHAR(200)         not null,
categorie            CHAR(1)              not null,
prix_Jour             DECIMAL(6,2)         not null,
nb_Portes             INT                  null,
nb_Passagers          INT                  null,
nb_Bagages            INT                  null,
clim                 BOOL                 not null,
volume               DECIMAL(4,2)         null,
charge_Utile         DECIMAL(4,2)         null,
longueur             DECIMAL(4,2)         null,
largeur              DECIMAL(4,2)         null,
hauteur              DECIMAL(4,2)         null,
constraint PK_VEHICULE primary key (code_Vehicule)
);

/*==============================================================*/
/* Index : VEHICULE_PK                                          */
/*==============================================================*/
create unique index VEHICULE_PK on Vehicule (
code_Vehicule
);

/*==============================================================*/
/* Table : proposer                                             */
/*==============================================================*/
create table proposer (
code_Vehicule         INT                  not null,
num_Agence            INT                  not null,
constraint PK_PROPOSER primary key (code_Vehicule, num_Agence)
);

/*==============================================================*/
/* Index : PROPOSER_PK                                          */
/*==============================================================*/
create unique index PROPOSER_PK on proposer (
code_Vehicule,
num_Agence
);

/*==============================================================*/
/* Index : PROPOSER_FK                                          */
/*==============================================================*/
create  index PROPOSER_FK on proposer (
code_Vehicule
);

/*==============================================================*/
/* Index : PROPOSER_FK2                                         */
/*==============================================================*/
create  index PROPOSER_FK2 on proposer (
num_Agence
);

/*==============================================================*/
/* Table : Attribuer                                            */
/*==============================================================*/
create table Attribuer (
code_Vehicule         INT                  not null,
nb_Jours              INT                  not null,
nb_Points             INT                  not null,
constraint PK_ATTRIBUER primary key (code_Vehicule, nb_Jours)
);


alter table Attribuer
   add constraint "code_vehicule=code_vehicule" foreign key (code_Vehicule)
      references Vehicule (code_Vehicule)
      on delete restrict on update restrict,
   add constraint "nb_jours=nb_jours" foreign key (nb_Jours)
      references Tranche_Location (nb_Jours)
      on delete restrict on update restrict;

alter table Ouverture
   add constraint FK_OUVERTUR___AGENCE foreign key (num_Agence)
      references Agence (num_Agence)
      on delete restrict on update restrict,
   add constraint FK_OUVERTUR___JOURSEMA foreign key (num_Jour)
      references Jour_Semaine (num_Jour)
      on delete restrict on update restrict;

alter table Reservation
   add constraint FK_RESERVAT_CONCERNER_CLIENT foreign key (num_Client)
      references Client (num_Client)
      on delete restrict on update restrict,
   add constraint FK_RESERVAT_DEPART_AGENCE foreign key (retour_agence)
      references Agence (num_Agence)
      on delete restrict on update restrict,
   add constraint FK_RESERVAT_RESERVER_VEHICULE foreign key (code_Vehicule)
      references Vehicule (code_Vehicule)
      on delete restrict on update restrict,
   add constraint FK_RESERVAT_RETOUR_AGENCE foreign key (depart_agence)
      references Agence (num_Agence)
      on delete restrict on update restrict;

alter table proposer
   add constraint FK_PROPOSER_AGENCE foreign key (num_Agence)
      references Agence (num_Agence)
      on delete restrict on update restrict,
   add constraint FK_PROPOSER_VEHICULE foreign key (code_Vehicule)
      references Vehicule (code_Vehicule)
      on delete restrict on update restrict;



--
-- Data for Name: agence; Type: TABLE DATA; Schema: ctrl_bdd_car_net; Owner: Laurent
--

INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1002, 'Sibelius', '06-51-93-47-82', '676 Aliquet Street', 'Frederick', 86873, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1007, 'Micsot', '06-85-77-89-82', 'Ap #159-8534 Nibh Rd.', 'Charleston', 36482, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1009, 'Chami', '06-97-30-32-04', '519-6317 Mollis St.', 'Weymouth', 59876, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1017, 'Alvisa', '06-47-41-78-33', 'P.O. Box 166, 3947 Est St.', 'Citrus Heights', 29892, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1018, 'Ade', '06-78-65-60-81', 'P.O. Box 528, 3106 Eget St.', 'Klamath Falls', 41464, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1022, 'Lavat', '06-27-41-57-29', 'P.O. Box 592, 3581 Mauris Road', 'Frankfort', 86404, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1024, 'Band', '06-35-60-82-94', '867-7845 Quisque Rd.', 'Boulder', 21255, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1001, 'Cakewalk nord', '06-63-51-83-84', '744-9880 Etiam Street', 'Albany', 86586, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1023, 'Cakewalk est', '06-09-06-62-69', '978-9633 Tellus. Rd.', 'Fort Wayne', 64312, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1015, 'Cakewalk sud', '06-09-21-60-09', 'P.O. Box 597, 3422 Consequat Rd.', 'Belleville', 50527, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1010, 'Cakewalk ouest', '06-28-85-18-99', '708-3072 Sed Road', 'Williamsport', 51729, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1008, 'Finale gare', '06-81-76-05-90', 'P.O. Box 962, 6778 Non, Rd.', 'Lancaster', 61281, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1011, 'Finale aeroport', '06-04-11-30-14', 'P.O. Box 736, 4606 Sollicitudin Rd.', 'Pasadena', 81981, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1014, 'Ggle gare', '06-53-69-07-78', '188-1260 Libero Road', 'Shawnee', 90646, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1013, 'Ggle centre', '06-04-73-37-18', 'Ap #635-8102 Sem. Rd.', 'Pendleton', 38984, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1000, 'Lavat sud', '06-16-81-55-86', '151-9424 Justo. Road', 'Pine Bluff', 51650, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1005, 'Lavat gare', '06-74-31-49-24', 'Ap #723-8218 Neque. Street', 'Catskill', 52157, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1021, 'Lyosft', '06-73-01-98-30', 'P.O. Box 154, 2865 Neque. Rd.', 'Alamogordo', 22312, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1004, 'Lynios', '06-75-30-30-61', 'P.O. Box 340, 6242 Posuere, St.', 'Monroe', 48409, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1019, 'Lyos centre', '06-65-53-54-46', 'P.O. Box 858, 1487 Sed Ave', 'Melrose', 95236, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1012, 'Lyos gare', '06-22-85-39-07', '878-7789 Eget St.', 'Elmira', 7025, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1006, 'Lyos aeroport', '06-30-07-92-20', 'Ap #367-1303 Amet Avenue', 'Fairbanks', 53734, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1003, 'Lyos nord', '06-48-98-37-65', 'Ap #891-2806 Eleifend Avenue', 'Kenosha', 51286, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1020, 'Micsonty', '06-91-34-58-11', '6751 Nibh St.', 'Rockville', 92938, 'US');
INSERT INTO agence (num_agence, nom_agence, tel_agence, adr_agence, ville_agence, cp_agence, pays_agence) VALUES (1016, 'Sibeus', '06-77-04-70-41', 'Ap #912-6359 Vestibulum Rd.', 'Frisco', 91566, 'US');


--
-- Data for Name: tranche_location; Type: TABLE DATA; Schema: ctrl_bdd_car_net; Owner: Laurent
--

INSERT INTO tranche_location (nb_jours) VALUES (3);
INSERT INTO tranche_location (nb_jours) VALUES (5);
INSERT INTO tranche_location (nb_jours) VALUES (7);
INSERT INTO tranche_location (nb_jours) VALUES (8);
INSERT INTO tranche_location (nb_jours) VALUES (10);
INSERT INTO tranche_location (nb_jours) VALUES (20);
INSERT INTO tranche_location (nb_jours) VALUES (30);


--
-- Data for Name: vehicule; Type: TABLE DATA; Schema: ctrl_bdd_car_net; Owner: Laurent
--

INSERT INTO vehicule (code_vehicule, exemple, categorie, prix_jour, nb_portes, nb_passagers, nb_bagages, clim, volume, charge_utile, longueur, largeur, hauteur) VALUES (1, 'opel corsa', 'A', 33.00, 3, 5, 1, true, NULL, NULL, NULL, NULL, NULL);
INSERT INTO vehicule (code_vehicule, exemple, categorie, prix_jour, nb_portes, nb_passagers, nb_bagages, clim, volume, charge_utile, longueur, largeur, hauteur) VALUES (6, 'citroen C4', 'B', 119.00, 5, 5, 2, false, NULL, NULL, NULL, NULL, NULL);
INSERT INTO vehicule (code_vehicule, exemple, categorie, prix_jour, nb_portes, nb_passagers, nb_bagages, clim, volume, charge_utile, longueur, largeur, hauteur) VALUES (12, 'AUSTIN 	MINI', 'A', 135.00, 3, 5, 2, true, NULL, NULL, NULL, NULL, NULL);
INSERT INTO vehicule (code_vehicule, exemple, categorie, prix_jour, nb_portes, nb_passagers, nb_bagages, clim, volume, charge_utile, longueur, largeur, hauteur) VALUES (4, 'toyota yaris', 'A', 78.00, 3, 5, 2, true, NULL, NULL, NULL, NULL, NULL);
INSERT INTO vehicule (code_vehicule, exemple, categorie, prix_jour, nb_portes, nb_passagers, nb_bagages, clim, volume, charge_utile, longueur, largeur, hauteur) VALUES (10, 'peugeot 107', 'A', 51.00, 3, 5, 1, false, NULL, NULL, NULL, NULL, NULL);
INSERT INTO vehicule (code_vehicule, exemple, categorie, prix_jour, nb_portes, nb_passagers, nb_bagages, clim, volume, charge_utile, longueur, largeur, hauteur) VALUES (11, 'TOYOTA PRIUS', 'B', 103.00, 5, 5, 3, true, NULL, NULL, NULL, NULL, NULL);
INSERT INTO vehicule (code_vehicule, exemple, categorie, prix_jour, nb_portes, nb_passagers, nb_bagages, clim, volume, charge_utile, longueur, largeur, hauteur) VALUES (13, 'ford fiesta', 'B', 56.00, 3, 5, 1, false, NULL, NULL, NULL, NULL, NULL);
INSERT INTO vehicule (code_vehicule, exemple, categorie, prix_jour, nb_portes, nb_passagers, nb_bagages, clim, volume, charge_utile, longueur, largeur, hauteur) VALUES (3, 'seat ibiza 1.3', 'B', 50.00, 5, 5, 2, true, NULL, NULL, NULL, NULL, NULL);
INSERT INTO vehicule (code_vehicule, exemple, categorie, prix_jour, nb_portes, nb_passagers, nb_bagages, clim, volume, charge_utile, longueur, largeur, hauteur) VALUES (5, 'citroen C5', 'C', 127.00, 3, 5, 2, false, NULL, NULL, NULL, NULL, NULL);
INSERT INTO vehicule (code_vehicule, exemple, categorie, prix_jour, nb_portes, nb_passagers, nb_bagages, clim, volume, charge_utile, longueur, largeur, hauteur) VALUES (15, 'renault m�gane 1,6', 'C', 98.00, 5, 5, 1, true, NULL, NULL, NULL, NULL, NULL);
INSERT INTO vehicule (code_vehicule, exemple, categorie, prix_jour, nb_portes, nb_passagers, nb_bagages, clim, volume, charge_utile, longueur, largeur, hauteur) VALUES (7, 'citroen jumper', 'F', 145.00, NULL, NULL, NULL, false, 5.00, 1.20, 4.84, 1.86, 2.27);
INSERT INTO vehicule (code_vehicule, exemple, categorie, prix_jour, nb_portes, nb_passagers, nb_bagages, clim, volume, charge_utile, longueur, largeur, hauteur) VALUES (16, 'renaul kangoo', 'K', 107.00, NULL, NULL, NULL, false, 3.13, 0.59, 4.23, 1.67, 1.81);
INSERT INTO vehicule (code_vehicule, exemple, categorie, prix_jour, nb_portes, nb_passagers, nb_bagages, clim, volume, charge_utile, longueur, largeur, hauteur) VALUES (2, 'peugeot partner', 'K', 131.00, NULL, NULL, NULL, true, 1.42, 0.69, 4.40, 1.80, 1.95);
INSERT INTO vehicule (code_vehicule, exemple, categorie, prix_jour, nb_portes, nb_passagers, nb_bagages, clim, volume, charge_utile, longueur, largeur, hauteur) VALUES (14, 'ford transit', 'F', 128.00, NULL, NULL, NULL, true, 3.34, 0.67, 4.90, 1.86, 2.20);
INSERT INTO vehicule (code_vehicule, exemple, categorie, prix_jour, nb_portes, nb_passagers, nb_bagages, clim, volume, charge_utile, longueur, largeur, hauteur) VALUES (9, 'CITROEN BERLINGO ', 'F', 129.00, NULL, NULL, NULL, false, 3.30, 0.65, 4.84, 1.78, 1.82);
INSERT INTO vehicule (code_vehicule, exemple, categorie, prix_jour, nb_portes, nb_passagers, nb_bagages, clim, volume, charge_utile, longueur, largeur, hauteur) VALUES (8, 'IVECO 	DAILY ', 'F', 154.00, NULL, NULL, NULL, false, 6.50, 1.40, 4.78, 1.80, 2.23);


--
-- Data for Name: attribuer; Type: TABLE DATA; Schema: ctrl_bdd_car_net; Owner: Laurent
--

INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (1, 3, 10);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (1, 5, 20);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (1, 7, 30);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (1, 8, 40);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (1, 10, 50);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (1, 20, 60);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (1, 30, 100);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (2, 3, 20);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (2, 5, 40);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (2, 7, 60);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (2, 8, 80);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (2, 10, 100);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (2, 20, 120);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (2, 30, 200);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (3, 3, 15);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (3, 5, 30);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (3, 7, 45);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (3, 8, 60);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (3, 10, 75);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (3, 20, 90);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (3, 30, 150);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (4, 3, 10);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (4, 5, 20);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (4, 7, 30);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (4, 8, 40);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (4, 10, 50);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (4, 20, 60);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (4, 30, 100);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (5, 3, 17);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (5, 5, 34);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (5, 7, 51);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (5, 8, 68);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (5, 10, 85);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (5, 20, 102);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (5, 30, 170);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (6, 3, 15);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (6, 5, 30);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (6, 7, 45);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (6, 8, 60);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (6, 10, 75);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (6, 20, 90);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (6, 30, 150);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (7, 3, 19);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (7, 5, 38);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (7, 7, 57);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (7, 8, 76);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (7, 10, 95);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (7, 20, 114);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (7, 30, 190);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (8, 3, 19);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (8, 5, 38);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (8, 7, 57);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (8, 8, 76);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (8, 10, 95);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (8, 20, 114);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (8, 30, 190);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (9, 3, 19);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (9, 5, 38);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (9, 7, 57);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (9, 8, 76);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (9, 10, 95);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (9, 20, 114);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (9, 30, 190);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (10, 3, 10);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (10, 5, 20);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (10, 7, 30);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (10, 8, 40);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (10, 10, 50);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (10, 20, 60);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (10, 30, 100);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (11, 3, 15);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (11, 5, 30);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (11, 7, 45);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (11, 8, 60);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (11, 10, 75);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (11, 20, 90);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (11, 30, 150);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (12, 3, 10);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (12, 5, 20);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (12, 7, 30);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (12, 8, 40);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (12, 10, 50);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (12, 20, 60);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (12, 30, 100);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (13, 3, 15);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (13, 5, 30);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (13, 7, 45);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (13, 8, 60);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (13, 10, 75);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (13, 20, 90);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (13, 30, 150);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (14, 3, 19);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (14, 5, 38);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (14, 7, 57);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (14, 8, 76);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (14, 10, 95);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (14, 20, 114);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (14, 30, 190);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (15, 3, 17);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (15, 5, 34);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (15, 7, 51);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (15, 8, 68);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (15, 10, 85);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (15, 20, 102);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (15, 30, 170);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (16, 3, 20);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (16, 5, 40);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (16, 7, 60);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (16, 8, 80);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (16, 10, 100);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (16, 20, 120);
INSERT INTO attribuer (code_vehicule, nb_jours, nb_points) VALUES (16, 30, 200);


--
-- Data for Name: client; Type: TABLE DATA; Schema: ctrl_bdd_car_net; Owner: Laurent
--

INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (131, 'Fid�le', 'M', 'Shields', 'Octavia', '9173 Enim, Ave', 'Fulton', 28799, 'AF', '06-41-50-92-48', 'tristique.pharetra.Quisque@utquam.com', NULL, '1957-07-31', 886659448766, '1989-03-03', NULL, 4564080072462825);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (132, 'Fid�le', 'M', 'Albert', 'Dorothy', '1591 Egestas Ave', 'Belleville', 29796, 'GQ', '06-53-75-17-59', 'Nullam@nibhAliquam.ca', NULL, '1986-07-01', 24056738867, '1956-11-07', 160, 6548086503104267);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (133, 'Fid�le', 'M', 'Cooke', 'Rae', '645-548 Commodo Street', 'Providence', 48324, 'TZ', '06-63-95-04-53', 'ligula.elit@eutemporerat.edu', NULL, '1946-10-01', 701494854503, '1986-10-14', 210, 8287926421067546);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (102, 'Fid�le', 'Mlle', 'Miller', 'Nehru', '7007 Eu, Street', 'Belleville', 71531, 'BI', '06-24-56-34-04', 'eleifend.nec@purus.edu', NULL, '1950-05-17', 950620827908, '1980-09-15', 240, 4496731376411549);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (104, 'Fid�le', 'Mme', 'Goodman', 'Quin', '492-5815 Eu, Street', 'Bentonville', 5282, 'WF', '06-39-11-52-42', 'mattis.Integer.eu@condimentumeget.com', NULL, '1964-07-31', 222935480586, '1959-02-20', 190, 8688989132561304);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (110, 'Fid�le', 'Mme', 'Byers', 'Georgia', '203-2808 Sed, St.', 'Nanticoke', 90861, 'KI', '06-50-39-03-84', 'tempor.erat.neque@ut.ca', NULL, '1948-07-05', 883294407097, '1976-07-12', 370, 9684287190038842);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (116, 'Fid�le', 'M', 'Gonzales', 'Daniel', '747-5369 Nunc Rd.', 'Westlake Village', 73748, 'UM', '06-60-75-49-99', 'ultrices.posuere.cubilia@penatibusetmagnis.org', NULL, '1989-11-02', 500805371244, '1982-06-18', 130, 9939536185183360);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (136, 'Fid�le', 'Mlle', 'Pitts', 'Ori', 'P.O. Box 255, 2941 Dictum Avenue', 'Marietta', 54887, 'MG', '06-26-05-19-49', 'mattis.ornare.lectus@arcuiaculisenim.edu', NULL, '1974-10-01', 432181294859, '1988-07-13', 180, 6362622142549532);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (138, 'Fid�le', 'Mme', 'Cabrera', 'Shelley', '802-3122 Ac Rd.', 'Tupelo', 63082, 'FM', '06-13-27-24-82', 'mus.Donec@pedeSuspendissedui.edu', NULL, '1987-03-13', 493338611585, '1977-07-27', 130, 567104538453132);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (139, 'Fid�le', 'Mme', 'Randolph', 'Michael', 'P.O. Box 672, 7189 Odio. St.', 'Durant', 82038, 'KN', '06-19-51-41-52', 'ipsum.leo@magnaLorem.org', NULL, '1958-06-11', 238918076258, '1963-01-31', 100, 3970076218745902);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (148, 'Fid�le', 'Mme', 'Colon', 'Richard', 'P.O. Box 269, 7527 Nisi Av.', 'Bowling Green', 31865, 'TG', '06-93-16-63-48', 'sed@molestietortornibh.edu', NULL, '1971-09-18', 56864982014, '1991-04-15', 480, 9798629393776761);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (130, 'Fid�le', 'Mme', 'Bullock', 'Kaitlin', 'Ap #343-3385 A, Av.', 'St. Petersburg', 21880, 'FK', '06-06-27-18-57', 'dictum.Proin.eget@idblanditat.com', NULL, '1986-01-06', 317816549461, '1982-01-18', 440, 2515677396973068);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (125, 'Occassionnel', 'Mme', 'Gregory', 'Fiona', '600-9649 Nec Av.', 'Worland', 24851, 'QA', '06-06-20-56-76', 'ipsum.Suspendisse@magnaDuis.edu', 'esp�ce', NULL, NULL, NULL, NULL, NULL);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (129, 'Occassionnel', 'M', 'Reynolds', 'Madonna', '7227 Sed Ave', 'Glens Falls', 76056, 'RO', '06-44-86-01-18', 'Nunc.sed@ultriciesornareelit.com', 'CB', NULL, NULL, NULL, NULL, NULL);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (135, 'Occassionnel', 'M', 'Cox', 'Mira', 'P.O. Box 993, 6230 Habitant Avenue', 'Scottsbluff', 99120, 'LI', '06-89-74-62-75', 'tempor@Phasellusdapibusquam.org', 'cheque', NULL, NULL, NULL, NULL, NULL);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (137, 'Occassionnel', 'Mlle', 'Carter', 'Katelyn', '184-5710 Fringilla, Street', 'Fort Wayne', 53840, 'CR', '06-12-84-50-97', 'a.sollicitudin@Nuncut.ca', 'cheque', NULL, NULL, NULL, NULL, NULL);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (141, 'Occassionnel', 'M', 'Haynes', 'Gail', '386-6654 Sem Street', 'Placentia', 43558, 'AF', '06-91-65-23-14', 'Quisque@ipsumDonec.com', 'esp�ce', NULL, NULL, NULL, NULL, NULL);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (145, 'Occassionnel', 'M', 'Petty', 'Imani', '9411 Donec Street', 'Troy', 86690, 'PH', '06-27-48-11-18', 'vel.quam.dignissim@natoque.ca', 'CB', NULL, NULL, NULL, NULL, NULL);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (149, 'Occassionnel', 'Mlle', 'Waters', 'Maia', '666-7448 Vulputate Av.', 'Bristol', 87227, 'DZ', '06-15-64-59-38', 'Integer.mollis.Integer@temporbibendum.org', 'esp�ce', NULL, NULL, NULL, NULL, NULL);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (101, 'Occassionnel', 'Mlle', 'Hughes', 'Owen', 'P.O. Box 531, 7713 Ullamcorper. Av.', 'New Madrid', 85123, 'SC', '06-46-51-21-66', 'commodo@magna.org', 'CB', NULL, NULL, NULL, NULL, NULL);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (103, 'Occassionnel', 'M', 'Sellers', 'Caleb', '862-3165 Donec Rd.', 'Opelousas', 62656, 'BJ', '06-43-78-41-50', 'nec.tempus@ut.edu', 'CB', NULL, NULL, NULL, NULL, NULL);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (105, 'Occassionnel', 'Mme', 'Webster', 'Brynne', 'Ap #224-4066 Erat, Avenue', 'Guayama', 29187, 'SZ', '06-75-86-59-98', 'et.magna@sagittisaugueeu.org', 'cheque', NULL, NULL, NULL, NULL, NULL);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (111, 'Occassionnel', 'Mme', 'Mccarty', 'Brendan', 'P.O. Box 361, 2871 Et Av.', 'Brunswick', 3073, 'PR', '06-57-94-50-36', 'lobortis@Integersem.edu', 'cheque', NULL, NULL, NULL, NULL, NULL);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (117, 'Occassionnel', 'Mlle', 'Mayo', 'Chase', 'P.O. Box 371, 7213 Dignissim Road', 'West Palm Beach', 49489, 'IS', '06-19-95-50-41', 'molestie@euismodenim.ca', 'cheque', NULL, NULL, NULL, NULL, NULL);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (123, 'Occassionnel', 'M', 'Brennan', 'Carson', '555-457 Aenean Av.', 'Louisville', 36587, 'AO', '06-49-16-42-59', 'urna.Nullam@sitamet.edu', 'esp�ce', NULL, NULL, NULL, NULL, NULL);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (140, 'Fid�le', 'Mme', 'Parker', 'Gannon', '156-6555 Augue Rd.', 'Evanston', 69852, 'SC', '06-23-89-90-18', 'nibh.vulputate.mauris@elit.org', NULL, '1979-05-29', 598815321680, '1963-05-21', 220, 5433661651749277);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (143, 'Fid�le', 'M', 'Hunter', 'Kathleen', '7197 At St.', 'San Clemente', 94630, 'KR', '06-60-38-45-55', 'eget.laoreet.posuere@dui.org', NULL, '1957-11-08', 773229316111, '1987-12-26', 30, 7412126961428425);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (144, 'Fid�le', 'Mme', 'Winters', 'Phillip', 'P.O. Box 494, 5155 Aenean St.', 'Chesapeake', 16324, 'KN', '06-36-86-28-24', 'Proin@ipsumac.ca', NULL, '1990-07-24', 800552597703, '1964-02-11', 150, 277646265518056);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (147, 'Fid�le', 'Mlle', 'Gordon', 'Holly', 'P.O. Box 746, 123 Eu St.', 'Mequon', 71829, 'KI', '06-24-49-09-78', 'Sed.eget.lacus@luctussit.ca', NULL, '1980-11-04', 289621801473, '1987-05-28', 130, 3928272271960105);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (118, 'Fid�le', 'M', 'Beck', 'Deacon', 'P.O. Box 218, 7879 Non, Street', 'Louisville', 32251, 'LT', '06-73-58-68-59', 'magna.Phasellus@arcuVestibulum.ca', NULL, '1952-03-13', 806079287819, '1971-04-29', 220, 708443301806252);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (120, 'Fid�le', 'Mlle', 'Mcclain', 'Phoebe', 'P.O. Box 211, 8755 Nisi. Street', 'Carson City', 8918, 'PY', '06-10-01-25-66', 'at.iaculis@veliteu.edu', NULL, '1974-06-10', 882534543751, '1979-03-10', 220, 6603714940515263);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (124, 'Fid�le', 'Mlle', 'Rhodes', 'Silas', '6287 Quam. Ave', 'Edina', 16292, 'ZA', '06-64-48-71-64', 'interdum.libero.dui@quis.org', NULL, '1965-06-23', 603490176482, '1970-04-29', 490, 7855509370910912);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (126, 'Fid�le', 'Mlle', 'Case', 'Grady', '8756 Odio Av.', 'Saint Albans', 92730, 'LU', '06-29-01-58-06', 'ornare@Curabiturdictum.com', NULL, '1966-11-16', 205449238031, '1986-11-14', 330, 7612813961023865);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (134, 'Fid�le', 'Mlle', 'Koch', 'Aretha', 'P.O. Box 256, 8183 Ante Avenue', 'North Charleston', 63602, 'TL', '06-90-81-62-48', 'Sed@loremut.org', NULL, '1966-10-16', 671641769333, '1985-04-16', 50, 359267429812970);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (142, 'Fid�le', 'Mme', 'Daugherty', 'Clare', 'P.O. Box 732, 6456 Pede St.', 'Dalton', 28805, 'BR', '06-72-25-79-74', 'ornare.libero.at@ipsum.com', NULL, '1958-11-26', 459631607935, '1979-07-08', 390, 7309131701459760);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (146, 'Fid�le', 'Mlle', 'Mcintyre', 'Linus', 'P.O. Box 540, 7406 Commodo St.', 'Hagerstown', 3526, 'PR', '06-46-04-03-57', 'eget.nisi.dictum@nonummy.org', NULL, '1950-06-07', 293883830134, '1956-05-27', 190, 7504065478945553);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (100, 'Fid�le', 'Mlle', 'Paul', 'Troy', '9066 Lacus. Rd.', 'Texarkana', 10917, 'MS', '06-05-28-88-57', 'accumsan@euismodin.org', NULL, '1976-11-26', 652354933854, '1956-10-24', 220, 7613766554124274);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (106, 'Fid�le', 'Mme', 'Schroeder', 'Raphael', 'P.O. Box 415, 7665 Integer Rd.', 'Radford', 23501, 'CF', '06-67-58-26-66', 'ad.litora@doloregestas.ca', NULL, '1978-01-07', 863658886509, '1975-11-13', 210, 112788614370533);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (107, 'Fid�le', 'M', 'Dudley', 'Erasmus', '9811 Tempor Av.', 'Pendleton', 65275, 'FO', '06-96-57-53-36', 'orci.consectetuer.euismod@etnetus.com', NULL, '1963-09-13', 649971860536, '1984-06-21', 160, 7120095748116864);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (108, 'Fid�le', 'M', 'Small', 'Zoe', '7606 Et Av.', 'New Kensington', 48175, 'TH', '06-87-98-74-62', 'sed.sem@nislelementum.org', NULL, '1973-03-20', 951758535174, '1977-01-25', 110, 349171245869709);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (109, 'Fid�le', 'Mme', 'Hendricks', 'Megan', 'P.O. Box 438, 7369 Donec St.', 'Minnetonka', 99332, 'ZA', '06-34-10-53-51', 'Duis@accumsan.edu', NULL, '1974-03-16', 338990138727, '1961-04-03', 120, 698930984496606);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (112, 'Fid�le', 'Mme', 'Rivers', 'Gregory', '640-8423 Luctus. Street', 'Statesboro', 95263, 'ID', '06-67-14-23-77', 'magna.Ut.tincidunt@Innec.ca', NULL, '1952-11-17', 22485843738, '1985-10-04', 90, 914695129897438);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (113, 'Fid�le', 'Mlle', 'Holloway', 'Maggie', '231-7534 Justo. Av.', 'South El Monte', 55145, 'CN', '06-69-86-59-84', 'Donec.elementum.lorem@dui.edu', NULL, '1973-01-20', 540208626471, '1966-09-06', 220, 6168767316264086);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (114, 'Fid�le', 'Mme', 'Stephenson', 'Herrod', '280-7162 Enim, St.', 'Oneonta', 81398, 'ML', '06-67-32-47-41', 'tincidunt.aliquam.arcu@orcilobortis.ca', NULL, '1957-01-18', 852282700492, '1958-08-29', 120, 7903586823343303);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (115, 'Fid�le', 'Mlle', 'Crawford', 'Silas', 'Ap #327-2602 Ac, Rd.', 'Sheboygan', 26744, 'MP', '06-58-23-40-68', 'Fusce.aliquet@congue.edu', NULL, '1977-04-08', 322227940776, '1985-06-20', 240, 5212794144828945);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (119, 'Fid�le', 'Mlle', 'Wall', 'Brynne', '3577 Laoreet St.', 'Fort Collins', 70199, 'BF', '06-60-91-42-45', 'condimentum.eget@duiCras.org', NULL, '1973-02-08', 711626619980, '1985-08-06', 60, 702301544998259);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (121, 'Fid�le', 'Mme', 'Dale', 'Yoko', '868-3842 Metus. Av.', 'San Gabriel', 21348, 'AF', '06-51-76-67-16', 'nisl@rutrum.ca', NULL, '1961-01-07', 71009392114, '1968-06-03', 230, 4524132709972197);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (122, 'Fid�le', 'M', 'Britt', 'Gisela', '748-4758 Nonummy St.', 'Hawthorne', 6540, 'BN', '06-65-20-80-07', 'dolor.sit.amet@Vivamus.ca', NULL, '1991-03-10', 352734108504, '1973-10-27', 230, 1452014095174986);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (127, 'Fid�le', 'Mlle', 'Montoya', 'Josiah', '8037 Lacus. St.', 'Grafton', 26368, 'IO', '06-29-31-16-17', 'sodales.Mauris.blandit@at.edu', NULL, '1957-04-02', 319067055482, '1990-07-21', 300, 8409703810998100);
INSERT INTO client (num_client, type_client, civilite, nom_client, pre_client, adr_client, ville_client, cp_client, pays_client, tel_client, mail_client, mode_reglement, date_naissance, num_permis, date_permis, pts_bonus_acquis, num_cb) VALUES (128, 'Fid�le', 'M', 'Le', 'Tasha', 'Ap #471-6224 Metus. Rd.', 'Carolina', 90928, 'KZ', '06-27-12-10-41', 'ac.eleifend.vitae@nonarcuVivamus.com', NULL, '1984-09-25', 177033579779, '1963-04-30', 360, 6981163473892293);


--
-- Data for Name: jour_semaine; Type: TABLE DATA; Schema: ctrl_bdd_car_net; Owner: Laurent
--

INSERT INTO jour_semaine (num_jour, libelle_jour) VALUES (1, 'lundi');
INSERT INTO jour_semaine (num_jour, libelle_jour) VALUES (2, 'mardi');
INSERT INTO jour_semaine (num_jour, libelle_jour) VALUES (3, 'mercredi');
INSERT INTO jour_semaine (num_jour, libelle_jour) VALUES (4, 'jeudi');
INSERT INTO jour_semaine (num_jour, libelle_jour) VALUES (5, 'vendredi');
INSERT INTO jour_semaine (num_jour, libelle_jour) VALUES (6, 'samedi');
INSERT INTO jour_semaine (num_jour, libelle_jour) VALUES (7, 'dimanche');


--
-- Data for Name: ouverture; Type: TABLE DATA; Schema: ctrl_bdd_car_net; Owner: Laurent
--

INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1000, 2, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1000, 5, '07:00:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1001, 2, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1001, 5, '07:00:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1001, 1, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1003, 1, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1003, 2, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1003, 5, '07:00:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1004, 2, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1004, 5, '07:00:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1006, 2, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1006, 5, '07:00:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1007, 2, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1007, 5, '07:00:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1009, 2, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1009, 5, '07:00:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1010, 2, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1010, 5, '07:00:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1012, 2, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1012, 5, '07:00:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1013, 2, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1013, 5, '07:00:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1006, 1, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1007, 1, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1009, 1, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1010, 1, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1013, 1, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1015, 1, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1018, 1, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1000, 1, '07:30:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1004, 1, '07:30:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1012, 1, '07:30:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1016, 1, '07:30:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1002, 1, '07:00:00', '21:30:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1005, 1, '07:00:00', '21:30:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1011, 1, '07:00:00', '21:30:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1014, 1, '07:00:00', '21:30:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1017, 1, '07:00:00', '21:30:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1008, 1, '07:30:00', '21:30:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1015, 2, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1016, 2, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1018, 2, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1000, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1001, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1002, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1003, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1004, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1005, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1006, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1007, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1008, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1009, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1010, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1011, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1012, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1013, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1014, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1015, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1016, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1017, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1001, 4, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1003, 4, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1006, 4, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1007, 4, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1009, 4, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1010, 4, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1013, 4, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1015, 4, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1018, 4, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1000, 4, '07:30:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1004, 4, '07:30:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1012, 4, '07:30:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1016, 4, '07:30:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1002, 4, '08:00:00', '21:30:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1005, 4, '08:00:00', '21:30:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1011, 4, '08:00:00', '21:30:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1014, 4, '08:00:00', '21:30:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1017, 4, '08:00:00', '21:30:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1008, 4, '07:30:00', '21:30:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1015, 5, '07:00:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1016, 5, '07:00:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1018, 5, '07:00:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1000, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1001, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1002, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1003, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1004, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1005, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1006, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1007, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1008, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1009, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1010, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1011, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1012, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1013, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1014, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1001, 7, '10:00:00', '18:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1002, 7, '10:00:00', '18:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1003, 7, '10:00:00', '18:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1004, 7, '10:00:00', '18:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1005, 7, '10:00:00', '18:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1006, 7, '10:00:00', '18:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1008, 7, '10:00:00', '18:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1009, 7, '10:00:00', '18:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1010, 7, '10:00:00', '18:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1011, 7, '10:00:00', '18:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1012, 7, '10:00:00', '18:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1013, 7, '10:00:00', '18:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1014, 7, '10:00:00', '18:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1015, 7, '10:00:00', '18:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1016, 7, '10:00:00', '18:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1017, 7, '10:00:00', '18:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1018, 7, '10:00:00', '18:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1019, 1, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1021, 1, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1022, 1, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1024, 1, '07:30:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1023, 1, '07:00:00', '21:30:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1020, 1, '07:30:00', '21:30:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1019, 2, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1021, 2, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1022, 2, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1024, 2, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1002, 2, '06:30:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1005, 2, '06:30:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1008, 2, '06:30:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1011, 2, '06:30:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1014, 2, '06:30:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1017, 2, '06:30:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1020, 2, '06:30:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1023, 2, '06:30:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1018, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1019, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1020, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1021, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1022, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1023, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1024, 3, '07:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1019, 4, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1021, 4, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1022, 4, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1024, 4, '07:30:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1023, 4, '08:00:00', '21:30:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1020, 4, '07:30:00', '21:30:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1019, 5, '07:00:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1021, 5, '07:00:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1022, 5, '07:00:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1024, 5, '07:00:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1002, 5, '06:30:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1005, 5, '06:30:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1008, 5, '06:30:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1011, 5, '06:30:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1014, 5, '06:30:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1017, 5, '06:30:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1020, 5, '06:30:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1023, 5, '06:30:00', '24:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1015, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1016, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1017, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1018, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1019, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1020, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1021, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1022, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1023, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1024, 6, '08:00:00', '22:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1019, 7, '10:00:00', '18:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1021, 7, '10:00:00', '18:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1022, 7, '10:00:00', '18:00:00');
INSERT INTO ouverture (num_agence, num_jour, heure_ouverture, heure_fermeture) VALUES (1023, 7, '10:00:00', '18:00:00');


--
-- Data for Name: proposer; Type: TABLE DATA; Schema: ctrl_bdd_car_net; Owner: Laurent
--

INSERT INTO proposer (code_vehicule, num_agence) VALUES (11, 1000);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (5, 1000);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (3, 1000);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (14, 1000);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (7, 1000);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (6, 1000);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (4, 1000);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (1, 1001);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (6, 1001);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (3, 1001);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (16, 1001);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (7, 1001);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (12, 1001);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (10, 1001);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (15, 1001);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (5, 1002);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (2, 1002);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (10, 1002);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (13, 1002);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (15, 1002);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (4, 1002);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (6, 1002);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (16, 1002);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (10, 1003);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (13, 1003);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (5, 1003);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (2, 1004);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (6, 1004);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (13, 1004);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (9, 1005);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (3, 1005);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (10, 1005);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (7, 1005);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (3, 1006);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (5, 1006);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (10, 1006);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (2, 1007);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (5, 1007);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (10, 1007);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (14, 1007);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (4, 1008);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (1, 1008);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (11, 1008);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (8, 1009);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (7, 1009);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (2, 1009);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (9, 1009);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (12, 1009);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (1, 1009);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (15, 1009);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (14, 1009);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (11, 1009);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (12, 1010);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (15, 1010);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (6, 1010);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (2, 1010);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (5, 1010);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (7, 1010);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (4, 1010);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (1, 1010);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (5, 1011);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (3, 1011);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (16, 1011);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (4, 1011);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (8, 1011);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (10, 1011);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (2, 1011);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (7, 1011);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (4, 1012);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (2, 1012);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (14, 1012);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (7, 1012);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (12, 1013);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (7, 1013);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (8, 1013);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (13, 1013);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (5, 1013);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (13, 1014);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (12, 1014);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (14, 1014);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (5, 1014);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (15, 1015);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (8, 1015);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (5, 1015);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (4, 1015);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (14, 1015);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (15, 1016);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (16, 1016);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (3, 1016);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (12, 1016);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (13, 1016);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (6, 1016);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (9, 1017);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (8, 1017);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (12, 1017);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (16, 1017);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (10, 1017);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (1, 1017);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (2, 1017);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (3, 1017);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (15, 1018);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (16, 1018);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (2, 1018);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (14, 1018);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (5, 1018);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (4, 1018);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (7, 1018);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (1, 1018);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (6, 1018);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (11, 1018);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (2, 1019);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (10, 1019);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (12, 1019);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (6, 1020);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (2, 1020);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (16, 1020);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (10, 1020);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (8, 1020);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (4, 1020);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (10, 1021);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (15, 1021);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (5, 1021);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (7, 1021);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (11, 1021);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (14, 1021);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (6, 1021);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (15, 1022);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (14, 1022);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (2, 1022);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (10, 1022);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (7, 1022);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (5, 1022);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (16, 1022);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (16, 1023);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (2, 1023);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (7, 1023);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (1, 1023);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (10, 1023);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (4, 1023);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (9, 1023);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (11, 1023);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (5, 1023);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (4, 1024);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (1, 1024);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (6, 1024);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (9, 1024);
INSERT INTO proposer (code_vehicule, num_agence) VALUES (12, 1024);


--
-- Data for Name: reservation; Type: TABLE DATA; Schema: ctrl_bdd_car_net; Owner: Laurent
--

INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (78, 1011, 1007, 146, 2, '2010-10-19', '2010-10-19 00:00:00', '2010-10-21 03:01:46');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (82, 1018, 1006, 147, 5, '2010-04-06', '2010-04-11 00:00:00', '2010-04-13 23:15:43');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (100, 1020, 1013, 110, 7, '2010-06-23', '2010-06-24 00:00:00', '2010-06-28 20:47:20');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (134, 1001, 1005, 140, 10, '2011-03-21', '2011-03-29 00:00:00', '2011-03-31 19:00:31');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (136, 1005, 1002, 147, 2, '2009-09-21', '2009-09-22 00:00:00', '2009-09-26 21:14:18');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (148, 1007, 1001, 140, 7, '2011-03-03', '2011-03-06 00:00:00', '2011-03-12 16:40:32');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (154, 1024, 1003, 119, 5, '2011-12-11', '2011-12-11 00:00:00', '2011-12-15 01:04:53');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (166, 1008, 1010, 126, 2, '2009-12-22', '2009-12-28 00:00:00', '2009-12-30 12:56:05');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (186, 1014, 1002, 114, 5, '2009-09-11', '2009-09-14 00:00:00', '2009-09-18 04:17:15');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (200, 1012, 1020, 132, 2, '2009-10-16', '2009-10-16 00:00:00', '2009-10-24 09:57:04');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (204, 1015, 1022, 142, 2, '2011-11-15', '2011-11-16 00:00:00', '2011-11-22 21:59:14');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (226, 1007, 1017, 144, 3, '2012-04-06', '2012-04-08 00:00:00', '2012-04-10 17:23:54');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (228, 1013, 1010, 116, 5, '2012-01-02', '2012-01-03 00:00:00', '2012-01-05 14:00:37');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (238, 1019, 1020, 136, 16, '2009-10-30', '2009-10-31 00:00:00', '2009-11-02 12:53:03');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (276, 1010, 1014, 127, 14, '2010-04-03', '2010-04-03 00:00:00', '2010-04-09 07:39:24');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (294, 1010, 1018, 112, 7, '2010-04-21', '2010-04-22 00:00:00', '2010-04-28 08:47:25');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (300, 1013, 1019, 112, 2, '2011-11-12', '2011-11-13 00:00:00', '2011-11-21 16:19:59');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (304, 1001, 1017, 138, 1, '2012-02-03', '2012-02-04 00:00:00', '2012-02-10 13:49:06');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (182, 1022, 1023, 100, 4, '2010-11-06', '2010-11-06 00:00:00', '2010-11-08 13:24:12');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (298, 1010, 1001, 107, 1, '2010-03-30', '2010-04-03 00:00:00', '2010-04-09 23:34:14');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (174, 1024, 1019, 124, 10, '2011-01-21', '2011-01-22 00:00:00', '2011-01-24 09:29:24');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (142, 1013, 1023, 142, 1, '2009-12-12', '2009-12-19 00:00:00', '2009-12-21 00:30:37');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (106, 1021, 1001, 119, 12, '2011-10-14', '2011-10-15 00:00:00', '2011-10-21 15:53:10');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (76, 1007, 1011, 123, 5, '2009-06-02', '2009-06-03 00:00:00', '2009-06-07 01:20:41');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (84, 1022, 1024, 127, 9, '2011-07-27', '2011-08-01 00:00:00', '2011-08-11 21:30:21');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (90, 1009, 1010, 113, 12, '2009-09-06', '2009-09-10 00:00:00', '2009-09-28 17:04:27');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (92, 1022, 1018, 149, 6, '2011-04-28', '2011-05-06 00:00:00', '2011-05-16 04:34:59');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (4, 1023, 1022, 103, 5, '2011-03-11', '2011-03-19 00:00:00', '2011-03-27 10:57:03');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (2, 1003, 1000, 143, 5, '2010-08-27', '2010-08-29 00:00:00', '2010-08-31 04:25:53');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (8, 1024, 1005, 144, 3, '2010-09-19', '2010-09-21 00:00:00', '2010-09-25 10:41:31');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (6, 1022, 1007, 137, 5, '2010-10-13', '2010-10-17 00:00:00', '2010-10-27 19:14:01');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (16, 1015, 1001, 127, 12, '2010-03-24', '2010-04-01 00:00:00', '2010-04-03 01:16:22');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (10, 1007, 1011, 144, 2, '2012-01-12', '2012-01-20 00:00:00', '2012-02-07 00:43:48');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (12, 1017, 1018, 148, 14, '2009-08-15', '2009-08-17 00:00:00', '2009-09-06 20:33:46');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (26, 1020, 1009, 132, 9, '2011-04-17', '2011-04-26 00:00:00', '2011-05-08 17:08:34');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (32, 1000, 1009, 136, 2, '2009-04-26', '2009-05-02 00:00:00', '2009-05-12 13:34:48');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (28, 1002, 1015, 118, 14, '2011-03-22', '2011-03-27 00:00:00', '2011-03-29 02:56:55');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (36, 1021, 1010, 116, 4, '2010-02-11', '2010-02-20 00:00:00', '2010-03-06 09:41:29');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (42, 1012, 1022, 125, 10, '2010-05-12', '2010-05-13 00:00:00', '2010-05-25 08:05:48');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (48, 1016, 1015, 145, 8, '2011-04-17', '2011-04-23 00:00:00', '2011-05-07 03:41:46');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (40, 1003, 1002, 112, 16, '2010-09-20', '2010-09-25 00:00:00', '2010-09-29 01:41:22');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (50, 1009, 1000, 128, 4, '2009-12-02', '2009-12-11 00:00:00', '2009-12-23 12:10:23');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (54, 1017, 1000, 127, 14, '2012-03-22', '2012-03-30 00:00:00', '2012-04-11 09:54:33');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (60, 1004, 1017, 106, 1, '2011-10-14', '2011-10-18 00:00:00', '2011-11-07 04:10:06');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (62, 1024, 1000, 141, 11, '2009-07-07', '2009-07-12 00:00:00', '2009-07-30 05:04:14');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (58, 1017, 1008, 110, 4, '2010-06-11', '2010-06-18 00:00:00', '2010-06-20 07:20:38');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (64, 1015, 1018, 105, 16, '2011-04-04', '2011-04-08 00:00:00', '2011-04-12 02:26:59');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (70, 1016, 1014, 104, 13, '2011-06-08', '2011-06-10 00:00:00', '2011-06-16 15:42:37');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (72, 1009, 1023, 120, 2, '2009-10-14', '2009-10-16 00:00:00', '2009-10-24 15:57:35');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (128, 1012, 1016, 133, 16, '2010-07-11', '2010-07-11 00:00:00', '2010-07-12 03:48:02');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (132, 1022, 1024, 138, 4, '2012-03-06', '2012-03-07 00:00:00', '2012-03-08 13:22:17');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (172, 1016, 1021, 119, 5, '2010-07-19', '2010-07-28 00:00:00', '2010-07-29 01:12:41');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (314, 1002, 1023, 142, 10, '2011-02-24', '2011-02-25 00:00:00', '2011-02-26 06:05:41');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (20, 1008, 1002, 114, 4, '2011-04-01', '2011-04-10 00:00:00', '2011-04-11 06:24:20');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (46, 1020, 1007, 143, 14, '2009-05-27', '2009-05-31 00:00:00', '2009-06-01 09:45:11');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (52, 1010, 1022, 121, 14, '2010-05-03', '2010-05-13 00:00:00', '2010-05-14 00:47:08');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (0, 1004, 1021, 124, 10, '2009-11-02', '2009-11-04 00:00:00', '2009-11-06 14:25:53');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (24, 1006, 1009, 124, 9, '2011-11-12', '2011-11-19 00:00:00', '2011-11-21 15:21:40');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (94, 1001, 1023, 122, 2, '2009-08-27', '2009-09-05 00:00:00', '2009-09-15 03:06:06');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (96, 1024, 1013, 144, 12, '2010-06-23', '2010-06-29 00:00:00', '2010-07-03 00:59:18');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (102, 1004, 1013, 118, 13, '2009-08-03', '2009-08-04 00:00:00', '2009-08-16 20:58:37');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (104, 1007, 1010, 128, 12, '2009-10-08', '2009-10-12 00:00:00', '2009-10-20 14:21:24');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (108, 1015, 1009, 104, 11, '2009-10-24', '2009-10-29 00:00:00', '2009-11-12 09:46:38');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (112, 1001, 1015, 148, 14, '2010-06-24', '2010-06-28 00:00:00', '2010-07-14 13:59:53');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (116, 1012, 1018, 135, 11, '2009-12-21', '2009-12-27 00:00:00', '2010-01-14 23:15:14');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (118, 1007, 1001, 121, 10, '2011-12-01', '2011-12-06 00:00:00', '2011-12-26 13:15:58');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (120, 1012, 1000, 115, 6, '2010-10-23', '2010-10-26 00:00:00', '2010-11-13 04:55:14');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (124, 1002, 1005, 106, 7, '2010-07-06', '2010-07-14 00:00:00', '2010-07-20 01:10:49');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (126, 1018, 1021, 133, 14, '2010-10-02', '2010-10-04 00:00:00', '2010-10-18 21:05:12');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (130, 1015, 1004, 114, 2, '2011-05-17', '2011-05-27 00:00:00', '2011-06-02 06:00:01');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (138, 1020, 1001, 127, 15, '2011-06-20', '2011-06-25 00:00:00', '2011-07-01 23:12:34');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (140, 1006, 1017, 113, 1, '2010-01-07', '2010-01-09 00:00:00', '2010-01-17 18:08:05');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (146, 1017, 1007, 114, 10, '2009-09-25', '2009-09-27 00:00:00', '2009-10-13 02:26:00');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (150, 1006, 1015, 148, 8, '2011-08-20', '2011-08-20 00:00:00', '2011-09-09 23:37:56');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (152, 1017, 1023, 128, 9, '2010-04-26', '2010-04-28 00:00:00', '2010-05-04 09:52:35');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (156, 1020, 1016, 113, 6, '2009-12-25', '2009-12-29 00:00:00', '2010-01-12 03:05:24');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (158, 1015, 1002, 120, 4, '2009-07-27', '2009-08-01 00:00:00', '2009-08-15 08:35:44');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (160, 1015, 1010, 120, 6, '2009-09-18', '2009-09-21 00:00:00', '2009-10-03 20:26:31');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (162, 1018, 1017, 146, 1, '2009-12-09', '2009-12-15 00:00:00', '2009-12-29 03:05:48');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (164, 1019, 1018, 121, 1, '2009-04-21', '2009-04-22 00:00:00', '2009-04-30 02:14:46');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (170, 1005, 1024, 128, 1, '2011-09-08', '2011-09-17 00:00:00', '2011-09-29 01:26:22');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (180, 1014, 1011, 121, 16, '2011-12-23', '2011-12-25 00:00:00', '2012-01-06 10:44:55');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (184, 1001, 1015, 126, 5, '2010-03-24', '2010-03-25 00:00:00', '2010-04-06 02:48:13');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (188, 1024, 1016, 127, 15, '2009-09-28', '2009-10-08 00:00:00', '2009-10-24 22:49:05');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (190, 1011, 1001, 126, 12, '2011-10-02', '2011-10-06 00:00:00', '2011-10-18 06:25:09');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (192, 1024, 1011, 134, 10, '2009-07-29', '2009-08-02 00:00:00', '2009-08-10 23:06:55');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (194, 1007, 1018, 148, 15, '2012-02-29', '2012-03-02 00:00:00', '2012-03-14 03:12:14');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (196, 1005, 1009, 142, 2, '2011-12-12', '2011-12-19 00:00:00', '2011-12-27 00:19:45');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (198, 1008, 1021, 115, 7, '2011-04-25', '2011-05-03 00:00:00', '2011-05-19 03:39:44');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (206, 1023, 1009, 140, 15, '2012-03-07', '2012-03-08 00:00:00', '2012-03-22 13:05:59');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (210, 1005, 1011, 100, 8, '2012-04-13', '2012-04-17 00:00:00', '2012-04-23 14:18:57');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (214, 1018, 1020, 129, 4, '2011-02-10', '2011-02-10 00:00:00', '2011-02-20 16:01:36');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (216, 1016, 1006, 115, 10, '2010-04-04', '2010-04-14 00:00:00', '2010-05-04 01:30:38');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (218, 1004, 1016, 126, 13, '2010-07-11', '2010-07-17 00:00:00', '2010-07-25 18:52:56');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (224, 1005, 1020, 133, 8, '2009-05-17', '2009-05-19 00:00:00', '2009-06-04 06:43:28');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (232, 1003, 1020, 127, 6, '2009-06-18', '2009-06-19 00:00:00', '2009-06-29 22:41:48');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (234, 1011, 1001, 107, 16, '2010-01-18', '2010-01-19 00:00:00', '2010-02-02 08:22:33');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (236, 1010, 1001, 122, 3, '2011-01-16', '2011-01-22 00:00:00', '2011-02-05 03:43:15');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (240, 1016, 1009, 122, 15, '2010-01-09', '2010-01-13 00:00:00', '2010-01-27 09:44:19');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (244, 1019, 1009, 146, 1, '2010-01-25', '2010-01-25 00:00:00', '2010-02-08 09:35:18');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (248, 1006, 1013, 140, 12, '2011-11-24', '2011-11-26 00:00:00', '2011-12-16 03:58:50');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (252, 1000, 1004, 110, 13, '2010-07-18', '2010-07-21 00:00:00', '2010-07-25 15:13:04');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (254, 1024, 1023, 138, 11, '2011-12-08', '2011-12-10 00:00:00', '2011-12-22 02:29:39');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (256, 1007, 1005, 128, 7, '2010-12-22', '2010-12-30 00:00:00', '2011-01-09 11:21:25');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (258, 1013, 1016, 102, 6, '2010-08-25', '2010-08-27 00:00:00', '2010-09-14 16:41:43');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (260, 1000, 1024, 118, 6, '2009-12-27', '2009-12-28 00:00:00', '2010-01-11 01:10:11');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (262, 1010, 1009, 140, 12, '2009-07-01', '2009-07-03 00:00:00', '2009-07-15 05:46:07');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (264, 1022, 1015, 120, 8, '2009-11-01', '2009-11-07 00:00:00', '2009-11-25 12:21:55');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (266, 1014, 1003, 126, 10, '2011-08-08', '2011-08-09 00:00:00', '2011-08-19 13:56:33');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (270, 1016, 1002, 147, 16, '2009-12-03', '2009-12-08 00:00:00', '2009-12-20 04:10:59');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (272, 1007, 1012, 118, 14, '2011-10-24', '2011-10-26 00:00:00', '2011-10-30 04:27:43');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (274, 1004, 1010, 109, 4, '2011-07-29', '2011-07-29 00:00:00', '2011-08-16 05:47:27');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (280, 1024, 1023, 116, 9, '2011-02-13', '2011-02-17 00:00:00', '2011-03-05 08:14:24');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (282, 1001, 1021, 106, 6, '2010-03-17', '2010-03-17 00:00:00', '2010-03-31 01:35:28');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (284, 1014, 1011, 133, 4, '2012-02-07', '2012-02-09 00:00:00', '2012-02-27 15:42:53');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (286, 1014, 1015, 110, 15, '2009-09-04', '2009-09-13 00:00:00', '2009-09-17 20:19:10');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (288, 1003, 1014, 136, 5, '2009-08-07', '2009-08-15 00:00:00', '2009-08-29 21:30:38');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (290, 1000, 1023, 124, 7, '2011-08-29', '2011-09-03 00:00:00', '2011-09-21 09:32:00');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (292, 1012, 1000, 111, 7, '2011-07-30', '2011-08-08 00:00:00', '2011-08-24 12:52:24');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (296, 1016, 1014, 146, 12, '2011-05-24', '2011-05-27 00:00:00', '2011-06-10 02:23:20');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (302, 1009, 1011, 148, 8, '2011-07-06', '2011-07-13 00:00:00', '2011-07-25 03:01:24');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (306, 1016, 1006, 122, 3, '2010-07-24', '2010-07-27 00:00:00', '2010-08-16 01:01:07');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (308, 1007, 1017, 128, 12, '2010-08-24', '2010-08-28 00:00:00', '2010-09-09 20:22:45');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (310, 1010, 1020, 104, 2, '2010-08-11', '2010-08-19 00:00:00', '2010-08-29 13:42:01');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (312, 1009, 1000, 142, 14, '2012-03-24', '2012-04-01 00:00:00', '2012-04-07 08:41:06');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (144, 1014, 1012, 100, 4, '2010-08-06', '2010-08-14 00:00:00', '2010-08-24 07:34:08');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (178, 1015, 1021, 100, 7, '2010-08-29', '2010-09-03 00:00:00', '2010-09-21 01:56:48');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (88, 1014, 1018, 102, 14, '2011-05-23', '2011-05-26 00:00:00', '2011-06-13 08:13:44');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (242, 1002, 1008, 102, 11, '2011-11-14', '2011-11-24 00:00:00', '2011-12-14 21:27:54');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (122, 1021, 1017, 107, 8, '2011-04-21', '2011-04-27 00:00:00', '2011-04-29 08:22:43');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (86, 1014, 1016, 110, 16, '2011-08-11', '2011-08-16 00:00:00', '2011-08-26 18:37:01');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (222, 1018, 1017, 110, 9, '2010-11-05', '2010-11-08 00:00:00', '2010-11-18 07:17:08');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (114, 1011, 1023, 124, 5, '2011-03-28', '2011-03-30 00:00:00', '2011-04-19 12:12:36');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (208, 1020, 1012, 124, 2, '2012-04-03', '2012-04-10 00:00:00', '2012-04-18 15:11:04');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (230, 1006, 1022, 124, 15, '2011-11-12', '2011-11-17 00:00:00', '2011-11-27 04:16:43');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (168, 1008, 1002, 130, 6, '2010-05-05', '2010-05-07 00:00:00', '2010-05-27 21:46:07');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (250, 1015, 1023, 130, 1, '2009-07-02', '2009-07-07 00:00:00', '2009-07-15 17:11:56');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (176, 1005, 1022, 142, 16, '2010-06-18', '2010-06-24 00:00:00', '2010-07-04 20:07:29');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (220, 1013, 1009, 142, 8, '2010-11-08', '2010-11-09 00:00:00', '2010-11-27 12:20:17');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (110, 1007, 1013, 136, 5, '2010-03-24', '2010-04-02 00:00:00', '2010-04-14 17:49:33');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (98, 1019, 1021, 148, 11, '2011-05-25', '2011-05-26 00:00:00', '2011-06-07 03:24:53');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (246, 1007, 1011, 148, 8, '2010-01-05', '2010-01-09 00:00:00', '2010-01-27 09:28:04');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (80, 1001, 1003, 102, 13, '2011-01-02', '2011-01-09 00:00:00', '2011-01-25 17:24:50');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (202, 1023, 1010, 110, 15, '2010-09-14', '2010-09-23 00:00:00', '2010-10-01 00:07:55');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (212, 1021, 1008, 126, 4, '2009-10-16', '2009-10-25 00:00:00', '2009-10-29 00:53:47');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (66, 1018, 1016, 109, 3, '2010-06-01', '2010-06-03 00:00:00', '2010-06-17 19:29:33');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (68, 1014, 1015, 101, 5, '2011-10-14', '2011-10-20 00:00:00', '2011-10-26 06:19:19');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (74, 1006, 1015, 117, 8, '2009-09-08', '2009-09-13 00:00:00', '2009-10-01 07:03:46');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (18, 1001, 1010, 100, 1, '2009-12-02', '2009-12-05 00:00:00', '2009-12-21 20:39:11');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (34, 1019, 1018, 107, 2, '2010-10-04', '2010-10-08 00:00:00', '2010-10-24 00:46:21');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (22, 1009, 1001, 124, 6, '2012-01-09', '2012-01-17 00:00:00', '2012-02-06 10:03:10');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (44, 1013, 1021, 124, 15, '2012-03-20', '2012-03-27 00:00:00', '2012-04-12 03:17:35');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (14, 1019, 1018, 130, 16, '2010-05-05', '2010-05-12 00:00:00', '2010-05-26 14:03:58');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (38, 1011, 1019, 130, 12, '2012-03-09', '2012-03-13 00:00:00', '2012-03-23 09:38:49');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (30, 1009, 1023, 142, 16, '2010-02-13', '2010-02-23 00:00:00', '2010-03-13 09:28:32');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (56, 1003, 1020, 142, 10, '2011-01-27', '2011-02-05 00:00:00', '2011-02-21 09:45:44');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (268, 1007, 1018, 110, 5, '2010-04-08', '2010-04-16 00:00:00', '2010-04-26 18:41:47');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (318, 1013, 1017, 128, 10, '2010-04-12', '2010-04-16 00:00:00', '2010-04-20 02:49:19');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (332, 1018, 1003, 144, 5, '2011-10-05', '2011-10-05 00:00:00', '2011-10-11 00:42:50');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (334, 1020, 1011, 144, 4, '2011-03-28', '2011-04-05 00:00:00', '2011-04-07 00:11:38');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (342, 1016, 1022, 133, 7, '2009-04-24', '2009-04-27 00:00:00', '2009-05-01 00:13:17');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (352, 1013, 1000, 130, 3, '2011-05-28', '2011-05-31 00:00:00', '2011-06-06 06:44:20');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (362, 1021, 1005, 118, 10, '2011-11-12', '2011-11-19 00:00:00', '2011-11-21 10:12:59');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (364, 1001, 1012, 108, 7, '2011-12-14', '2011-12-17 00:00:00', '2011-12-19 02:22:11');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (372, 1019, 1004, 134, 13, '2010-04-18', '2010-04-24 00:00:00', '2010-04-26 19:00:42');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (374, 1003, 1017, 143, 9, '2012-02-19', '2012-02-23 00:00:00', '2012-02-25 18:08:12');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (388, 1021, 1011, 147, 16, '2011-01-17', '2011-01-17 00:00:00', '2011-01-25 15:17:59');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (398, 1019, 1000, 130, 6, '2011-11-09', '2011-11-12 00:00:00', '2011-11-14 20:11:33');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (350, 1008, 1000, 138, 3, '2011-10-31', '2011-11-08 00:00:00', '2011-11-09 10:18:49');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (358, 1000, 1023, 100, 2, '2011-03-10', '2011-03-19 00:00:00', '2011-03-20 08:21:28');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (384, 1013, 1016, 138, 12, '2011-12-10', '2011-12-18 00:00:00', '2011-12-19 18:43:14');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (386, 1008, 1016, 138, 3, '2011-02-12', '2011-02-20 00:00:00', '2011-02-21 05:47:50');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (390, 1003, 1020, 127, 2, '2010-11-20', '2010-11-30 00:00:00', '2010-12-01 18:28:47');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (336, 1020, 1013, 124, 8, '2010-03-05', '2010-03-12 00:00:00', '2010-03-14 17:49:41');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (370, 1003, 1017, 142, 2, '2011-04-27', '2011-04-30 00:00:00', '2011-05-02 02:49:18');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (392, 1023, 1015, 142, 4, '2011-11-22', '2011-11-22 00:00:00', '2011-11-28 12:21:43');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (320, 1009, 1008, 132, 1, '2009-08-06', '2009-08-10 00:00:00', '2009-08-22 11:43:58');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (322, 1015, 1002, 108, 15, '2011-01-13', '2011-01-17 00:00:00', '2011-02-02 02:53:35');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (324, 1019, 1018, 130, 4, '2010-08-20', '2010-08-29 00:00:00', '2010-09-12 06:43:15');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (326, 1014, 1017, 115, 16, '2009-11-01', '2009-11-09 00:00:00', '2009-11-27 03:10:36');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (328, 1018, 1003, 139, 13, '2009-08-02', '2009-08-06 00:00:00', '2009-08-20 10:41:57');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (330, 1002, 1015, 121, 14, '2011-08-02', '2011-08-06 00:00:00', '2011-08-24 16:11:00');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (344, 1001, 1011, 110, 3, '2010-03-17', '2010-03-18 00:00:00', '2010-03-28 01:28:09');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (346, 1002, 1015, 148, 14, '2012-03-19', '2012-03-22 00:00:00', '2012-04-09 22:37:35');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (348, 1018, 1021, 106, 10, '2009-10-31', '2009-11-05 00:00:00', '2009-11-25 11:17:28');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (354, 1010, 1023, 126, 9, '2009-06-25', '2009-06-28 00:00:00', '2009-07-04 11:09:34');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (356, 1023, 1002, 113, 10, '2011-01-28', '2011-02-07 00:00:00', '2011-02-25 00:50:24');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (366, 1012, 1023, 128, 1, '2009-05-10', '2009-05-12 00:00:00', '2009-05-20 12:12:28');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (368, 1023, 1004, 108, 6, '2010-06-06', '2010-06-08 00:00:00', '2010-06-16 16:49:23');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (376, 1022, 1002, 104, 13, '2011-04-13', '2011-04-21 00:00:00', '2011-05-01 00:46:56');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (378, 1007, 1011, 118, 7, '2011-10-12', '2011-10-20 00:00:00', '2011-11-01 06:52:36');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (380, 1024, 1013, 139, 8, '2009-10-19', '2009-10-21 00:00:00', '2009-10-29 17:32:52');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (382, 1011, 1009, 124, 7, '2011-08-16', '2011-08-16 00:00:00', '2011-08-30 05:43:21');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (394, 1002, 1004, 130, 2, '2010-06-09', '2010-06-18 00:00:00', '2010-06-30 05:01:35');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (396, 1017, 1010, 126, 4, '2011-01-12', '2011-01-18 00:00:00', '2011-01-30 12:35:12');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (360, 1010, 1005, 124, 9, '2009-09-23', '2009-10-02 00:00:00', '2009-10-06 11:09:09');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (338, 1015, 1010, 110, 7, '2009-06-28', '2009-07-03 00:00:00', '2009-07-19 08:51:33');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (278, 1023, 1009, 124, 14, '2009-07-19', '2009-07-23 00:00:00', '2009-07-31 23:58:19');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (316, 1017, 1002, 130, 2, '2012-02-09', '2012-02-12 00:00:00', '2012-02-26 10:15:51');
INSERT INTO reservation (num_resa, retour_agence, depart_agence, num_client, code_vehicule, date_resa, date_heure_depart, date_heure_retour) VALUES (340, 1003, 1024, 130, 12, '2012-03-18', '2012-03-18 00:00:00', '2012-03-20 10:33:25');




--
-- Name: agence_num_agence_seq; Type: SEQUENCE SET; Schema: ctrl_bdd_car_net; Owner: Laurent
--

SELECT pg_catalog.setval('agence_num_agence_seq', 1024, true);


--
-- Name: client_num_client_seq; Type: SEQUENCE SET; Schema: ctrl_bdd_car_net; Owner: Laurent
--

SELECT pg_catalog.setval('client_num_client_seq', 149, true);


--
-- Name: reservation_num_resa_seq; Type: SEQUENCE SET; Schema: ctrl_bdd_car_net; Owner: Laurent
--

SELECT pg_catalog.setval('reservation_num_resa_seq', 399, false);


--
-- Name: vehicule_code_vehicule_seq; Type: SEQUENCE SET; Schema: ctrl_bdd_car_net; Owner: Laurent
--

SELECT pg_catalog.setval('vehicule_code_vehicule_seq', 16, true);

-- creation de la vue  view_agence_ouverture
create or replace view  view_agence_ouverture
as
select *
from agence join ouverture using(num_agence)
            join jour_semaine using (num_jour)
order by nom_agence, num_jour;
