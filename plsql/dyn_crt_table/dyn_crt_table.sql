REM
REM     Script:        dyn_crt_table.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Dec 11, 2019
REM
REM     Purpose:
REM        This SQL script usually uses to dynamically create a test table via substitution variable of SQL*Plus.
REM

SET VERIFY OFF

PROMPT ===========================================================================
PROMPT Creating a test table, according to the value of variable "l_num" you input
PROMPT ===========================================================================

DROP TABLE t PURGE;

UNDEFINE l_num;

CREATE TABLE t
SEGMENT CREATION IMMEDIATE
NOLOGGING
AS
   SELECT ROWNUM id
          , CASE WHEN ROWNUM BETWEEN 1             AND 1/5*(&&l_num) THEN 'low'
                 WHEN ROWNUM BETWEEN 2/5*(&&l_num) AND 3/5*(&&l_num) THEN 'mid'
                 WHEN ROWNUM BETWEEN 4/5*(&&l_num) AND     (&&l_num) THEN 'high'
                 ELSE 'unknown' 
            END flag
          , DBMS_RANDOM.string ('p', 8) pwd
   FROM XMLTABLE ('1 to xs:integer($i)' passing &&l_num as "i")
;

-- A simple Demo is as follows:
-- 
-- SQL> @dyn_crt_tab
-- ===========================================================================
-- Creating a test table, according to the value of variable "l_num" you input
-- ===========================================================================
-- DROP TABLE t PURGE
--            *
-- ERROR at line 1:
-- ORA-00942: table or view does not exist
-- 
-- 
-- Enter value for l_num: 1e4
-- 
-- Table created.
-- 
-- SQL> desc t
--  Name                                      Null?    Type
--  ----------------------------------------- -------- ----------------------------
--  ID                                                 NUMBER
--  FLAG                                               VARCHAR2(7)
--  PWD                                                VARCHAR2(4000)
-- 
-- SQL> select count(*) from t;
-- 
--   COUNT(*)
-- ----------
--      10000
-- 
-- SQL> 
