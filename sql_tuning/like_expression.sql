REM
REM     Script:        like_expression.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Mar 22, 2020
REM     Updated:       Mar 30, 2020
REM                    adding this function invoking DBMS_RANDOM.seed(0) after create a test table "person",
REM                    and subsequently replaced with the new execution plan shows up in my each case.
REM
REM     Last tested:
REM             19.3.0.0
REM
REM     Purpose:  
REM       This sql script uses to optimize the SQL statement with LIKE expression on Oracle Database.
REM
REM       In general a LIKE expression has four number of situation in a SQL query statement.
REM       Take, for example, some random combinations of between '%' and character strings 'qw'.
REM       (1)qw%; (2)%qw; (3)%qw%; (4)q%w;
REM

CREATE TABLE person
( id   NUMBER GENERATED ALWAYS AS IDENTITY
, name VARCHAR2(6) NOT NULL
, sex  VARCHAR2(1) NOT NULL
, flag VARCHAR2(1)
, pwd  VARCHAR2(6)
, CONSTRAINT person_pk PRIMARY KEY(id)
);

EXEC DBMS_RANDOM.seed(0); -- In order to ensure that the random data generated each time is completely consistent. Thanks Jonathan Lewis prompts me on Twitter.

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
PROMPT 'qw%'
PROMPT =====

CREATE INDEX idx_person_name ON person (name);

SET LINESIZE 300
SET PAGESIZE 150
SET SERVEROUTPUT OFF
  
ALTER SESSION SET statistics_level = all;

SELECT *
  FROM person
 WHERE name LIKE 'qw%'
;

SELECT *
  FROM table(DBMS_XPLAN.display_cursor(null, null, 'cost allstats last'))
;

-- Plan hash value: 1105672549
-- 
-- ---------------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name            | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers | Reads  |
-- ---------------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |                 |      1 |        |    25 (100)|    108 |00:00:00.03 |     119 |      2 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON          |      1 |     21 |    25   (0)|    108 |00:00:00.03 |     119 |      2 |
-- |*  2 |   INDEX RANGE SCAN                  | IDX_PERSON_NAME |      1 |     21 |     3   (0)|    108 |00:00:00.03 |      11 |      2 |
-- ---------------------------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - access("NAME" LIKE 'qw%')
--        filter("NAME" LIKE 'qw%')

PROMPT =====
PROMPT '%qw'
PROMPT =====

CREATE INDEX idx_person_name_reverse ON person (REVERSE(name));

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
-- |   0 | SELECT STATEMENT  |        |      1 |        |   327 (100)|    113 |00:00:00.05 |    1160 |
-- |*  1 |  TABLE ACCESS FULL| PERSON |      1 |  15000 |   327   (3)|    113 |00:00:00.05 |    1160 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("NAME" LIKE '%qw')

SELECT /*+ index(person idx_person_name) */ *
  FROM person
 WHERE name LIKE '%qw'
;

SELECT *
  FROM table(DBMS_XPLAN.display_cursor(null, null, 'cost allstats last'))
;

-- Plan hash value: 1664794999
-- 
-- ---------------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name            | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers | Reads  |
-- ---------------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |                 |      1 |        | 15759 (100)|    113 |00:00:00.33 |     875 |    732 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON          |      1 |  15000 | 15759   (1)|    113 |00:00:00.33 |     875 |    732 |
-- |*  2 |   INDEX FULL SCAN                   | IDX_PERSON_NAME |      1 |  15000 |   761   (1)|    113 |00:00:00.33 |     762 |    732 |
-- ---------------------------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - filter("NAME" LIKE '%qw')

SELECT *
  FROM person
 WHERE REVERSE(name) LIKE REVERSE('%qw')
;

SELECT *
  FROM table(DBMS_XPLAN.display_cursor(null, null, 'cost allstats last'))
;

