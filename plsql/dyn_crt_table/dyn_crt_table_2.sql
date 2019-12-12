REM
REM     Script:        dyn_crt_table_2.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Dec 11, 2019
REM
REM     Purpose:
REM        This SQL script usually uses to dynamically create a test table via *ACCEPT* command of SQL*Plus.
REM
REM     Notice:
REM        If you directly pastle my code into SQL*Plus and run it Oracle won't acquire the value of "l_num".
REM
REM        SQL> SET VERIFY OFF
REM        SQL> 
REM        SQL> PROMPT ===========================================================================
REM        SQL> PROMPT Creating a test table, according to the value of variable "l_num" you input
REM        SQL> PROMPT ===========================================================================
REM        SQL> 
REM        SQL> DROP TABLE t PURGE;
REM        
REM        ACCEPT l_num NUMBER PROMPT 'Please input a value of l_num: ';
REM        
REM        
REM        Table dropped.
REM        
REM        SQL> SQL> Please input a value of l_num: SQL> CREATE TABLE t
REM          2  SEGMENT CREATION IMMEDIATE
REM          3  NOLOGGING
REM          4  AS
REM          5     SELECT ROWNUM id
REM          6            , CASE WHEN ROWNUM BETWEEN 1            AND 1/5*(&l_num) THEN 'low'
REM          7                   WHEN ROWNUM BETWEEN 2/5*(&l_num) AND 3/5*(&l_num) THEN 'mid'
REM          8                   WHEN ROWNUM BETWEEN 4/5*(&l_num) AND     (&l_num) THEN 'high'
REM          9                   ELSE 'unknown' 
REM         10              END flag
REM         11            , DBMS_RANDOM.string ('p', 8) pwd
REM         12     FROM XMLTABLE ('1 to xs:integer($i)' passing &l_num as "i")
REM         13  ;
REM        
REM        Table created.
REM        
REM        SQL> desc t
REM         Name                                      Null?    Type
REM         ----------------------------------------- -------- ----------------------------
REM         ID                                                 NUMBER
REM         FLAG                                               VARCHAR2(7)
REM         PWD                                                VARCHAR2(4000)
REM        
REM        SQL> select count(*) from t;
REM        
REM          COUNT(*)
REM        ----------
REM                 0
REM        
REM        SQL> 
REM

SET VERIFY OFF

PROMPT ===========================================================================
PROMPT Creating a test table, according to the value of variable "l_num" you input
PROMPT ===========================================================================

DROP TABLE t PURGE;

ACCEPT l_num NUMBER PROMPT 'Please input a value of l_num: ';

CREATE TABLE t
SEGMENT CREATION IMMEDIATE
NOLOGGING
AS
   SELECT ROWNUM id
          , CASE WHEN ROWNUM BETWEEN 1            AND 1/5*(&l_num) THEN 'low'
                 WHEN ROWNUM BETWEEN 2/5*(&l_num) AND 3/5*(&l_num) THEN 'mid'
                 WHEN ROWNUM BETWEEN 4/5*(&l_num) AND     (&l_num) THEN 'high'
                 ELSE 'unknown' 
            END flag
          , DBMS_RANDOM.string ('p', 8) pwd
   FROM XMLTABLE ('1 to xs:integer($i)' passing &l_num as "i")
;

-- A simple Demo is as follows:
-- 
-- Here you must call my sql script name to run it otherwise Oracle won't give you a chance to acquire the value of "l_num".
-- 
-- SQL> @dyn_crt_tab_2
-- ===========================================================================
-- Creating a test table, according to the value of variable "l_num" you input
-- ===========================================================================
-- DROP TABLE t PURGE
--            *
-- ERROR at line 1:
-- ORA-00942: table or view does not exist
-- 
-- 
-- Please input a value of l_num: 1e4
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
