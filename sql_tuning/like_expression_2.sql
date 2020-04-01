REM
REM     Script:        like_expression_2.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Apr 01, 2020
REM
REM     Last tested:
REM             19.3.0.0
REM
REM     Purpose:  
REM       This sql script is the 2nd version of like_expression.sql, which will focus on talking about
REM       these two cases: "%qw" and "q%w".
REM

CREATE TABLE person
( id   NUMBER GENERATED ALWAYS AS IDENTITY
, name VARCHAR2(6) NOT NULL
, sex  VARCHAR2(1) NOT NULL
, flag VARCHAR2(1)
, pwd  VARCHAR2(6)
, CONSTRAINT person_pk PRIMARY KEY(id)
);

EXEC DBMS_RANDOM.seed(0);

INSERT /*+APPEND*/ INTO person (name, sex, flag, pwd)
SELECT DBMS_RANDOM.string('A', 6) AS name
     , CASE MOD(ROWNUM, 2) WHEN 0 THEN 'F'
                           WHEN 1 THEN 'M'
       END sex
     , CASE MOD(ROWNUM, 3) WHEN 0 THEN 'T'
                           WHEN 1 THEN NULL
                           WHEN 2 THEN 'F'
       END flag
     , DBMS_RANDOM.string ('p', 6) AS pwd
FROM dual
CONNECT BY level <= 3e5;

COMMIT;

EXEC DBMS_STATS.gather_table_stats(ownname => NULL, tabname => 'PERSON');

PROMPT =====
PROMPT '%qw'
PROMPT =====

CREATE INDEX idx_person_name_reverse ON person (name) REVERSE;

SET LINESIZE 300
SET PAGESIZE 150
SET SERVEROUTPUT OFF
  
ALTER SESSION SET statistics_level = all;

SELECT *
  FROM person
 WHERE name LIKE '%qw'
;

SELECT *
  FROM table(DBMS_XPLAN.display_cursor(null, null, 'cost allstats last'))
;

-- Plan hash value: 1493655343
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation         | Name   | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT  |        |      1 |        |   327 (100)|    113 |00:00:00.06 |    1160 |
-- |*  1 |  TABLE ACCESS FULL| PERSON |      1 |  15000 |   327   (3)|    113 |00:00:00.06 |    1160 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("NAME" LIKE '%qw')

SELECT /*+ index(person idx_person_name_reverse) */ *
  FROM person
 WHERE name LIKE '%qw'
;

SELECT *
  FROM table(DBMS_XPLAN.display_cursor(null, null, 'cost allstats last'))
;

-- Plan hash value: 3102595867
-- 
-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name                    | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers | Reads  |
-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |                         |      1 |        | 15757 (100)|    113 |00:00:00.20 |     875 |    753 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON                  |      1 |  15000 | 15757   (1)|    113 |00:00:00.20 |     875 |    753 |
-- |*  2 |   INDEX FULL SCAN                   | IDX_PERSON_NAME_REVERSE |      1 |  15000 |   761   (1)|    113 |00:00:00.20 |     762 |    753 |
-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - filter("NAME" LIKE '%qw')

CREATE INDEX idx_person_name_reverse_function ON person (REVERSE(name));

SELECT *
  FROM person
 WHERE REVERSE(name) LIKE REVERSE('%qw')
;

SELECT *
  FROM table(DBMS_XPLAN.display_cursor(null, null, 'cost allstats last'))
;

-- Plan hash value: 525723249
-- 
-- --------------------------------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name                             | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers | Reads  |
-- --------------------------------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |                                  |      1 |        |   321 (100)|    113 |00:00:00.01 |     124 |      2 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON                           |      1 |  15000 |   321   (1)|    113 |00:00:00.01 |     124 |      2 |
-- |*  2 |   INDEX RANGE SCAN                  | IDX_PERSON_NAME_REVERSE_FUNCTION |      1 |   2700 |     9   (0)|    113 |00:00:00.01 |      11 |      2 |
-- --------------------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - access("PERSON"."SYS_NC00006$" LIKE 'wq%')
--        filter("PERSON"."SYS_NC00006$" LIKE 'wq%')

-- repeatedly running the previous SQL statement

-- Plan hash value: 525723249
-- 
-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name                             | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |                                  |      1 |        |   122 (100)|    113 |00:00:00.01 |     124 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON                           |      1 |    113 |   122   (0)|    113 |00:00:00.01 |     124 |
-- |*  2 |   INDEX RANGE SCAN                  | IDX_PERSON_NAME_REVERSE_FUNCTION |      1 |    113 |     9   (0)|    113 |00:00:00.01 |      11 |
-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - access("PERSON"."SYS_NC00006$" LIKE 'wq%')
--        filter("PERSON"."SYS_NC00006$" LIKE 'wq%')
-- 
-- Note
-- -----
--    - statistics feedback used for this statement

