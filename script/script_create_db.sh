# A lancer dans la console dos 
# creation de la base de données
CREATEDB -U postgres libresqe 

psql -U postgres -c "CREATE EXTENSION POSTGIS" libresqe
#creation des deux schemas
psql -U postgres -c "CREATE SCHEMA ref"
psql -U postgres -c "CREATE SCHEMA sqe"
#psql -U postgres -f "script/createrole.sql" libresqe 

# exemple de sauvegarde : base complète (restaurer avec psql)
pg_dump -U postgres -f "libresqe.sql" libresqe
# restauration (sur une base vide)
psql -U postgres -f "libresqe.sql" libresqe

# sauvegarde d'un schema
pg_dump -U postgres -f "libresqe_ref.sql" --schema ref libresqe
# restauration 
psql -U postgres -c "DROP SCHEMA ref CASCADE" libresqe
psql -U postgres -f "libresqe_ref.sql" libresqe

# sauvegarde d'une table
pg_dump -U postgres -f "libresqe_ref_matable.sql" --table ref.matable libresqe
# restauration 
psql -U postgres -c "DROP SCHEMA ref CASCADE" libresqe
psql -U postgres -f "libresqe_ref_matable.sql" libresqe


# exemple de sauvegarde : base complète (restaurer avec pg_restore = format compressé)
pg_dump -U postgres -Fc -f "libresqe.backup" libresqe
# restauration (sur une base vide)
pg_restore -d libresqe -U postgres libresqe.backup