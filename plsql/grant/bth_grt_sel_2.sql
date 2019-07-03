REM
REM     Script:     bth_grt_sel_2.sql
REM     Author:     Quanwen Zhao
REM     Dated:      Jun 30, 2019
REM
REM     Purpose:
REM         This SQL script file (the 2nd version of 'bth_grt_sel.sql' you can see
REM         here - https://github.com/guestart/Oracle-SQL-Scripts/blob/master/grant/bth_grt_sel.sql) also uses to
REM         batch grant (only) select privilege on specific user (prod)'s all of tables to a new user qwz, this time
REM         I use a relatively simple PL/SQL code snippet to achieve the same intention.
REM

DROP USER qwz;
CREATE USER qwz IDENTIFIED BY qwz;
GRANT connect, resource TO qwz;
 
SET serveroutput ON
SET linesize 300
 
BEGIN
  DBMS_OUTPUT.enable(1000000);
  FOR r IN (
  SELECT 'GRANT SELECT ON ' || t.OWNER || '.' || t.TABLE_NAME || ' TO qwz' x_sql
  FROM SYS.dba_tables t
  WHERE OWNER = 'PROD'
  ORDER BY t.table_name
  )
  LOOP
    BEGIN
      EXECUTE IMMEDIATE r.x_sql;
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line(SUBSTR(r.x_sql, 1, 255));
        DBMS_OUTPUT.put_line(SQLCODE || ':' || SQLERRM);
    END;
  END LOOP;
END;
/