COLUMN index_name FORMAT a35
COLUMN index_type FORMAT a22

SELECT index_name
     , index_type
     , visibility
     , clustering_factor
     , num_rows
FROM   user_indexes
WHERE  table_name = 'PERSON'
;

INDEX_NAME                          INDEX_TYPE             VISIBILIT CLUSTERING_FACTOR   NUM_ROWS
----------------------------------- ---------------------- --------- ----------------- ----------
PERSON_PK                           NORMAL                 VISIBLE                1148     300000
IDX_PERSON_NAME_REVERSE             NORMAL/REV             VISIBLE              299731     300000
IDX_PERSON_NAME_REVERSE_FUNCTION    FUNCTION-BASED NORMAL  VISIBLE              299731     300000

COLUMN index_name        FORMAT a35
COLUMN column_expression FORMAT a17

SELECT index_name
     , column_expression
FROM   user_ind_expressions
WHERE  table_name = 'PERSON'
;

INDEX_NAME                          COLUMN_EXPRESSION
----------------------------------- -----------------
IDX_PERSON_NAME_REVERSE_FUNCTION    REVERSE("NAME")

PROMPT =====
PROMPT 'q%w'
PROMPT =====

ALTER INDEX idx_person_name_reverse INVISIBLE;

-- ALTER INDEX idx_person_name_reverse_function INVISIBLE;

CREATE INDEX idx_person_name ON person (name);

COLUMN index_name FORMAT a35
COLUMN index_type FORMAT a22

SELECT index_name
     , index_type
     , visibility
     , clustering_factor
     , num_rows
FROM   user_indexes
WHERE  table_name = 'PERSON'
;

INDEX_NAME                          INDEX_TYPE             VISIBILIT CLUSTERING_FACTOR   NUM_ROWS
----------------------------------- ---------------------- --------- ----------------- ----------
PERSON_PK                           NORMAL                 VISIBLE                1148     300000
IDX_PERSON_NAME_REVERSE             NORMAL/REV             INVISIBLE            299731     300000
IDX_PERSON_NAME_REVERSE_FUNCTION    FUNCTION-BASED NORMAL  VISIBLE              299731     300000
IDX_PERSON_NAME                     NORMAL                 VISIBLE              299764     300000

SELECT /*+ index(person idx_person_name) */ *
  FROM person
 WHERE name LIKE 'q%'
   AND name LIKE '%w'
;

SELECT *
  FROM table(DBMS_XPLAN.display_cursor(null, null, 'cost allstats last'))
;

-- Plan hash value: 1105672549
-- 
-- ---------------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name            | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers | Reads  |
-- ---------------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |                 |      1 |        |  5259 (100)|    114 |00:00:00.03 |     139 |     21 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON          |      1 |    262 |  5259   (1)|    114 |00:00:00.03 |     139 |     21 |
-- |*  2 |   INDEX RANGE SCAN                  | IDX_PERSON_NAME |      1 |   5244 |    16   (0)|    114 |00:00:00.02 |      25 |     21 |
-- ---------------------------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - access("NAME" LIKE 'q%')
--        filter(("NAME" LIKE 'q%' AND "NAME" LIKE '%w'))

-- repeatedly running the previous SQL statement

-- Plan hash value: 1105672549
-- 
-- ------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name            | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
-- ------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |                 |      1 |        |   130 (100)|    114 |00:00:00.01 |     139 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON          |      1 |    114 |   130   (0)|    114 |00:00:00.01 |     139 |
-- |*  2 |   INDEX RANGE SCAN                  | IDX_PERSON_NAME |      1 |    114 |    16   (0)|    114 |00:00:00.01 |      25 |
-- ------------------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - access("NAME" LIKE 'q%')
--        filter(("NAME" LIKE 'q%' AND "NAME" LIKE '%w'))
-- 
-- Note
-- -----
--    - statistics feedback used for this statement

SELECT *
  FROM person
 WHERE name LIKE 'q%'
   AND REVERSE(name) LIKE REVERSE('%w')
;

SELECT *
  FROM table(DBMS_XPLAN.display_cursor(null, null, 'cost allstats last'))
;

-- Plan hash value: 1105672549
-- 
-- ------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name            | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
-- ------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |                 |      1 |        |   278 (100)|    114 |00:00:00.01 |     139 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON          |      1 |    262 |   278   (0)|    114 |00:00:00.01 |     139 |
-- |*  2 |   INDEX RANGE SCAN                  | IDX_PERSON_NAME |      1 |    262 |    16   (0)|    114 |00:00:00.01 |      25 |
-- ------------------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - access("NAME" LIKE 'q%')
--        filter(("NAME" LIKE 'q%' AND REVERSE("NAME") LIKE 'w%'))