-- Plan hash value: 3646499062
-- 
-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name                    | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers | Reads  |
-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |                         |      1 |        |   321 (100)|    113 |00:00:00.11 |     124 |      2 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON                  |      1 |  15000 |   321   (1)|    113 |00:00:00.11 |     124 |      2 |
-- |*  2 |   INDEX RANGE SCAN                  | IDX_PERSON_NAME_REVERSE |      1 |   2700 |     9   (0)|    113 |00:00:00.11 |      11 |      2 |
-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - access("PERSON"."SYS_NC00006$" LIKE 'wq%')
--        filter("PERSON"."SYS_NC00006$" LIKE 'wq%')

-- repeatedly running the previous SQL statement

-- Plan hash value: 3646499062
-- 
-- --------------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name                    | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
-- --------------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |                         |      1 |        |   122 (100)|    113 |00:00:00.01 |     124 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON                  |      1 |    113 |   122   (0)|    113 |00:00:00.01 |     124 |
-- |*  2 |   INDEX RANGE SCAN                  | IDX_PERSON_NAME_REVERSE |      1 |    113 |     9   (0)|    113 |00:00:00.01 |      11 |
-- --------------------------------------------------------------------------------------------------------------------------------------
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

PROMPT ======
PROMPT '%qw%'
PROMPT ======

CREATE INDEX idx_person_name_instr ON person (INSTR(name, 'qw'));

SELECT *
  FROM person
 WHERE name LIKE '%qw%'
;

SELECT *
  FROM table(DBMS_XPLAN.display_cursor(null, null, 'cost allstats last'))
;

-- Plan hash value: 1493655343
--  
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation         | Name   | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT  |        |      1 |        |   327 (100)|    547 |00:00:00.06 |    1189 |
-- |*  1 |  TABLE ACCESS FULL| PERSON |      1 |  15000 |   327   (3)|    547 |00:00:00.06 |    1189 |
-- ---------------------------------------------------------------------------------------------------
--  
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
--  
--    1 - filter("NAME" LIKE '%qw%')

SELECT /*+ index(person idx_person_name) */ *
  FROM person
 WHERE name LIKE '%qw%'
;

SELECT *
  FROM table(DBMS_XPLAN.display_cursor(null, null, 'cost allstats last'))
;

-- Plan hash value: 1664794999
-- 
-- ------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name            | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
-- ------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |                 |      1 |        | 15759 (100)|    547 |00:00:00.07 |    1338 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON          |      1 |  15000 | 15759   (1)|    547 |00:00:00.07 |    1338 |
-- |*  2 |   INDEX FULL SCAN                   | IDX_PERSON_NAME |      1 |  15000 |   761   (1)|    547 |00:00:00.07 |     791 |
-- ------------------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - filter("NAME" LIKE '%qw%')

SELECT *
  FROM person
 WHERE INSTR(name, 'qw') > 0
;

SELECT *
  FROM table(DBMS_XPLAN.display_cursor(null, null, 'cost allstats last'))
;

-- Plan hash value: 2185790021
-- 
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name                  | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers | Reads  |
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |                       |      1 |        |    23 (100)|    547 |00:00:00.04 |     565 |      5 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON                |      1 |  15000 |    23   (0)|    547 |00:00:00.04 |     565 |      5 |
-- |*  2 |   INDEX RANGE SCAN                  | IDX_PERSON_NAME_INSTR |      1 |   2700 |     7   (0)|    547 |00:00:00.04 |      41 |      5 |
-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - access("PERSON"."SYS_NC00007$">0)

-- repeatedly running the previous SQL statement

-- Plan hash value: 2185790021
--  
-- ------------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name                  | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
-- ------------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |                       |      1 |        |    11 (100)|    547 |00:00:00.01 |     565 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON                |      1 |    547 |    11   (0)|    547 |00:00:00.01 |     565 |
-- |*  2 |   INDEX RANGE SCAN                  | IDX_PERSON_NAME_INSTR |      1 |    547 |     7   (0)|    547 |00:00:00.01 |      41 |
-- ------------------------------------------------------------------------------------------------------------------------------------
--  
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
--  
--    2 - access("PERSON"."SYS_NC00007$">0)
--  
-- Note
-- -----
--    - statistics feedback used for this statement

PROMPT =====
PROMPT 'q%w'
PROMPT =====

SELECT *
  FROM person
 WHERE name LIKE 'q%w'
;

