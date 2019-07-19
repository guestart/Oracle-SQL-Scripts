REM
REM     Script:    bgs_role_syn_tab_3.sql
REM     Author:    Quanwen Zhao
REM     Dated:     Jul 18, 2019
REM
REM     Purpose:
REM         This SQL script uses to grant (only) select privilege on specific user (prod)'s tables T1 to
REM         a new role (bbs) and then grant this role to new user (qwz). At the same time it could also query out
REM         table T1's latest data of schema (prod) on schema (qwz).
REM
REM         The order of executing steps are as follws:
REM           (01) Create new user 'qwz' and grant connect, resource to it on schema 'SYS';
REM           (02) Grant create and drop public synonym to schema 'prod' on schema 'SYS';
REM           (03) Grant create any materialized view and drop any materialized view to schema 'prod' on schema 'SYS';
REM           (04) Create new role 'bbs' on schema 'SYS';
REM           (05) First, drop materialized view 'mv_t1' on schema 'prod';
REM           (06) Create materialized view 'mv_t1' on schema 'prod';
REM           (07) Grant select on mv_t1 to role 'bbs' on schema 'prod';
REM           (08) Create public synonym mv_t1 for mv_t1 on schema 'prod';
REM           (09) Grant new role (bbs) to new user (qwz) on schema 'SYS';
REM
REM         The advantage and convenience of this approach is that it could not only grant more than one user but also just revoke role.
REM

-- Firstly I create a table T1 on schema 'prod'.

-- PROD@xxxx> create table t1 (id number, name varchar2(30));
-- 
-- Table created.
-- 
-- PROD@xxxx> insert into t1 values (1, 'Quanwen Zhao');
-- 
-- 1 row created.
-- 
-- PROD@xxxx> insert into t1 values (2, 'Zlatko Sirotic');
-- 
-- 1 row created.
-- 
-- PROD@xxxx> insert into t1 values (3, 'Sven Weller');
-- 
-- 1 row created.
-- 
-- PROD@xxxx> insert into t1 values (4, 'L Fernigrini');
-- 
-- 1 row created.
-- 
-- PROD@xxxx> insert into t1 values (5, 'Cookie Monster');
-- 
-- 1 row created.
-- 
-- PROD@xxxx> insert into t1 values (6, 'Jara Mill');
-- 
-- 1 row created.
-- 
-- PROD@xxxx> insert into t1 values (7, 'Paul Zip');
-- 
-- 1 row created.
-- 
-- PROD@xxxx> commit;
-- 
-- Commit complete.
-- 
-- PROD@xxxx> exec dbms_stats.gather_table_stats(ownname=>'PROD', tabname=>'T1');
-- 
-- PL/SQL procedure successfully completed.
-- 
-- PROD@xxxx> set linesize 100
-- PROD@xxxx> set pagesize 50
-- PROD@xxxx> select table_name, num_rows, partitioned from user_tables order by table_name;
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
-- T1                                                                    7 NO
-- TEST                                                              68373 NO
-- TEST2                                                             68375 NO
-- TEST3                                                               134 NO
-- 
-- 17 rows selected.

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

CREATE ROLE bbs;

PROMPT ==========================
PROMPT Executing on "PROD" schema
PROMPT ==========================

-- switching to specific schema "prod", BTW I use Oracle SEPS (Security External Password Store) to achieve the intention
-- saving password of schema "prod".

CONN /@prod;

DROP MATERIALIZED VIEW mv_t1; 

CREATE MATERIALIZED VIEW mv_t1
-- BUILD IMMEDIATE
-- DISABLE QUERY REWRITE
-- REFRESH FAST ON COMMIT
REFRESH COMPLETE ON DEMAND
AS
   SELECT id
          , name
   FROM t1
   ORDER BY id
;

-- CREATE MATERIALIZED VIEW LOG ON t1
-- WITH PRIMARY KEY
-- INCLUDING NEW VALUES
-- ;

GRANT SELECT ON mv_t1 TO bbs;
CREATE PUBLIC SYNONYM mv_t1 FOR mv_t1;

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

CONN / as sysdba;
GRANT bbs TO qwz;

-- The following demo guide you how to use this SQL script file.

-- SYS@xxxx> @bgs_role_syn_tab_3.sql;
-- SYS@xxxx> 
-- 
-- QWZ@xxxx> select * from mv_t1;
-- 
--         ID NAME
-- ---------- ------------------------------------------------------------
--          1 Quanwen Zhao
--          2 Zlatko Sirotic
--          3 Sven Weller
--          4 L Fernigrini
--          5 Cookie Monster
--          6 Jara Mill
--          7 Paul Zip
-- 
-- PROD@xxxx> insert into t1 values (8, 'Mark Powell');
-- 
-- 1 row created.
-- 
-- PROD@xxxx> insert into t1 values (9, 'Andrew Sayer');
-- 
-- 1 row created.
-- 
-- PROD@xxxx> exec dbms_mview.refresh('MV_T1', 'F'); -- or exec dbms_mview.refresh('MV_T1', 'C');
-- 
-- PL/SQL procedure successfully completed.
-- 
-- QWZ@xxxx> select * from mv_t1;
-- 
--         ID NAME
-- ---------- ------------------------------------------------------------
--          1 Quanwen Zhao
--          2 Zlatko Sirotic
--          3 Sven Weller
--          4 L Fernigrini
--          5 Cookie Monster
--          6 Jara Mill
--          7 Paul Zip
--          8 Mark Powell
--          9 Andrew Sayer
-- 
-- 9 rows selected.