-- repeatedly running the previous SQL statement

-- Plan hash value: 1105672549
-- 
-- ------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name            | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
-- ------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |                 |      1 |        |   130 (100)|    114 |00:00:00.01 |     139 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON          |      1 |    114 |   130   (0)|    114 |00:00:00.01 |     139 |
-- |*  2 |   INDEX RANGE SCAN                  | IDX_PERSON_NAME |      1 |    114 |    16   (0)|    114 |00:00:00.01 |      25 |
-- ------------------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - access("NAME" LIKE 'q%')
--        filter(("NAME" LIKE 'q%' AND REVERSE("NAME") LIKE 'w%'))
-- 
-- Note
-- -----
--    - statistics feedback used for this statement

SELECT /*+ index_combine(person idx_person_name idx_person_name_reverse_function) */ *
  FROM person
 WHERE name LIKE 'q%'
   AND REVERSE(name) LIKE REVERSE('%w')
;

SELECT *
  FROM table(DBMS_XPLAN.display_cursor(null, null, 'cost allstats last'))
;

-- Plan hash value: 1105672549
-- 
-- ------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name            | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
-- ------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |                 |      1 |        |   278 (100)|    114 |00:00:00.01 |     139 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON          |      1 |    262 |   278   (0)|    114 |00:00:00.01 |     139 |
-- |*  2 |   INDEX RANGE SCAN                  | IDX_PERSON_NAME |      1 |    262 |    16   (0)|    114 |00:00:00.01 |      25 |
-- ------------------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - access("NAME" LIKE 'q%')
--        filter(("NAME" LIKE 'q%' AND REVERSE("NAME") LIKE 'w%'))

-- repeatedly running the previous SQL statement

-- Plan hash value: 1105672549
-- 
-- ------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name            | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
-- ------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |                 |      1 |        |   130 (100)|    114 |00:00:00.01 |     139 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON          |      1 |    114 |   130   (0)|    114 |00:00:00.01 |     139 |
-- |*  2 |   INDEX RANGE SCAN                  | IDX_PERSON_NAME |      1 |    114 |    16   (0)|    114 |00:00:00.01 |      25 |
-- ------------------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - access("NAME" LIKE 'q%')
--        filter(("NAME" LIKE 'q%' AND REVERSE("NAME") LIKE 'w%'))
-- 
-- Note
-- -----
--    - statistics feedback used for this statement

CREATE INDEX idx_person_nr ON person (name, REVERSE(name));

COLUMN index_name FORMAT a35
COLUMN index_type FORMAT a22

SELECT index_name
     , index_type
     , visibility
     , clustering_factor
     , num_rows
FROM   user_indexes
WHERE  table_name = 'PERSON'
;

INDEX_NAME                          INDEX_TYPE             VISIBILIT CLUSTERING_FACTOR   NUM_ROWS
----------------------------------- ---------------------- --------- ----------------- ----------
PERSON_PK                           NORMAL                 VISIBLE                1148     300000
IDX_PERSON_NAME_REVERSE             NORMAL/REV             INVISIBLE            299731     300000
IDX_PERSON_NAME_REVERSE_FUNCTION    FUNCTION-BASED NORMAL  VISIBLE              299731     300000
IDX_PERSON_NAME                     NORMAL                 VISIBLE              299764     300000
IDX_PERSON_NR                       FUNCTION-BASED NORMAL  VISIBLE              299764     300000

SELECT *
  FROM person
 WHERE name LIKE 'q%'
   AND REVERSE(name) LIKE REVERSE('%w')
;

SELECT *
  FROM table(DBMS_XPLAN.display_cursor(null, null, 'cost allstats last'))
;

-- Plan hash value: 1070135284
-- 
-- -------------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name          | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers | Reads  |
-- -------------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |               |      1 |        |    69 (100)|    114 |00:00:00.03 |     145 |     22 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON        |      1 |    262 |    69   (0)|    114 |00:00:00.03 |     145 |     22 |
-- |*  2 |   INDEX RANGE SCAN                  | IDX_PERSON_NR |      1 |     47 |    21   (0)|    114 |00:00:00.03 |      31 |     22 |
-- -------------------------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - access("NAME" LIKE 'q%' AND "PERSON"."SYS_NC00006$" LIKE 'w%')
--        filter(("NAME" LIKE 'q%' AND "PERSON"."SYS_NC00006$" LIKE 'w%'))

