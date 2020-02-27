REM
REM     Script:        pagination_query_bug.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Feb 27, 2020                                                  
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             18.3.0.0
REM             19.3.0.0
REM             LiveSQL (19.5.0.0)
REM
REM     Purpose:  
REM       This sql script uses to observe the execution plan of top-N and pagination query on Oracle Database
REM       via setting autotrace traceonly.
REM
REM       Here I intend to use total three methods to do this pagination query.
REM         (1) ROWNUM (traditional);
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

CREATE INDEX idx_staff_desc_nb ON staff (name DESC, birth_day DESC);

EXEC DBMS_STATS.gather_table_stats('','STAFF');

SET LINESIZE 300
SET PAGESIZE 150

SET AUTOTRACE TRACEONLY

PROMPT =========================
PROMPT Traditional: ROWNUM (1st)
PROMPT =========================

SELECT *
  FROM (   SELECT *
             FROM staff
         ORDER BY name DESC
                , birth_day DESC
       )
 WHERE ROWNUM <= 20;

SELECT *
  FROM (   SELECT /*+ first_rows (20) */ *
             FROM staff
         ORDER BY name DESC
                , birth_day DESC
       )
 WHERE ROWNUM <= 20;

SELECT *
  FROM ( SELECT t.*
              , ROWNUM rnum
         FROM (   SELECT *
                    FROM staff
                ORDER BY name DESC
                       , birth_day DESC
              ) t
         WHERE ROWNUM <= 10000
       )
 WHERE rnum >= 9981;

SELECT *
  FROM ( SELECT t.*
              , ROWNUM rnum
         FROM (   SELECT /*+ first_rows (20) */ *
                    FROM staff
                ORDER BY name DESC
                       , birth_day DESC
              ) t
         WHERE ROWNUM <= 10000
       )
 WHERE rnum >= 9981;

PROMPT =====================================
PROMPT Analytic function: ROW_NUMBER() (2nd)
PROMPT =====================================

SELECT *
  FROM ( SELECT t.*
              , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
         FROM staff t
       )
 WHERE rnum <= 20;

SELECT *
  FROM ( SELECT /*+ first_rows (20) */ t.*
              , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
         FROM staff t
       )
 WHERE rnum <= 20;

SELECT *
  FROM ( SELECT t.*
              , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
         FROM staff t
       )
 WHERE rnum BETWEEN 9981 AND 10000;

SELECT *
  FROM ( SELECT /*+ first_rows (20) */ t.*
              , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
         FROM staff t
       )
 WHERE rnum BETWEEN 9981 AND 10000;

PROMPT =============================================
PROMPT Limiting SQL Rows: Offset ... fetch ... (3rd)
PROMPT =============================================

SELECT *
  FROM staff t
ORDER BY t.name DESC
       , t.birth_day DESC
FETCH FIRST 20 ROWS ONLY;

SELECT /*+ first_rows (20) */ *
  FROM staff t
ORDER BY t.name DESC
       , t.birth_day DESC
FETCH FIRST 20 ROWS ONLY;

SELECT *
FROM staff t
ORDER BY t.name DESC
       , t.birth_day DESC
OFFSET 9980 ROWS FETCH NEXT 20 ROWS ONLY;

SELECT /*+ first_rows (20) */ *
FROM staff
ORDER BY name DESC
       , birth_day DESC
OFFSET 9980 ROWS FETCH NEXT 20 ROWS ONLY;

-- The following is execution plan that I've separately observed from 11gR2, 12cR2, 18c and 19c.

-- on 11gR2

