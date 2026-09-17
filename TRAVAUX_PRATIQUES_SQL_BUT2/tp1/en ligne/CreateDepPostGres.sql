create schema TP1_Dep_Emp;
SET search_path=TP1_Dep_Emp;

SET CLIENT_ENCODING TO 'utf8';
--
-- création de la table departement
--
CREATE TABLE departement
    (
	nodept NUMERIC(2) NOT NULL CONSTRAINT dept_nodept_pk PRIMARY KEY, 
     	nom VARCHAR(25) ,
     	noregion NUMERIC(1) NOT NULL
    ) ;

	 -- insertion des valeurs dans la table departement
--
INSERT INTO departement VALUES(10,'Finance',1);
INSERT INTO departement VALUES(20,'Atelier',2);
INSERT INTO departement VALUES(30,'Atelier',3);
INSERT INTO departement VALUES(31,'Vente',1);
INSERT INTO departement VALUES(32,'Vente',2);
INSERT INTO departement VALUES(33,'Vente',3);
INSERT INTO departement VALUES(34,'Vente',4);
INSERT INTO departement VALUES(35,'Vente',5);
INSERT INTO departement VALUES(41,'Distribution',1);
INSERT INTO departement VALUES(42,'Distribution',2);
INSERT INTO departement  VALUES(43,'Distribution',3);
INSERT INTO departement VALUES(44,'Distribution',4);
INSERT INTO departement VALUES(45,'Distribution',5);
INSERT INTO departement VALUES(50,'Administration',1);
--
-- création de la table employes
--
CREATE TABLE employes
     (
	   noemp NUMERIC(7) NOT NULL CONSTRAINT emp_noemp_pk PRIMARY KEY, 
	     nom VARCHAR(25),
      prenom VARCHAR(25),
      embauche DATE,
      nosupr NUMERIC(7),
      titre  VARCHAR(25),
      nodept NUMERIC(2) NOT NULL,
      salaire NUMERIC(11,2),
      tx_commission NUMERIC(4,2)
      CONSTRAINT emp_tx_commission_ck CHECK (tx_commission BETWEEN 10 AND 20)
     );


-- insertion des valeurs dans la table employes
--
INSERT INTO employes VALUES(1,'Patamob','Adhémar','2000-03-26',NULL,'President',50,50000);
INSERT INTO employes VALUES(2,'Zeublouze','Agathe','2000-04-15',1,'Dir. Distrib',41,35000);
INSERT INTO employes VALUES(3,'Kuzbidon','Alex','2000-05-05',1,'Dir. Vente',31,34000);
INSERT INTO employes VALUES(4,'Locale','Anasthasie','2000-05-25',1,'Dir. Finance',10,36000);
INSERT INTO employes VALUES(5,'Teutmaronne','Armand','2000-06-14',1,'Dir. Administr',50,36000);
INSERT INTO employes VALUES(6,'Zoudanlkou','Debbie','2000-07-04',2,'Chef Entrepôt',41,25000);
INSERT INTO employes VALUES(7,'Rivenbusse','Elsa','2000-07-24',2,'Chef Entrepôt',42,24000);
INSERT INTO employes VALUES(8,'Ardelpic','Helmut','2000-08-13',2,'Chef Entrepôt',43,23000);
INSERT INTO employes VALUES(9,'Peursconla','Humphrey','2000-09-02',2,'Chef Entrepôt',44,22000);
INSERT INTO employes VALUES(10,'Vrante','Héléna','2000-09-22',2,'Chef Entrepôt',45,21000);
INSERT INTO employes VALUES(11,'Enfaillite','Mélusine','2000-10-12',3,'Représentant',31,25000,10);
INSERT INTO employes VALUES(12,'Eurktumeme','Odile','2000-11-01',3,'Représentant',32,26000,12.5);
INSERT INTO employes VALUES(13,'Hotdeugou','Olaf','2000-11-21',3,'Représentant',33,27000,10);
INSERT INTO employes VALUES(14,'Odlavieille','Pacôme','2000-12-11',3,'Représentant',34,25500,15);
INSERT INTO employes VALUES(15,'Amartakaldire','Quentin','2000-12-31',3,'Représentant',35,23000,17.5);
INSERT INTO employes VALUES(16,'Traibien','Samira','2001-01-10',6,'Secrétaire',41,15000);
INSERT INTO employes VALUES(17,'Fonfec','Sophie','2001-01-20',6,'Secrétaire',41,14000);
INSERT INTO employes VALUES(18,'Fairant','Teddy','2001-02-09',7,'Secrétaire',42,13000);
INSERT INTO employes VALUES(19,'Blaireur','Terry','2001-02-09',7,'Secrétaire',42,13000);
INSERT INTO employes VALUES(20,'Ajerre','Tex','2001-02-19',8,'Secrétaire',43,13000);
INSERT INTO employes VALUES(21,'Chmonfisse','Thierry','2001-02-19',8,'Secrétaire',43,12000);
INSERT INTO employes VALUES(22,'Phototetedemort','Thomas','2001-03-01',9,'Secrétaire',44,22500);
INSERT INTO employes VALUES(23,'Kaécouté','Xavier','2001-03-11',9,'Secrétaire',34,11500);
INSERT INTO employes VALUES(24,'Adrouille-Toultan','Yves','2001-03-21',10,'Secrétaire',45,11000);
INSERT INTO employes VALUES(25,'Anchier','Yvon','2001-12-31',10,'Secrétaire',45,10000);

 
	 
--
-- Ajout des contrainte de clés étrangéres
--

-- clé étrangére de la table employes vers la table departement
--
	ALTER TABLE employes
		ADD CONSTRAINT emp_nodept_fk FOREIGN KEY(nodept) REFERENCES departement(nodept);

-- clé étrangére de la table employes vers elle même (création de l'association réflexive)
--
	ALTER TABLE employes
		ADD CONSTRAINT emp_nosupr_fk FOREIGN KEY(nosupr) REFERENCES employes(noemp);