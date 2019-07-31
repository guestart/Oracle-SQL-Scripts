REM
REM     Script:    bgs_role_syn_tab_2.sql
REM     Author:    Quanwen Zhao
REM     Dated:     Jul 15, 2019
REM     Updated:   Jul 24, 2019
REM                (1) Eliminating query column 'num_rows' on creating materialized view 'u_tables';
REM                (2) Adding 'DROP ROLE bbs' in front of 'CREATE ROLE bbs'.
REM     Updated:   Jul 31, 2019
REM                (1) Adding keyword "or replace" within those two SQL statements of "create public synonym ...",
REM                    like this, "create or replace public synonym ...".
REM
REM     Purpose:
REM         This SQL script uses to batch grant (only) select privilege on specific user (prod)'s all of tables to
REM         a new role (bbs) and then grant this role to new user (qwz). At the same time it could also query out
REM         schema (prod)'s all of table names on schema (qwz).
REM
REM         The order of executing steps are as follws:
REM           (01) Create new user 'qwz' and grant connect, resource to it on schema 'SYS';
REM           (02) Grant create and drop public synonym to schema 'prod' on schema 'SYS';
REM           (03) Grant create any materialized view and drop any materialized view to schema 'prod' on schema 'SYS';
REM           (04) Create new role 'bbs' on schema 'SYS';
REM           (05) First, drop materialized view 'u_tables' on schema 'prod';
REM           (06) Create materialized view u_tables on schema 'prod';
REM           (07) Grant select on u_tables to role 'bbs' on schema 'prod';
REM           (08) Create public synonym u_tables for u_tables on schema 'prod';
REM           (09) Batch generate "grant (only) select privilege on schema (prod)'s all of tables to a new role (bbs) on schema 'prod';
REM           (10) Also batch generate "create the name of public synonym for original table name" on schema 'prod';
REM           (11) Execute SPOOL sql file 'gen_bgs_role_syn_tab_2.sql' on schema 'prod';
REM           (12) Grant new role (bbs) to new user (qwz) on schema 'SYS';
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

GRANT create any materialized view TO prod;
GRANT drop any materialized view TO prod;
GRANT on commit refresh TO prod;

DROP ROLE bbs;
CREATE ROLE bbs;

PROMPT ==========================
PROMPT Executing on "PROD" schema
PROMPT ==========================

-- switching to specific schema "prod", BTW I use Oracle SEPS (Security External Password Store) to achieve the intention
-- saving password of schema "prod".

CONN /@prod;

DROP MATERIALIZED VIEW u_tables; 

CREATE MATERIALIZED VIEW u_tables
-- BUILD IMMEDIATE
-- DISABLE QUERY REWRITE
REFRESH COMPLETE ON DEMAND
AS
   SELECT table_name
--        , num_rows
          , partitioned
   FROM all_tables
   WHERE owner = 'PROD'
   ORDER BY table_name
;

GRANT SELECT ON u_tables TO bbs;
-- CREATE PUBLIC SYNONYM u_tables FOR u_tables;
CREATE OR REPLACE PUBLIC SYNONYM u_tables FOR u_tables;

SPOOL gen_bgs_role_syn_tab_2.sql
SELECT 'GRANT SELECT ON '
       || table_name
       || ' TO bbs;'
FROM user_tables
ORDER BY table_name
/

-- SELECT 'CREATE PUBLIC SYNONYM '
SELECT 'CREATE OR REPLACE PUBLIC SYNONYM '
       || table_name
       || ' FOR '
       || table_name
       || ';'
FROM user_tables
ORDER BY table_name
/
SPOOL off

@gen_bgs_role_syn_tab_2.sql;

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

CONN / as sysdba;
GRANT bbs TO qwz;

-- The following is a demo (running on Jul 15, 2019) of how to use this SQL script (grantor schema is 'SZD_BBS_V2' and grantee schema is 'QWZ').

-- SYS@xxxx> @bgs_role_syn_tab_2.sql;
-- SYS@xxxx> 

-- QWZ@xxxx> set linesize 100
-- QWZ@xxxx> set pagesize 50
-- QWZ@xxxx> 
-- QWZ@xxxx> select * from u_tables;
--
-- TABLE_NAME                                                     NUM_ROWS PARTIT  
-- ------------------------------------------------------------ ---------- ------  
-- MD_BBS_ASSUME                                                         0 NO
-- MD_BBS_BOARD                                                   27833709 NO
-- MD_BBS_BOARD_CASE0723                                             24141 NO
-- MD_BBS_FILE                                                        1958 NO
-- MD_BBS_PIC                                                         1373 NO
-- MD_BBS_PRAISE_LOG                                                    10 NO
-- MD_BBS_REPLY                                                     107508 NO
-- MD_BBS_TOPIC                                                   10329942 NO
-- MD_BBS_TOPIC_20190704                                          10404822 NO
-- MD_BBS_TOPIC_CASE                                                 52688 NO
-- MD_BBS_USER                                                           0 NO
-- MD_BBS_USER_BOARD_MAP                                           2366795 NO
-- MD_BBS_VIDEO                                                        321 NO
-- MLOG$_T1                                                                NO
-- RUPD$_T1                                                                NO
-- T1                                                                    7 NO
-- TEST                                                              68373 NO
-- TEST2                                                             68375 NO
-- TEST3                                                               134 NO
-- U_TABLES                                                                NO
-- 
-- 20 rows selected.

