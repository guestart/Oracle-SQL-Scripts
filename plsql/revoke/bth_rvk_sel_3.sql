REM
REM     Script:     bth_rvk_sel_3.sql
REM     Author:     Quanwen Zhao
REM     Dated:      Jul 02, 2019
REM
REM     Purpose:
REM         This SQL script file (the 3rd version of 'bth_rvk_sel.sql' you can see
REM         here - https://github.com/guestart/Oracle-SQL-Scripts/blob/master/revoke/bth_rvk_sel.sql) also uses to
REM         batch revoke (only) select privilege on specific user (prod)'s all of tables from a new user (qwz) to whom
REM         if (once) being granted, this time I use a relatively complicated PL/SQL code to achieve the same intention. 
REM         Although code has a bit more final output is pretty readable and friendly.
REM

DROP USER qwz;
CREATE USER qwz IDENTIFIED BY qwz;
GRANT connect, resource TO qwz;

SET serveroutput ON
SET linesize 300

DECLARE
  v_cnt  number;
  v_flag number;
  v_sql  varchar2(100);
  CURSOR c_dba_tables IS
  SELECT owner, table_name
  FROM dba_tables
  WHERE owner = 'PROD'
  ORDER BY table_name
  ;
  v_dba_tables c_dba_tables%ROWTYPE;

BEGIN
  SELECT count(*) INTO v_cnt FROM dba_tables WHERE owner = 'PROD';
  v_flag := 0;
  OPEN c_dba_tables;
  LOOP
    BEGIN
      FETCH c_dba_tables INTO v_dba_tables;
      EXIT WHEN c_dba_tables%NOTFOUND;
      v_sql := 'REVOKE SELECT ON ' || v_dba_tables.owner || '.' || v_dba_tables.table_name || ' FROM qwz';
      EXECUTE IMMEDIATE v_sql;
      v_flag := v_flag + 1;
   -- DBMS_OUTPUT.put_line(v_dba_tables.table_name || ' revoked successfully.');
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line(SQLCODE || ':' || SQLERRM);
    END;
  END LOOP;
  CLOSE c_dba_tables;
  DBMS_OUTPUT.put_line(chr(13));
  DBMS_OUTPUT.put_line('Totally ' || v_flag || ' tables have been revoked only select privilege from new user ''QWZ''.');
  DBMS_OUTPUT.put_line(chr(13));
  DBMS_OUTPUT.put_line('Actually there are ' || v_cnt || ' tables on specific user ''PROD''.');
END;
/
