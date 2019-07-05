REM
REM     Script:    brs_role_syn.sql
REM     Author:    Quanwen Zhao
REM     Dated:     Jul 05, 2019
REM
REM     Purpose:
REM         This SQL script uses to batch generate "revoke (only) select privilege on specific user (prod)'s all of tables from
REM         a new role (prod)" and also batch generate "drop the name of public synonym for original table name" on schema 'PROD', 
REM         next revoke new role (prod) from new user (qwz) on schema 'SYS', finally execute SPOOL sql file 'gen_brs_role_syn.sql'
REM         on schema 'PROD' to achieve the function of 'batch revoke select'.
REM
REM         The advantage and convenience of this approach is that it could not only revoke more than one user but also just 
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

REVOKE prod FROM qwz;

PROMPT ==========================
PROMPT Executing on <PROD> schema
PROMPT ==========================

-- switching to specific schema "prod", BTW I use Oracle SEPS (Security External Pasword Store) to achieve the intention
-- saving password of schema "prod".

CONN /@prod;

SPOOL gen_brs_role_syn.sql
SELECT 'REVOKE SELECT ON '
       || table_name
       || ' FROM prod;'
FROM user_tables
ORDER BY table_name
/

SELECT 'DROP PUBLIC SYNONYM '
       || table_name
--     || ' FOR '
--     || table_name
       || ';'
FROM user_tables
ORDER BY table_name
/
SPOOL off

@gen_brs_role_syn.sql;

PROMPT =========================
PROMPT Executing on <SYS> schema
PROMPT =========================

CONN / as sysdba;

REVOKE drop public synonym FROM prod;
REVOKE create public synonym FROM prod;

DROP ROLE prod;

REVOKE connect, resource FROM qwz;

DROP USER qwz;

-- Or just revoke role_name from new user_name.
-- REVOKE prod FROM qwz;
