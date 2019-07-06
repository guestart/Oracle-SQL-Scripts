REM
REM     Script:     bth_rvk_sel_2.sql
REM     Author:     Quanwen Zhao
REM     Dated:      JuL 02, 2019
REM
REM     Purpose:
REM         This SQL script file (the 2nd version of 'bth_rvk_sel.sql' you can see
REM         here - https://github.com/guestart/Oracle-SQL-Scripts/blob/master/revoke/bth_rvk_sel.sql) also uses to
REM         batch revoke (only) select privilege on specific user (prod)'s all of tables from a new user (qwz) to whom
REM         if (once) being granted, this time I use a relatively simple PL/SQL code snippet to achieve the same intention.
REM

SET serveroutput ON
SET linesize 300

DROP USER qwz;
CREATE USER qwz IDENTIFIED BY qwz;
GRANT connect, resource TO qwz;

BEGIN
  DBMS_OUTPUT.enable(1000000);
  FOR r IN (
  SELECT 'REVOKE SELECT ON ' || t.OWNER || '.' || t.TABLE_NAME || ' FROM qwz' x_sql
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
