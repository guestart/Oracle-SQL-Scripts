REM
REM     Script:        pagination_query_ascending_index.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Mar 06, 2020
REM
REM     Last tested:
REM             19.3.0.0
REM
REM     Purpose:  
REM       This sql script uses to observe the execution plan of top-N and pagination query on Oracle Database
REM       via calling DBMS_XPLAN.display_cursor().
REM
REM       Here I intend to use total three methods to check the previous two types of SQL query's execution plan:
REM         (1) ROWNUM (traditional)
REM         (2) ROW_NUMBER() (analytic function)
REM         (3) OFFSET ... FETCH ... (limiting sql rows, which is usable since Oracle 12.1)
REM

CONN qwz/qwz;

ALTER SESSION SET nls_date_format = 'YYYY-MM-DD';

DROP TABLE staff PURGE;

CREATE TABLE staff
  ( id        NUMBER       CONSTRAINT staff_pk PRIMARY KEY
  , name      VARCHAR2 (6) NOT NULL
  , sex       NUMBER   (1) NOT NULL
  , birth_day DATE         NOT NULL
  , address   VARCHAR2(16) NOT NULL
  , email     VARCHAR2(15)
  , qq        NUMBER   (9)
  )
NOLOGGING  
;

INSERT /*+ APPEND */
INTO staff (id, name, sex, birth_day, address, email, qq)
SELECT ROWNUM                                                                      AS id
     , DBMS_RANDOM.string('A', 6)                                                  AS name
     , ROUND(DBMS_RANDOM.value(0, 1))                                              AS sex
     , TO_DATE('1977-06-14', 'YYYY-MM-DD') + TRUNC(DBMS_RANDOM.value(-4713, 9999)) AS birth_day
     , DBMS_RANDOM.string('L', 16)                                                 AS address
     , DBMS_RANDOM.string('L', 6) || '@' || DBMS_RANDOM.string('L', 4) || '.com'   AS email
     , DBMS_RANDOM.value(10000001, 999999999)                                      AS qq
FROM dual
CONNECT BY level <= 1e4;

COMMIT;

CREATE INDEX idx_staff_nb ON staff (name, birth_day);

EXEC DBMS_STATS.gather_table_stats('','STAFF');

SET LINESIZE 300
SET PAGESIZE 150
SET SERVEROUTPUT OFF

ALTER SESSION SET statistics_level = all;

PROMPT =========================
PROMPT Traditional: ROWNUM (1st)
PROMPT =========================

SELECT *
  FROM (   SELECT *
             FROM staff
            WHERE name like 'q%'
         ORDER BY name DESC
                , birth_day DESC
       )
 WHERE ROWNUM <= 20;

SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));

-- Plan hash value: 1920017108
-- 
-- ---------------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- ---------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |              |      1 |        |     20 |00:00:00.01 |      23 |
-- |*  1 |  COUNT STOPKEY                 |              |      1 |        |     20 |00:00:00.01 |      23 |
-- |   2 |   VIEW                         |              |      1 |     21 |     20 |00:00:00.01 |      23 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID | STAFF        |      1 |    176 |     20 |00:00:00.01 |      23 |
-- |*  4 |     INDEX RANGE SCAN DESCENDING| IDX_STAFF_NB |      1 |     21 |     20 |00:00:00.01 |       4 |
-- ---------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(ROWNUM<=20)
--    4 - access("NAME" LIKE 'q%')
--        filter("NAME" LIKE 'q%')

SELECT *
  FROM (   SELECT /*+ index_desc(staff idx_staff_nb) */ *
             FROM staff
            WHERE name like 'q%'
         ORDER BY name DESC
                , birth_day DESC
       )
 WHERE ROWNUM <= 20;

SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST +HINT_REPORT'));

