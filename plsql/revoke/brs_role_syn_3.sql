REM
REM     Script:    brs_role_syn_3.sql
REM     Author:    Quanwen Zhao
REM     Dated:     Jul 06, 2019
REM
REM     Purpose:
REM         This SQL script file (the 2nd version of 'brs_role_syn.sql' you can see
REM         here - https://github.com/guestart/Oracle-SQL-Scripts/blob/master/revoke/brs_role_syn.sql),
REM         this time I use a relatively complicated PL/SQL code snippet to achieve the same intention.
REM         Although code has a bit more final output is pretty readable and friendly.
REM

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

REVOKE prod FROM qwz;

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
      v_sql := 'REVOKE SELECT ON ' || v_user_tables.table_name || ' FROM prod';
      v_sql_2 := 'DROP PUBLIC SYNONYM ' || v_user_tables.table_name;
      EXECUTE IMMEDIATE v_sql;
      EXECUTE IMMEDIATE v_sql_2;
      v_flag := v_flag + 1;
   -- DBMS_OUTPUT.put_line(v_user_tables.table_name || ' revoked successfully.');
   -- DBMS_OUTPUT.put_line('Public synonym ' || v_user_tables.table_name || ' on schema ''PROD'' droped successfully.');
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line(SQLCODE || ':' || SQLERRM);
    END;
  END LOOP;
  CLOSE c_user_tables;
  DBMS_OUTPUT.put_line(chr(13));
  DBMS_OUTPUT.put_line('Totally ' || v_flag || ' tables have been revoked only select privilege from new role ''PROD''.');
  DBMS_OUTPUT.put_line(chr(13));
  DBMS_OUTPUT.put_line('Actually there are ' || v_cnt || ' tables on schema ''PROD''.');
END;
/

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

CONN / as sysdba;

DROP ROLE prod;

REVOKE drop public synonym FROM prod;
REVOKE create public synonym FROM prod;

REVOKE connect, resource FROM qwz;
DROP USER qwz;

-- Or just revoke role_name from new user_name.
-- REVOKE prod FROM qwz;
