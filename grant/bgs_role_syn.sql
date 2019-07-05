REM
REM     Script:    bgs_role_syn.sql
REM     Author:    Quanwen Zhao
REM     Dated:     Jul 03, 2019
REM
REM     Purpose:
REM         This SQL script uses to batch grant (only) select privilege on specific user (prod)'s all of tables to
REM         a new role (prod) and also batch create the name of public synonym by original table name on schema 'PROD', 
REM         next grant new role (prod) to new user (qwz) on schema 'SYS', finally execute SPOOL sql file 'gen_bgs_role_syn.sql'
REM         on schema 'PROD' to achieve the function of 'batch grant select'.
REM
REM         The advantage and convenience of this approach is that it could not only grant more than one user but also just 
REM         revoke role when revoking.
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

PROMPT =========================
PROMPT Executing on <SYS> schema
PROMPT =========================

DROP USER qwz;
CREATE USER qwz IDENTIFIED BY qwz;
GRANT connect, resource TO qwz;

CREATE ROLE prod;

GRANT create public synonym TO prod;
GRANT drop public synonym TO prod;

PROMPT ==========================
PROMPT Executing on <PROD> schema
PROMPT ==========================

-- switching to specific schema "prod", BTW I use Oracle SEPS (Security External Pasword Store) to achieve the intention
-- saving password of schema "prod".

CONN /@prod;

SPOOL gen_bgs_role_syn.sql
SELECT 'GRANT SELECT ON '
       || table_name
       || ' TO prod;'
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

PROMPT =========================
PROMPT Executing on <SYS> schema
PROMPT =========================

CONN / as sysdba;
GRANT prod TO qwz;

PROMPT ==========================
PROMPT Executing on <PROD> schema
PROMPT ==========================

CONN /@prod;
@gen_bgs_role_syn.sql