-- Plan hash value: 1920017108
-- 
-- ---------------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- ---------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |              |      1 |        |     20 |00:00:00.01 |      23 |
-- |*  1 |  COUNT STOPKEY                 |              |      1 |        |     20 |00:00:00.01 |      23 |
-- |   2 |   VIEW                         |              |      1 |     21 |     20 |00:00:00.01 |      23 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID | STAFF        |      1 |     21 |     20 |00:00:00.01 |      23 |
-- |*  4 |     INDEX RANGE SCAN DESCENDING| IDX_STAFF_NB |      1 |    176 |     20 |00:00:00.01 |       4 |
-- ---------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(ROWNUM<=20)
--    4 - access("NAME" LIKE 'q%')
--        filter(("NAME" LIKE 'q%' AND "NAME" LIKE 'q%' AND "NAME" LIKE 'q%'))
-- 
-- Hint Report (identified by operation id / Query Block Name / Object Alias):
-- Total hints for statement: 1 (U - Unused (1))
-- ---------------------------------------------------------------------------
-- 
--    3 -  SEL$2 / STAFF@SEL$2
--          U -  index_desc(staff idx_staff_nb)

SELECT *
  FROM (   SELECT /*+ first_rows(20) */ *
             FROM staff
            WHERE name like 'q%'
         ORDER BY name DESC
                , birth_day DESC
       )
 WHERE ROWNUM <= 20;

SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST +HINT_REPORT'));

-- Plan hash value: 1920017108
-- 
-- ---------------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- ---------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |              |      1 |        |     20 |00:00:00.01 |      23 |
-- |*  1 |  COUNT STOPKEY                 |              |      1 |        |     20 |00:00:00.01 |      23 |
-- |   2 |   VIEW                         |              |      1 |     21 |     20 |00:00:00.01 |      23 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID | STAFF        |      1 |    176 |     20 |00:00:00.01 |      23 |
-- |*  4 |     INDEX RANGE SCAN DESCENDING| IDX_STAFF_NB |      1 |     21 |     20 |00:00:00.01 |       4 |
-- ---------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(ROWNUM<=20)
--    4 - access("NAME" LIKE 'q%')
--        filter("NAME" LIKE 'q%')
-- 
-- Hint Report (identified by operation id / Query Block Name / Object Alias):
-- Total hints for statement: 1
-- ---------------------------------------------------------------------------
-- 
--    0 -  STATEMENT
--            -  first_rows(20)

SELECT *
  FROM ( SELECT t.*
              , ROWNUM rnum
         FROM (   SELECT *
                    FROM staff
                   WHERE name like 'q%'
                ORDER BY name DESC
                       , birth_day DESC
              ) t
         WHERE ROWNUM <= 100
       )
 WHERE rnum >= 81;

SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));

-- Plan hash value: 599682722
-- 
-- -----------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                | Name  | Starts | E-Rows | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
-- -----------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |       |      1 |        |     20 |00:00:00.01 |      96 |       |       |          |
-- |*  1 |  VIEW                    |       |      1 |    100 |     20 |00:00:00.01 |      96 |       |       |          |
-- |*  2 |   COUNT STOPKEY          |       |      1 |        |    100 |00:00:00.01 |      96 |       |       |          |
-- |   3 |    VIEW                  |       |      1 |    176 |    100 |00:00:00.01 |      96 |       |       |          |
-- |*  4 |     SORT ORDER BY STOPKEY|       |      1 |    176 |    100 |00:00:00.01 |      96 | 15360 | 15360 |14336  (0)|
-- |*  5 |      TABLE ACCESS FULL   | STAFF |      1 |    176 |    173 |00:00:00.01 |      96 |       |       |          |
-- -----------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM">=81)
--    2 - filter(ROWNUM<=100)
--    4 - filter(ROWNUM<=100)
--    5 - filter("NAME" LIKE 'q%')

