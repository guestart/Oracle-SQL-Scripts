REM
REM     Script:     brgs_role_syn_tab_3.sql
REM     Author:     Quanwen Zhao
REM     Dated:      Jul 30, 2019
REM
REM     Purpose:
REM         This is the 3rd version of 'brgs_role_syn_tab.sql'. On this version I create a materiralzed view 
REM         "u_tables" on my user-defined procedure "brgs_role_syn_tab_3" on grantor schema SZD_BBS_V2.
REM

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

DROP USER qwz;

CREATE USER qwz IDENTIFIED BY qwz;
GRANT connect, resource TO qwz;

GRANT create public synonym TO szd_bbs_v2;
GRANT drop public synonym TO szd_bbs_v2;

GRANT create materialized view TO szd_bbs_v2;
GRANT drop any materialized view TO szd_bbs_v2;

GRANT create job TO szd_bbs_v2;

DROP ROLE bbs;
CREATE ROLE bbs;

GRANT bbs TO qwz;

PROMPT ================================
PROMPT Executing on "SZD_BBS_V2" schema
PROMPT ================================

CONN /@szd_bbs_v2;

CREATE OR REPLACE PROCEDURE brgs_role_syn_tab_3
IS
  v_u_tables      VARCHAR2(200);
  v_gs_u_tables   VARCHAR2(200);  -- gs is the first letter abbreviation of "grant select"
  v_cps_u_tables  VARCHAR2(200);  -- cps is the first letter abbreviation of "create public synonym"
BEGIN
  v_u_tables := 'CREATE MATERIALIZED VIEW u_tables'
                || ' REFRESH COMPLETE ON DEMAND'
                || ' AS SELECT table_name, partitioned FROM all_tables'
		|| ' WHERE owner = ''SZD_BBS_V2'''
		|| ' ORDER BY table_name';
  v_gs_u_tables := 'GRANT SELECT ON u_tables TO bbs';
  v_cps_u_tables := 'CREATE OR REPLACE PUBLIC SYNONYM u_tables FOR u_tables';
  EXECUTE IMMEDIATE v_u_tables;
  EXECUTE IMMEDIATE v_gs_u_tables;
  EXECUTE IMMEDIATE v_cps_u_tables;
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
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line(SUBSTR(r.x_sql, 1, 255));
	DBMS_OUTPUT.put_line(SUBSTR(r.y_sql, 1, 255));
        DBMS_OUTPUT.put_line(SQLCODE || ':' || SQLERRM);
    END;
  END LOOP;
END;
/
