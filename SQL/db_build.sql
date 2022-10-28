/*
Code TO build db_libreSQL
*/
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
isa_codepostal INTEGER);




CREATE TABLE refer.tr_prestataire_pre(
pre_id serial PRIMARY KEY,
pre_nom TEXT,
pre_siret TEXT,
pre_isa_codesandre TEXT,
CONSTRAINT c_fk_pre_codesandre FOREIGN KEY (pre_isa_codesandre) 
REFERENCES refer.intervenantsandre_isa(isa_codesandre) 
ON DELETE RESTRICT ON UPDATE CASCADE
);






