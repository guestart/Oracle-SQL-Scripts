REM
REM     Script:     bth_grt_sel_3.sql
REM     Author:     Quanwen Zhao
REM     Dated:      Jun 30, 2019
REM
REM     Purpose:
REM         This SQL script file (the 3rd version of 'bth_grt_sel.sql' you can see
REM         here - https://github.com/guestart/Oracle-SQL-Scripts/blob/master/grant/bth_grt_sel.sql) is also used to
REM         batch grant (only) select privilege on specific user's all of tables to a new user qwz, this time I
REM         use a relatively complicated PL/SQL code to achieve the same intention. Although code has a bit more final
REM         output is pretty readable and friendly.
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
      v_sql := 'GRANT SELECT ON ' || v_dba_tables.owner || '.' || v_dba_tables.table_name || ' TO qwz';
      EXECUTE IMMEDIATE v_sql;
      v_flag := v_flag + 1;
   -- DBMS_OUTPUT.put_line(v_dba_tables.table_name || ' granted successfully.');
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line(SQLCODE || ':' || SQLERRM);
    END;
  END LOOP;
  CLOSE c_dba_tables;
  DBMS_OUTPUT.put_line(chr(13));
  DBMS_OUTPUT.put_line('Totally ' || v_flag || ' tables have been granted only select privilege to new user ''QWZ''.');
  DBMS_OUTPUT.put_line(chr(13));
  DBMS_OUTPUT.put_line('Actually there are ' || v_cnt || ' tables on specific user ''PROD''.');
END;
/
