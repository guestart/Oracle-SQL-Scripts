REM
REM     Script:    bgs_role_syn.sql
REM     Author:    Quanwen Zhao
REM     Dated:     Jul 03, 2019
REM
REM     Purpose:
REM         This SQL script uses to batch grant (only) select privilege on specific user (prod)'s all of tables to
REM         a new role (prod) and then grant this role to new user (qwz).
REM
REM         The order of executing steps are as follws:
REM           (1) Create new user 'qwz' and grant connect, resource to it on schema 'SYS';
REM           (2) Grant create and drop public synonym to schema 'PROD' on schema 'SYS';
REM           (3) Create new role 'prod' on schema 'SYS';
REM           (4) Batch generate "grant (only) select privilege on schema (prod)'s all of tables to a new role (prod)" on schema 'PROD';
REM           (5) Also batch generate "create the name of public synonym for original table name" on schema 'PROD';
REM           (6) Execute SPOOL sql file 'gen_bgs_role_syn.sql' on schema 'PROD';
REM           (7) grant new role (prod) to new user (qwz) on schema 'SYS';
REM
REM         The advantage and convenience of this approach is that it could not only grant more than one user but also just revoke role.
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

DROP USER qwz;
CREATE USER qwz IDENTIFIED BY qwz;
GRANT connect, resource TO qwz;

GRANT create public synonym TO prod;
GRANT drop public synonym TO prod;

CREATE ROLE prod;

PROMPT ==========================
PROMPT Executing on "PROD" schema
PROMPT ==========================

-- switching to specific schema "prod", BTW I use Oracle SEPS (Security External Password Store) to achieve the intention
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

@gen_bgs_role_syn.sql;

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

CONN / as sysdba;
GRANT prod TO qwz;
