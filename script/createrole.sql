

CREATE ROLE cbriand WITH 
  LOGIN PASSWORD 'see pass'
  ;

--creer un role user acoudart

CREATE ROLE adebur WITH 
  LOGIN PASSWORD 'see pass'
  ;



-- alter role

ALTER USER cbriand WITH SUPERUSER;
ALTER USER adebur WITH SUPERUSER;

CREATE ROLE grp_eptbv_planif_dba WITH 
  CREATEDB 
  CREATEROLE
  ;

REASSIGN OWNED BY cbriand, adebur TO grp_eptbv_planif_dba


GRANT grp_eptbv_planif_dba TO cbriand;
GRANT grp_eptbv_planif_dba TO adebur;

GRANT ALL ON SCHEMA refer TO grp_eptbv_planif_dba;
  
GRANT ALL ON SCHEMA sqe TO grp_eptbv_planif_dba;