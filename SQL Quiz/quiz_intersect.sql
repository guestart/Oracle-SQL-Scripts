REM
REM     Script:        quiz_intersect.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Dec 31, 2020
REM
REM     Last tested:
REM             18.3.0.0
REM             19.8.0.0 (LiveSQL)
REM
REM     Purpose:
REM       This SQL script uses to take the following SQL Quiz I once noticed on a place
REM       where I seem like to not remember it a few days ago.
REM
REM       Which statement is true regarding the INTERSECT operator in the oracle database?
REM
REM       (1) By reversing the order of the intersected tables alter the result.
REM
REM       (2) It ignores the NULL values.
REM
REM       (3) The number of columns and the data types must be identical for all of the
REM           SELECT statements in the query.
REM
REM       (4) The names of all columns in the SELECT statements must be identical.
REM
REM       (5) None.

PROMPT  ==================================================================
PROMPT             Building a demo for verifying Choice 1:
PROMPT  ==================================================================
PROMPT  By reversing the order of the intersected tables alter the result.
PROMPT  ==================================================================

DROP TABLE t1 PURGE;

CREATE table t1(a VARCHAR2(1), b VARCHAR2(1));

INSERT INTO t1 VALUES ('a', 'b');
INSERT INTO t1 VALUES ('a', 'c');
INSERT INTO t1 VALUES ('b', 'c');

COMMIT;

DROP TABLE t2 PURGE;

CREATE TABLE t2(a VARCHAR2(1), b VARCHAR2(1));

INSERT INTO t2 VALUES ('a', 'b');
INSERT INTO t2 VALUES ('c', 'd');
INSERT INTO t2 VALUES ('b', 'c');

COMMIT;

SELECT * FROM t1
INTERSECT
SELECT * FROM t2
;

-- on 18.3 and LiveSQL:

-- A B
-- - -
-- a b
-- b c

SELECT * FROM t2
INTERSECT
SELECT * FROM t1
;

-- on 18.3 and LiveSQL:

-- A B
-- - -
-- a b
-- b c

PROMPT  =======================================
PROMPT  Building a demo for verifying Choice 2:
PROMPT  =======================================
PROMPT  It ignores the NULL values.
PROMPT  =======================================

DROP TABLE t1 PURGE;

CREATE table t1(a CHAR(1), b CHAR(1), c CHAR(1));

INSERT INTO t1 VALUES ('a', 'b', null);
INSERT INTO t1 VALUES ('a', null, 'c');
INSERT INTO t1 VALUES ('a', 'b', 'c');

COMMIT;

DROP TABLE t2 PURGE;

CREATE TABLE t2(a CHAR(1), b CHAR(1), c CHAR(1));

INSERT INTO t2 VALUES ('a', 'b', null);
INSERT INTO t2 VALUES ('a', null, 'c');
INSERT INTO t2 VALUES ('d', 'e', 'f');

COMMIT;

SELECT * FROM t1
INTERSECT
SELECT * FROM t2
;

-- on 18.3:

-- A B C
-- - - -
-- a b
-- a   c

-- on LiveSQL:

-- A B C
-- - - -
-- a b -
-- a - c

SELECT
           CASE WHEN a IS NULL THEN 'null'
           ELSE a
           END "A",
           CASE WHEN b IS NULL THEN 'null'
           else b
           end "B",
           CASE WHEN c IS NULL THEN 'null'
           else c
           end "C"
FROM
           t1
INTERSECT
SELECT
           CASE WHEN a IS NULL THEN 'null'
           ELSE a
           END "A",
           CASE WHEN b IS NULL THEN 'null'
           else b
           end "B",
           CASE WHEN c IS NULL THEN 'null'
           else c
           end "C"
FROM
           t2
;

-- on 18.3:

-- A    B    C
-- ---- ---- ----
-- a    b    null
-- a    null c

-- on LiveSQL:

-- A B    C
-- - ---- ----
-- a b    null
-- a null c

SELECT
           NVL(a, 'null') a,
           NVL(b, 'null') b,
           NVL(c, 'null') c
FROM
           t1
INTERSECT
SELECT
           NVL(a, 'null') a,
           NVL(b, 'null') b,
           NVL(c, 'null') c
FROM
           t2
;

-- on 18.3:

-- A    B    C
-- ---- ---- ----
-- a    b    null
-- a    null c

-- on LiveSQL:

-- A B    C
-- - ---- ----
-- a b    null
-- a null c

PROMPT  =========================================================================
PROMPT                  Building a demo for verifying Choice 3:
PROMPT  =========================================================================
PROMPT  The number of columns and the data types must be identical for all of the
PROMPT  SELECT statements in the query.
PROMPT  =========================================================================

-- The number of columns of the SQL query (for the INTERSECTION in two tables) is different. 

DROP TABLE t1 PURGE;

CREATE table t1(a NUMBER(1), b NUMBER(1));

INSERT INTO t1 VALUES (1, 2);
INSERT INTO t1 VALUES (2, 3);
INSERT INTO t1 VALUES (1, 3);

COMMIT;

DROP TABLE t2 PURGE;

CREATE TABLE t2(a NUMBER(1), b NUMBER(1));

INSERT INTO t2 VALUES (1, 2);
INSERT INTO t2 VALUES (3, 4);
INSERT INTO t2 VALUES (2, 3);

COMMIT;

SELECT
           a, b
FROM       t1
INTERSECT
SELECT     a
FROM       t2
;

-- on 18.3 and LiveSQL:

-- ORA-01789: query block has incorrect number of result columns


-- The data type of columns of the SQL query (for the INTERSECTION in two tables) is different.

DROP TABLE t1 PURGE;

CREATE table t1(a NUMBER(1), b NUMBER(1));

INSERT INTO t1 VALUES (1, 2);
INSERT INTO t1 VALUES (2, 3);
INSERT INTO t1 VALUES (1, 3);

COMMIT;

DROP TABLE t2 PURGE;

CREATE TABLE t2(a CHAR(1), b CHAR(1));

INSERT INTO t2 VALUES ('1', '2');
INSERT INTO t2 VALUES ('3', '4');
INSERT INTO t2 VALUES ('2', '3');

COMMIT;

SELECT * FROM t1
INTERSECT
SELECT * FROM t2
;

-- on 18.3 and LiveSQL:

-- ORA-01790: expression must have same datatype as corresponding expression

DROP TABLE t1 PURGE;

CREATE table t1(a NUMBER, b NUMBER);

INSERT INTO t1 VALUES (1, 2);
INSERT INTO t1 VALUES (2, 3);
INSERT INTO t1 VALUES (1, 3);

COMMIT;

DROP TABLE t2 PURGE;

-- showing an error of ORA-00907: missing right parenthesis when creating the table t2 using the data type INTEGER(1).
-- CREATE TABLE t2(a INTEGER(1), b INTEGER(1));

CREATE TABLE t2(a INTEGER, b INTEGER);

INSERT INTO t2 VALUES (1, 2);
INSERT INTO t2 VALUES (3, 4);
INSERT INTO t2 VALUES (2, 3);

COMMIT;

SELECT * FROM t1
INTERSECT
SELECT * FROM t2
;

-- on 18.3:

--          A          B
-- ---------- ----------
--          1          2
--          2          3

-- on LiveSQL:

-- A B
-- - -
-- 1 2
-- 2 3

PROMPT  ====================================================================
PROMPT                Building a demo for verifying Choice 4:
PROMPT  ====================================================================
PROMPT  The names of all columns in the SELECT statements must be identical.
PROMPT  ====================================================================

DROP TABLE t1 PURGE;

CREATE table t1(a INTEGER);

INSERT INTO t1 VALUES (1);
INSERT INTO t1 VALUES (2);
INSERT INTO t1 VALUES (3);

COMMIT;

DROP TABLE t2 PURGE;

CREATE TABLE t2(b INTEGER);

INSERT INTO t2 VALUES (1);
INSERT INTO t2 VALUES (3);
INSERT INTO t2 VALUES (4);

COMMIT;

SELECT a FROM t1
INTERSECT
SELECT b FROM t2
;

-- on 18.3:

--          A
-- ----------
--          1
--          3

-- on LiveSQL:

-- A
-- -
-- 1
-- 3

SELECT b FROM t2
INTERSECT
SELECT a FROM t1
;

-- on 18.3:

--          B
-- ----------
--          1
--          3

-- on LiveSQL:

-- B
-- -
-- 1
-- 3