-- repeatedly running the previous SQL statement

-- Plan hash value: 1070135284
-- 
-- ----------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name          | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
-- ----------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |               |      1 |        |   135 (100)|    114 |00:00:00.01 |     145 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON        |      1 |    114 |   135   (0)|    114 |00:00:00.01 |     145 |
-- |*  2 |   INDEX RANGE SCAN                  | IDX_PERSON_NR |      1 |    114 |    21   (0)|    114 |00:00:00.01 |      31 |
-- ----------------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - access("NAME" LIKE 'q%' AND "PERSON"."SYS_NC00006$" LIKE 'w%')
--        filter(("NAME" LIKE 'q%' AND "PERSON"."SYS_NC00006$" LIKE 'w%'))
-- 
-- Note
-- -----
--    - statistics feedback used for this statement

SELECT /*+ index(person idx_person_nr) */ *
  FROM person
 WHERE name LIKE 'q%'
   AND REVERSE(name) LIKE REVERSE('%w')
;

SELECT *
  FROM table(DBMS_XPLAN.display_cursor(null, null, 'cost allstats last'))
;

-- Plan hash value: 1070135284
-- 
-- ----------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name          | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
-- ----------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |               |      1 |        |    69 (100)|    114 |00:00:00.01 |     145 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON        |      1 |    262 |    69   (0)|    114 |00:00:00.01 |     145 |
-- |*  2 |   INDEX RANGE SCAN                  | IDX_PERSON_NR |      1 |     47 |    21   (0)|    114 |00:00:00.01 |      31 |
-- ----------------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - access("NAME" LIKE 'q%' AND "PERSON"."SYS_NC00006$" LIKE 'w%')
--        filter(("NAME" LIKE 'q%' AND "PERSON"."SYS_NC00006$" LIKE 'w%'))

-- repeatedly running the previous SQL statement

-- Plan hash value: 1070135284
-- 
-- ----------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name          | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
-- ----------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |               |      1 |        |   135 (100)|    114 |00:00:00.01 |     145 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON        |      1 |    114 |   135   (0)|    114 |00:00:00.01 |     145 |
-- |*  2 |   INDEX RANGE SCAN                  | IDX_PERSON_NR |      1 |    114 |    21   (0)|    114 |00:00:00.01 |      31 |
-- ----------------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - access("NAME" LIKE 'q%' AND "PERSON"."SYS_NC00006$" LIKE 'w%')
--        filter(("NAME" LIKE 'q%' AND "PERSON"."SYS_NC00006$" LIKE 'w%'))
-- 
-- Note
-- -----
--    - statistics feedback used for this statement

ALTER INDEX idx_person_name_reverse_function INVISIBLE;

COLUMN index_name FORMAT a35
COLUMN index_type FORMAT a22

SELECT index_name
     , index_type
     , visibility
     , clustering_factor
     , num_rows
FROM   user_indexes
WHERE  table_name = 'PERSON'
;

INDEX_NAME                          INDEX_TYPE             VISIBILIT CLUSTERING_FACTOR   NUM_ROWS
----------------------------------- ---------------------- --------- ----------------- ----------
PERSON_PK                           NORMAL                 VISIBLE                1148     300000
IDX_PERSON_NAME_REVERSE             NORMAL/REV             INVISIBLE            299731     300000
IDX_PERSON_NAME_REVERSE_FUNCTION    FUNCTION-BASED NORMAL  INVISIBLE            299731     300000
IDX_PERSON_NAME                     NORMAL                 VISIBLE              299764     300000
IDX_PERSON_NR                       FUNCTION-BASED NORMAL  VISIBLE              299764     300000

SELECT *
  FROM person
 WHERE REVERSE(name) LIKE REVERSE('%qw')
;

SELECT *
  FROM table(DBMS_XPLAN.display_cursor(null, null, 'cost allstats last'))
;

-- Plan hash value: 1493655343
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation         | Name   | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT  |        |      1 |        |   333 (100)|    113 |00:00:00.05 |    1160 |
-- |*  1 |  TABLE ACCESS FULL| PERSON |      1 |  15000 |   333   (4)|    113 |00:00:00.05 |    1160 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(REVERSE("NAME") LIKE 'wq%')

-- repeatedly running the previous SQL statement

-- Plan hash value: 1493655343
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation         | Name   | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT  |        |      1 |        |   333 (100)|    113 |00:00:00.05 |    1160 |
-- |*  1 |  TABLE ACCESS FULL| PERSON |      1 |    113 |   333   (4)|    113 |00:00:00.05 |    1160 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(REVERSE("NAME") LIKE 'wq%')
-- 
-- Note
-- -----
--    - statistics feedback used for this statement
