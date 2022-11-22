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
isa_siret TEXT,
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
per_geom geometry
);

ALTER TABLE refer.tr_perimetre_per OWNER TO grp_eptbv_planif_dba;

INSERT INTO refer.tr_perimetre_per(per_nom, per_description)
VALUES  ('UGVA', 'Unité gestion Vilaine Aval');
INSERT INTO refer.tr_perimetre_per(per_nom, per_description)
VALUES  ('UGVE', 'Unité gestion Vilaine Est');
INSERT INTO refer.tr_perimetre_per(per_nom, per_description)
VALUES  ('UGVO', 'Unité gestion Vilaine Ouest');








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
mar_pre_id INTEGER, -- Titulaire du marché.
mar_per_nom TEXT,
mar_montantmin NUMERIC,
mar_montantmax NUMERIC,
mar_datedebut DATE,
mar_datefin DATE,
mar_statut TEXT,
CONSTRAINT c_fk_mar_pre_id FOREIGN KEY (mar_pre_id) REFERENCES refer.tr_prestataire_pre(pre_id) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_mar_per_nom FOREIGN KEY (mar_per_nom) REFERENCES refer.tr_perimetre_per (per_nom) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_ck_mar_statut CHECK (mar_statut='En cours' OR mar_statut='Terminé'),
CONSTRAINT c_ck_mar_datefin CHECK (mar_datefin > mar_datedebut)
);


/*
-- COMMENT CHANGER LA CONTRAINTE

ALTER TABLE DROP CONSTRAINT c_ck_mar_statut ;
ALTER TABLE ADD CONSTRAINT c_ck_mar_statut ....

*/



COMMENT ON TABLE sqe.t_marche_mar IS 'Table des marchés';
COMMENT ON COLUMN sqe.t_marche_mar.mar_pre_id IS 'Identifiant du prestataire';
ALTER TABLE sqe.t_marche_mar OWNER TO grp_eptbv_planif_dba;

----------------------------------------
-- creation des tables relatives aux prestations 
----------------------------------------






----------------------------------------
-- creation des tables relatives aux prestations du marché
----------------------------------------

CREATE TABLE sqe.t_prestation_prs(
prs_id INTEGER PRIMARY KEY, -- identifiant de la prestation
prs_mar_id INTEGER, -- identifiant du marché
prs_pre_id INTEGER, -- identifiant du prestataire
prs_nomprestation TEXT,
prs_natureprestation TEXT,
prm_unitedoeuvre TEXT, -- A VOIR SI UTILE 
CONSTRAINT  c_fk_prs_mar_id FOREIGN KEY (prs_mar_id) REFERENCES sqe.t_marche_mar(mar_id) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT  c_fk_prs_pre_id FOREIGN KEY (prs_pre_id) REFERENCES refer.tr_prestataire_pre(pre_id) ON UPDATE CASCADE ON DELETE CASCADE
);
COMMENT ON COLUMN sqe.t_prestation_prs.prs_pre_id IS 'Identifiant du prestataire, soit titulaire du marché soit sous traitant';
COMMENT ON COLUMN sqe.t_prestation_prs.prs_mar_id IS 'Identifiant marché';
COMMENT ON COLUMN sqe.t_prestation_prs.prs_id IS 'Identifiant de la prestation';



  
CREATE TABLE refer.tr_statutpresta_stp(
stp_nom TEXT PRIMARY KEY,
stp_description TEXT
);

INSERT INTO refer.tr_statutpresta_stp VALUES ('Programmé', 'Bon de commande prêt à être émis');
INSERT INTO refer.tr_statutpresta_stp VALUES ('Emis', 'Bon de commande emis');
INSERT INTO refer.tr_statutpresta_stp VALUES ('Prélevé', 'Prélèvement fait');
INSERT INTO refer.tr_statutpresta_stp VALUES ('Analysé', 'Analyse rendue');
INSERT INTO refer.tr_statutpresta_stp VALUES ('Validé', 'Analyse validée');

-- DROP TABLE sqe.t_boncommande_bco 

CREATE TABLE sqe.t_boncommande_bco(
bco_id serial PRIMARY KEY,
bco_prs_id integer,
bco_per_nom TEXT,
bco_refcommande TEXT,
bco_stp_nom TEXT, -- Statut
bco_date_prev DATE, -- Date prévisionnelle de la prestation 
bco_commentaires TEXT,
bco_nbpresta INTEGER,
CONSTRAINT c_fk_bco_prs_id FOREIGN KEY (bco_prs_id) 
REFERENCES sqe.t_prestation_prs (prs_id) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT c_fk_per_nom FOREIGN KEY (bco_per_nom) 
REFERENCES refer.tr_perimetre_per (per_nom) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_bco_stp_nom FOREIGN KEY (bco_stp_nom) 
REFERENCES refer.tr_statutpresta_stp (stp_nom) ON UPDATE CASCADE ON DELETE RESTRICT
);
COMMENT ON COLUMN sqe.t_boncommande_bco.bco_per_nom IS 'Périmètre du bon de commande (ex territoireX_projetY';
COMMENT ON COLUMN sqe.t_boncommande_bco.bco_refcommande IS 'Référence du bon de commande';
COMMENT ON COLUMN sqe.t_boncommande_bco.bco_stp_nom IS 'Statut du bon de commande';
COMMENT ON COLUMN sqe.t_boncommande_bco.bco_date_prev IS 'Date prévisionnelle de la prestation';

