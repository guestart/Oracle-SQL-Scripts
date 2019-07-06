REM
REM     Script:     bgs_role_syn_2.sql
REM     Author:     Quanwen Zhao
REM     Dated:      Jul 06, 2019
REM
REM     Purpose:
REM         This SQL script file (the 2nd version of 'bgs_role_syn.sql' you can see
REM         here - https://github.com/guestart/Oracle-SQL-Scripts/blob/master/grant/bgs_role_syn.sql) also uses to
REM         batch grant (only) select privilege on specific user (prod)'s all of tables to a new role (prod) and grant
REM         this new role to new user (qwz). This time I use a relatively simple PL/SQL code snippet to achieve the same intention.
REM

SET serveroutput ON
SET linesize 300

PROMPT =========================
PROMPT Executing on <SYS> schema
PROMPT =========================

DROP USER qwz;
CREATE USER qwz IDENTIFIED BY qwz;
GRANT connect, resource TO qwz;

GRANT create public synonym TO prod;
GRANT drop public synonym TO prod;

CREATE ROLE prod;

PROMPT ==========================
PROMPT Executing on <PROD> schema
PROMPT ==========================

-- switching to specific schema "prod", BTW I use Oracle SEPS (Security External Pasword Store) to achieve the intention
-- saving password of schema "prod".

CONN /@prod;

BEGIN
  DBMS_OUTPUT.enable(1000000);
  FOR r IN (
  SELECT 'GRANT SELECT ON ' || t.table_name || ' TO prod' x_sql,
         'CREATE PUBLIC SYNONYM ' || t.table_name || ' FOR ' || t.table_name y_sql
  FROM user_tables t
  ORDER BY t.table_name
  )
  LOOP
    BEGIN
      EXECUTE IMMEDIATE r.x_sql;
      EXECUTE IMMEDIATE r.y_sql;
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line(SUBSTR(r.x_sql, 1, 255));
        DBMS_OUTPUT.put_line(SUBSTR(r.y_sql, 1, 255));
        DBMS_OUTPUT.put_line(SQLCODE || ':' || SQLERRM);
    END;
  END LOOP;
END;
/

PROMPT =========================
PROMPT Executing on <SYS> schema
PROMPT =========================

CONN / as sysdba;
GRANT prod TO qwz;
