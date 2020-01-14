REM
REM     Script:        optimize_query_null_value.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Jan 14, 2020
REM
REM     Last tested:
REM             18.3.0.0
REM             19.3.0.0
REM
REM     Purpose:
REM        This Demo script mainly uses to optimize the SQL query of "NULL" value.
REM        I respectively create 4 number of index so that observing the corresponding
REM        row source execution plan to attain the goal of optimization.
REM

SET LINESIZE 300
SET PAGESIZE 300
SET SERVEROUTPUT OFF
ALTER SESSION SET statistics_level = all;

PROMPT ====================================================================
PROMPT  Creating Tablespace, Temporary Tablespace and appropriate User,
PROMPT  meanwhile granting several role and object privileges to that User
PROMPT ====================================================================

CREATE TABLESPACE qwz DATAFILE 'C:\APP\ADMINISTRATOR\VIRTUAL\ORADATA\ORA19C\QWZ01.DBF' SIZE 2g;
CREATE TEMPORARY TABLESPACE qwz_temp TEMPFILE 'C:\APP\ADMINISTRATOR\VIRTUAL\ORADATA\ORA19C\QWZ_TEMP01.DBF' size 5g;
CREATE USER c##qwz IDENTIFIED BY qwz DEFAULT TABLESPACE qwz TEMPORARY TABLESPACE qwz_temp QUOTA UNLIMITED ON qwz;

GRANT connect, resource TO c##qwz;

GRANT select ON v_$sql_plan TO c##qwz;
GRANT select ON v_$session TO c##qwz;
GRANT select ON v_$sql_plan_statistics_all TO c##qwz;
GRANT select ON v_$sql TO c##qwz;

PROMPT =============================================
PROMPT  Creating table "test", inserting some data, 
PROMPT  next observing its data distribution.
PROMPT =============================================

CREATE TABLE test
( id   NUMBER GENERATED ALWAYS AS IDENTITY
, flag VARCHAR2(1)
, pwd  VARCHAR2(6)
, CONSTRAINT test_pk PRIMARY KEY(id)
);

INSERT /*+APPEND*/ INTO test (flag, pwd)
SELECT CASE WHEN ROWNUM <= 1e5 - 50 THEN NULL
            WHEN ROWNUM <= 1e5 - 45 THEN 'T'
            ELSE 'F'
       END flag
     , DBMS_RANDOM.string ('p', 6) pwd
FROM dual
CONNECT BY level <= 1e5;

COMMIT;

SELECT COUNT(*) FROM test;

COLUMN flag FORMAT a4

SELECT flag, COUNT(*)
FROM   test
GROUP BY flag
ORDER BY 1 NULLS FIRST;

PROMPT ==========================================================
PROMPT  Creating Single Column Index "test_idx" on column "flag"
PROMPT ==========================================================

CREATE INDEX test_idx ON test (flag);

EXEC SYS.DBMS_STATS.gather_table_stats(ownname => NULL, tabname => 'TEST');

COLUMN index_name       FORMAT a10
COLUMN index_type       FORMAT a10
COLUMN constraint_index FORMAT a16

SELECT index_name
     , index_type
     , num_rows
     , leaf_blocks
--   , constraint_index
FROM user_indexes
WHERE table_name = 'TEST'
ORDER BY 1;

SELECT COUNT(*) FROM test WHERE flag IS NULL;
SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));

SELECT COUNT(*) FROM test WHERE flag = 'T';
SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));

PROMPT ====================================================================
PROMPT  Creating Composite Index "test_idx_2" on two columns "flag", "pwd"
PROMPT ====================================================================

CREATE INDEX test_idx_2 ON test (flag, pwd);

EXEC SYS.DBMS_STATS.gather_table_stats(ownname => NULL, tabname => 'TEST');

COLUMN index_name       FORMAT a10
COLUMN index_type       FORMAT a10
COLUMN constraint_index FORMAT a16

SELECT index_name
     , index_type
     , num_rows
     , leaf_blocks
--   , constraint_index
FROM user_indexes
WHERE table_name = 'TEST'
ORDER BY 1;

SELECT pwd FROM test WHERE flag IS NULL;
SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));