SELECT *
  FROM ( SELECT t.*
              , ROWNUM rnum
         FROM (   SELECT /*+ index_desc(staff idx_staff_nb) */ *
                    FROM staff
                   WHERE name like 'q%'
                ORDER BY name DESC
                       , birth_day DESC
              ) t
         WHERE ROWNUM <= 100
       )
 WHERE rnum >= 81;

SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST +HINT_REPORT'));

-- Plan hash value: 2305039850
-- 
-- ----------------------------------------------------------------------------------------------------------
-- | Id  | Operation                       | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- ----------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                |              |      1 |        |     20 |00:00:00.01 |     103 |
-- |*  1 |  VIEW                           |              |      1 |    100 |     20 |00:00:00.01 |     103 |
-- |*  2 |   COUNT STOPKEY                 |              |      1 |        |    100 |00:00:00.01 |     103 |
-- |   3 |    VIEW                         |              |      1 |    100 |    100 |00:00:00.01 |     103 |
-- |   4 |     TABLE ACCESS BY INDEX ROWID | STAFF        |      1 |    100 |    100 |00:00:00.01 |     103 |
-- |*  5 |      INDEX RANGE SCAN DESCENDING| IDX_STAFF_NB |      1 |    176 |    100 |00:00:00.01 |       4 |
-- ----------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM">=81)
--    2 - filter(ROWNUM<=100)
--    5 - access("NAME" LIKE 'q%')
--        filter(("NAME" LIKE 'q%' AND "NAME" LIKE 'q%' AND "NAME" LIKE 'q%'))
-- 
-- Hint Report (identified by operation id / Query Block Name / Object Alias):
-- Total hints for statement: 1 (U - Unused (1))
-- ---------------------------------------------------------------------------
-- 
--    4 -  SEL$3 / STAFF@SEL$3
--          U -  index_desc(staff idx_staff_nb)

SELECT *
  FROM ( SELECT t.*
              , ROWNUM rnum
         FROM (   SELECT /*+ first_rows(20) */ *
                    FROM staff
                   WHERE name like 'q%'
                ORDER BY name DESC
                       , birth_day DESC
              ) t
         WHERE ROWNUM <= 100
       )
 WHERE rnum >= 81;

SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST +HINT_REPORT'));

-- Plan hash value: 2305039850
-- 
-- ----------------------------------------------------------------------------------------------------------
-- | Id  | Operation                       | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- ----------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                |              |      1 |        |     20 |00:00:00.01 |     103 |
-- |*  1 |  VIEW                           |              |      1 |     21 |     20 |00:00:00.01 |     103 |
-- |*  2 |   COUNT STOPKEY                 |              |      1 |        |    100 |00:00:00.01 |     103 |
-- |   3 |    VIEW                         |              |      1 |     21 |    100 |00:00:00.01 |     103 |
-- |   4 |     TABLE ACCESS BY INDEX ROWID | STAFF        |      1 |    176 |    100 |00:00:00.01 |     103 |
-- |*  5 |      INDEX RANGE SCAN DESCENDING| IDX_STAFF_NB |      1 |     21 |    100 |00:00:00.01 |       4 |
-- ----------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM">=81)
--    2 - filter(ROWNUM<=100)
--    5 - access("NAME" LIKE 'q%')
--        filter("NAME" LIKE 'q%')
-- 
-- Hint Report (identified by operation id / Query Block Name / Object Alias):
-- Total hints for statement: 1
-- ---------------------------------------------------------------------------
-- 
--    0 -  STATEMENT
--            -  first_rows(20)

PROMPT =====================================
PROMPT Analytic function: ROW_NUMBER() (2nd)
PROMPT =====================================

SELECT *
  FROM ( SELECT t.*
              , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
         FROM staff t
         WHERE name like 'q%'
       )
 WHERE rnum <= 20;

SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));

