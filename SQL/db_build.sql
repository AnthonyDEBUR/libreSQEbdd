/*
Code TO build db_libreSQL
*/

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
----------------------------------------
-- creation des tables referentielles
----------------------------------------
DROP TABLE IF EXISTS refer.tr_intervenantsandre_isa CASCADE;
CREATE TABLE refer.tr_intervenantsandre_isa(
isa_codesandre TEXT PRIMARY KEY,
isa_nom TEXT,
isa_statut TEXT,
isa_datecreation date,
isa_datemaj date,
--isa_auteur,
isa_mnemo TEXT,
isa_ensembleimmobilier TEXT,
isa_bp TEXT,
isa_rue TEXT,
isa_lieudit TEXT,
isa_ville TEXT,
isa_departementpays TEXT,
isa_codepostal INTEGER
);

ALTER TABLE refer.tr_intervenantsandre_isa OWNER TO grp_eptbv_planif_dba;

-- indexation des noms d'intervenants
CREATE INDEX tr_intervenantsandre_isa_nom_key ON refer.tr_intervenantsandre_isa USING btree (isa_nom);


-- test

CREATE TABLE refer.tr_prestataire_pre(
pre_id serial PRIMARY KEY,
pre_nom TEXT,
pre_siret TEXT,
pre_isa_codesandre TEXT,
CONSTRAINT c_fk_pre_codesandre FOREIGN KEY (pre_isa_codesandre) 
REFERENCES refer.tr_intervenantsandre_isa(isa_codesandre) 
ON DELETE RESTRICT ON UPDATE CASCADE
);

ALTER TABLE refer.tr_prestataire_pre OWNER TO grp_eptbv_planif_dba;


CREATE TABLE refer.tr_perimetre_per(
per_nom TEXT PRIMARY KEY,
per_description TEXT,
per_entite_gestionaire TEXT,
per_geom geometry
);

ALTER TABLE refer.tr_perimetre_per OWNER TO grp_eptbv_planif_dba;

INSERT INTO refer.tr_perimetre_per(per_nom, per_description, per_entite_gestionaire)
VALUES  ('UGVA', 'Unité gestion Vilaine Aval', 'UGVA');
INSERT INTO refer.tr_perimetre_per(per_nom, per_description, per_entite_gestionaire)
VALUES  ('UGVE', 'Unité gestion Vilaine Est', 'UGVE');
INSERT INTO refer.tr_perimetre_per(per_nom, per_description, per_entite_gestionaire)
VALUES  ('UGVO', 'Unité gestion Vilaine Ouest', 'UGVO');
INSERT INTO refer.tr_perimetre_per(per_nom, per_description, per_entite_gestionaire)
VALUES  ('UGVE_PONT_BILLON', 'Unité gestion Vilaine Est - suivi spécifique captage de Pont-Billon', 'UGVE');
INSERT INTO refer.tr_perimetre_per(per_nom, per_description, per_entite_gestionaire)
VALUES  ('UGVE_VALIERE', 'Unité gestion Vilaine Est - suivi spécifique captage de la Valière', 'UGVE');
INSERT INTO refer.tr_perimetre_per(per_nom, per_description, per_entite_gestionaire)
VALUES  ('UGVO - IIF', 'Unité gestion Vilaine Ouest - suivi spécifique bassin Ille-Illet et Flume', 'UGVO');
INSERT INTO refer.tr_perimetre_per(per_nom, per_description, per_entite_gestionaire)
VALUES  ('UGVO - VHBC', 'Unité gestion Vilaine Est - suivi spécifique territoire de Vallons de Haute-Bretagne Communauté', 'UGVO');






/*
 * EXEMPLE UUID
 */
/*
DROP TABLE IF EXISTS TEST;
CREATE TABLE test(
mar_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
mar_text TEXT
)

INSERT INTO TEST(mar_text) VALUES ('toto');
SELECT * FROM TEST
*/
----------------------------------------
-- creation des tables relatives au marché
----------------------------------------

DROP TABLE IF EXISTS sqe.t_marche_mar CASCADE;
CREATE TABLE sqe.t_marche_mar(
mar_id serial PRIMARY KEY,
mar_pre_id TEXT, -- Titulaire du marché.
mar_reference TEXT, -- référence du marché
mar_nom TEXT UNIQUE, -- nom du marché
mar_nom_long TEXT, -- libellé long du marché
mar_montantmin NUMERIC,
mar_montantmax NUMERIC,
mar_datedebut DATE, -- date début validité marché (date premier prélèvement)
mar_datefin DATE,-- date fin validité marché (date premier prélèvement)
mar_statut TEXT,
CONSTRAINT c_fk_mar_pre_id FOREIGN KEY (mar_pre_id) REFERENCES refer.tr_prestataire_pre(pre_id) ON UPDATE CASCADE ON DELETE RESTRICT,
-- CONSTRAINT c_fk_mar_per_nom FOREIGN KEY (mar_per_nom) REFERENCES refer.tr_perimetre_per (per_nom) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_ck_mar_statut CHECK (mar_statut='En cours' OR mar_statut='Terminé'),
CONSTRAINT c_ck_mar_datefin CHECK (mar_datefin > mar_datedebut)
);


/*
-- COMMENT CHANGER LA CONTRAINTE

ALTER TABLE DROP CONSTRAINT c_ck_mar_statut ;
ALTER TABLE ADD CONSTRAINT c_ck_mar_statut ....

ALTER TABLE  sqe.t_marche_mar DROP CONSTRAINT c_fk_mar_per_nom;



*/


COMMENT ON TABLE sqe.t_marche_mar IS 'Table des marchés';
COMMENT ON COLUMN sqe.t_marche_mar.mar_pre_id IS 'Identifiant du prestataire titulaire du marché';
COMMENT ON COLUMN sqe.t_marche_mar.mar_datedebut IS 'Date début de marché (i.e. date à partir de laquelle on peut prélever)';
COMMENT ON COLUMN sqe.t_marche_mar.mar_datefin IS 'Date fin de marché (i.e. date jusqu à laquelle on peut prélever)';
COMMENT ON COLUMN sqe.t_marche_mar.mar_reference IS 'Référence du marché';
COMMENT ON COLUMN sqe.t_marche_mar.mar_statut IS 'Statut du marché (En cours ou Terminé)';
COMMENT ON COLUMN sqe.t_marche_mar.mar_nom IS 'Nom du marché (unique)';
COMMENT ON COLUMN sqe.t_marche_mar.mar_nom_long IS 'Nom long du marché (pour titre des bons de commandes)';

ALTER TABLE sqe.t_marche_mar OWNER TO grp_eptbv_planif_dba;

----------------------------------------
-- creation de la table de jointure marché / périmètres de gestion 
----------------------------------------

DROP TABLE IF EXISTS sqe.tj_marche_perimetre_map CASCADE;
CREATE TABLE sqe.tj_marche_perimetre_map(
map_mar_id INTEGER, -- Identifiant du marché
map_per_nom TEXT, -- Périmètre de gestion 
CONSTRAINT c_fk_map_mar_id FOREIGN KEY (map_mar_id) REFERENCES sqe.t_marche_mar (mar_id) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_map_per_nom FOREIGN KEY (map_per_nom) REFERENCES refer.tr_perimetre_per (per_nom) ON UPDATE CASCADE ON DELETE RESTRICT
);