SELECT *
  FROM table(DBMS_XPLAN.display_cursor(null, null, 'cost allstats last'))
;

-- Plan hash value: 1493655343
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation         | Name   | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT  |        |      1 |        |   327 (100)|    114 |00:00:00.04 |    1160 |
-- |*  1 |  TABLE ACCESS FULL| PERSON |      1 |   5244 |   327   (3)|    114 |00:00:00.04 |    1160 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("NAME" LIKE 'q%w')

SELECT *
  FROM person
 WHERE name LIKE 'q%'
   AND name LIKE '%w'
;

SELECT *
  FROM table(DBMS_XPLAN.display_cursor(null, null, 'cost allstats last'))
;

-- Plan hash value: 1493655343
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation         | Name   | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT  |        |      1 |        |   327 (100)|    114 |00:00:00.05 |    1160 |
-- |*  1 |  TABLE ACCESS FULL| PERSON |      1 |    262 |   327   (3)|    114 |00:00:00.05 |    1160 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(("NAME" LIKE 'q%' AND "NAME" LIKE '%w'))

-- repeatedly running the previous SQL statement

-- Plan hash value: 1493655343
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation         | Name   | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT  |        |      1 |        |   327 (100)|    114 |00:00:00.04 |    1160 |
-- |*  1 |  TABLE ACCESS FULL| PERSON |      1 |    114 |   327   (3)|    114 |00:00:00.04 |    1160 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(("NAME" LIKE 'q%' AND "NAME" LIKE '%w'))
-- 
-- Note
-- -----
--    - statistics feedback used for this statement

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
-- ------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name            | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
-- ------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |                 |      1 |        |  5259 (100)|    114 |00:00:00.01 |     139 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON          |      1 |    262 |  5259   (1)|    114 |00:00:00.01 |     139 |
-- |*  2 |   INDEX RANGE SCAN                  | IDX_PERSON_NAME |      1 |   5244 |    16   (0)|    114 |00:00:00.01 |      25 |
-- ------------------------------------------------------------------------------------------------------------------------------
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

SELECT /*+ index(person idx_person_name_reverse) */ *
  FROM person
 WHERE name LIKE 'q%'
   AND name LIKE '%w'
;

SELECT *
  FROM table(DBMS_XPLAN.display_cursor(null, null, 'cost allstats last'))
;

-- Plan hash value: 3102595867
-- 
-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name                    | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers | Reads  |
-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |                         |      1 |        |   300K(100)|    114 |00:00:00.53 |     300K|    752 |
-- |*  1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON                  |      1 |    262 |   300K  (1)|    114 |00:00:00.53 |     300K|    752 |
-- |   2 |   INDEX FULL SCAN                   | IDX_PERSON_NAME_REVERSE |      1 |    300K|   759   (1)|    300K|00:00:00.19 |     762 |    752 |
-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(("NAME" LIKE 'q%' AND "NAME" LIKE '%w'))

-- repeatedly running the previous SQL statement

-- Plan hash value: 3102595867
-- 
-- --------------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name                    | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
-- --------------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |                         |      1 |        |   300K(100)|    114 |00:00:00.40 |     300K|
-- |*  1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON                  |      1 |    114 |   300K  (1)|    114 |00:00:00.40 |     300K|
-- |   2 |   INDEX FULL SCAN                   | IDX_PERSON_NAME_REVERSE |      1 |    300K|   759   (1)|    300K|00:00:00.05 |     762 |
-- --------------------------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(("NAME" LIKE 'q%' AND "NAME" LIKE '%w'))
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
-- ---------------------------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                           | Name            | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers | Reads  |
-- ---------------------------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                    |                 |      1 |        |   278 (100)|    114 |00:00:00.02 |     139 |     19 |
-- |   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PERSON          |      1 |    262 |   278   (0)|    114 |00:00:00.02 |     139 |     19 |
-- |*  2 |   INDEX RANGE SCAN                  | IDX_PERSON_NAME |      1 |    262 |    16   (0)|    114 |00:00:00.02 |      25 |     19 |
-- ---------------------------------------------------------------------------------------------------------------------------------------
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