-- Plan hash value: 833379334
-- 
-- ---------------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- ---------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |              |      1 |        |     20 |00:00:00.01 |      23 |
-- |*  1 |  VIEW                          |              |      1 |     20 |     20 |00:00:00.01 |      23 |
-- |*  2 |   WINDOW NOSORT STOPKEY        |              |      1 |     21 |     20 |00:00:00.01 |      23 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID | STAFF        |      1 |    176 |     20 |00:00:00.01 |      23 |
-- |*  4 |     INDEX RANGE SCAN DESCENDING| IDX_STAFF_NB |      1 |     21 |     20 |00:00:00.01 |       4 |
-- ---------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM"<=20)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("NAME") DESC
--               ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=20)
--    4 - access("NAME" LIKE 'q%')
--        filter("NAME" LIKE 'q%')

SELECT *
  FROM ( SELECT /*+ index_desc(staff idx_staff_nb) */ t.*
              , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
         FROM staff t
         WHERE name like 'q%'
       )
 WHERE rnum <= 20;

SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST +HINT_REPORT'));

-- Plan hash value: 833379334
-- 
-- ---------------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- ---------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |              |      1 |        |     20 |00:00:00.01 |      23 |
-- |*  1 |  VIEW                          |              |      1 |     20 |     20 |00:00:00.01 |      23 |
-- |*  2 |   WINDOW NOSORT STOPKEY        |              |      1 |     21 |     20 |00:00:00.01 |      23 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID | STAFF        |      1 |    176 |     20 |00:00:00.01 |      23 |
-- |*  4 |     INDEX RANGE SCAN DESCENDING| IDX_STAFF_NB |      1 |     21 |     20 |00:00:00.01 |       4 |
-- ---------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM"<=20)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("NAME") DESC
--               ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=20)
--    4 - access("NAME" LIKE 'q%')
--        filter("NAME" LIKE 'q%')
-- 
-- Hint Report (identified by operation id / Query Block Name / Object Alias):
-- Total hints for statement: 1 (N - Unresolved (1))
-- ---------------------------------------------------------------------------
-- 
--    2 -  SEL$2
--          N -  index_desc(staff idx_staff_nb)

SELECT *
  FROM ( SELECT /*+ first_rows(20) */ t.*
              , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
         FROM staff t
         WHERE name like 'q%'
       )
 WHERE rnum <= 20;

SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST +HINT_REPORT'));

-- Plan hash value: 833379334
-- 
-- ---------------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- ---------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |              |      1 |        |     20 |00:00:00.01 |      23 |
-- |*  1 |  VIEW                          |              |      1 |     20 |     20 |00:00:00.01 |      23 |
-- |*  2 |   WINDOW NOSORT STOPKEY        |              |      1 |     21 |     20 |00:00:00.01 |      23 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID | STAFF        |      1 |    176 |     20 |00:00:00.01 |      23 |
-- |*  4 |     INDEX RANGE SCAN DESCENDING| IDX_STAFF_NB |      1 |     21 |     20 |00:00:00.01 |       4 |
-- ---------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM"<=20)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("NAME") DESC
--               ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=20)
--    4 - access("NAME" LIKE 'q%')
--        filter("NAME" LIKE 'q%')
-- 
-- Hint Report (identified by operation id / Query Block Name / Object Alias):
-- Total hints for statement: 1
-- ---------------------------------------------------------------------------
-- 
--    0 -  STATEMENT
--            -  first_rows(20)

SELECT *
  FROM ( SELECT t.*
              , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
         FROM staff t
         WHERE name like 'q%'
       )
 WHERE rnum BETWEEN 81 AND 100;

SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));