-- SELECT *
--   FROM (   SELECT *
--              FROM staff
--          ORDER BY name DESC
--                 , birth_day DESC
--        )
--  WHERE ROWNUM <= 20;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3290597552
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation                     | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT              |                   |    20 |  1440 |    22   (0)| 00:00:01 |
-- |*  1 |  COUNT STOPKEY                |                   |       |       |            |          |
-- |   2 |   VIEW                        |                   |    20 |  1440 |    22   (0)| 00:00:01 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   4 |     INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(ROWNUM<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--          25  consistent gets
--           0  physical reads
--          72  redo size
--        2439  bytes sent via SQL*Net to client
--         531  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           0  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM (   SELECT /*+ first_rows (20) */ *
--              FROM staff
--          ORDER BY name DESC
--                 , birth_day DESC
--        )
--  WHERE ROWNUM <= 20;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3290597552
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation                     | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT              |                   |    20 |  1440 |    22   (0)| 00:00:01 |
-- |*  1 |  COUNT STOPKEY                |                   |       |       |            |          |
-- |   2 |   VIEW                        |                   |    20 |  1440 |    22   (0)| 00:00:01 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   4 |     INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(ROWNUM<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--          24  consistent gets
--           0  physical reads
--           0  redo size
--        2439  bytes sent via SQL*Net to client
--         531  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           0  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT t.*
--               , ROWNUM rnum
--          FROM (   SELECT *
--                     FROM staff
--                 ORDER BY name DESC
--                        , birth_day DESC
--               ) t
--          WHERE ROWNUM <= 10000
--        )
--  WHERE rnum >= 9981;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 599682722
-- 
-- ----------------------------------------------------------------------------------
-- | Id  | Operation                | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |       | 10000 |   830K|    30   (4)| 00:00:01 |
-- |*  1 |  VIEW                    |       | 10000 |   830K|    30   (4)| 00:00:01 |
-- |*  2 |   COUNT STOPKEY          |       |       |       |            |          |
-- |   3 |    VIEW                  |       | 10000 |   703K|    30   (4)| 00:00:01 |
-- |*  4 |     SORT ORDER BY STOPKEY|       | 10000 |   605K|    30   (4)| 00:00:01 |
-- |   5 |      TABLE ACCESS FULL   | STAFF | 10000 |   605K|    29   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM">=9981)
--    2 - filter(ROWNUM<=10000)
--    4 - filter(ROWNUM<=10000)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--          96  consistent gets
--           0  physical reads
--           0  redo size
--        2585  bytes sent via SQL*Net to client
--         531  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT t.*
--               , ROWNUM rnum
--          FROM (   SELECT /*+ first_rows (20) */ *
--                     FROM staff
--                 ORDER BY name DESC
--                        , birth_day DESC
--               ) t
--          WHERE ROWNUM <= 10000
--        )
--  WHERE rnum >= 9981;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 885898956
-- 
-- ----------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |                   |    20 |  1700 |    22   (0)| 00:00:01 |
-- |*  1 |  VIEW                          |                   |    20 |  1700 |    22   (0)| 00:00:01 |
-- |*  2 |   COUNT STOPKEY                |                   |       |       |            |          |
-- |   3 |    VIEW                        |                   |    20 |  1440 |    22   (0)| 00:00:01 |
-- |   4 |     TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   5 |      INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM">=9981)
--    2 - filter(ROWNUM<=10000)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--        9934  consistent gets
--           0  physical reads
--           0  redo size
--        2585  bytes sent via SQL*Net to client
--         531  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           0  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT t.*
--               , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
--          FROM staff t
--        )
--  WHERE rnum <= 20;
--  
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3395473997
-- 
-- ----------------------------------------------------------------------------------
-- | Id  | Operation                | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |       | 10000 |   830K|    30   (4)| 00:00:01 |
-- |*  1 |  VIEW                    |       | 10000 |   830K|    30   (4)| 00:00:01 |
-- |*  2 |   WINDOW SORT PUSHED RANK|       | 10000 |   605K|    30   (4)| 00:00:01 |
-- |   3 |    TABLE ACCESS FULL     | STAFF | 10000 |   605K|    29   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM"<=20)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("T"."NAME")
--               DESC ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--          96  consistent gets
--           0  physical reads
--           0  redo size
--        2565  bytes sent via SQL*Net to client
--         531  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT /*+ first_rows (20) */ t.*
--               , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
--          FROM staff t
--        )
--  WHERE rnum <= 20;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3862960255
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation                     | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT              |                   |    20 |  1700 |    22   (0)| 00:00:01 |
-- |*  1 |  VIEW                         |                   |    20 |  1700 |    22   (0)| 00:00:01 |
-- |*  2 |   WINDOW NOSORT STOPKEY       |                   |    20 |  1240 |    22   (0)| 00:00:01 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   4 |     INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM"<=20)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY SYS_OP_DESCEND("NAME"),SYS_OP_DESCEND("BIRTH_DAY
--               "))<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--          25  consistent gets
--           0  physical reads
--           0  redo size
--        2565  bytes sent via SQL*Net to client
--         531  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           0  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT t.*
--               , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
--          FROM staff t
--        )
--  WHERE rnum BETWEEN 9981 AND 10000;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3395473997
-- 
-- ----------------------------------------------------------------------------------
-- | Id  | Operation                | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |       | 10000 |   830K|    30   (4)| 00:00:01 |
-- |*  1 |  VIEW                    |       | 10000 |   830K|    30   (4)| 00:00:01 |
-- |*  2 |   WINDOW SORT PUSHED RANK|       | 10000 |   605K|    30   (4)| 00:00:01 |
-- |   3 |    TABLE ACCESS FULL     | STAFF | 10000 |   605K|    29   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM">=9981 AND "RNUM"<=10000)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("T"."NAME")
--               DESC ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=10000)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--          96  consistent gets
--           0  physical reads
--           0  redo size
--        2585  bytes sent via SQL*Net to client
--         531  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT /*+ first_rows (20) */ t.*
--               , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
--          FROM staff t
--        )
--  WHERE rnum BETWEEN 9981 AND 10000;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3862960255
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation                     | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT              |                   |    20 |  1700 |    22   (0)| 00:00:01 |
-- |*  1 |  VIEW                         |                   |    20 |  1700 |    22   (0)| 00:00:01 |
-- |*  2 |   WINDOW NOSORT STOPKEY       |                   |    20 |  1240 |    22   (0)| 00:00:01 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   4 |     INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM">=9981 AND "RNUM"<=10000)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY SYS_OP_DESCEND("NAME"),SYS_OP_DESCEND("BIRTH_DAY
--               "))<=10000)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--        9934  consistent gets
--           0  physical reads
--           0  redo size
--        2585  bytes sent via SQL*Net to client
--         531  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           0  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- 11gR2 hasn't been available on the limiting sql rows, such as "Offset ... fetch ...".

-- on 12cR2

