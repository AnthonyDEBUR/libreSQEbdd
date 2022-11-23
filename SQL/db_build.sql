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
bco_prs_id integer NOT NULL, -- attention dans la table t_resultatanalyse_rea on ignore le bco mais on en aura besoin, donc il faut NOT null
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
uni_symbole TEXT,
uni_lblsandreunite TEXT
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
VALUES('tr_methode_met', '1950-01-01');

INSERT INTO sqe.ts_suivi_maj_refer
(ts_table, ts_date)
VALUES('tr_parametre_par', '1950-01-01');

INSERT INTO sqe.ts_suivi_maj_refer
(ts_table, ts_date)
VALUES('tr_uniteparametre_uni', '1950-01-01');


-- trigger for refer ts_suivi_maj_refer()
/* permet d'acualiser la date de dernière mise à jour d'une table du schéma réfer
 * dans la table sqe.ts_suivi_maj_refer
 */ 
CREATE OR REPLACE FUNCTION sqe.fn_update_date_refer() RETURNS TRIGGER AS
$$
DECLARE
        sql TEXT;
BEGIN
  sql := format('UPDATE sqe.ts_suivi_maj_refer SET (ts_table, ts_date) =(''%s'', now()::date)', TG_ARGV[0]);
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
  stm_lbstationmesureeauxsurface TEXT,
  stm_x NUMERIC,
  stm_y NUMERIC,
  stm_commentaires TEXT,
  geom geometry,
  CONSTRAINT c_uk_stm_cdstationmesureauxsurface UNIQUE(stm_cdstationmesureauxsurface) );


CREATE TABLE refer.tr_statutanalyse_san(
san_cdstatutana INTEGER PRIMARY KEY,
san_mnemostatutana TEXT NOT NULL);

CREATE TABLE refer.tr_rdd_rdd(
rdd_cdrdd TEXT PRIMARY KEY,
rdd_nomrdd TEXT NOT NULL);
COMMENT ON TABLE refer.tr_rdd_rdd IS 'Réseau de mesure - dispositif de collecte';

CREATE TABLE refer.tr_qualificationana_qal(
qal_code INTEGER PRIMARY KEY,
qal_mnemo TEXT,
qal_libelle TEXT,
qal_definition TEXT);
COMMENT ON TABLE refer.tr_rdd_rdd IS 'Code des qualifications d''analyse';


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
res_stm_cdstationmesureauxsurface TEXT,
res_codeprel TEXT,
res_dateprel DATE,
CONSTRAINT c_fk_res_stm_cdstationmesureauxsurface FOREIGN KEY (res_stm_cdstationmesureauxsurface) REFERENCES 
refer.tr_stationmesure_stm(stm_cdstationmesureauxsurface) ON UPDATE CASCADE ON DELETE RESTRICT
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
rea_ldana NUMERIC, -- ? NUMERIC
rea_lqana NUMERIC, -- ? NUMERIC
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
rea_dfi_iddepot INTEGER NOT NULL,
rea_datemodif DATE DEFAULT NOW()::date,
CONSTRAINT c_fk_res_stm_cdstationmesureauxsurface FOREIGN KEY (res_stm_cdstationmesureauxsurface) REFERENCES 
refer.tr_stationmesure_stm(stm_cdstationmesureauxsurface) ON UPDATE CASCADE ON DELETE RESTRICT,  -- il faut redéfinir les contraintes dans la TABLE héritée
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
CONSTRAINT c_fk_rec_par_cdparametre FOREIGN KEY (rec_par_cdparametre) REFERENCES 
refer.tr_parametre_par(par_cdparametre) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_res_stm_cdstationmesureauxsurface FOREIGN KEY (res_stm_cdstationmesureauxsurface) REFERENCES 
refer.tr_stationmesure_stm(stm_cdstationmesureauxsurface) ON UPDATE CASCADE ON DELETE RESTRICT,  -- il faut redéfinir les contraintes dans la TABLE héritée
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
 CONSTRAINT c_fk_res_stm_cdstationmesureauxsurface FOREIGN KEY (res_stm_cdstationmesureauxsurface) REFERENCES 
refer.tr_stationmesure_stm(stm_cdstationmesureauxsurface) ON UPDATE CASCADE ON DELETE RESTRICT,  -- il faut redéfinir les contraintes dans la TABLE héritée
CONSTRAINT c_fk_reo_met_code FOREIGN KEY (reo_met_code) REFERENCES 
refer.tr_methode_met (met_code) ON UPDATE CASCADE ON DELETE RESTRICT,
 CONSTRAINT c_fk_reo_rdd_cdrdd FOREIGN KEY (reo_rdd_cdrdd) REFERENCES 
 refer.tr_rdd_rdd(rdd_cdrdd) ON UPDATE CASCADE ON DELETE RESTRICT
 ) INHERITS (sqe.t_resultat_res);
 
 
 
 CREATE TABLE sqe.t_resultatcondreceptechantillon_ree(
 ree_datereceptech DATE,
 ree_heurereceptech TIME,
 ree_temperaturereceptech NUMERIC,
 CONSTRAINT c_fk_res_stm_cdstationmesureauxsurface FOREIGN KEY (res_stm_cdstationmesureauxsurface) REFERENCES 
refer.tr_stationmesure_stm(stm_cdstationmesureauxsurface) ON UPDATE CASCADE ON DELETE RESTRICT-- il faut redéfinir les contraintes dans la TABLE héritée
 ) INHERITS (sqe.t_resultat_res);