-- Plan hash value: 3395473997
-- 
-- -----------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                | Name  | Starts | E-Rows | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
-- -----------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |       |      1 |        |     20 |00:00:00.01 |      96 |       |       |          |
-- |*  1 |  VIEW                    |       |      1 |    100 |     20 |00:00:00.01 |      96 |       |       |          |
-- |*  2 |   WINDOW SORT PUSHED RANK|       |      1 |    176 |    100 |00:00:00.01 |      96 | 15360 | 15360 |14336  (0)|
-- |*  3 |    TABLE ACCESS FULL     | STAFF |      1 |    176 |    173 |00:00:00.01 |      96 |       |       |          |
-- -----------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(("RNUM">=81 AND "RNUM"<=100))
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("NAME") DESC ,INTERNAL_FUNCTION("T"."BIRTH_DAY")
--               DESC )<=100)
--    3 - filter("NAME" LIKE 'q%')

SELECT *
  FROM ( SELECT /*+ index_desc(staff idx_staff_nb) */ t.*
              , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
         FROM staff t
         WHERE name like 'q%'
       )
 WHERE rnum BETWEEN 81 AND 100;

SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST +HINT_REPORT'));

-- Plan hash value: 3395473997
-- 
-- -----------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                | Name  | Starts | E-Rows | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
-- -----------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |       |      1 |        |     20 |00:00:00.01 |      96 |       |       |          |
-- |*  1 |  VIEW                    |       |      1 |    100 |     20 |00:00:00.01 |      96 |       |       |          |
-- |*  2 |   WINDOW SORT PUSHED RANK|       |      1 |    176 |    100 |00:00:00.01 |      96 | 15360 | 15360 |14336  (0)|
-- |*  3 |    TABLE ACCESS FULL     | STAFF |      1 |    176 |    173 |00:00:00.01 |      96 |       |       |          |
-- -----------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(("RNUM">=81 AND "RNUM"<=100))
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("NAME") DESC ,INTERNAL_FUNCTION("T"."BIRTH_DAY")
--               DESC )<=100)
--    3 - filter("NAME" LIKE 'q%')
-- 
-- Hint Report (identified by operation id / Query Block Name / Object Alias):
-- Total hints for statement: 1 (N - Unresolved (1))
-- ---------------------------------------------------------------------------
-- 
--    2 -  SEL$2
--          N -  index_desc(staff idx_staff_nb)

SELECT *
  FROM ( SELECT /*+ first_rows(20) */ t.*
              , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
         FROM staff t
         WHERE name like 'q%'
       )
 WHERE rnum BETWEEN 81 AND 100;

SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST +HINT_REPORT'));

-- Plan hash value: 833379334
-- 
-- ---------------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- ---------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |              |      1 |        |     20 |00:00:00.01 |     103 |
-- |*  1 |  VIEW                          |              |      1 |    100 |     20 |00:00:00.01 |     103 |
-- |*  2 |   WINDOW NOSORT STOPKEY        |              |      1 |     21 |    100 |00:00:00.01 |     103 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID | STAFF        |      1 |    176 |    100 |00:00:00.01 |     103 |
-- |*  4 |     INDEX RANGE SCAN DESCENDING| IDX_STAFF_NB |      1 |     21 |    100 |00:00:00.01 |       4 |
-- ---------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(("RNUM">=81 AND "RNUM"<=100))
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("NAME") DESC
--               ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=100)
--    4 - access("NAME" LIKE 'q%')
--        filter("NAME" LIKE 'q%')
-- 
-- Hint Report (identified by operation id / Query Block Name / Object Alias):
-- Total hints for statement: 1
-- ---------------------------------------------------------------------------
-- 
--    0 -  STATEMENT
--            -  first_rows(20)

PROMPT =============================================
PROMPT Limiting SQL Rows: Offset ... fetch ... (3rd)
PROMPT =============================================

SELECT *
FROM staff t
WHERE name like 'q%'
ORDER BY t.name DESC
       , t.birth_day DESC
FETCH FIRST 20 ROWS ONLY;

SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));

