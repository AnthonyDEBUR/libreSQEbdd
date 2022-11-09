ALTER TABLE refer.tr_prestataire_pre DROP CONSTRAINT IF EXISTS c_fk_pre_codesandre;
DELETE FROM refer.tr_intervenantsandre_isa;
INSERT INTO refer.tr_intervenantsandre_isa
(isa_codesandre, isa_siret, isa_nom, isa_statut, isa_datecreation, isa_datemaj, isa_mnemo, isa_ensembleimmobilier, isa_bp, isa_rue, isa_lieudit, isa_ville, isa_departementpays, isa_codepostal)
SELECT isa_codesandre, isa_siret, isa_nom, isa_statut, isa_datecreation::date, isa_datemaj::date, isa_mnemo, isa_ensembleimmobilier, isa_bp, isa_rue, isa_lieudit, isa_ville, isa_departementpays, isa_codepostal::INTEGER
FROM
temp.temp_isa; -- 158842
ALTER TABLE refer.tr_prestataire_pre ADD CONSTRAINT c_fk_pre_codesandre FOREIGN KEY (pre_isa_codesandre) 
REFERENCES refer.tr_intervenantsandre_isa(isa_codesandre) 
ON DELETE RESTRICT ON UPDATE CASCADE;