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
prs_mar_id INTEGER,
prs_pre_id INTEGER,
prs_nomprestation TEXT,
prs_natureprestation TEXT,
prm_unitedoeuvre TEXT, -- A VOIR SI UTILE 
CONSTRAINT  c_fk_prs_mar_id FOREIGN KEY (prs_mar_id) REFERENCES sqe.t_marche_mar(mar_id) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT  c_fk_prs_pre_id FOREIGN KEY (prs_pre_id) REFERENCES refer.tr_prestataire_pre(pre_id) ON UPDATE CASCADE ON DELETE CASCADE
);
COMMENT ON COLUMN sqe.t_prestation_prs.prs_pre_id IS 'Soit titulaire du marché soit sous traitant';

----------------------------------------
-- creation des tables relatives aux prix unitaires
----------------------------------------
DROP TABLE IF EXISTS sqe.t_prixunitaire_pru;
CREATE TABLE sqe.t_prixunitaire_pru(
pru_id serial PRIMARY KEY,
pru_prs_id INTEGER,
pru_datedebut DATE,
pru_datefin DATE,
pru_valeur NUMERIC, 
CONSTRAINT  c_fk_pru_prs_id FOREIGN KEY (pru_prs_id) REFERENCES sqe.t_prestation_prs(prs_id) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT c_ck_pru_datefin CHECK (pru_datefin > pru_datedebut)
);

COMMENT ON COLUMN sqe.t_prixunitaire_pru.pru_datedebut IS 'Date de début de la validité du prix';
COMMENT ON COLUMN sqe.t_prixunitaire_pru.pru_datefin IS 'Date de fin de la validité du prix';



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

  
  
CREATE TABLE refer.tr_statutpresta_stp(
stp_nom TEXT PRIMARY KEY,
stp_description TEXT
);

INSERT INTO refer.tr_statutpresta_stp VALUES ('Emis', 'Bon de commande emis');
INSERT INTO refer.tr_statutpresta_stp VALUES ('Prélevé', 'Prélèvement fait');
INSERT INTO refer.tr_statutpresta_stp VALUES ('Analysé', 'Analyse rendue');
INSERT INTO refer.tr_statutpresta_stp VALUES ('Validé', 'Analyse validée');


CREATE TABLE sqe.t_boncommande_bco(
bco_id serial PRIMARY KEY,
bco_prs_id integer,
bco_per_nom TEXT,
bco_refcommande TEXT,
bco_stp_nom TEXT, -- Statut 
bco_commentaires TEXT,
bco_nbpresta INTEGER,
CONSTRAINT c_fk_bco_prs_id FOREIGN KEY (bco_prs_id) 
REFERENCES sqe.t_prestation_prs (prs_id) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT c_fk_per_nom FOREIGN KEY (bco_per_nom) 
REFERENCES refer.tr_perimetre_per (per_nom) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_bco_stp_nom FOREIGN KEY (bco_stp_nom) 
REFERENCES refer.tr_statutpresta_stp (stp_nom) ON UPDATE CASCADE ON DELETE RESTRICT
);
COMMENT ON COLUMN sqe.t_boncommande_bco.bco_stp_nom IS 'Statut du bon de commande';


/*
 * programme type
 * 
 */



