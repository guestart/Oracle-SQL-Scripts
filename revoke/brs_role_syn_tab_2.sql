REM
REM     Script:    brs_role_syn_tab_2.sql
REM     Author:    Quanwen Zhao
REM     Dated:     Jul 15, 2019
REM
REM     Purpose:
REM         This SQL script uses to revoke new role (bbs) from new user (qwz) to whom if (once) being granted on schema 'SYS'.
REM
REM         If you wanna furthermore revoke select privilege on new role (bbs) and drop this role you can do the following steps:
REM           (01) Batch generate "revoke (only) select privilege on specific user (prod)'s all of tables from a new role (bbs)" on schema 'prod';
REM           (02) Also batch generate "drop the name of public synonym for original table name" on schema 'prod';
REM           (03) Execute SPOOL sql file 'gen_brs_role_syn_tab_2.sql' on schema 'prod';
REM           (04) Drop public synonym u_tables on schema 'prod';
REM           (05) Revoke 'select on u_tables' from role 'bbs' on schema 'prod';
REM           (06) Drop materialized view 'u_tables' on schema 'prod';
REM           (07) Drop role 'bbs' on schema 'SYS';
REM           (08) Revoke 'drop any materialized view' from schema 'prod' on schema 'SYS';
REM           (09) Revoke 'create any materialized view' from schema 'prod' on schema 'SYS';
REM           (10) Revoke 'drop public synonym' from schema 'prod' on schema 'SYS';
REM           (11) Revoke 'create public synonym' from schema 'prod' on schema 'SYS';
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

REVOKE bbs FROM qwz;

PROMPT ==========================
PROMPT Executing on "prod" schema
PROMPT ==========================

-- switching to specific schema "prod", BTW I use Oracle SEPS (Security External Password Store) to achieve the intention
-- saving password of schema "prod".

CONN /@prod;

SPOOL gen_brs_role_syn_tab_2.sql
SELECT 'REVOKE SELECT ON '
       || table_name
       || ' FROM bbs;'
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

@gen_brs_role_syn_tab_2.sql;

DROP PUBLIC SYNONYM u_tables;
REVOKE SELECT ON u_tables FROM bbs;

DROP MATERIALIZED VIEW u_tables;

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

CONN / as sysdba;

DROP ROLE bbs;

REVOKE drop any materialized view FROM prod;
REVOKE create any materialized view FROM prod;

REVOKE drop public synonym FROM prod;
REVOKE create public synonym FROM prod;

REVOKE connect, resource FROM qwz;
DROP USER qwz;

-- Or just revoke role_name from new user_name.
-- REVOKE bbs FROM qwz;