-- SELECT *
--   FROM (   SELECT *
--              FROM staff
--          ORDER BY name DESC
--                 , birth_day DESC
--        )
--  WHERE ROWNUM <= 20;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3290597552
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation                     | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT              |                   |    20 |  1440 |    22   (0)| 00:00:01 |
-- |*  1 |  COUNT STOPKEY                |                   |       |       |            |          |
-- |   2 |   VIEW                        |                   |    20 |  1440 |    22   (0)| 00:00:01 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   4 |     INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(ROWNUM<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--          28  recursive calls
--          52  db block gets
--          36  consistent gets
--           0  physical reads
--       10200  redo size
--        2472  bytes sent via SQL*Net to client
--         619  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           0  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM (   SELECT /*+ first_rows (20) */ *
--              FROM staff
--          ORDER BY name DESC
--                 , birth_day DESC
--        )
--  WHERE ROWNUM <= 20;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3290597552
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation                     | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT              |                   |    20 |  1440 |    22   (0)| 00:00:01 |
-- |*  1 |  COUNT STOPKEY                |                   |       |       |            |          |
-- |   2 |   VIEW                        |                   |    20 |  1440 |    22   (0)| 00:00:01 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   4 |     INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(ROWNUM<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           2  recursive calls
--           0  db block gets
--          26  consistent gets
--           0  physical reads
--           0  redo size
--        2472  bytes sent via SQL*Net to client
--         619  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           0  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT t.*
--               , ROWNUM rnum
--          FROM (   SELECT *
--                     FROM staff
--                 ORDER BY name DESC
--                        , birth_day DESC
--               ) t
--          WHERE ROWNUM <= 10000
--        )
--  WHERE rnum >= 9981;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 599682722
-- 
-- ----------------------------------------------------------------------------------
-- | Id  | Operation                | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |       | 10000 |   830K|    30   (4)| 00:00:01 |
-- |*  1 |  VIEW                    |       | 10000 |   830K|    30   (4)| 00:00:01 |
-- |*  2 |   COUNT STOPKEY          |       |       |       |            |          |
-- |   3 |    VIEW                  |       | 10000 |   703K|    30   (4)| 00:00:01 |
-- |*  4 |     SORT ORDER BY STOPKEY|       | 10000 |   605K|    30   (4)| 00:00:01 |
-- |   5 |      TABLE ACCESS FULL   | STAFF | 10000 |   605K|    29   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM">=9981)
--    2 - filter(ROWNUM<=10000)
--    4 - filter(ROWNUM<=10000)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           3  recursive calls
--           4  db block gets
--         109  consistent gets
--           0  physical reads
--           0  redo size
--        2606  bytes sent via SQL*Net to client
--         619  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT t.*
--               , ROWNUM rnum
--          FROM (   SELECT /*+ first_rows (20) */ *
--                     FROM staff
--                 ORDER BY name DESC
--                        , birth_day DESC
--               ) t
--          WHERE ROWNUM <= 10000
--        )
--  WHERE rnum >= 9981;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 885898956
-- 
-- ----------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |                   |    20 |  1700 |    22   (0)| 00:00:01 |
-- |*  1 |  VIEW                          |                   |    20 |  1700 |    22   (0)| 00:00:01 |
-- |*  2 |   COUNT STOPKEY                |                   |       |       |            |          |
-- |   3 |    VIEW                        |                   |    20 |  1440 |    22   (0)| 00:00:01 |
-- |   4 |     TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   5 |      INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM">=9981)
--    2 - filter(ROWNUM<=10000)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           3  recursive calls
--           0  db block gets
--        9947  consistent gets
--           0  physical reads
--           0  redo size
--        2606  bytes sent via SQL*Net to client
--         619  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           0  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT t.*
--               , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
--          FROM staff t
--        )
--  WHERE rnum <= 20;
--  
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3395473997
-- 
-- ----------------------------------------------------------------------------------
-- | Id  | Operation                | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |       |    20 |  1700 |    30   (4)| 00:00:01 |
-- |*  1 |  VIEW                    |       |    20 |  1700 |    30   (4)| 00:00:01 |
-- |*  2 |   WINDOW SORT PUSHED RANK|       | 10000 |   605K|    30   (4)| 00:00:01 |
-- |   3 |    TABLE ACCESS FULL     | STAFF | 10000 |   605K|    29   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM"<=20)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("T"."NAME")
--               DESC ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           4  recursive calls
--           9  db block gets
--         108  consistent gets
--           0  physical reads
--         996  redo size
--        2598  bytes sent via SQL*Net to client
--         619  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT /*+ first_rows (20) */ t.*
--               , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
--          FROM staff t
--        )
--  WHERE rnum <= 20;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3862960255
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation                     | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT              |                   |    20 |  1700 |    22   (0)| 00:00:01 |
-- |*  1 |  VIEW                         |                   |    20 |  1700 |    22   (0)| 00:00:01 |
-- |*  2 |   WINDOW NOSORT STOPKEY       |                   |    20 |  1240 |    22   (0)| 00:00:01 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   4 |     INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM"<=20)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY SYS_OP_DESCEND("NAME"),SYS_OP_DESCEND("BIRTH_DAY
--               "))<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           4  recursive calls
--           5  db block gets
--          28  consistent gets
--           0  physical reads
--        1000  redo size
--        2598  bytes sent via SQL*Net to client
--         619  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           0  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT t.*
--               , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
--          FROM staff t
--        )
--  WHERE rnum BETWEEN 9981 AND 10000;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3395473997
-- 
-- ----------------------------------------------------------------------------------
-- | Id  | Operation                | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |       | 10000 |   830K|    30   (4)| 00:00:01 |
-- |*  1 |  VIEW                    |       | 10000 |   830K|    30   (4)| 00:00:01 |
-- |*  2 |   WINDOW SORT PUSHED RANK|       | 10000 |   605K|    30   (4)| 00:00:01 |
-- |   3 |    TABLE ACCESS FULL     | STAFF | 10000 |   605K|    29   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM">=9981 AND "RNUM"<=10000)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("T"."NAME")
--               DESC ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=10000)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           2  recursive calls
--           4  db block gets
--         107  consistent gets
--           0  physical reads
--           0  redo size
--        2606  bytes sent via SQL*Net to client
--         619  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT /*+ first_rows (20) */ t.*
--               , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
--          FROM staff t
--        )
--  WHERE rnum BETWEEN 9981 AND 10000;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3862960255
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation                     | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT              |                   | 10000 |   830K|    22   (0)| 00:00:01 |
-- |*  1 |  VIEW                         |                   | 10000 |   830K|    22   (0)| 00:00:01 |
-- |*  2 |   WINDOW NOSORT STOPKEY       |                   |    20 |  1240 |    22   (0)| 00:00:01 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   4 |     INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM">=9981 AND "RNUM"<=10000)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY SYS_OP_DESCEND("NAME"),SYS_OP_DESCEND("BIRTH_DAY
--               "))<=10000)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           2  recursive calls
--           0  db block gets
--        9945  consistent gets
--           0  physical reads
--           0  redo size
--        2606  bytes sent via SQL*Net to client
--         619  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           0  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM staff t
-- ORDER BY t.name DESC
--        , t.birth_day DESC
-- FETCH FIRST 20 ROWS ONLY;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3395473997
-- 
-- ----------------------------------------------------------------------------------
-- | Id  | Operation                | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |       |    20 |  1980 |    30   (4)| 00:00:01 |
-- |*  1 |  VIEW                    |       |    20 |  1980 |    30   (4)| 00:00:01 |
-- |*  2 |   WINDOW SORT PUSHED RANK|       | 10000 |   605K|    30   (4)| 00:00:01 |
-- |   3 |    TABLE ACCESS FULL     | STAFF | 10000 |   605K|    29   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("from$_subquery$_002"."rowlimit_$$_rownumber"<=20)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("T"."NAME")
--               DESC ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           2  recursive calls
--           4  db block gets
--         107  consistent gets
--           0  physical reads
--           0  redo size
--        2472  bytes sent via SQL*Net to client
--         619  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT /*+ first_rows (20) */ *
--   FROM staff t
-- ORDER BY t.name DESC
--        , t.birth_day DESC
-- FETCH FIRST 20 ROWS ONLY;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3587465693
-- 
-- ----------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |                   |    20 |  1980 |    23   (5)| 00:00:01 |
-- |   1 |  SORT ORDER BY                 |                   |    20 |  1980 |    23   (5)| 00:00:01 |
-- |*  2 |   VIEW                         |                   |    20 |  1980 |    22   (0)| 00:00:01 |
-- |*  3 |    WINDOW NOSORT STOPKEY       |                   |    20 |  1240 |    22   (0)| 00:00:01 |
-- |   4 |     TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   5 |      INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - filter("from$_subquery$_002"."rowlimit_$$_rownumber"<=20)
--    3 - filter(ROW_NUMBER() OVER ( ORDER BY SYS_OP_DESCEND("NAME"),SYS_OP_DESCEND("BIRTH_DAY"
--               ))<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           2  recursive calls
--           0  db block gets
--          25  consistent gets
--           0  physical reads
--           0  redo size
--        2472  bytes sent via SQL*Net to client
--         619  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
-- FROM staff t
-- ORDER BY t.name DESC
--        , t.birth_day DESC
-- OFFSET 9980 ROWS FETCH NEXT 20 ROWS ONLY;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3395473997
-- 
-- ----------------------------------------------------------------------------------
-- | Id  | Operation                | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |       | 10000 |   966K|    30   (4)| 00:00:01 |
-- |*  1 |  VIEW                    |       | 10000 |   966K|    30   (4)| 00:00:01 |
-- |*  2 |   WINDOW SORT PUSHED RANK|       | 10000 |   605K|    30   (4)| 00:00:01 |
-- |   3 |    TABLE ACCESS FULL     | STAFF | 10000 |   605K|    29   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("from$_subquery$_002"."rowlimit_$$_rownumber"<=CASE  WHEN
--               (9980>=0) THEN 9980 ELSE 0 END +20 AND
--               "from$_subquery$_002"."rowlimit_$$_rownumber">9980)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("T"."NAME")
--               DESC ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=CASE  WHEN (9980>=0)
--               THEN 9980 ELSE 0 END +20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           2  recursive calls
--           4  db block gets
--         107  consistent gets
--           0  physical reads
--           0  redo size
--        2461  bytes sent via SQL*Net to client
--         619  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT /*+ first_rows (20) */ *
-- FROM staff
-- ORDER BY name DESC
--        , birth_day DESC
-- OFFSET 9980 ROWS FETCH NEXT 20 ROWS ONLY;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3587465693
-- 
-- ----------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |                   |    20 |  1980 |    23   (5)| 00:00:01 |
-- |   1 |  SORT ORDER BY                 |                   |    20 |  1980 |    23   (5)| 00:00:01 |
-- |*  2 |   VIEW                         |                   |    20 |  1980 |    22   (0)| 00:00:01 |
-- |*  3 |    WINDOW NOSORT STOPKEY       |                   |    20 |  1240 |    22   (0)| 00:00:01 |
-- |   4 |     TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   5 |      INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - filter("from$_subquery$_002"."rowlimit_$$_rownumber"<=CASE  WHEN (9980>=0) THEN 9980
--               ELSE 0 END +20 AND "from$_subquery$_002"."rowlimit_$$_rownumber">9980)
--    3 - filter(ROW_NUMBER() OVER ( ORDER BY SYS_OP_DESCEND("NAME"),SYS_OP_DESCEND("BIRTH_DAY"
--               ))<=CASE  WHEN (9980>=0) THEN 9980 ELSE 0 END +20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           2  recursive calls
--           0  db block gets
--        9943  consistent gets
--           0  physical reads
--           0  redo size
--        2461  bytes sent via SQL*Net to client
--         619  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- on 18c

-- SELECT *
--   FROM (   SELECT *
--              FROM staff
--          ORDER BY name DESC
--                 , birth_day DESC
--        )
--  WHERE ROWNUM <= 20;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3290597552
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation                     | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT              |                   |    20 |  1440 |    22   (0)| 00:00:01 |
-- |*  1 |  COUNT STOPKEY                |                   |       |       |            |          |
-- |   2 |   VIEW                        |                   |    20 |  1440 |    22   (0)| 00:00:01 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   4 |     INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(ROWNUM<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--          27  recursive calls
--          52  db block gets
--          36  consistent gets
--           0  physical reads
--       10268  redo size
--        2521  bytes sent via SQL*Net to client
--         635  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           0  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM (   SELECT /*+ first_rows (20) */ *
--              FROM staff
--          ORDER BY name DESC
--                 , birth_day DESC
--        )
--  WHERE ROWNUM <= 20;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3290597552
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation                     | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT              |                   |    20 |  1440 |    22   (0)| 00:00:01 |
-- |*  1 |  COUNT STOPKEY                |                   |       |       |            |          |
-- |   2 |   VIEW                        |                   |    20 |  1440 |    22   (0)| 00:00:01 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   4 |     INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(ROWNUM<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--          24  consistent gets
--           0  physical reads
--           0  redo size
--        2521  bytes sent via SQL*Net to client
--         635  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           0  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT t.*
--               , ROWNUM rnum
--          FROM (   SELECT *
--                     FROM staff
--                 ORDER BY name DESC
--                        , birth_day DESC
--               ) t
--          WHERE ROWNUM <= 10000
--        )
--  WHERE rnum >= 9981;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 599682722
-- 
-- ----------------------------------------------------------------------------------
-- | Id  | Operation                | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |       | 10000 |   830K|    31   (7)| 00:00:01 |
-- |*  1 |  VIEW                    |       | 10000 |   830K|    31   (7)| 00:00:01 |
-- |*  2 |   COUNT STOPKEY          |       |       |       |            |          |
-- |   3 |    VIEW                  |       | 10000 |   703K|    31   (7)| 00:00:01 |
-- |*  4 |     SORT ORDER BY STOPKEY|       | 10000 |   605K|    31   (7)| 00:00:01 |
-- |   5 |      TABLE ACCESS FULL   | STAFF | 10000 |   605K|    29   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM">=9981)
--    2 - filter(ROWNUM<=10000)
--    4 - filter(ROWNUM<=10000)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--          97  consistent gets
--           0  physical reads
--           0  redo size
--        2683  bytes sent via SQL*Net to client
--         635  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT t.*
--               , ROWNUM rnum
--          FROM (   SELECT /*+ first_rows (20) */ *
--                     FROM staff
--                 ORDER BY name DESC
--                        , birth_day DESC
--               ) t
--          WHERE ROWNUM <= 10000
--        )
--  WHERE rnum >= 9981;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 885898956
-- 
-- ----------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |                   |    20 |  1700 |    22   (0)| 00:00:01 |
-- |*  1 |  VIEW                          |                   |    20 |  1700 |    22   (0)| 00:00:01 |
-- |*  2 |   COUNT STOPKEY                |                   |       |       |            |          |
-- |   3 |    VIEW                        |                   |    20 |  1440 |    22   (0)| 00:00:01 |
-- |   4 |     TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   5 |      INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM">=9981)
--    2 - filter(ROWNUM<=10000)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--        9938  consistent gets
--           0  physical reads
--           0  redo size
--        2683  bytes sent via SQL*Net to client
--         635  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           0  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT t.*
--               , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
--          FROM staff t
--        )
--  WHERE rnum <= 20;
--  
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3395473997
-- 
-- ----------------------------------------------------------------------------------
-- | Id  | Operation                | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |       |    20 |  1700 |    31   (7)| 00:00:01 |
-- |*  1 |  VIEW                    |       |    20 |  1700 |    31   (7)| 00:00:01 |
-- |*  2 |   WINDOW SORT PUSHED RANK|       | 10000 |   605K|    31   (7)| 00:00:01 |
-- |   3 |    TABLE ACCESS FULL     | STAFF | 10000 |   605K|    29   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM"<=20)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("T"."NAME")
--               DESC ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           3  recursive calls
--           5  db block gets
--          97  consistent gets
--           0  physical reads
--         992  redo size
--        2655  bytes sent via SQL*Net to client
--         635  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT /*+ first_rows (20) */ t.*
--               , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
--          FROM staff t
--        )
--  WHERE rnum <= 20;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3862960255
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation                     | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT              |                   |    20 |  1700 |    22   (0)| 00:00:01 |
-- |*  1 |  VIEW                         |                   |    20 |  1700 |    22   (0)| 00:00:01 |
-- |*  2 |   WINDOW NOSORT STOPKEY       |                   |    20 |  1240 |    22   (0)| 00:00:01 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   4 |     INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM"<=20)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY SYS_OP_DESCEND("NAME"),SYS_OP_DESCEND("BIRTH_DAY
--               "))<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           3  recursive calls
--           5  db block gets
--          26  consistent gets
--           0  physical reads
--        1064  redo size
--        2655  bytes sent via SQL*Net to client
--         635  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           0  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT t.*
--               , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
--          FROM staff t
--        )
--  WHERE rnum BETWEEN 9981 AND 10000;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3395473997
-- 
-- ----------------------------------------------------------------------------------
-- | Id  | Operation                | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |       | 10000 |   830K|    31   (7)| 00:00:01 |
-- |*  1 |  VIEW                    |       | 10000 |   830K|    31   (7)| 00:00:01 |
-- |*  2 |   WINDOW SORT PUSHED RANK|       | 10000 |   605K|    31   (7)| 00:00:01 |
-- |   3 |    TABLE ACCESS FULL     | STAFF | 10000 |   605K|    29   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM">=9981 AND "RNUM"<=10000)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("T"."NAME")
--               DESC ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=10000)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--          96  consistent gets
--           0  physical reads
--           0  redo size
--        2683  bytes sent via SQL*Net to client
--         635  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT /*+ first_rows (20) */ t.*
--               , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
--          FROM staff t
--        )
--  WHERE rnum BETWEEN 9981 AND 10000;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3862960255
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation                     | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT              |                   | 10000 |   830K|    22   (0)| 00:00:01 |
-- |*  1 |  VIEW                         |                   | 10000 |   830K|    22   (0)| 00:00:01 |
-- |*  2 |   WINDOW NOSORT STOPKEY       |                   |    20 |  1240 |    22   (0)| 00:00:01 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   4 |     INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM">=9981 AND "RNUM"<=10000)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY SYS_OP_DESCEND("NAME"),SYS_OP_DESCEND("BIRTH_DAY
--               "))<=10000)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--        9938  consistent gets
--           0  physical reads
--           0  redo size
--        2683  bytes sent via SQL*Net to client
--         635  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           0  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM staff t
-- ORDER BY t.name DESC
--        , t.birth_day DESC
-- FETCH FIRST 20 ROWS ONLY;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3395473997
-- 
-- ----------------------------------------------------------------------------------
-- | Id  | Operation                | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |       |    20 |  1980 |    31   (7)| 00:00:01 |
-- |*  1 |  VIEW                    |       |    20 |  1980 |    31   (7)| 00:00:01 |
-- |*  2 |   WINDOW SORT PUSHED RANK|       | 10000 |   605K|    31   (7)| 00:00:01 |
-- |   3 |    TABLE ACCESS FULL     | STAFF | 10000 |   605K|    29   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("from$_subquery$_002"."rowlimit_$$_rownumber"<=20)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("T"."NAME")
--               DESC ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--          96  consistent gets
--           0  physical reads
--           0  redo size
--        2521  bytes sent via SQL*Net to client
--         635  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT /*+ first_rows (20) */ *
--   FROM staff t
-- ORDER BY t.name DESC
--        , t.birth_day DESC
-- FETCH FIRST 20 ROWS ONLY;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3587465693
-- 
-- ----------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |                   |    20 |  1980 |    23   (5)| 00:00:01 |
-- |   1 |  SORT ORDER BY                 |                   |    20 |  1980 |    23   (5)| 00:00:01 |
-- |*  2 |   VIEW                         |                   |    20 |  1980 |    22   (0)| 00:00:01 |
-- |*  3 |    WINDOW NOSORT STOPKEY       |                   |    20 |  1240 |    22   (0)| 00:00:01 |
-- |   4 |     TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   5 |      INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - filter("from$_subquery$_002"."rowlimit_$$_rownumber"<=20)
--    3 - filter(ROW_NUMBER() OVER ( ORDER BY SYS_OP_DESCEND("NAME"),SYS_OP_DESCEND("BIRTH_DAY"
--               ))<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--          23  consistent gets
--           0  physical reads
--           0  redo size
--        2521  bytes sent via SQL*Net to client
--         635  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
-- FROM staff t
-- ORDER BY t.name DESC
--        , t.birth_day DESC
-- OFFSET 9980 ROWS FETCH NEXT 20 ROWS ONLY;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3395473997
-- 
-- ----------------------------------------------------------------------------------
-- | Id  | Operation                | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |       | 10000 |   966K|    31   (7)| 00:00:01 |
-- |*  1 |  VIEW                    |       | 10000 |   966K|    31   (7)| 00:00:01 |
-- |*  2 |   WINDOW SORT PUSHED RANK|       | 10000 |   605K|    31   (7)| 00:00:01 |
-- |   3 |    TABLE ACCESS FULL     | STAFF | 10000 |   605K|    29   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("from$_subquery$_002"."rowlimit_$$_rownumber"<=CASE  WHEN
--               (9980>=0) THEN 9980 ELSE 0 END +20 AND
--               "from$_subquery$_002"."rowlimit_$$_rownumber">9980)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("T"."NAME")
--               DESC ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=CASE  WHEN (9980>=0)
--               THEN 9980 ELSE 0 END +20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--          96  consistent gets
--           0  physical reads
--           0  redo size
--        2530  bytes sent via SQL*Net to client
--         635  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT /*+ first_rows (20) */ *
-- FROM staff
-- ORDER BY name DESC
--        , birth_day DESC
-- OFFSET 9980 ROWS FETCH NEXT 20 ROWS ONLY;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3587465693
-- 
-- ----------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |                   |    20 |  1980 |    23   (5)| 00:00:01 |
-- |   1 |  SORT ORDER BY                 |                   |    20 |  1980 |    23   (5)| 00:00:01 |
-- |*  2 |   VIEW                         |                   |    20 |  1980 |    22   (0)| 00:00:01 |
-- |*  3 |    WINDOW NOSORT STOPKEY       |                   |    20 |  1240 |    22   (0)| 00:00:01 |
-- |   4 |     TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   5 |      INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - filter("from$_subquery$_002"."rowlimit_$$_rownumber"<=CASE  WHEN (9980>=0) THEN 9980
--               ELSE 0 END +20 AND "from$_subquery$_002"."rowlimit_$$_rownumber">9980)
--    3 - filter(ROW_NUMBER() OVER ( ORDER BY SYS_OP_DESCEND("NAME"),SYS_OP_DESCEND("BIRTH_DAY"
--               ))<=CASE  WHEN (9980>=0) THEN 9980 ELSE 0 END +20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--        9936  consistent gets
--           0  physical reads
--           0  redo size
--        2530  bytes sent via SQL*Net to client
--         635  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- on 19c

-- SELECT *
--   FROM (   SELECT *
--              FROM staff
--          ORDER BY name DESC
--                 , birth_day DESC
--        )
--  WHERE ROWNUM <= 20;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3290597552
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation                     | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT              |                   |    20 |  1440 |    22   (0)| 00:00:01 |
-- |*  1 |  COUNT STOPKEY                |                   |       |       |            |          |
-- |   2 |   VIEW                        |                   |    20 |  1440 |    22   (0)| 00:00:01 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   4 |     INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(ROWNUM<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--          24  consistent gets
--           4  physical reads
--           0  redo size
--        2517  bytes sent via SQL*Net to client
--         515  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           0  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM (   SELECT /*+ first_rows (20) */ *
--              FROM staff
--          ORDER BY name DESC
--                 , birth_day DESC
--        )
--  WHERE ROWNUM <= 20;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3290597552
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation                     | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT              |                   |    20 |  1440 |    22   (0)| 00:00:01 |
-- |*  1 |  COUNT STOPKEY                |                   |       |       |            |          |
-- |   2 |   VIEW                        |                   |    20 |  1440 |    22   (0)| 00:00:01 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   4 |     INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter(ROWNUM<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--          24  consistent gets
--           0  physical reads
--           0  redo size
--        2517  bytes sent via SQL*Net to client
--         538  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           0  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT t.*
--               , ROWNUM rnum
--          FROM (   SELECT *
--                     FROM staff
--                 ORDER BY name DESC
--                        , birth_day DESC
--               ) t
--          WHERE ROWNUM <= 10000
--        )
--  WHERE rnum >= 9981;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 599682722
-- 
-- ----------------------------------------------------------------------------------
-- | Id  | Operation                | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |       | 10000 |   830K|    31   (7)| 00:00:01 |
-- |*  1 |  VIEW                    |       | 10000 |   830K|    31   (7)| 00:00:01 |
-- |*  2 |   COUNT STOPKEY          |       |       |       |            |          |
-- |   3 |    VIEW                  |       | 10000 |   703K|    31   (7)| 00:00:01 |
-- |*  4 |     SORT ORDER BY STOPKEY|       | 10000 |   605K|    31   (7)| 00:00:01 |
-- |   5 |      TABLE ACCESS FULL   | STAFF | 10000 |   605K|    29   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM">=9981)
--    2 - filter(ROWNUM<=10000)
--    4 - filter(ROWNUM<=10000)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--          97  consistent gets
--           0  physical reads
--           0  redo size
--        2673  bytes sent via SQL*Net to client
--         648  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT t.*
--               , ROWNUM rnum
--          FROM (   SELECT /*+ first_rows (20) */ *
--                     FROM staff
--                 ORDER BY name DESC
--                        , birth_day DESC
--               ) t
--          WHERE ROWNUM <= 10000
--        )
--  WHERE rnum >= 9981;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 885898956
-- 
-- ----------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |                   |    20 |  1700 |    22   (0)| 00:00:01 |
-- |*  1 |  VIEW                          |                   |    20 |  1700 |    22   (0)| 00:00:01 |
-- |*  2 |   COUNT STOPKEY                |                   |       |       |            |          |
-- |   3 |    VIEW                        |                   |    20 |  1440 |    22   (0)| 00:00:01 |
-- |   4 |     TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   5 |      INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM">=9981)
--    2 - filter(ROWNUM<=10000)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--        9933  consistent gets
--          15  physical reads
--           0  redo size
--        2673  bytes sent via SQL*Net to client
--         671  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           0  sorts (memory)
--           0  sorts (disk)
--          20  rows processed  

-- SELECT *
--   FROM ( SELECT t.*
--               , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
--          FROM staff t
--        )
--  WHERE rnum <= 20;
--  
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3862960255
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation                     | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT              |                   |    20 |  1700 |    22   (0)| 00:00:01 |
-- |*  1 |  VIEW                         |                   |    20 |  1700 |    22   (0)| 00:00:01 |
-- |*  2 |   WINDOW NOSORT STOPKEY       |                   |    20 |  1240 |    22   (0)| 00:00:01 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   4 |     INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM"<=20)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY SYS_OP_DESCEND("NAME"),SYS_OP_DESCEND("BIRTH_DAY
--               "))<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           2  recursive calls
--           0  db block gets
--          26  consistent gets
--           0  physical reads
--           0  redo size
--        2651  bytes sent via SQL*Net to client
--         530  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           0  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT /*+ first_rows (20) */ t.*
--               , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
--          FROM staff t
--        )
--  WHERE rnum <= 20;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3862960255
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation                     | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT              |                   |    20 |  1700 |    22   (0)| 00:00:01 |
-- |*  1 |  VIEW                         |                   |    20 |  1700 |    22   (0)| 00:00:01 |
-- |*  2 |   WINDOW NOSORT STOPKEY       |                   |    20 |  1240 |    22   (0)| 00:00:01 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   4 |     INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM"<=20)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY SYS_OP_DESCEND("NAME"),SYS_OP_DESCEND("BIRTH_DAY
--               "))<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--          24  consistent gets
--           0  physical reads
--           0  redo size
--        2651  bytes sent via SQL*Net to client
--         553  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           0  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT t.*
--               , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
--          FROM staff t
--        )
--  WHERE rnum BETWEEN 9981 AND 10000;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3395473997
-- 
-- ----------------------------------------------------------------------------------
-- | Id  | Operation                | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |       | 10000 |   830K|    31   (7)| 00:00:01 |
-- |*  1 |  VIEW                    |       | 10000 |   830K|    31   (7)| 00:00:01 |
-- |*  2 |   WINDOW SORT PUSHED RANK|       | 10000 |   605K|    31   (7)| 00:00:01 |
-- |   3 |    TABLE ACCESS FULL     | STAFF | 10000 |   605K|    29   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM">=9981 AND "RNUM"<=10000)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("T"."NAME")
--               DESC ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=10000)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--          97  consistent gets
--           0  physical reads
--           0  redo size
--        2673  bytes sent via SQL*Net to client
--         547  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM ( SELECT /*+ first_rows (20) */ t.*
--               , ROW_NUMBER() OVER (ORDER BY t.name DESC, t.birth_day DESC) rnum
--          FROM staff t
--        )
--  WHERE rnum BETWEEN 9981 AND 10000;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3862960255
-- 
-- ---------------------------------------------------------------------------------------------------
-- | Id  | Operation                     | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ---------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT              |                   | 10000 |   830K|    22   (0)| 00:00:01 |
-- |*  1 |  VIEW                         |                   | 10000 |   830K|    22   (0)| 00:00:01 |
-- |*  2 |   WINDOW NOSORT STOPKEY       |                   |    20 |  1240 |    22   (0)| 00:00:01 |
-- |   3 |    TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   4 |     INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ---------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("RNUM">=9981 AND "RNUM"<=10000)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY SYS_OP_DESCEND("NAME"),SYS_OP_DESCEND("BIRTH_DAY
--               "))<=10000)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--        9933  consistent gets
--           0  physical reads
--           0  redo size
--        2673  bytes sent via SQL*Net to client
--         570  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           0  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
--   FROM staff t
-- ORDER BY t.name DESC
--        , t.birth_day DESC
-- FETCH FIRST 20 ROWS ONLY;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3587465693
-- 
-- ----------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |                   |    20 |  1980 |    23   (5)| 00:00:01 |
-- |   1 |  SORT ORDER BY                 |                   |    20 |  1980 |    23   (5)| 00:00:01 |
-- |*  2 |   VIEW                         |                   |    20 |  1980 |    22   (0)| 00:00:01 |
-- |*  3 |    WINDOW NOSORT STOPKEY       |                   |    20 |  1240 |    22   (0)| 00:00:01 |
-- |   4 |     TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   5 |      INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - filter("from$_subquery$_002"."rowlimit_$$_rownumber"<=20)
--    3 - filter(ROW_NUMBER() OVER ( ORDER BY SYS_OP_DESCEND("NAME"),SYS_OP_DESCEND("BIRTH_DAY"
--               ))<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--          22  consistent gets
--           0  physical reads
--           0  redo size
--        2517  bytes sent via SQL*Net to client
--         468  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT /*+ first_rows (20) */ *
--   FROM staff t
-- ORDER BY t.name DESC
--        , t.birth_day DESC
-- FETCH FIRST 20 ROWS ONLY;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3587465693
-- 
-- ----------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |                   |    20 |  1980 |    23   (5)| 00:00:01 |
-- |   1 |  SORT ORDER BY                 |                   |    20 |  1980 |    23   (5)| 00:00:01 |
-- |*  2 |   VIEW                         |                   |    20 |  1980 |    22   (0)| 00:00:01 |
-- |*  3 |    WINDOW NOSORT STOPKEY       |                   |    20 |  1240 |    22   (0)| 00:00:01 |
-- |   4 |     TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|    22   (0)| 00:00:01 |
-- |   5 |      INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |     2   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - filter("from$_subquery$_002"."rowlimit_$$_rownumber"<=20)
--    3 - filter(ROW_NUMBER() OVER ( ORDER BY SYS_OP_DESCEND("NAME"),SYS_OP_DESCEND("BIRTH_DAY"
--               ))<=20)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--          22  consistent gets
--           0  physical reads
--           0  redo size
--        2517  bytes sent via SQL*Net to client
--         491  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT *
-- FROM staff t
-- ORDER BY t.name DESC
--        , t.birth_day DESC
-- OFFSET 9980 ROWS FETCH NEXT 20 ROWS ONLY;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3395473997
-- 
-- ----------------------------------------------------------------------------------
-- | Id  | Operation                | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |       | 10000 |   966K|    31   (7)| 00:00:01 |
-- |*  1 |  VIEW                    |       | 10000 |   966K|    31   (7)| 00:00:01 |
-- |*  2 |   WINDOW SORT PUSHED RANK|       | 10000 |   605K|    31   (7)| 00:00:01 |
-- |   3 |    TABLE ACCESS FULL     | STAFF | 10000 |   605K|    29   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    1 - filter("from$_subquery$_002"."rowlimit_$$_rownumber"<=10000 AND
--               "from$_subquery$_002"."rowlimit_$$_rownumber">9980)
--    2 - filter(ROW_NUMBER() OVER ( ORDER BY INTERNAL_FUNCTION("T"."NAME")
--               DESC ,INTERNAL_FUNCTION("T"."BIRTH_DAY") DESC )<=10000)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--          97  consistent gets
--           0  physical reads
--           0  redo size
--        2520  bytes sent via SQL*Net to client
--         482  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed

-- SELECT /*+ first_rows (20) */ *
-- FROM staff
-- ORDER BY name DESC
--        , birth_day DESC
-- OFFSET 9980 ROWS FETCH NEXT 20 ROWS ONLY;
-- 
-- Execution Plan
-- ----------------------------------------------------------
-- Plan hash value: 3587465693
-- 
-- ------------------------------------------------------------------------------------------------------------
-- | Id  | Operation                      | Name              | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
-- ------------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT               |                   | 10000 |   966K|       |   250   (1)| 00:00:01 |
-- |   1 |  SORT ORDER BY                 |                   | 10000 |   966K|  1240K|   250   (1)| 00:00:01 |
-- |*  2 |   VIEW                         |                   | 10000 |   966K|       |    22   (0)| 00:00:01 |
-- |*  3 |    WINDOW NOSORT STOPKEY       |                   |    20 |  1240 |       |    22   (0)| 00:00:01 |
-- |   4 |     TABLE ACCESS BY INDEX ROWID| STAFF             | 10000 |   605K|       |    22   (0)| 00:00:01 |
-- |   5 |      INDEX FULL SCAN           | IDX_STAFF_DESC_NB |    20 |       |       |     2   (0)| 00:00:01 |
-- ------------------------------------------------------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
-- 
--    2 - filter("from$_subquery$_002"."rowlimit_$$_rownumber"<=10000 AND
--               "from$_subquery$_002"."rowlimit_$$_rownumber">9980)
--    3 - filter(ROW_NUMBER() OVER ( ORDER BY SYS_OP_DESCEND("NAME"),SYS_OP_DESCEND("BIRTH_DAY"))<=1000
--               0)
-- 
-- 
-- Statistics
-- ----------------------------------------------------------
--           1  recursive calls
--           0  db block gets
--        9931  consistent gets
--           0  physical reads
--           0  redo size
--        2520  bytes sent via SQL*Net to client
--         499  bytes received via SQL*Net from client
--           3  SQL*Net roundtrips to/from client
--           1  sorts (memory)
--           0  sorts (disk)
--          20  rows processed