/*
 * programme type
 * 
 */

CREATE TABLE refer.tr_parametre_par(
par_cdparametre TEXT PRIMARY KEY,
par_nomparametre TEXT,
par_statutparametre TEXT,
par_nomcourt TEXT,
par_codecas TEXT
);



CREATE TABLE refer.tr_uniteparametre_uni(
uni_codesandreunite TEXT PRIMARY KEY,
uni_symbole TEXT
);

CREATE TABLE refer.tr_fraction_fra(
fra_codefraction TEXT PRIMARY KEY,
fra_nomfraction TEXT
);

CREATE TABLE refer.tr_methode_met(
met_code TEXT PRIMARY KEY,
met_nom TEXT
);

/*
 * 
 * 
 */

CREATE TABLE sqe.t_runanalytique_run(
run_id serial PRIMARY KEY,
run_nom TEXT,
run_met_code TEXT, -- FOREIGN KEY methode sandre
CONSTRAINT c_fk_run_met_code FOREIGN KEY (run_met_code) 
REFERENCES refer.tr_methode_met  (met_code) ON UPDATE CASCADE ON DELETE RESTRICT
);


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
ppt_par_cdparametre TEXT, -- code SANDRE du paramètre (clé étrangère)
ppt_codetemporaireparametre TEXT, -- code temporaire en attente de code SANDRE
ppt_fra_codefraction TEXT,
ppt_nomparametre TEXT,
ppt_uni_codesandreunite TEXT,
ppt_analyseinsitu BOOLEAN,
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
CONSTRAINT c_fk_ppt_run_id FOREIGN KEY (ppt_run_id) 
REFERENCES sqe.t_runanalytique_run (run_id) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT c_ck_nn_codetemporaireparametre CHECK (ppt_par_cdparametre IS NULL  
AND ppt_codetemporaireparametre IS  NOT NULL) -- si le code sandre n'existe pas il faut un code temporaire
);
COMMENT ON COLUMN sqe.t_parametreprogrammetype_ppt.ppt_prs_id IS 'Identifiant de la prestation';
COMMENT ON COLUMN sqe.t_parametreprogrammetype_ppt.ppt_par_cdparametre IS 'Code SANDRE du paramètre (clé étrangère)';
COMMENT ON COLUMN sqe.t_parametreprogrammetype_ppt.ppt_codetemporaireparametre IS 'Code temporaire en attente de code SANDRE';
COMMENT ON COLUMN sqe.t_parametreprogrammetype_ppt.ppt_limitequantif IS 'Limite garantie par le prestataire';
COMMENT ON COLUMN sqe.t_parametreprogrammetype_ppt.ppt_incertitude IS 'Code temporaire en attente de code SANDRE';
COMMENT ON COLUMN sqe.t_parametreprogrammetype_ppt.ppt_accreditation IS 'Accreditation du prestataire ';
COMMENT ON COLUMN sqe.t_parametreprogrammetype_ppt.ppt_commentaireparametre IS 'Commentaire sur le paramètre du prestataire dans le marché en cours';
COMMENT ON COLUMN sqe.t_parametreprogrammetype_ppt.ppt_run_id IS 'FK t_runanalytique_run. Un paramètre peut être analysé par plusieurs run analytiques différents au sein d''un programme type';



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

CREATE TABLE sqe.t_prixunitaireprestation_prp (
prp_prs_id INTEGER,
CONSTRAINT  c_fk_prp_prs_id FOREIGN KEY (prp_prs_id) 
REFERENCES sqe.t_prestation_prs(prs_id) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT c_ck_pru_datefin CHECK (pru_datefin > pru_datedebut)
)INHERITS (sqe.t_prixunitaire_pru) ;

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
    WHERE  pru_prs_id = NEW.pru_prs_id 
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
ts_date DATE -- Date de mise à jour de la base
);  


CREATE TABLE sqe.ts_suivi_maj_sqe() INHERITS(sqe.ts_suivi_maj);  

CREATE TABLE sqe.ts_suivi_maj_refer() INHERITS(sqe.ts_suivi_maj); 

INSERT INTO sqe.ts_suivi_maj_refer
(ts_table, ts_date)
VALUES('tr_fraction_fra', '1950-01-01');

INSERT INTO sqe.ts_suivi_maj_refer
(ts_table, ts_date)
VALUES('tr_intervenantsandre_isa', '1950-01-01');

INSERT INTO sqe.ts_suivi_maj_refer
(ts_table, ts_date)
VALUES('tr_intervenantsandre_isa', '1950-01-01');

INSERT INTO sqe.ts_suivi_maj_refer
(ts_table, ts_date)
VALUES('tr_methode_met', '1950-01-01');

INSERT INTO sqe.ts_suivi_maj_refer
(ts_table, ts_date)
VALUES('tr_parametre_par', '1950-01-01');

INSERT INTO sqe.ts_suivi_maj_refer
(ts_table, ts_date)
VALUES('tr_perimetre_per', '1950-01-01');

INSERT INTO sqe.ts_suivi_maj_refer
(ts_table, ts_date)
VALUES('tr_uniteparametre_uni', '1950-01-01');

