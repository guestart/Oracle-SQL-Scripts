REM
REM     Script:    brs_role_syn_tab.sql
REM     Author:    Quanwen Zhao
REM     Dated:     Jul 09, 2019
REM
REM     Purpose:
REM         This SQL script uses to revoke new role (prod) from new user (qwz) to whom if (once) being granted on schema 'SYS'.
REM
REM         If you wanna furthermore revoke select privilege on new role (prod) and drop this role you can do the following steps:
REM           (01) Batch generate "revoke (only) select privilege on specific user (prod)'s all of tables from a new role (prod)" on schema 'PROD';
REM           (02) Also batch generate "drop the name of public synonym for original table name" on schema 'PROD';
REM           (03) Execute SPOOL sql file 'gen_brs_role_syn.sql' on schema 'PROD';
REM           (04) Drop public synonym usr_tables on schema 'PROD';
REM           (05) Revoke 'select on usr_tables' from role 'prod' on schema 'PROD';
REM           (06) Drop view 'usr_tables' on schema 'PROD';
REM           (07) Drop role 'prod' on schema 'SYS';
REM           (08) Revoke 'drop any view' from schema 'PROD' on schema 'SYS';
REM           (09) Revoke 'create view' from schema 'PROD' on schema 'SYS';
REM           (10) Revoke 'drop public synonym' from schema 'PROD' on schema 'SYS';
REM           (11) Revoke 'create publicc synonym' from schema 'PROD' on schema 'SYS';
REM           (12) Drop user 'qwz' on schema 'SYS';
REM
REM         The advantage and convenience of this approach is that it could not only revoke more than one user but also just revoke role.
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
PROMPT Executing on "SYS" schema
PROMPT =========================

REVOKE prod FROM qwz;

PROMPT ==========================
PROMPT Executing on "PROD" schema
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

DROP PUBLIC SYNONYM usr_tables;
REVOKE SELECT ON usr_tables FROM prod;

DROP VIEW usr_tables;

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

CONN / as sysdba;

DROP ROLE prod;

REVOKE drop any view FROM prod;
REVOKE create view FROM prod;

REVOKE drop public synonym FROM prod;
REVOKE create public synonym FROM prod;

REVOKE connect, resource FROM qwz;
DROP USER qwz;

-- Or just revoke role_name from new user_name.
-- REVOKE prod FROM qwz;
