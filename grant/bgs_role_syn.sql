REM
REM     Script:    bgs_role_syn(bth_grt_sel).sql
REM     Author:    Quanwen Zhao
REM     Dated:     Jul 03, 2019
REM
REM     Purpose:
REM         This SQL script uses to batch grant (only) select privilege on specific user (prod)'s all of tables to
REM         a new user (qwz), and then execute SPOOL sql file 'gen_bgs_role.sql' and 'gen_bgs_role_syn.sql' to achieve
REM         the function of 'batch grant select'.
REM

SET long     10000
SET linesize 300
SET pagesize 0
 
SET echo      OFF
SET feedback  OFF
SET heading   OFF
SET termout   OFF
SET verify    OFF
SET trimout   ON
SET trimspool ON

DROP USER qwz;
CREATE USER qwz IDENTIFIED BY qwz;
GRANT connect, resource TO qwz;

CREATE ROLE prod_sel;

GRANT create public synonym TO prod;
GRANT drop public synonym TO prod;

-- switching to specific schema "prod", BTW I use Oracle SEPS (Security External Pasword Store) to achieve the intention
-- saving password of schema "prod".
CONN /@prod;

SPOOL gen_bgs_role_syn.sql
SELECT 'GRANT SELECT ON '
       || table_name
       || ' TO prod_sel;'
FROM user_tables
ORDER BY table_name
/

SELECT 'CREATE PUBLIC SYNONYM '
       || table_name
       || ' FOR '
       || table_name
       || ';'
FROM user_tables
ORDER BY table_name
/
SPOOL off

CONN / as sysdba;
GRANT prod_sel TO qwz;
