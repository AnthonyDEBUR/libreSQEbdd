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
mar_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
mar_pre_id INTEGER, 
mar_per_nom TEXT,
mar_montantmin NUMERIC,
mar_montantmax NUMERIC,
mar_datedebut DATE,
mar_datefin DATE,
mar_statut TEXT,
CONSTRAINT c_fk_mar_pre_id FOREIGN KEY (mar_pre_id) REFERENCES refer.tr_prestataire_pre(pre_id) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_fk_mar_per_nom FOREIGN KEY (mar_per_nom) REFERENCES refer.tr_perimetre_per (per_nom) ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT c_ck_mar_statut CHECK (mar_statut='En cours' OR mar_statut='Terminé')
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
-- creation des tables relatives aux prestations du marché
----------------------------------------

CREATE TABLE sqe.t_premar_prm(
prm_mar_id UUID,
prm_pre_id INTEGER,
prm_nom TEXT,
prm_nature TEXT,
prm_unitedoeuvre TEXT,
CONSTRAINT cpk_prm PRIMARY KEY (prm_mar_id, prm_pre_id)
CONSTRAINT  c_fk_prm_mar_id FOREIGN KEY (prm_mar_id) REFERENCES sqe.t_marche_mar(par_id) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT  c_fk_prm_pre_id FOREIGN KEY (prm_pre_id) REFERENCES sqe.tr_prestataire_pre(pre_id) ON UPDATE CASCADE ON DELETE CASCADE
);


----------------------------------------
-- creation des tables relatives aux prestations du marché
----------------------------------------

CREATE TABLE sqe.t_premar_prm(
prm_mar_id UUID,
prm_pre_id INTEGER,
prm_nom TEXT,
prm_nature TEXT,
prm_unitedoeuvre TEXT,
CONSTRAINT cpk_prm PRIMARY KEY (prm_mar_id, prm_pre_id)
CONSTRAINT  c_fk_prm_mar_id FOREIGN KEY (prm_mar_id) REFERENCES sqe.t_marche_mar(par_id) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT  c_fk_prm_pre_id FOREIGN KEY (prm_pre_id) REFERENCES sqe.tr_prestataire_pre(pre_id) ON UPDATE CASCADE ON DELETE CASCADE
);



