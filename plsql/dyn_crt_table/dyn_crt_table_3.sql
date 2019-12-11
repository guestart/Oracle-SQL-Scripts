REM
REM     Script:        dyn_crt_table_3.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Dec 11, 2019
REM
REM     Purpose:
REM        This PL/SQL code usually uses to dynamically create a test table via using a concatenation string "||".
REM

CREATE OR REPLACE PROCEDURE crt_tab_test (l_num IN NUMBER)
AS
   v_sql_1 VARCHAR2(2000);
   v_sql_2 VARCHAR2(2000);
BEGIN
   v_sql_1 := 'DROP TABLE t PURGE';
   v_sql_2 := 'CREATE TABLE t '
           || 'SEGMENT CREATION IMMEDIATE '
           || 'NOLOGGING '
           || 'AS '
           || '   SELECT ROWNUM id '
           || '          , CASE WHEN ROWNUM BETWEEN 1                      AND 1/5*' || l_num || ' THEN ''low'' '
           || '                 WHEN ROWNUM BETWEEN 2/5*' || l_num || '    AND 3/5*' || l_num || ' THEN ''mid'' '
           || '                 WHEN ROWNUM BETWEEN 4/5*' || l_num || '    AND     ' || l_num || ' THEN ''high'' '
           || '                 ELSE ''unknown'' '
           || '            END flag '
           || '          , DBMS_RANDOM.string (''p'', 8) pwd '
           || '   FROM XMLTABLE (''1 to ' || l_num || ''')';
   EXECUTE IMMEDIATE v_sql_1;
   EXECUTE IMMEDIATE v_sql_2;
   DBMS_STATS.gather_table_stats(
           OWNNAME            => user,
           TABNAME            => 'T'
   );
EXCEPTION
   WHEN OTHERS THEN
      EXECUTE IMMEDIATE v_sql_2;
      DBMS_STATS.gather_table_stats(
              OWNNAME            => user,
              TABNAME            => 'T'
      );
END crt_tab_test;
/

-- A simple Demo is as follows:
-- 
-- SQL> @dyn_crt_tab_3
-- 
-- Procedure created.
-- 
-- SQL> execute crt_tab_test(1e4);
-- 
-- PL/SQL procedure successfully completed.
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