-- Plan hash value: 833379334
-- 
-- ---------------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- ---------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |              |      1 |        |     20 |00:00:00.01 |      23 |
-- |*  1 |  VIEW                          |              |      1 |     20 |     20 |00:00:00.01 |      23 |
-- |*  2 |   WINDOW NOSORT STOPKEY        |              |      1 |     21 |     20 |00:00:00.01 |      23 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID | STAFF        |      1 |    176 |     20 |00:00:00.01 |      23 |
-- |*  4 |     INDEX RANGE SCAN DESCENDING| IDX_STAFF_NB |      1 |     21 |     20 |00:00:00.01 |       4 |
-- ---------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("from$_subquery$_002"."rowlimit_$$_rownumber"<=20)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("T"."NAME") DESC
--               ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=20)
--    4 - access("NAME" LIKE 'q%')
--        filter("NAME" LIKE 'q%')

SELECT /*+ index_desc(staff idx_staff_nb) */ *
FROM staff t
WHERE name like 'q%'
ORDER BY t.name DESC
       , t.birth_day DESC
FETCH FIRST 20 ROWS ONLY;

SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST +HINT_REPORT'));

-- Plan hash value: 833379334
-- 
-- ---------------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- ---------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |              |      1 |        |     20 |00:00:00.01 |      23 |
-- |*  1 |  VIEW                          |              |      1 |     20 |     20 |00:00:00.01 |      23 |
-- |*  2 |   WINDOW NOSORT STOPKEY        |              |      1 |     21 |     20 |00:00:00.01 |      23 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID | STAFF        |      1 |    176 |     20 |00:00:00.01 |      23 |
-- |*  4 |     INDEX RANGE SCAN DESCENDING| IDX_STAFF_NB |      1 |     21 |     20 |00:00:00.01 |       4 |
-- ---------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("from$_subquery$_002"."rowlimit_$$_rownumber"<=20)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("T"."NAME") DESC
--               ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=20)
--    4 - access("NAME" LIKE 'q%')
--        filter("NAME" LIKE 'q%')
-- 
-- Hint Report (identified by operation id / Query Block Name / Object Alias):
-- Total hints for statement: 1 (N - Unresolved (1))
-- ---------------------------------------------------------------------------
-- 
--    2 -  SEL$1
--          N -  index_desc(staff idx_staff_nb)

SELECT /*+ first_rows(20) */ *
FROM staff t
WHERE name like 'q%'
ORDER BY t.name DESC
       , t.birth_day DESC
FETCH FIRST 20 ROWS ONLY;

SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST +HINT_REPORT'));

-- Plan hash value: 833379334
-- 
-- ---------------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- ---------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |              |      1 |        |     20 |00:00:00.01 |      23 |
-- |*  1 |  VIEW                          |              |      1 |     20 |     20 |00:00:00.01 |      23 |
-- |*  2 |   WINDOW NOSORT STOPKEY        |              |      1 |     21 |     20 |00:00:00.01 |      23 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID | STAFF        |      1 |    176 |     20 |00:00:00.01 |      23 |
-- |*  4 |     INDEX RANGE SCAN DESCENDING| IDX_STAFF_NB |      1 |     21 |     20 |00:00:00.01 |       4 |
-- ---------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("from$_subquery$_002"."rowlimit_$$_rownumber"<=20)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("T"."NAME") DESC
--               ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=20)
--    4 - access("NAME" LIKE 'q%')
--        filter("NAME" LIKE 'q%')
-- 
-- Hint Report (identified by operation id / Query Block Name / Object Alias):
-- Total hints for statement: 1
-- ---------------------------------------------------------------------------
-- 
--    0 -  STATEMENT
--            -  first_rows(20)

SELECT *
FROM staff t
WHERE name like 'q%'
ORDER BY t.name DESC
       , t.birth_day DESC
OFFSET 80 ROWS FETCH NEXT 20 ROWS ONLY;

SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST'));

