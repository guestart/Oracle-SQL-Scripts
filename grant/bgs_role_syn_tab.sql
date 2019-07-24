REM
REM     Script:    bgs_role_syn_tab.sql
REM     Author:    Quanwen Zhao
REM     Dated:     Jul 09, 2019
REM     Updated:   Jul 24, 2019
REM                eliminate query column 'num_rows' on creating or replacing view 'usr_tables'.
REM                add 'DROP ROLE prod' in front of 'CREATE ROLE prod'.
REM
REM     Purpose:
REM         This SQL script uses to batch grant (only) select privilege on specific user (prod)'s all of tables to
REM         a new role (prod) and then grant this role to new user (qwz). At the same time it could also query out
REM         schema (prod)'s all of table names on schema (qwz).
REM
REM         The order of executing steps are as follws:
REM           (01) Create new user 'qwz' and grant connect, resource to it on schema 'SYS';
REM           (02) Grant create and drop public synonym to schema 'PROD' on schema 'SYS';
REM           (03) Grant create view and drop any view to schema 'PROD' on schema 'SYS';
REM           (04) Create new role 'prod' on schema 'SYS';
REM           (05) Create or replace view usr_tables on schema 'PROD';
REM           (06) Grant select on usr_table to role 'PROD' on schema 'PROD';
REM           (07) Create public synonym usr_tables for usr_tables on schema 'PROD';
REM           (08) Batch generate "grant (only) select privilege on schema (prod)'s all of tables to a new role (prod)" on schema 'PROD';
REM           (09) Also batch generate "create the name of public synonym for original table name" on schema 'PROD';
REM           (10) Execute SPOOL sql file 'gen_bgs_role_syn_tab.sql' on schema 'PROD';
REM           (11) Grant new role (prod) to new user (qwz) on schema 'SYS';
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

GRANT create view TO prod;
GRANT drop any view TO prod;

DROP ROLE prod;
CREATE ROLE prod;

PROMPT ==========================
PROMPT Executing on "PROD" schema
PROMPT ==========================

-- switching to specific schema "prod", BTW I use Oracle SEPS (Security External Password Store) to achieve the intention
-- saving password of schema "prod".

CONN /@prod;

CREATE OR REPLACE VIEW usr_tables
AS
SELECT table_name
--     , num_rows
       , partitioned
FROM all_tables
WHERE owner = 'PROD'
ORDER BY table_name
WITH READ ONLY
;

GRANT SELECT ON usr_tables TO prod;
CREATE PUBLIC SYNONYM usr_tables FOR usr_tables;

SPOOL gen_bgs_role_syn_tab.sql
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

@gen_bgs_role_syn_tab.sql;

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

CONN / as sysdba;
GRANT prod TO qwz;