ALTER TABLE sqe.tj_marche_perimetre_map OWNER TO grp_eptbv_planif_dba;




----------------------------------------
-- creation des tables relatives aux prestations 
----------------------------------------



----------------------------------------
-- creation des tables relatives aux prestations du marché
----------------------------------------
DROP TABLE IF EXISTS sqe.t_prestation_prs CASCADE;
CREATE TABLE sqe.t_prestation_prs(
prs_id serial PRIMARY KEY, -- identifiant de la prestation
prs_mar_id INTEGER, -- identifiant du marché
prs_pre_id INTEGER, -- identifiant du prestataire
prs_label_prestation TEXT, -- label (nom court) de la prestation
prs_nomprestation TEXT,
prs_natureprestation TEXT,
prm_unitedoeuvre TEXT,-- A VOIR SI UTILE
prs_idprestationdansbpu TEXT, 
CONSTRAINT  c_fk_prs_mar_id FOREIGN KEY (prs_mar_id) REFERENCES sqe.t_marche_mar(mar_id) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT  c_fk_prs_pre_id FOREIGN KEY (prs_pre_id) REFERENCES refer.tr_prestataire_pre(pre_id) ON UPDATE CASCADE ON DELETE CASCADE
);
COMMENT ON COLUMN sqe.t_prestation_prs.prs_pre_id IS 'Identifiant du prestataire, soit titulaire du marché soit sous traitant';
COMMENT ON COLUMN sqe.t_prestation_prs.prs_mar_id IS 'Identifiant marché';
COMMENT ON COLUMN sqe.t_prestation_prs.prs_id IS 'Identifiant de la prestation';
COMMENT ON COLUMN sqe.t_prestation_prs.prs_label_prestation IS 'Label (nom court) de la prestation';
COMMENT ON COLUMN sqe.t_prestation_prs.prs_idprestationdansbpu IS 'identifiant de la prestation dans le BPU';

ALTER TABLE sqe.t_prestation_prs OWNER TO grp_eptbv_planif_dba;

  
CREATE TABLE refer.tr_statutpresta_stp(
stp_nom TEXT PRIMARY KEY,
stp_description TEXT
);

INSERT INTO refer.tr_statutpresta_stp VALUES ('1-projet', 'Bon de commande prêt à être émis');
INSERT INTO refer.tr_statutpresta_stp VALUES ('2-à la signature', 'Bon de commande dans le circuit de signature');
INSERT INTO refer.tr_statutpresta_stp VALUES ('3-signé', 'Bon de commande signé, en attente de transmission au prestataire');
INSERT INTO refer.tr_statutpresta_stp VALUES ('4-émis', 'Bon de commande transmis au prestataire');
INSERT INTO refer.tr_statutpresta_stp VALUES ('Prélevé', 'Prélèvement fait');
INSERT INTO refer.tr_statutpresta_stp VALUES ('Analysé', 'Analyse rendue');
INSERT INTO refer.tr_statutpresta_stp VALUES ('Validé', 'Analyse validée');

-- DROP TABLE sqe.t_boncommande_bco CASCADE;
DROP TABLE IF EXISTS sqe.t_boncommande_bco CASCADE;
CREATE TABLE sqe.t_boncommande_bco(
bco_id serial PRIMARY KEY,
bco_mar_id INTEGER NOT NULL, --fk
-- bco_prs_id integer NOT NULL, 
bco_per_nom TEXT,
bco_refcommande TEXT NOT NULL,
bco_stp_nom TEXT, -- Statut
-- bco_date_prev DATE, -- Date prévisionnelle de la prestation 
bco_commentaires TEXT,
CONSTRAINT c_fk_bco_mar_id FOREIGN KEY (bco_mar_id) 
REFERENCES sqe.t_marche_mar (mar_id) ON UPDATE CASCADE ON DELETE CASCADE,
/*CONSTRAINT c_fk_bco_prs_id FOREIGN KEY (bco_prs_id) 
REFERENCES sqe.t_prestation_prs (prs_id) ON UPDATE CASCADE ON DELETE CASCADE,*/
CONSTRAINT c_fk_per_nom FOREIGN KEY (bco_per_nom) 
REFERENCES refer.tr_perimetre_per (per_nom) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_bco_stp_nom FOREIGN KEY (bco_stp_nom) 
REFERENCES refer.tr_statutpresta_stp (stp_nom) ON UPDATE CASCADE ON DELETE RESTRICT
);
COMMENT ON COLUMN sqe.t_boncommande_bco.bco_per_nom IS 'Périmètre du bon de commande (ex territoireX_projetY';
COMMENT ON COLUMN sqe.t_boncommande_bco.bco_refcommande IS 'Référence du bon de commande';
COMMENT ON COLUMN sqe.t_boncommande_bco.bco_stp_nom IS 'Statut du bon de commande';
-- COMMENT ON COLUMN sqe.t_boncommande_bco.bco_date_prev IS 'Date prévisionnelle de la prestation';


-- VERIFIE QUE LA PRESTATION EXISTE BIEN DANS LE MARCHE
/* CREATE OR REPLACE FUNCTION sqe.checkexistebco_prs_id()
 RETURNS trigger
 LANGUAGE plpgsql
 AS $function$   

 DECLARE nbexistecal  INTEGER    ;
 
  BEGIN
   
    -- verification des non-chevauchements pour les operations du dispositif
    SELECT count(*) INTO nbexistecal 
    FROM   sqe.t_prestation_prs
    WHERE  prs_id = NEW.bco_prs_id 
    AND    prs_mar_id = NEW.bco_mar_id
    ;

    -- Comme le trigger est declenche sur AFTER et non pas sur BEFORE, il faut (nbChevauchements > 1) et non pas >0, car l enregistrement a deja ete ajoute, donc il se chevauche avec lui meme, ce qui est normal !
    IF (nbexistecal = 0) THEN 
      RAISE EXCEPTION 'Le type de prestation à ajouter dans la table t_boncommande_quantitatif_bcq n''existe pas dans la table t_boncommande_bco pour le bon de commande sélectionné'  ;
    END IF  ;

    RETURN NEW ;
  END  ;
$function$;

CREATE TRIGGER checkexistebco_prs_id AFTER INSERT OR UPDATE ON 
    sqe.t_boncommande_bco FOR EACH ROW EXECUTE FUNCTION  sqe.checkexistebco_prs_id();
*/