-- SZD_BBS_V2@xxxx> set linesize 100
-- SZD_BBS_V2@xxxx> set pagesize 50
-- SZD_BBS_V2@xxxx> 
-- SZD_BBS_V2@xxxx> select table_name, num_rows, partitioned from user_tables order by table_name;
-- 
-- TABLE_NAME                                                     NUM_ROWS PARTIT
-- ------------------------------------------------------------ ---------- ------  
-- MD_BBS_ASSUME                                                         0 NO
-- MD_BBS_BOARD                                                   27833709 NO
-- MD_BBS_BOARD_CASE0723                                             24141 NO
-- MD_BBS_FILE                                                        1958 NO
-- MD_BBS_PIC                                                         1373 NO
-- MD_BBS_PRAISE_LOG                                                    10 NO
-- MD_BBS_REPLY                                                     107508 NO
-- MD_BBS_TOPIC                                                   10329942 NO
-- MD_BBS_TOPIC_20190704                                          10404822 NO
-- MD_BBS_TOPIC_CASE                                                 52688 NO
-- MD_BBS_USER                                                           0 NO
-- MD_BBS_USER_BOARD_MAP                                           2366795 NO
-- MD_BBS_VIDEO                                                        321 NO
-- MLOG$_T1                                                                NO
-- RUPD$_T1                                                                NO
-- T1                                                                    7 NO
-- TEST                                                              68373 NO
-- TEST2                                                             68375 NO
-- TEST3                                                               134 NO
-- U_TABLES                                                                NO
-- 
-- 20 rows selected.

-- SZD_BBS_V2@xxxx> create table t2 as select * from all_objects;
-- 
-- Table created. 
-- 
-- SZD_BBS_V2@xxxx> exec dbms_stats.gather_table_stats(ownname=>'SZD_BBS_V2', tabname=>'T2');
-- 
-- PL/SQL procedure successfully completed.
-- 
-- SZD_BBS_V2@xxxx> exec dbms_mview.refresh('U_TABLES', 'F');
-- BEGIN dbms_mview.refresh('U_TABLES', 'F'); END;
-- 
-- *
-- ERROR at line 1:
-- ORA-12004: REFRESH FAST cannot be used for materialized view "SZD_BBS_V2"."U_TABLES"
-- ORA-06512: at "SYS.DBMS_SNAPSHOT", line 2809
-- ORA-06512: at "SYS.DBMS_SNAPSHOT", line 3025
-- ORA-06512: at "SYS.DBMS_SNAPSHOT", line 2994
-- ORA-06512: at line 1
-- 
-- 
-- SZD_BBS_V2@xxxx> exec dbms_mview.refresh('U_TABLES', 'C');
-- 
-- PL/SQL procedure successfully completed.
-- 
-- SZD_BBS_V2@xxxx> select table_name, num_rows, partitioned from user_tables order by table_name;
--   
-- TABLE_NAME                                                     NUM_ROWS PARTIT
-- ------------------------------------------------------------ ---------- ------
-- MD_BBS_ASSUME                                                         0 NO
-- MD_BBS_BOARD                                                   27833709 NO
-- MD_BBS_BOARD_CASE0723                                             24141 NO
-- MD_BBS_FILE                                                        1958 NO
-- MD_BBS_PIC                                                         1373 NO
-- MD_BBS_PRAISE_LOG                                                    10 NO
-- MD_BBS_REPLY                                                     107508 NO
-- MD_BBS_TOPIC                                                   10329942 NO
-- MD_BBS_TOPIC_20190704                                          10404822 NO
-- MD_BBS_TOPIC_CASE                                                 52688 NO
-- MD_BBS_USER                                                           0 NO
-- MD_BBS_USER_BOARD_MAP                                           2366795 NO
-- MD_BBS_VIDEO                                                        321 NO
-- MLOG$_T1                                                                NO
-- RUPD$_T1                                                                NO
-- T1                                                                    7 NO
-- T2                                                                68390 NO
-- TEST                                                              68373 NO
-- TEST2                                                             68375 NO
-- TEST3                                                               134 NO
-- U_TABLES                                                                NO
-- 
-- 21 rows selected.

-- QWZ@xxxx> select * from u_tables order by table_name;
-- 
-- TABLE_NAME                                                     NUM_ROWS PARTIT
-- ------------------------------------------------------------ ---------- ------
-- MD_BBS_ASSUME                                                         0 NO
-- MD_BBS_BOARD                                                   27833709 NO
-- MD_BBS_BOARD_CASE0723                                             24141 NO
-- MD_BBS_FILE                                                        1958 NO
-- MD_BBS_PIC                                                         1373 NO
-- MD_BBS_PRAISE_LOG                                                    10 NO
-- MD_BBS_REPLY                                                     107508 NO
-- MD_BBS_TOPIC                                                   10329942 NO
-- MD_BBS_TOPIC_20190704                                          10404822 NO
-- MD_BBS_TOPIC_CASE                                                 52688 NO
-- MD_BBS_USER                                                           0 NO
-- MD_BBS_USER_BOARD_MAP                                           2366795 NO
-- MD_BBS_VIDEO                                                        321 NO
-- MLOG$_T1                                                                NO
-- RUPD$_T1                                                                NO
-- T1                                                                    7 NO
-- T2                                                                68390 NO
-- TEST                                                              68373 NO
-- TEST2                                                             68375 NO
-- TEST3                                                               134 NO
-- U_TABLES                                                                NO
-- 
-- 21 rows selected.
