REM
REM     Script:     brgs_role_syn_tab_2.sql
REM     Author:     Quanwen Zhao
REM     Dated:      Jul 23, 2019
REM
REM     Purpose:
REM         This is the 2nd version of 'brgs_role_syn_tab.sql'. On this version I simplify my user-defined procedure 
REM         'brgs_role_syn_tab_2' based on 'brgs_role_syn_tab' on schema SZD_BBS_V2.
REM
REM         As you can see from the following demo, repeatedly do both 'grant' and 'create or replace' operation is okay,
REM         except 'revoke' operation. So it's why I reduce several procedure source code in particuluar 'IF ... THEN ... END IF'.
REM
REM         SZD_BBS_V2@xxxx> GRANT SELECT ON usr_tables TO bbs;
REM
REM         Grant succeeded.
REM
REM         SZD_BBS_V2@xxxx> GRANT SELECT ON usr_tables TO bbs;
REM
REM         Grant succeeded.
REM
REM         SZD_BBS_V2@xxxx> REVOKE SELECT ON usr_tables FROM bbs;
REM
REM         Revoke succeeded.
REM
REM         SZD_BBS_V2@xxxx> REVOKE SELECT ON usr_tables FROM bbs;
REM         REVOKE SELECT ON usr_tables FROM bbs
REM         *
REM         ERROR at line 1:
REM         ORA-01927: cannot REVOKE privileges you did not grant
REM
REM         SZD_BBS_V2@xxxx> CREATE OR REPLACE PUBLIC SYNONYM usr_tables FOR usr_tables;
REM
REM         Synonym created.
REM
REM         SZD_BBS_V2@xxxx> CREATE OR REPLACE PUBLIC SYNONYM usr_tables FOR usr_tables;
REM
REM         Synonym created.
REM
REM         The primary intention is able to query all of schema SZD_BBS_V2's table on schema QWZ.
REM

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

DROP USER qwz;

CREATE USER qwz IDENTIFIED BY qwz;
GRANT connect, resource TO qwz;

GRANT create public synonym TO szd_bbs_v2;
GRANT drop public synonym TO szd_bbs_v2;

-- GRANT select ON dba_synonyms TO szd_bbs_v2;

GRANT create view TO szd_bbs_v2;
GRANT drop any view TO szd_bbs_v2;

GRANT create job TO szd_bbs_v2;

DROP ROLE bbs;
CREATE ROLE bbs;

GRANT bbs TO qwz;

PROMPT ================================
PROMPT Executing on "SZD_BBS_V2" schema
PROMPT ================================

CONN /@szd_bbs_v2;

CREATE OR REPLACE PROCEDURE brgs_role_syn_tab_2
IS
  -- v_usr_tables  VARACHAR2(200);
  v_usr_tables     VARCHAR2(200);
  -- v_usr_tab_privs VARCHAR2(200);
  v_gs_usr_tables  VARCHAR2(200); -- gs is the first letter abbreviation of "grant select"
  v_cps_usr_tables VARCHAR2(200); -- cps is the first letter abbreviation of "create public synonym"
  -- v_utp_number  NUMBER;        -- utp is the first letter abbreviation of view "user_tab_privs"
  -- v_ds_number   NUMBER;        -- ds is the first letter abbreviation of view "dba_synonyms"
BEGIN
  v_usr_tables := 'CREATE OR REPLACE VIEW usr_tables'
                  || ' AS SELECT table_name, partitioned FROM all_tables'
		  || ' WHERE owner = ''SZD_BBS_V2'''
		  || ' ORDER BY table_name'
		  || ' WITH READ ONLY';
  v_gs_usr_tables := 'GRANT SELECT ON usr_tables TO bbs';
  v_cps_usr_tables := 'CREATE OR REPLACE PUBLIC SYNONYM usr_tables FOR usr_tables';
  EXECUTE IMMEDIATE v_usr_tables;
  EXECUTE IMMEDIATE v_gs_usr_tables;
  EXECUTE IMMEDIATE v_cps_usr_tables;
  -- v_usr_tab_privs := 'SELECT table_name, grantor, privilege FROM user_tab_privs WHERE grantee = ''BBS''';
  -- SELECT COUNT(*) INTO v_utp_number FROM user_tab_privs WHERE grantee = 'BBS';
  -- SELECT COUNT(*) INTO v_ds_number FROM dba_synonyms WHERE table_owner = 'SZD_BBS_V2';
  DBMS_OUTPUT.enable(1000000);
  FOR r IN (
  SELECT 'GRANT SELECT ON ' || t.table_name || ' TO bbs' x_sql,
	 'CREATE OR REPLACE PUBLIC SYNONYM ' || t.table_name || ' FOR ' || t.table_name y_sql
  FROM user_tables t
  ORDER BY t.table_name
  )
  LOOP
    BEGIN
      EXECUTE IMMEDIATE r.x_sql;
      EXECUTE IMMEDIATE r.y_sql;
    -- EXECEPTION
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line(SUBSTR(r.x_sql, 1, 255));
	DBMS_OUTPUT.put_line(SUBSTR(r.y_sql, 1, 255));
        DBMS_OUTPUT.put_line(SQLCODE || ':' || SQLERRM);
    END;
  END LOOP;
END;
/