SELECT pwd FROM test WHERE flag = 'T';
SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));

PROMPT ==============================================================
PROMPT  Creating Function-Based Index "test_idx_fn" on column "flag"
PROMPT ==============================================================

CREATE INDEX test_idx_fn ON test (NVL(flag, '0'));

EXEC SYS.DBMS_STATS.gather_table_stats(ownname => NULL, tabname => 'TEST');

COLUMN index_name       FORMAT a11
COLUMN index_type       FORMAT a21
COLUMN constraint_index FORMAT a16

SELECT index_name
     , index_type
     , num_rows
     , leaf_blocks
--   , constraint_index
FROM user_indexes
WHERE table_name = 'TEST'
ORDER BY 1;

SELECT COUNT(*) FROM test WHERE NVL(flag, '0') = '0';
SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));

SELECT COUNT(*) FROM test WHERE NVL(flag, '0') = 'T';
SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));

-- Checking the invisible virtual column on function-based index "test_idx_fn".

COLUMN table_name     FORMAT a10
COLUMN extension_name FORMAT a14
COLUMN extension      FORMAT a17
COLUMN creator        FORMAT a7
COLUMN droppable      FORMAT a9

SELECT * FROM user_stat_extensions WHERE table_name = 'TEST';

COLUMN sys_nc00004$ FORMAT a12

SELECT SYS_NC00004$
     , COUNT(*)
FROM test
GROUP BY SYS_NC00004$
ORDER BY 1;

PROMPT ===========================================================
PROMPT  Creating Virtual Column "virtual_flag" (within INVISIBLE)
PROMPT  using SQL clause "GENERATED ALWAYS AS (NVL(flag, '0'))"
PROMPT ===========================================================

DROP INDEX test_idx_fn;

ALTER TABLE test ADD virtual_flag VARCHAR2(1) INVISIBLE 
GENERATED ALWAYS AS (NVL(flag, '0'));

COLUMN table_name     FORMAT a10
COLUMN extension_name FORMAT a14
COLUMN extension      FORMAT a17
COLUMN creator        FORMAT a7
COLUMN droppable      FORMAT a9

SELECT * FROM user_stat_extensions WHERE table_name = 'TEST';

CREATE INDEX test_virtual_flag ON test (virtual_flag);

COLUMN virtual_flag FORMAT a12

SELECT VIRTUAL_FLAG
     , COUNT(*)
FROM test
GROUP BY VIRTUAL_FLAG
ORDER BY 1;

COLUMN index_name       FORMAT a17
COLUMN index_type       FORMAT a21
COLUMN constraint_index FORMAT a16

SELECT index_name
     , index_type
     , num_rows
     , leaf_blocks
--   , constraint_index
FROM user_indexes
WHERE table_name = 'TEST'
ORDER BY 1;

SELECT COUNT(*) FROM test WHERE virtual_flag = '0';
SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));

SELECT COUNT(*) FROM test WHERE virtual_flag = '0';
SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));

SELECT COUNT(*) FROM test WHERE NVL(flag, '0') = '0';
SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));

SELECT COUNT(*) FROM test WHERE NVL(flag, '0') = '0';
SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));

SELECT COUNT(*) FROM test WHERE flag = 'T';
SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));

-- The following is output of this SQL script, like this:

-- PROMPT =============================================
-- PROMPT  Creating table "test", inserting some data, 
-- PROMPT  next observing its data distribution.
-- PROMPT =============================================
-- 
-- SELECT COUNT(*) FROM test;
-- 
--   COUNT(*)
-- ----------
--     100000
-- 
-- COLUMN flag FORMAT a4
-- 
-- SELECT flag, COUNT(*)
-- FROM   test
-- GROUP BY flag
-- ORDER BY 1 NULLS FIRST;
-- 
-- FLAG   COUNT(*)
-- ---- ----------
--           99950
-- F            45
-- T             5
-- 
-- PROMPT ==========================================================
-- PROMPT  Creating Single Column Index "test_idx" on column "flag"
-- PROMPT ==========================================================
-- 
-- COLUMN index_name       FORMAT a10
-- COLUMN index_type       FORMAT a10
-- COLUMN constraint_index FORMAT a16
-- 
-- SELECT index_name
--      , index_type
--      , num_rows
--      , leaf_blocks
-- --   , constraint_index
-- FROM user_indexes
-- WHERE table_name = 'TEST'
-- ORDER BY 1;
-- 
-- INDEX_NAME INDEX_TYPE   NUM_ROWS LEAF_BLOCKS
-- ---------- ---------- ---------- -----------
-- TEST_IDX   NORMAL             50           1
-- TEST_PK    NORMAL         100000         187
-- 
-- SELECT COUNT(*) FROM test WHERE flag IS NULL;
-- 
--   COUNT(*)
-- ----------
--      99950
-- 
-- SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));
-- 
-- -------------------------------------
-- SQL_ID  9adyx4fz8g6bd, child number 0
-- -------------------------------------
-- SELECT COUNT(*) FROM test WHERE flag IS NULL
-- 
-- Plan hash value: 1950795681
-- 
-- -------------------------------------------------------------------------------------
-- | Id  | Operation          | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- -------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT   |      |      1 |        |      1 |00:00:00.01 |     251 |
-- |   1 |  SORT AGGREGATE    |      |      1 |      1 |      1 |00:00:00.01 |     251 |
-- |*  2 |   TABLE ACCESS FULL| TEST |      1 |  99950 |  99950 |00:00:00.01 |     251 |
-- -------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - filter("FLAG" IS NULL)
-- 
-- SELECT COUNT(*) FROM test WHERE flag = 'T';
-- 
--   COUNT(*)
-- ----------
--          5
-- 
-- SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));
-- 
-- -------------------------------------
-- SQL_ID  d92v6na2hqyr0, child number 0
-- -------------------------------------
-- SELECT COUNT(*) FROM test WHERE flag = 'T'
-- 
-- Plan hash value: 190015244
-- 
-- ----------------------------------------------------------------------------------------
-- | Id  | Operation         | Name     | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- ----------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT  |          |      1 |        |      1 |00:00:00.01 |       1 |
-- |   1 |  SORT AGGREGATE   |          |      1 |      1 |      1 |00:00:00.01 |       1 |
-- |*  2 |   INDEX RANGE SCAN| TEST_IDX |      1 |     25 |      5 |00:00:00.01 |       1 |
-- ----------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - access("FLAG"='T')
-- 
-- PROMPT ====================================================================
-- PROMPT  Creating Composite Index "test_idx_2" on two columns "flag", "pwd"
-- PROMPT ====================================================================
-- 
-- CREATE INDEX test_idx_2 ON test (flag, pwd);
-- 
-- EXEC SYS.DBMS_STATS.gather_table_stats(ownname => NULL, tabname => 'TEST');
-- 
-- COLUMN index_name       FORMAT a10
-- COLUMN index_type       FORMAT a10
-- COLUMN constraint_index FORMAT a16
-- 
-- SELECT index_name
--      , index_type
--      , num_rows
--      , leaf_blocks
-- --   , constraint_index
-- FROM user_indexes
-- WHERE table_name = 'TEST'
-- ORDER BY 1;
-- 
-- INDEX_NAME INDEX_TYPE   NUM_ROWS LEAF_BLOCKS
-- ---------- ---------- ---------- -----------
-- TEST_IDX   NORMAL             50           1
-- TEST_IDX_2 NORMAL         100000         265
-- TEST_PK    NORMAL         100000         187
-- 
-- 
-- SELECT pwd FROM test WHERE flag IS NULL;
-- 
-- PWD
-- ------
-- ...
-- %+5CPj
-- 
-- 99950 rows select.
-- 
-- 
-- SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));
-- 
-- -------------------------------------
-- SQL_ID  5ky5p6xbhptcy, child number 0
-- -------------------------------------
-- SELECT pwd FROM test WHERE flag IS NULL
-- 
-- Plan hash value: 1357081020
-- 
-- ------------------------------------------------------------------------------------
-- | Id  | Operation         | Name | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- ------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT  |      |      1 |        |  99950 |00:00:00.08 |    6862 |
-- |*  1 |  TABLE ACCESS FULL| TEST |      1 |  99950 |  99950 |00:00:00.08 |    6862 |
-- ------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("FLAG" IS NULL)
-- 
-- SELECT pwd FROM test WHERE flag = 'T';
-- 
-- PWD
-- ------
-- @@CWM+
-- ZKBYr~
-- ^'+2a"
-- jVda=)
-- s,V,LL
-- 
-- SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));
-- 
-- -------------------------------------
-- SQL_ID  9drjb2sv2mwnh, child number 0
-- -------------------------------------
-- SELECT pwd FROM test WHERE flag = 'T'
-- 
-- Plan hash value: 289448651
-- 
-- -----------------------------------------------------------------------------------------
-- | Id  | Operation        | Name       | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- -----------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT |            |      1 |        |      5 |00:00:00.01 |       3 |
-- |*  1 |  INDEX RANGE SCAN| TEST_IDX_2 |      1 |      5 |      5 |00:00:00.01 |       3 |
-- -----------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - access("FLAG"='T')
-- 
-- PROMPT ==============================================================
-- PROMPT  Creating Function-Based Index "test_idx_fn" on column "flag"
-- PROMPT ==============================================================
-- 
-- COLUMN index_name       FORMAT a11
-- COLUMN index_type       FORMAT a21
-- COLUMN constraint_index FORMAT a16
-- 
-- SELECT index_name
--      , index_type
--      , num_rows
--      , leaf_blocks
-- --   , constraint_index
-- FROM user_indexes
-- WHERE table_name = 'TEST'
-- ORDER BY 1;
-- 
-- INDEX_NAME  INDEX_TYPE              NUM_ROWS LEAF_BLOCKS
-- ----------- --------------------- ---------- -----------
-- TEST_IDX    NORMAL                        50           1
-- TEST_IDX_2  NORMAL                    100000         265
-- TEST_IDX_FN FUNCTION-BASED NORMAL     100000         182
-- TEST_PK     NORMAL                    100000         187
-- 
-- 
-- SELECT COUNT(*) FROM test WHERE NVL(flag, '0') = '0';
-- 
--   COUNT(*)
-- ----------
--      99950
-- 
-- SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));
-- 
-- -------------------------------------
-- SQL_ID  8vx32xsytynuz, child number 0
-- -------------------------------------
-- SELECT COUNT(*) FROM test WHERE NVL(flag, '0') = '0'
-- 
-- Plan hash value: 948231894
-- 
-- -----------------------------------------------------------------------------------------------
-- | Id  | Operation             | Name        | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- -----------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT      |             |      1 |        |      1 |00:00:00.04 |     190 |
-- |   1 |  SORT AGGREGATE       |             |      1 |      1 |      1 |00:00:00.04 |     190 |
-- |*  2 |   INDEX FAST FULL SCAN| TEST_IDX_FN |      1 |  33333 |  99950 |00:00:00.03 |     190 |
-- -----------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - filter("TEST"."SYS_NC00004$"='0')
-- 
-- SELECT COUNT(*) FROM test WHERE NVL(flag, '0') = 'T';
-- 
--   COUNT(*)
-- ----------
--          5
-- 
-- SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));
-- 
-- -------------------------------------
-- SQL_ID  gr2g8m3r0wxdd, child number 0
-- -------------------------------------
-- SELECT COUNT(*) FROM test WHERE NVL(flag, '0') = 'T'
-- 
-- Plan hash value: 948231894
-- 
-- -----------------------------------------------------------------------------------------------
-- | Id  | Operation             | Name        | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- -----------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT      |             |      1 |        |      1 |00:00:00.02 |     190 |
-- |   1 |  SORT AGGREGATE       |             |      1 |      1 |      1 |00:00:00.02 |     190 |
-- |*  2 |   INDEX FAST FULL SCAN| TEST_IDX_FN |      1 |  33333 |      5 |00:00:00.02 |     190 |
-- -----------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - filter("TEST"."SYS_NC00004$"='T')
-- 
-- -- Checking the invisible virtual column on function-based index "test_idx_fn".
-- 
-- COLUMN table_name     FORMAT a10
-- COLUMN extension_name FORMAT a14
-- COLUMN extension      FORMAT a17
-- COLUMN creator        FORMAT a7
-- COLUMN droppable      FORMAT a9
-- 
-- SELECT * FROM user_stat_extensions WHERE table_name = 'TEST';
-- 
-- TABLE_NAME EXTENSION_NAME EXTENSION         CREATOR DROPPABLE
-- ---------- -------------- ----------------- ------- ---------
-- TEST       SYS_NC00004$   (NVL("FLAG",'0')) SYSTEM  NO
-- 
-- COLUMN sys_nc00004$ FORMAT a12
-- 
-- SELECT SYS_NC00004$
--      , COUNT(*)
-- FROM test
-- GROUP BY SYS_NC00004$
-- ORDER BY 1;
-- 
-- SYS_NC00004$   COUNT(*)
-- ------------ ----------
-- 0                 99950
-- F                    45
-- T                     5
-- 
-- PROMPT ===========================================================
-- PROMPT  Creating Virtual Column "virtual_flag" (within INVISIBLE)
-- PROMPT  using SQL clause "GENERATED ALWAYS AS (NVL(flag, '0'))"
-- PROMPT ===========================================================
-- 
-- DROP INDEX test_idx_fn;
-- 
-- ALTER TABLE test ADD virtual_flag VARCHAR2(1) INVISIBLE 
-- GENERATED ALWAYS AS (NVL(flag, '0'));
-- 
-- COLUMN table_name     FORMAT a10
-- COLUMN extension_name FORMAT a14
-- COLUMN extension      FORMAT a17
-- COLUMN creator        FORMAT a7
-- COLUMN droppable      FORMAT a9
-- 
-- SELECT * FROM user_stat_extensions WHERE table_name = 'TEST';
-- 
-- TABLE_NAME EXTENSION_NAME EXTENSION         CREATOR DROPPABLE
-- ---------- -------------- ----------------- ------- ---------
-- TEST       VIRTUAL_FLAG   (NVL("FLAG",'0')) SYSTEM  NO
-- 
-- CREATE INDEX test_virtual_flag ON test (virtual_flag);
-- 
-- COLUMN virtual_flag FORMAT a12
-- 
-- SELECT VIRTUAL_FLAG
--      , COUNT(*)
-- FROM test
-- GROUP BY VIRTUAL_FLAG
-- ORDER BY 1;
-- 
-- VIRTUAL_FLAG   COUNT(*)
-- ------------ ----------
-- 0                 99950
-- F                    45
-- T                     5
-- 
-- COLUMN index_name       FORMAT a17
-- COLUMN index_type       FORMAT a21
-- COLUMN constraint_index FORMAT a16
-- 
-- SELECT index_name
--      , index_type
--      , num_rows
--      , leaf_blocks
-- --   , constraint_index
-- FROM user_indexes
-- WHERE table_name = 'TEST'
-- ORDER BY 1;
-- 
-- INDEX_NAME        INDEX_TYPE              NUM_ROWS LEAF_BLOCKS
-- ----------------- --------------------- ---------- -----------
-- TEST_IDX          NORMAL                        50           1
-- TEST_IDX_2        NORMAL                    100000         265
-- TEST_PK           NORMAL                    100000         187
-- TEST_VIRTUAL_FLAG FUNCTION-BASED NORMAL     100000         182
-- 
-- SELECT COUNT(*) FROM test WHERE virtual_flag = '0';
-- 
--   COUNT(*)
-- ----------
--      99950
-- 
-- SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));
-- 
-- -------------------------------------
-- SQL_ID  7pq1rf41qna91, child number 0
-- -------------------------------------
-- SELECT COUNT(*) FROM test WHERE virtual_flag = '0'
-- 
-- Plan hash value: 322223494
-- 
-- -----------------------------------------------------------------------------------------------------
-- | Id  | Operation             | Name              | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- -----------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT      |                   |      1 |        |      1 |00:00:00.03 |     190 |
-- |   1 |  SORT AGGREGATE       |                   |      1 |      1 |      1 |00:00:00.03 |     190 |
-- |*  2 |   INDEX FAST FULL SCAN| TEST_VIRTUAL_FLAG |      1 |   1000 |  99950 |00:00:00.02 |     190 |
-- -----------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - filter("VIRTUAL_FLAG"='0')
-- 
-- SELECT COUNT(*) FROM test WHERE virtual_flag = '0';
-- 
--   COUNT(*)
-- ----------
--      99950
-- 
-- SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));
-- 
-- -------------------------------------
-- SQL_ID  7pq1rf41qna91, child number 1
-- -------------------------------------
-- SELECT COUNT(*) FROM test WHERE virtual_flag = '0'
-- 
-- Plan hash value: 322223494
-- 
-- -----------------------------------------------------------------------------------------------------
-- | Id  | Operation             | Name              | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- -----------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT      |                   |      1 |        |      1 |00:00:00.02 |     190 |
-- |   1 |  SORT AGGREGATE       |                   |      1 |      1 |      1 |00:00:00.02 |     190 |
-- |*  2 |   INDEX FAST FULL SCAN| TEST_VIRTUAL_FLAG |      1 |  99950 |  99950 |00:00:00.02 |     190 |
-- -----------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - filter("VIRTUAL_FLAG"='0')
-- 
-- Note
-- -----
--    - statistics feedback used for this statement
-- 
-- SELECT COUNT(*) FROM test WHERE NVL(flag, '0') = '0';
-- 
--   COUNT(*)
-- ----------
--      99950
-- 
-- SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));
-- 
-- -------------------------------------
-- SQL_ID  8vx32xsytynuz, child number 0
-- -------------------------------------
-- SELECT COUNT(*) FROM test WHERE NVL(flag, '0') = '0'
-- 
-- Plan hash value: 322223494
-- 
-- -----------------------------------------------------------------------------------------------------
-- | Id  | Operation             | Name              | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- -----------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT      |                   |      1 |        |      1 |00:00:00.02 |     190 |
-- |   1 |  SORT AGGREGATE       |                   |      1 |      1 |      1 |00:00:00.02 |     190 |
-- |*  2 |   INDEX FAST FULL SCAN| TEST_VIRTUAL_FLAG |      1 |   1000 |  99950 |00:00:00.01 |     190 |
-- -----------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - filter("TEST"."VIRTUAL_FLAG"='0')
-- 
-- SELECT COUNT(*) FROM test WHERE NVL(flag, '0') = '0';
-- 
--   COUNT(*)
-- ----------
--      99950
-- 
-- SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));
-- 
-- -------------------------------------
-- SQL_ID  8vx32xsytynuz, child number 1
-- -------------------------------------
-- SELECT COUNT(*) FROM test WHERE NVL(flag, '0') = '0'
-- 
-- Plan hash value: 322223494
-- 
-- -----------------------------------------------------------------------------------------------------
-- | Id  | Operation             | Name              | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- -----------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT      |                   |      1 |        |      1 |00:00:00.02 |     190 |
-- |   1 |  SORT AGGREGATE       |                   |      1 |      1 |      1 |00:00:00.02 |     190 |
-- |*  2 |   INDEX FAST FULL SCAN| TEST_VIRTUAL_FLAG |      1 |  99950 |  99950 |00:00:00.01 |     190 |
-- -----------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - filter("TEST"."VIRTUAL_FLAG"='0')
-- 
-- Note
-- -----
--    - statistics feedback used for this statement
-- 
-- SELECT COUNT(*) FROM test WHERE flag = 'T';
-- 
--   COUNT(*)
-- ----------
--          5
-- 
-- SELECT * FROM table (DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));
-- 
-- PLAN_TABLE_OUTPUT
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SQL_ID  d92v6na2hqyr0, child number 0
-- -------------------------------------
-- SELECT COUNT(*) FROM test WHERE flag = 'T'
-- 
-- Plan hash value: 190015244
-- 
-- ----------------------------------------------------------------------------------------
-- | Id  | Operation         | Name     | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- ----------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT  |          |      1 |        |      1 |00:00:00.01 |       1 |
-- |   1 |  SORT AGGREGATE   |          |      1 |      1 |      1 |00:00:00.01 |       1 |
-- |*  2 |   INDEX RANGE SCAN| TEST_IDX |      1 |      5 |      5 |00:00:00.01 |       1 |
-- ----------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - access("FLAG"='T')
