REM
REM     Script:     bgs_role_syn_3.sql
REM     Author:     Quanwen Zhao
REM     Dated:      Jul 06, 2019
REM
REM     Purpose:
REM         This SQL script file (the 3rd version of 'bgs_role_syn.sql' you can see
REM         here - https://github.com/guestart/Oracle-SQL-Scripts/blob/master/grant/bgs_role_syn.sql) also uses to
REM         batch grant (only) select privilege on specific user (prod)'s all of tables to a new role (prod) and grant
REM         this new role to new user (qwz). This time I use a relatively complicated PL/SQL code snippet to achieve the same intention.
REM         Although code has a bit more final output is pretty readable and friendly.
REM

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

DROP USER qwz;
CREATE USER qwz IDENTIFIED BY qwz;
GRANT connect, resource TO qwz;

GRANT create public synonym TO prod;
GRANT drop public synonym TO prod;

CREATE ROLE prod;

PROMPT ==========================
PROMPT Executing on "PROD" schema
PROMPT ==========================

-- switching to specific schema "prod", BTW I use Oracle SEPS (Security External Password Store) to achieve the intention
-- saving password of schema "prod".

CONN /@prod;

SET serveroutput ON
SET linesize 300

DECLARE
  v_cnt   number;
  v_flag  number;
  v_sql   varchar2(100);
  v_sql_2 varchar2(100);
  CURSOR c_user_tables IS
  SELECT table_name
  FROM user_tables
  ORDER BY table_name
  ;
  v_user_tables c_user_tables%ROWTYPE;
 
BEGIN
  SELECT count(*) INTO v_cnt FROM user_tables;
  v_flag := 0;
  OPEN c_user_tables;
  LOOP
    BEGIN
      FETCH c_user_tables INTO v_user_tables;
      EXIT WHEN c_user_tables%NOTFOUND;
      v_sql := 'GRANT SELECT ON ' || v_user_tables.table_name || ' TO prod';
      v_sql_2 := 'CREATE PUBLIC SYNONYM ' || v_user_tables.table_name || ' FOR ' || v_user_tables.table_name;
      EXECUTE IMMEDIATE v_sql;
      EXECUTE IMMEDIATE v_sql_2;
      v_flag := v_flag + 1;
   -- DBMS_OUTPUT.put_line(v_user_tables.table_name || ' granted successfully.');
   -- DBMS_OUTPUT.put_line('Public synonym ' || v_user_tables.table_name || ' on schema ''PROD'' created successfully.');
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line(SQLCODE || ':' || SQLERRM);
    END;
  END LOOP;
  CLOSE c_user_tables;
  DBMS_OUTPUT.put_line(chr(13));
  DBMS_OUTPUT.put_line('Totally ' || v_flag || ' tables have been granted only select privilege to new role ''PROD''.');
  DBMS_OUTPUT.put_line(chr(13));
  DBMS_OUTPUT.put_line('Actually there are ' || v_cnt || ' tables on schema ''PROD''.');
END;
/

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

CONN / as sysdba;
GRANT prod TO qwz;