/* quantitatif bdc */
DROP TABLE IF EXISTS sqe.t_boncommande_quantitatif_bcq CASCADE; 
CREATE TABLE sqe.t_boncommande_quantitatif_bcq(
bcq_bco_id INTEGER, -- fk
bcq_prs_id INTEGER, 
bcq_nbprestacom NUMERIC,
bcq_nbprestareal NUMERIC,
CONSTRAINT c_fk_bcq_bco_id FOREIGN KEY (bcq_bco_id) 
REFERENCES sqe.t_boncommande_bco (bco_id) ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON COLUMN sqe.t_boncommande_quantitatif_bcq.bcq_nbprestacom IS 'Nombre de prestations commandées';
COMMENT ON COLUMN sqe.t_boncommande_quantitatif_bcq.bcq_nbprestareal IS 'Nombre de prestations réalisées';

/* prog bdc : programme du bon de commande */
DROP TABLE IF EXISTS sqe.t_boncommande_pgm_bcp CASCADE;
CREATE TABLE sqe.t_boncommande_pgm_bcp(
bcp_bco_id INTEGER, -- fk
bcp_prs_id INTEGER, -- id de la prestation
bcp_dateinterv DATE, -- date prévisionnelle d'intervention
bcp_stm_cdstationmesureinterne TEXT, --fk
CONSTRAINT c_fk_bcp_bco_id FOREIGN KEY (bcp_bco_id) 
REFERENCES sqe.t_boncommande_bco (bco_id) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT c_fk_bcp_prs_id FOREIGN KEY (bcp_prs_id) 
REFERENCES sqe.t_prestation_prs (prs_id) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT c_fk_bcp_stm_cdstationmesureinterne FOREIGN KEY (bcp_stm_cdstationmesureinterne) 
REFERENCES refer.tr_stationmesure_stm (stm_cdstationmesureinterne) ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON COLUMN sqe.t_boncommande_pgm_bcp.bcp_prs_id IS 'id de la prestation';
COMMENT ON COLUMN sqe.t_boncommande_pgm_bcp.bcp_dateinterv IS 'date prévisionnelle d''intervention';




/*
 * programme type
 * 
 */

CREATE TABLE refer.tr_parametre_par(
par_cdparametre TEXT PRIMARY KEY,
par_nomparametre TEXT,
par_statutparametre TEXT,
par_nomcourt TEXT,
par_codecas TEXT,
par_codesandre TEXT,
par_codetemporaire TEXT
);
-- indexation des noms de paramtres
CREATE INDEX tr_parametre_par_nom_key ON refer.tr_parametre_par USING btree (par_nomparametre);
COMMENT ON COLUMN refer.tr_parametre_par.par_cdparametre IS 'code du paramètre interne à libreSQE (cdSandre ou cdTemporaire)';
COMMENT ON COLUMN refer.tr_parametre_par.par_codesandre IS 'code sandre du paramètre';
COMMENT ON COLUMN refer.tr_parametre_par.par_codetemporaire IS 'code temporaire du paramètre';


CREATE TABLE refer.tr_uniteparametre_uni(
uni_codesandreunite TEXT PRIMARY KEY,
uni_symbole TEXT,
uni_lblsandreunite TEXT
);

CREATE TABLE refer.tr_fraction_fra(
fra_codefraction TEXT PRIMARY KEY,
fra_nomfraction TEXT
);

CREATE TABLE refer.tr_methode_met(
met_code TEXT PRIMARY KEY,
met_nom TEXT,
met_statut TEXT
);


CREATE TABLE sqe.t_runanalytique_run(
run_id serial PRIMARY KEY,
run_nom TEXT,
run_met_code TEXT, -- FOREIGN KEY methode sandre
run_prestataire INTEGER, -- FOREIGN KEY prestataire_id 
CONSTRAINT c_fk_run_met_code FOREIGN KEY (run_met_code) 
REFERENCES refer.tr_methode_met  (met_code) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_run_prestataire FOREIGN KEY (run_prestataire) 
REFERENCES refer.tr_prestataire_pre (pre_id) ON UPDATE CASCADE ON DELETE RESTRICT
);
COMMENT ON COLUMN sqe.t_runanalytique_run.run_nom IS 'Nom du run analytique';
COMMENT ON COLUMN sqe.t_runanalytique_run.run_met_code IS 'Code SANDRE méthode du run analytique';
COMMENT ON COLUMN sqe.t_runanalytique_run.run_prestataire IS 'Identifiant du prestataire en charge de l''analyse du run analytique';


/*
 * Un programme type est un ensemble de run analytiques
 * 
 */
DROP TABLE IF EXISTS sqe.t_parametreprogrammetype_ppt;
CREATE TABLE sqe.t_parametreprogrammetype_ppt(
ppt_id serial PRIMARY KEY,
ppt_prs_id INTEGER, -- Identifiant de la prestation
ppt_mar_id INTEGER NOT NULL,
ppt_run_id INTEGER, --FK t_runanalytique_run. Un paramètre peut être analysé par plusieurs run analytiques différents au sein d'un programme type
ppt_par_cdparametre TEXT NOT NULL, -- code LIBRESQE du paramètre (clé étrangère)
ppt_fra_codefraction TEXT NOT NULL,
ppt_nomparametre TEXT,
ppt_uni_codesandreunite TEXT NOT NULL,
ppt_met_codesandremethode TEXT,
ppt_pre_id INTEGER, -- Id du prestataire en charge de l'analyse
ppt_analyseinsitu BOOLEAN,
ppt_limitedetec NUMERIC, -- limite de détection garantie par le prestataire
ppt_limitequantif NUMERIC, -- limite garantie par le prestataire
ppt_incertitude NUMERIC,  -- incertitude garantie par le prestataire
ppt_accreditation BOOLEAN, --Accreditation du prestataire 
ppt_commentaireparametre TEXT, -- Commentaire sur le paramètre du prestataire dans le marché en cours
CONSTRAINT c_fk_ppt_prs_id FOREIGN KEY (ppt_prs_id) 
REFERENCES sqe.t_prestation_prs  (prs_id) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT c_fk_ppt_mar_id FOREIGN KEY (ppt_mar_id) 
REFERENCES sqe.t_marche_mar  (mar_id) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT c_fk_ppt_par_cdparametre FOREIGN KEY (ppt_par_cdparametre) 
REFERENCES refer.tr_parametre_par (par_cdparametre) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_ppt_uni_codesandreunite FOREIGN KEY (ppt_uni_codesandreunite) 
REFERENCES refer.tr_uniteparametre_uni (uni_codesandreunite) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_ppt_fra_codefraction FOREIGN KEY (ppt_fra_codefraction) 
REFERENCES refer.tr_fraction_fra (fra_codefraction) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_ppt_fra_codemethode FOREIGN KEY (ppt_met_codesandremethode) 
REFERENCES refer.tr_methode_met (met_code) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_ppt_pre_id FOREIGN KEY (ppt_pre_id) 
REFERENCES refer.tr_prestataire_pre (pre_id) ON UPDATE CASCADE ON DELETE CASCADE);

COMMENT ON COLUMN sqe.t_parametreprogrammetype_ppt.ppt_prs_id IS 'Identifiant de la prestation';
COMMENT ON COLUMN sqe.t_parametreprogrammetype_ppt.ppt_par_cdparametre IS 'Code SANDRE ou temporaire du paramètre (clé étrangère)';
COMMENT ON COLUMN sqe.t_parametreprogrammetype_ppt.ppt_limitedetec IS 'Limite de détection garantie par le prestataire';
COMMENT ON COLUMN sqe.t_parametreprogrammetype_ppt.ppt_limitequantif IS 'Limite de quantification garantie par le prestataire';
COMMENT ON COLUMN sqe.t_parametreprogrammetype_ppt.ppt_incertitude IS 'Code temporaire en attente de code SANDRE';
COMMENT ON COLUMN sqe.t_parametreprogrammetype_ppt.ppt_accreditation IS 'Accreditation du prestataire ';
COMMENT ON COLUMN sqe.t_parametreprogrammetype_ppt.ppt_commentaireparametre IS 'Commentaire sur le paramètre du prestataire dans le marché en cours';
COMMENT ON COLUMN sqe.t_parametreprogrammetype_ppt.ppt_run_id IS 'FK t_runanalytique_run. Un paramètre peut être analysé par plusieurs run analytiques différents au sein d''un programme type';
COMMENT ON COLUMN sqe.t_parametreprogrammetype_ppt.ppt_met_codesandremethode IS 'Code méthode SANDRE';
COMMENT ON COLUMN sqe.t_parametreprogrammetype_ppt.ppt_pre_id IS 'id du prestataire en charge de l''analyse';


/*
 * 
 * Table des prix unitaires : prix des prestations de type programme type, mais aussi les réunion,
 * flaconnage, prélèvements. Dans les prix d'analyse d'un programme type on commande des run analytiques, si un run analytique 
 * est incomplet il faudra enlever le prix du run analytique manquant 
 * 
*/

DROP TABLE IF EXISTS sqe.t_prixunitaire_pru CASCADE;
CREATE TABLE sqe.t_prixunitaire_pru(
pru_id serial PRIMARY KEY,
pru_datedebut DATE,
pru_datefin DATE,
pru_valeur NUMERIC, 
CONSTRAINT c_ck_pru_datefin CHECK (pru_datefin > pru_datedebut)
);

COMMENT ON COLUMN sqe.t_prixunitaire_pru.pru_datedebut IS 'Date de début de la validité du prix';
COMMENT ON COLUMN sqe.t_prixunitaire_pru.pru_datefin IS 'Date de fin de la validité du prix';

-- table héritée éléments du marché flacon, réunion ....
DROP TABLE IF EXISTS sqe.t_prixunitaireprestation_prp CASCADE;
CREATE TABLE sqe.t_prixunitaireprestation_prp (
prp_prs_id INTEGER,
CONSTRAINT  c_fk_prp_prs_id FOREIGN KEY (prp_prs_id) 
REFERENCES sqe.t_prestation_prs(prs_id) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT c_ck_pru_datefin CHECK (pru_datefin > pru_datedebut)
)INHERITS (sqe.t_prixunitaire_pru) ;

DROP TABLE IF EXISTS sqe.t_prixunitairerunanalytique_prr CASCADE;
CREATE TABLE sqe.t_prixunitairerunanalytique_prr (
prr_mar_id INTEGER,
prr_run_id INTEGER,
CONSTRAINT  c_fk_prr_mar_id FOREIGN KEY (prr_mar_id) 
REFERENCES sqe.t_marche_mar (mar_id) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT c_fk_prr_run_id FOREIGN KEY (prr_run_id) 
REFERENCES sqe.t_runanalytique_run (run_id) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT c_ck_pru_datefin CHECK (pru_datefin > pru_datedebut)
)INHERITS (sqe.t_prixunitaire_pru) ;


CREATE OR REPLACE FUNCTION sqe.checkoverlapsprixunitaire()
 RETURNS trigger
 LANGUAGE plpgsql
 AS $function$   

  DECLARE nbChevauchements  INTEGER    ;

  BEGIN

    -- verification des non-chevauchements pour les operations du dispositif
    SELECT COUNT(*) INTO nbChevauchements
    FROM   sqe.t_prixunitaire_pru
    WHERE  pru_id = NEW.pru_id 
           AND (pru_datedebut, pru_datefin) OVERLAPS (NEW.pru_datedebut, NEW.pru_datefin)
    ;

    -- Comme le trigger est declenche sur AFTER et non pas sur BEFORE, il faut (nbChevauchements > 1) et non pas >0, car l enregistrement a deja ete ajoute, donc il se chevauche avec lui meme, ce qui est normal !
    IF (nbChevauchements > 1) THEN 
      RAISE EXCEPTION 'Il est impossible d''avoir plusieurs prix unitaires pour une même date'  ;
    END IF  ;

    RETURN NEW ;
  END  ;
$function$;

CREATE TRIGGER update_pru  AFTER INSERT OR UPDATE ON 
    sqe.t_prixunitaire_pru FOR EACH ROW EXECUTE FUNCTION sqe.checkoverlapsprixunitaire();

CREATE TRIGGER update_prp  AFTER INSERT OR UPDATE ON 
    sqe.t_prixunitaireprestation_prp FOR EACH ROW EXECUTE FUNCTION sqe.checkoverlapsprixunitaire();
  
CREATE TRIGGER update_prr  AFTER INSERT OR UPDATE ON 
    sqe.t_prixunitairerunanalytique_prr FOR EACH ROW EXECUTE FUNCTION sqe.checkoverlapsprixunitaire();


   
-- table de suivi des mises à jour des tables du shéma sqe

CREATE TABLE sqe.ts_suivi_maj(
ts_table TEXT, -- nom de la table
ts_date DATE, -- Date de mise à jour de la base
ts_nom_referentiel TEXT -- Nom du référentiel SANDRE concerné
);  


CREATE TABLE sqe.ts_suivi_maj_sqe() INHERITS(sqe.ts_suivi_maj);  

CREATE TABLE sqe.ts_suivi_maj_refer() INHERITS(sqe.ts_suivi_maj); 

INSERT INTO sqe.ts_suivi_maj_refer
(ts_table, ts_date, ts_nom_referentiel)
VALUES('tr_fraction_fra', '1950-01-01', 'fractions');

INSERT INTO sqe.ts_suivi_maj_refer
(ts_table, ts_date, ts_nom_referentiel)
VALUES('tr_intervenantsandre_isa', '1950-01-01', 'intervenants');

INSERT INTO sqe.ts_suivi_maj_refer
(ts_table, ts_date, ts_nom_referentiel)
VALUES('tr_methode_met', '1950-01-01', 'méthodes');

INSERT INTO sqe.ts_suivi_maj_refer
(ts_table, ts_date, ts_nom_referentiel)
VALUES('tr_parametre_par', '1950-01-01', 'paramètres');

INSERT INTO sqe.ts_suivi_maj_refer
(ts_table, ts_date, ts_nom_referentiel)
VALUES('tr_uniteparametre_uni', '1950-01-01','unités');

INSERT INTO sqe.ts_suivi_maj_refer
(ts_table, ts_date, ts_nom_referentiel)
VALUES('tr_rdd_rdd', '1950-01-01','dispositifs de collecte');

INSERT INTO sqe.ts_suivi_maj_refer
(ts_table, ts_date, ts_nom_referentiel)
VALUES('tr_stationmesure_stm', '1950-01-01', 'stations de mesures');

-- trigger for refer ts_suivi_maj_refer()
/* permet d'acualiser la date de dernière mise à jour d'une table du schéma réfer
 * dans la table sqe.ts_suivi_maj_refer
 */ 
CREATE OR REPLACE FUNCTION sqe.fn_update_date_refer() RETURNS TRIGGER AS
$$
DECLARE
        sql TEXT;
BEGIN
  sql := format('UPDATE sqe.ts_suivi_maj_refer SET ts_date =now()::date WHERE ts_table = ''%s''', TG_ARGV[0]);
    EXECUTE sql USING NEW;
    RETURN new;
END;
$$
language plpgsql;

-- trigger for sqe ts_suivi_maj_sqe()

CREATE OR REPLACE FUNCTION sqe.fn_update_date_sqe() RETURNS TRIGGER AS
$$
DECLARE
        sql TEXT;
BEGIN
  sql := format('UPDATE sqe.ts_suivi_maj_sqe SET  ts_date = now()::date 
              WHERE ts_table=''%s''', TG_ARGV[0]);
    EXECUTE sql USING NEW;
    RETURN new;
END;
$$
language plpgsql;

-- met a jour automatiquement le suivi de la date d'actualisation de la table tr_fraction_fra
-- Le Trigger un à créer par table (ici exemple tr_fraction_fra

DROP TRIGGER IF EXISTS trg_date_tr_fraction_fra ON refer.tr_fraction_fra;
CREATE OR REPLACE TRIGGER trg_date_tr_fraction_fra
     AFTER INSERT OR UPDATE ON refer.tr_fraction_fra
     FOR EACH ROW
     EXECUTE PROCEDURE sqe.fn_update_date_refer("tr_fraction_fra");


DROP TRIGGER IF EXISTS trg_date_tr_intervenantsandre_isa ON refer.tr_intervenantsandre_isa;
CREATE OR REPLACE TRIGGER trg_date_tr_intervenantsandre_isa
     AFTER INSERT OR UPDATE ON refer.tr_intervenantsandre_isa
     FOR EACH ROW
     EXECUTE PROCEDURE sqe.fn_update_date_refer("tr_intervenantsandre_isa");    
    
DROP TRIGGER IF EXISTS trg_date_tr_methode_met ON refer.tr_methode_met;
CREATE OR REPLACE TRIGGER trg_date_tr_methode_met
     AFTER INSERT OR UPDATE ON refer.tr_methode_met
     FOR EACH ROW
     EXECUTE PROCEDURE sqe.fn_update_date_refer("tr_methode_met");       
    
DROP TRIGGER IF EXISTS trg_date_tr_parametre_par ON refer.tr_parametre_par;
CREATE OR REPLACE TRIGGER trg_date_tr_parametre_par
     AFTER INSERT OR UPDATE ON refer.tr_parametre_par
     FOR EACH ROW
     EXECUTE PROCEDURE sqe.fn_update_date_refer("tr_parametre_par");           
    
DROP TRIGGER IF EXISTS trg_date_tr_uniteparametre_uni ON refer.tr_uniteparametre_uni;
CREATE OR REPLACE TRIGGER trg_date_tr_uniteparametre_uni
     AFTER INSERT OR UPDATE ON refer.tr_uniteparametre_uni
     FOR EACH ROW
     EXECUTE PROCEDURE sqe.fn_update_date_refer("tr_uniteparametre_uni");
    
DROP TRIGGER IF EXISTS trg_date_tr_rdd_rdd ON refer.tr_rdd_rdd;
CREATE OR REPLACE TRIGGER trg_date_tr_rdd_rdd
     AFTER INSERT OR UPDATE ON refer.tr_rdd_rdd
     FOR EACH ROW
     EXECUTE PROCEDURE sqe.fn_update_date_refer("tr_rdd_rdd");    

DROP TRIGGER IF EXISTS trg_date_tr_stationmesure_stm ON refer.tr_stationmesure_stm;
CREATE OR REPLACE TRIGGER trg_date_tr_stationmesure_stm
     AFTER INSERT OR UPDATE ON refer.tr_stationmesure_stm
     FOR EACH ROW
     EXECUTE PROCEDURE sqe.fn_update_date_refer("tr_stationmesure_stm");        
    
/*   
INSERT INTO refer.tr_fraction_fra(fra_codefraction, fra_nomfraction)
VALUES('titi5', 'toto5');
 */  
   
-- SELECT FORMAT('UPDATE sqe.ts_suivi_maj_refer SET (ts_table, ts_date) =(''%I'', now()::date)', 'tr_fraction_fra')



CREATE TABLE sqe.t_realisationcommande_rec(
rec_id serial PRIMARY KEY,
rec_prs_id INTEGER,
rec_bco_id INTEGER, -- identifiant du bon de commande est-ce utile la prestation est liée à un bon de commande (auquel cas il faut mettre non nul)?
rec_dateprevi DATE,
rec_daterealisation DATE,
CONSTRAINT c_fk_rec_prs_id FOREIGN KEY (rec_prs_id) REFERENCES sqe.t_prestation_prs(prs_id) ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON COLUMN sqe.t_realisationcommande_rec.rec_prs_id IS 'clé étrangère, identifiant de la prestation';


CREATE TABLE sqe.t_realisationcommandeprel_rep() INHERITS (sqe.t_realisationcommande_rec);
CREATE TABLE  sqe.t_realisationcommandeautre_rea() INHERITS (sqe.t_realisationcommande_rec);

CREATE TABLE refer.tr_stationmesure_stm(
  stm_cdstationmesureauxsurface TEXT, 
  stm_cdstationmesureinterne TEXT,
  stm_memoirecodeprovisoire TEXT,
  stm_lbstationmesureeauxsurface TEXT,
  stm_x NUMERIC,
  stm_y NUMERIC,
  stm_commentaires TEXT,
  geom geometry,
  CONSTRAINT c_uk_stm_cdstationmesureinterne PRIMARY KEY (stm_cdstationmesureinterne)
 );

 -- indexation des noms de stations et des codes internes
CREATE INDEX tr_stationmesure_stm_nom_key ON refer.tr_stationmesure_stm USING btree (stm_lbstationmesureeauxsurface);
 

CREATE TABLE refer.tr_statutanalyse_san(
san_cdstatutana INTEGER PRIMARY KEY,
san_mnemostatutana TEXT NOT NULL);

INSERT INTO refer.tr_statutanalyse_san(san_cdstatutana, san_mnemostatutana)
VALUES  ('1', 'Donnée brute');

INSERT INTO refer.tr_statutanalyse_san(san_cdstatutana, san_mnemostatutana)
VALUES  ('2', 'Niveau 1');

INSERT INTO refer.tr_statutanalyse_san(san_cdstatutana, san_mnemostatutana)
VALUES  ('3', 'Niveau 2');

INSERT INTO refer.tr_statutanalyse_san(san_cdstatutana, san_mnemostatutana)
VALUES  ('4', 'Donnée interprétée');

/*

 Code	!  Mnémonique               !  Libellé
----------------------------------------------------------------------
    1	!  Donnée brute             !  Donnée brute
    2	!  Niveau 1                 !  Donnée contrôlée niveau 1 (données contrôlées)
    3	!  Niveau 2                 !  Donnée contrôlée niveau 2 (données validées)
    4	!  Donnée interprétée       !  Donnée interprétée
    
  */
      
CREATE TABLE refer.tr_rdd_rdd(
rdd_cdrdd TEXT PRIMARY KEY,
rdd_nomrdd TEXT NOT NULL,
rdd_statut TEXT);
COMMENT ON TABLE refer.tr_rdd_rdd IS 'Réseau de mesure - dispositif de collecte';

-- indexation des noms de réseaux
CREATE INDEX tr_rdd_rdd_nom_key ON refer.tr_rdd_rdd USING btree (rdd_nomrdd);


CREATE TABLE refer.tr_qualificationana_qal(
qal_code INTEGER PRIMARY KEY,
qal_mnemo TEXT,
qal_libelle TEXT);
COMMENT ON TABLE refer.tr_rdd_rdd IS 'Code des qualifications d''analyse';

INSERT INTO refer.tr_qualificationana_qal
(qal_code, qal_mnemo, qal_libelle)
VALUES(0, 'non définissable', 'Qualification non définissable');

INSERT INTO refer.tr_qualificationana_qal
(qal_code, qal_mnemo, qal_libelle)
VALUES(1, 'Correcte', 'Correcte');

INSERT INTO refer.tr_qualificationana_qal
(qal_code, qal_mnemo, qal_libelle)
VALUES(2, 'Incorrecte', 'Incorrecte');

INSERT INTO refer.tr_qualificationana_qal
(qal_code, qal_mnemo, qal_libelle)
VALUES(3, 'Incertaine', 'Incertaine');

INSERT INTO refer.tr_qualificationana_qal
(qal_code, qal_mnemo, qal_libelle)
VALUES(4, 'Non qualifié', 'Non qualifié');


/*
 * Pour chaque station à quelle date on va faire des prélèvements
 */
DROP TABLE sqe.t_calendrierprog_cal;
CREATE TABLE sqe.t_calendrierprog_cal(
cal_refannee TEXT, -- annee ou période de référence
cal_mar_id INTEGER ,
cal_typestation TEXT NOT NULL,
cal_date DATE, -- date prévisionnelle d'intervention
cal_prs_id INTEGER,-- id de la prestation (ie. nom du prog type)
cal_rattachement_bdc TEXT NOT NULL, -- pour grouper les bons de commande d'un même périmètre de gestion
CONSTRAINT c_fk_cal_mar_id FOREIGN KEY (cal_mar_id) REFERENCES 
 sqe.t_marche_mar (mar_id) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_cal_prs_id FOREIGN KEY (cal_prs_id) REFERENCES 
 sqe.t_prestation_prs (prs_id) ON UPDATE CASCADE ON DELETE RESTRICT);

COMMENT ON COLUMN sqe.t_calendrierprog_cal.cal_refannee IS 'Annee ou période de référence';
COMMENT ON COLUMN sqe.t_calendrierprog_cal.cal_mar_id IS 'Identifiant du marché';
COMMENT ON COLUMN sqe.t_calendrierprog_cal.cal_typestation IS 'Typologie de la station';
COMMENT ON COLUMN sqe.t_calendrierprog_cal.cal_date IS 'Date d intervention';
COMMENT ON COLUMN sqe.t_calendrierprog_cal.cal_prs_id IS 'Id de la prestation';



/*
 * Liée à la table précédente. Pour telle station de mesure je mets en oeuvre tel type de programme.
 * tableaux excels faits avec les unités.
 */
DROP TABLE sqe.t_progannuelle_pga;
CREATE TABLE sqe.t_progannuelle_pga(
pga_cal_refannee TEXT, -- référence année
pga_mar_id INTEGER, -- id marché
pga_per_nom TEXT, -- périmètre de gestion ou de facturation
pga_cal_typestation TEXT, -- type de station conforme au calendrier
pga_stm_cdstationmesureauxsurface TEXT,
pga_stm_cdstationmesureinterne TEXT,
CONSTRAINT c_fk_pga_stm_cdstationmesureauxsurface FOREIGN KEY (pga_stm_cdstationmesureauxsurface) REFERENCES 
 refer.tr_stationmesure_stm (stm_cdstationmesureauxsurface) ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT c_fk_pga_stm_cdstationmesureinterne FOREIGN KEY (pga_stm_cdstationmesureinterne) REFERENCES 
 refer.tr_stationmesure_stm (stm_cdstationmesureinterne) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT c_fk_pga_mar_id FOREIGN KEY (pga_mar_id) REFERENCES 
 sqe.t_marche_mar (mar_id) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_pga_per_nom FOREIGN KEY (pga_per_nom) REFERENCES 
 refer.tr_perimetre_per  (per_nom) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_ck_nn_uncoderenseignestation CHECK (pga_stm_cdstationmesureauxsurface IS NOT NULL  
OR pga_stm_cdstationmesureinterne IS  NOT NULL) 
); -- il faut soit un code sandre soit un code sandre temporaire

COMMENT ON COLUMN sqe.t_progannuelle_pga.pga_cal_refannee IS 'Annee ou période de référence';
COMMENT ON COLUMN sqe.t_progannuelle_pga.pga_mar_id IS 'Identifiant du marché';
COMMENT ON COLUMN sqe.t_progannuelle_pga.pga_cal_typestation IS 'Typologie de la station';
COMMENT ON COLUMN sqe.t_progannuelle_pga.pga_per_nom IS 'Périmètre de gestion (ou de facturation)';
COMMENT ON COLUMN sqe.t_progannuelle_pga.pga_stm_cdstationmesureauxsurface IS 'Code SANDRE de la station';
COMMENT ON COLUMN sqe.t_progannuelle_pga.pga_stm_cdstationmesureinterne IS 'Code provisoire de la station';

-- verif que l'année pga_cal_refannee existe dans cal_refannee (cal_refannee est du texte)


CREATE OR REPLACE FUNCTION sqe.checkexistecal_refannee()
 RETURNS trigger
 LANGUAGE plpgsql
 AS $function$   

 DECLARE nbexistecal  INTEGER    ;
 
  BEGIN
   
    -- verification des non-chevauchements pour les operations du dispositif
    SELECT count(*) INTO nbexistecal 
    FROM   sqe.t_calendrierprog_cal
    WHERE  cal_refannee = NEW.pga_cal_refannee            
    ;

    -- Comme le trigger est declenche sur AFTER et non pas sur BEFORE, il faut (nbChevauchements > 1) et non pas >0, car l enregistrement a deja ete ajoute, donc il se chevauche avec lui meme, ce qui est normal !
    IF (nbexistecal = 0) THEN 
      RAISE EXCEPTION 'L''année renseignée dans le programme annuel (pga_cal_refannee) n''existe pas dans le calendrier sqe.t_calendrierprog_cal(cal_refannee)'  ;
    END IF  ;

    RETURN NEW ;
  END  ;
$function$;

CREATE OR REPLACE TRIGGER checkexistecal_refannee AFTER INSERT OR UPDATE ON 
    sqe.t_progannuelle_pga FOR EACH ROW EXECUTE FUNCTION  sqe.checkexistecal_refannee();

-- VERIFIE QUE LE TYPE DE STATION EXISTE BIEN DANS LE CALENDRIER
 CREATE OR REPLACE FUNCTION sqe.checkexistepga_cal_typestation()
 RETURNS trigger
 LANGUAGE plpgsql
 AS $function$   

 DECLARE nbexistecal  INTEGER    ;
 
  BEGIN
   
    -- verification des non-chevauchements pour les operations du dispositif
    SELECT count(*) INTO nbexistecal 
    FROM   sqe.t_calendrierprog_cal
    WHERE  cal_typestation = NEW.pga_cal_typestation            
    ;

    -- Comme le trigger est declenche sur AFTER et non pas sur BEFORE, il faut (nbChevauchements > 1) et non pas >0, car l enregistrement a deja ete ajoute, donc il se chevauche avec lui meme, ce qui est normal !
    IF (nbexistecal = 0) THEN 
      RAISE EXCEPTION 'Le type de station renseigné dans le programme annuel (pga_cal_typestation) n''existe pas dans le calendrier sqe.t_calendrierprog_cal(cal_typestation)'  ;
    END IF  ;

    RETURN NEW ;
  END  ;
$function$;

CREATE TRIGGER checkexistecal_typestation AFTER INSERT OR UPDATE ON 
    sqe.t_progannuelle_pga FOR EACH ROW EXECUTE FUNCTION  sqe.checkexistepga_cal_typestation();

  

   

CREATE TABLE sqe.depotfichier_dfi(
dfi_iddepot SERIAL PRIMARY KEY,
dfi_deposant TEXT, -- code sandre de l'intervenant
dfi_horodate TIMESTAMP,
dfi_nomfichierdepos TEXT,
dfi_nblignesanalysedepos INTEGER,
dfi_bddorigine TEXT, -- Je me souviens plus ce que c'est, faut il une clé étrangère ?
dfi_bco_id INTEGER NOT NULL,
dfi_commentaires TEXT,
CONSTRAINT c_fk_dfi_deposant FOREIGN KEY (dfi_deposant) REFERENCES 
 refer.tr_intervenantsandre_isa (isa_codesandre) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_dfi_bco_id FOREIGN KEY (dfi_bco_id) REFERENCES 
 sqe.t_boncommande_bco  (bco_id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS sqe.t_resultat_res CASCADE;
CREATE TABLE sqe.t_resultat_res(
res_stm_cdstationmesureinterne TEXT NOT NULL,
res_codeprel TEXT,
res_dateprel DATE,
res_bco_id INTEGER NOT NULL,
CONSTRAINT c_fk_res_stm_cdstationmesureinterne FOREIGN KEY (res_stm_cdstationmesureinterne) REFERENCES 
refer.tr_stationmesure_stm(stm_cdstationmesureinterne) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_res_bco_id FOREIGN KEY (res_bco_id) REFERENCES 
sqe.t_boncommande_bco(bco_id) ON UPDATE CASCADE
);


-- table héritée 
CREATE TABLE sqe.t_resultatanalyse_rea(
rea_cdsupport TEXT, 
rea_cdfractionanalysee TEXT,
rea_heureprel TIME, -- FAut il mettre time WITH time ZONE ?
rea_dateana DATE,
rea_heureana TIME,
rea_par_cdparametre TEXT,
rea_rsana TEXT,
rea_cdunitemesure TEXT,
rea_cdrqana TEXT,
rea_cdinsituana TEXT,
rea_profondeurpre NUMERIC,
rea_cddifficulteana NUMERIC,
rea_ldana NUMERIC, --  NUMERIC
rea_lqana NUMERIC, -- NUMERIC
rea_lsana NUMERIC,
rea_cdmetfractionnement TEXT,
rea_cdmethode TEXT,
rea_rdtextration NUMERIC,
rea_cdmethodeextraction TEXT,
rea_cdaccreana TEXT,
rea_agreana TEXT,
rea_san_cdstatutana INTEGER, --FK
rea_qal_cdqualana INTEGER, --FK
rea_commentairesana TEXT,
rea_comresultatana TEXT,
rea_rdd_cdrdd TEXT, --FK
rea_cdproducteur TEXT, --FK
rea_cdpreleveur TEXT, --FK
rea_cdlaboratoire TEXT,--FK
rea_dfi_iddepot INTEGER,
rea_datemodif DATE DEFAULT NOW()::date,
CONSTRAINT c_fk_res_stm_cdstationmesureinterne FOREIGN KEY (res_stm_cdstationmesureinterne) REFERENCES 
refer.tr_stationmesure_stm(stm_cdstationmesureinterne) ON UPDATE CASCADE ON DELETE RESTRICT,  -- il faut redéfinir les contraintes dans la TABLE héritée
CONSTRAINT c_fk_res_bco_id FOREIGN KEY (res_bco_id) REFERENCES 
sqe.t_boncommande_bco(bco_id) ON UPDATE CASCADE,  -- il faut redéfinir les contraintes dans la TABLE héritée
CONSTRAINT c_fk_rea_par_cdparametre FOREIGN KEY (rea_par_cdparametre) REFERENCES 
refer.tr_parametre_par(par_cdparametre) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_rea_qal_cdqualana FOREIGN KEY (rea_qal_cdqualana) REFERENCES 
 refer.tr_qualificationana_qal(qal_code) ON UPDATE CASCADE ON DELETE RESTRICT,
 CONSTRAINT c_fk_rea_san_cdstatutana FOREIGN KEY (rea_san_cdstatutana) REFERENCES 
 refer.tr_statutanalyse_san(san_cdstatutana) ON UPDATE CASCADE ON DELETE RESTRICT,
 CONSTRAINT c_fk_rea_cdproducteur FOREIGN KEY (rea_cdproducteur) REFERENCES 
 refer.tr_intervenantsandre_isa (isa_codesandre) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_rea_rdd_cdrdd FOREIGN KEY (rea_rdd_cdrdd) REFERENCES 
 refer.tr_rdd_rdd(rdd_cdrdd) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_rea_cdpreleveur FOREIGN KEY (rea_cdpreleveur) REFERENCES 
 refer.tr_intervenantsandre_isa (isa_codesandre) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_rea_cdlaboratoire FOREIGN KEY (rea_cdlaboratoire) REFERENCES 
 refer.tr_intervenantsandre_isa (isa_codesandre) ON UPDATE CASCADE ON DELETE RESTRICT,
 CONSTRAINT c_fk_rea_dfi_iddepot FOREIGN KEY (rea_dfi_iddepot) REFERENCES 
 sqe.depotfichier_dfi (dfi_iddepot) ON UPDATE CASCADE ON DELETE CASCADE
) INHERITS (sqe.t_resultat_res);

-- table héritée 
CREATE TABLE sqe.t_resultatcondenvir_rec(
rec_par_cdparametre TEXT,
rec_rsparenv TEXT,
rec_cdunitemesure TEXT,
rec_cdrqparenv TEXT,
rec_cdstatutparenv TEXT,
rec_qal_cdqualana INTEGER,
rec_commentaireparenv TEXT, 
rec_dateparenv Date,
rec_heureparenv TIME,
rec_met_code TEXT,
rec_cdproducteur TEXT,
rec_cdpreleveur TEXT,
CONSTRAINT c_fk_res_stm_cdstationmesureinterne FOREIGN KEY (res_stm_cdstationmesureinterne) REFERENCES 
refer.tr_stationmesure_stm(stm_cdstationmesureinterne) ON UPDATE CASCADE ON DELETE RESTRICT,  -- il faut redéfinir les contraintes dans la TABLE héritée
CONSTRAINT c_fk_res_bco_id FOREIGN KEY (res_bco_id) REFERENCES 
sqe.t_boncommande_bco(bco_id) ON UPDATE CASCADE,  -- il faut redéfinir les contraintes dans la TABLE héritée
CONSTRAINT c_fk_rec_par_cdparametre FOREIGN KEY (rec_par_cdparametre) REFERENCES 
refer.tr_parametre_par(par_cdparametre) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_rec_qal_cdqualana FOREIGN KEY (rec_qal_cdqualana) REFERENCES 
refer.tr_qualificationana_qal(qal_code) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_rec_cdproducteur FOREIGN KEY (rec_cdproducteur) REFERENCES 
refer.tr_intervenantsandre_isa (isa_codesandre) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_rec_cdpreleveur FOREIGN KEY (rec_cdpreleveur) REFERENCES 
refer.tr_intervenantsandre_isa (isa_codesandre) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_rec_met_code FOREIGN KEY (rec_met_code) REFERENCES 
refer.tr_methode_met (met_code) ON UPDATE CASCADE ON DELETE RESTRICT
 ) INHERITS (sqe.t_resultat_res);
 
 
 
 CREATE TABLE sqe.t_resultatoperation_reo(
 reo_coordxprel NUMERIC,
 reo_coordyprel NUMERIC,
 reo_projectprel TEXT,
 reo_cdsupport TEXT,
 reo_met_code TEXT,
 reo_heureprel TIME,
 reo_datefinprel DATE,
 reo_heurefinprel TIME,
 reo_cdzoneverticaleprospectee TEXT,
 reo_profondeurprel NUMERIC,
 reo_cddifficulteprel TEXT,
 reo_cdaccredprel TEXT,
 reo_agreprel TEXT,
 reo_cdfinaliteprel TEXT,
 reo_commentairesprel TEXT,
 reo_rdd_cdrdd TEXT,
 CONSTRAINT c_fk_res_stm_cdstationmesureinterne FOREIGN KEY (res_stm_cdstationmesureinterne) REFERENCES 
refer.tr_stationmesure_stm(stm_cdstationmesureinterne) ON UPDATE CASCADE ON DELETE RESTRICT,  -- il faut redéfinir les contraintes dans la TABLE héritée
CONSTRAINT c_fk_res_bco_id FOREIGN KEY (res_bco_id) REFERENCES 
sqe.t_boncommande_bco(bco_id) ON UPDATE CASCADE,  -- il faut redéfinir les contraintes dans la TABLE héritée
CONSTRAINT c_fk_reo_met_code FOREIGN KEY (reo_met_code) REFERENCES 
refer.tr_methode_met (met_code) ON UPDATE CASCADE ON DELETE RESTRICT,
 CONSTRAINT c_fk_reo_rdd_cdrdd FOREIGN KEY (reo_rdd_cdrdd) REFERENCES 
 refer.tr_rdd_rdd(rdd_cdrdd) ON UPDATE CASCADE ON DELETE RESTRICT
 ) INHERITS (sqe.t_resultat_res);
 
 
 
 CREATE TABLE sqe.t_resultatcondreceptechantillon_ree(
 ree_datereceptech DATE,
 ree_heurereceptech TIME,
 ree_temperaturereceptech NUMERIC,
 CONSTRAINT c_fk_res_stm_cdstationmesureinterne FOREIGN KEY (res_stm_cdstationmesureinterne) REFERENCES 
refer.tr_stationmesure_stm(stm_cdstationmesureinterne) ON UPDATE CASCADE ON DELETE RESTRICT,  -- il faut redéfinir les contraintes dans la TABLE héritée
CONSTRAINT c_fk_res_bco_id FOREIGN KEY (res_bco_id) REFERENCES 
sqe.t_boncommande_bco(bco_id) ON UPDATE CASCADE  -- il faut redéfinir les contraintes dans la TABLE héritée
 ) INHERITS (sqe.t_resultat_res);
 
 





/* ==============================
 *             VIEWS 
 */   
   
CREATE OR REPLACE VIEW sqe.view_runanalytiques
AS SELECT * 
FROM sqe.t_prixunitairerunanalytique_prr 
INNER JOIN sqe.t_runanalytique_run 
ON prr_run_id = run_id;
   
CREATE OR REPLACE VIEW sqe.view_bpu
AS SELECT * 
FROM sqe.t_prestation_prs 
INNER JOIN sqe.t_prixunitaireprestation_prp 
ON prs_id = prp_prs_id;   
   
CREATE OR REPLACE VIEW sqe.view_bdc
AS SELECT * 
FROM sqe.t_boncommande_bco 
INNER JOIN sqe.t_marche_mar 
ON  bco_mar_id= mar_id;   
  

CREATE OR REPLACE VIEW sqe.view_bdc_quantif
AS SELECT mar_reference ,mar_nom,mar_nom_long, per_entite_gestionaire, bco_per_nom ,bco_id, bco_refcommande,
bco_commentaires, prs_idprestationdansbpu, prs_label_prestation, prm_unitedoeuvre,
bcq_nbprestacom,
pre_nom, pre_id,  pru_datedebut, pru_datefin, pru_valeur
FROM sqe.t_boncommande_bco 
INNER JOIN sqe.t_marche_mar 
ON  bco_mar_id= mar_id
INNER JOIN sqe.t_boncommande_quantitatif_bcq
ON bco_id=bcq_bco_id
INNER JOIN sqe.t_prestation_prs
ON bcq_prs_id=prs_id
INNER JOIN refer.tr_prestataire_pre
ON prs_pre_id=pre_id
INNER JOIN sqe.t_prixunitaireprestation_prp
ON prs_id=prp_prs_id
INNER JOIN refer.tr_perimetre_per
ON per_nom=bco_per_nom
;   
 

CREATE OR REPLACE VIEW sqe.view_bdc_quantif_par_staq
AS SELECT mar_reference ,mar_nom, bco_id, bco_per_nom , bco_refcommande,
bco_commentaires, prs_idprestationdansbpu, prs_label_prestation,
pre_nom, pre_id, bcp_stm_cdstationmesureinterne,stm_lbstationmesureeauxsurface,
bcp_dateinterv
FROM sqe.t_boncommande_bco 
INNER JOIN sqe.t_marche_mar 
ON  bco_mar_id= mar_id
INNER JOIN sqe.t_boncommande_pgm_bcp
ON bco_id=bcp_bco_id
INNER JOIN sqe.t_prestation_prs
ON bcp_prs_id=prs_id
INNER JOIN refer.tr_prestataire_pre
ON prs_pre_id=pre_id
INNER JOIN refer.tr_stationmesure_stm
ON bcp_stm_cdstationmesureinterne=stm_cdstationmesureinterne
;   


  


/* 
CREATE OR REPLACE VIEW sqe.test_vue AS 
 SELECT res_stm_cdstationmesureauxsurface, 
 res_codeprel, 
 res_dateprel, 
  stm.stm_lbstationmesureeauxsurface,
 rea_cdsupport, 
 rea_cdfractionanalysee, 
 rea_heureprel, 
 rea_dateana, 
 rea_heureana, 
 rea_par_cdparametre,
 rea_rsana, 
 rea_cdunitemesure, 
 rea_cdrqana, 
 rea_cdinsituana, 
 rea_profondeurpre, 
 rea_cddifficulteana,
 rea_ldana, 
 rea_lqana, 
 rea_lsana, 
 rea_cdmetfractionnement,
 rea_cdmethode, 
 rea_rdtextration, 
 rea_cdmethodeextraction, 
 rea_cdaccreana, 
 rea_agreana, 
 rea_san_cdstatutana, 
 rea_qal_cdqualana, 
 rea_commentairesana,
 rea_comresultatana, 
 rea_rdd_cdrdd, 
 rea_cdproducteur, 
 rea_cdpreleveur, 
 rea_cdlaboratoire,
 rea_dfi_iddepot, 
 rea_datemodif
 FROM sqe.t_resultatanalyse_rea rea
 JOIN refer.tr_stationmesure_stm stm ON stm.stm_cdstationmesureauxsurface= rea.res_stm_cdstationmesureauxsurface

 
 
 SELECT * FROM sqe.test_vue
 
  CREATE OR REPLACE MATERIALIZED VIEW sqe.test_vue AS 
 
 REFRESH MATERIALIZED VIEW
 */ 