-- Plan hash value: 3395473997
-- 
-- -----------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                | Name  | Starts | E-Rows | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
-- -----------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |       |      1 |        |     20 |00:00:00.01 |      96 |       |       |          |
-- |*  1 |  VIEW                    |       |      1 |    100 |     20 |00:00:00.01 |      96 |       |       |          |
-- |*  2 |   WINDOW SORT PUSHED RANK|       |      1 |    176 |    100 |00:00:00.01 |      96 | 15360 | 15360 |14336  (0)|
-- |*  3 |    TABLE ACCESS FULL     | STAFF |      1 |    176 |    173 |00:00:00.01 |      96 |       |       |          |
-- -----------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(("from$_subquery$_002"."rowlimit_$$_rownumber"<=100 AND
--               "from$_subquery$_002"."rowlimit_$$_rownumber">80))
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("T"."NAME") DESC
--               ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=100)
--    3 - filter("NAME" LIKE 'q%')

SELECT /*+ index_desc(staff idx_staff_nb) */ *
FROM staff t
WHERE name like 'q%'
ORDER BY t.name DESC
       , t.birth_day DESC
OFFSET 80 ROWS FETCH NEXT 20 ROWS ONLY;

SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST +HINT_REPORT'));

-- Plan hash value: 3395473997
-- 
-- -----------------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                | Name  | Starts | E-Rows | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
-- -----------------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |       |      1 |        |     20 |00:00:00.01 |      96 |       |       |          |
-- |*  1 |  VIEW                    |       |      1 |    100 |     20 |00:00:00.01 |      96 |       |       |          |
-- |*  2 |   WINDOW SORT PUSHED RANK|       |      1 |    176 |    100 |00:00:00.01 |      96 | 15360 | 15360 |14336  (0)|
-- |*  3 |    TABLE ACCESS FULL     | STAFF |      1 |    176 |    173 |00:00:00.01 |      96 |       |       |          |
-- -----------------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(("from$_subquery$_002"."rowlimit_$$_rownumber"<=100 AND
--               "from$_subquery$_002"."rowlimit_$$_rownumber">80))
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("T"."NAME") DESC
--               ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=100)
--    3 - filter("NAME" LIKE 'q%')
-- 
-- Hint Report (identified by operation id / Query Block Name / Object Alias):
-- Total hints for statement: 1 (N - Unresolved (1))
-- ---------------------------------------------------------------------------
-- 
--    2 -  SEL$1
--          N -  index_desc(staff idx_staff_nb)

SELECT /*+ first_rows(20) */ *
FROM staff t
WHERE name like 'q%'
ORDER BY t.name DESC
       , t.birth_day DESC
OFFSET 80 ROWS FETCH NEXT 20 ROWS ONLY;

SELECT * FROM table(DBMS_XPLAN.display_cursor(NULL, NULL, 'ALLSTATS LAST +HINT_REPORT'));

-- Plan hash value: 833379334
-- 
-- ---------------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name         | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-- ---------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |              |      1 |        |     20 |00:00:00.01 |     103 |
-- |*  1 |  VIEW                          |              |      1 |    100 |     20 |00:00:00.01 |     103 |
-- |*  2 |   WINDOW NOSORT STOPKEY        |              |      1 |     21 |    100 |00:00:00.01 |     103 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID | STAFF        |      1 |    176 |    100 |00:00:00.01 |     103 |
-- |*  4 |     INDEX RANGE SCAN DESCENDING| IDX_STAFF_NB |      1 |     21 |    100 |00:00:00.01 |       4 |
-- ---------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(("from$_subquery$_002"."rowlimit_$$_rownumber"<=100 AND
--               "from$_subquery$_002"."rowlimit_$$_rownumber">80))
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("T"."NAME") DESC
--               ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=100)
--    4 - access("NAME" LIKE 'q%')
--        filter("NAME" LIKE 'q%')
-- 
-- Hint Report (identified by operation id / Query Block Name / Object Alias):
-- Total hints for statement: 1
-- ---------------------------------------------------------------------------
-- 
--    0 -  STATEMENT
--            -  first_rows(20)
