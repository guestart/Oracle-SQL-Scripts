REM
REM     Script:     rgy_refresh_mview_uts.sql
REM     Author:     Quanwen Zhao
REM     Dated:      Jul 30, 2019
REM
REM     Purpose:
REM         This SQL script uses to regularly refresh MView "u_tables" created by procedure "brgs_role_syn_tab_3"
REM         from the SQL script "brgs_role_syn_tab_3.sql".
REM

PROMPT ================================
PROMPT Executing on "SZD_BBS_V2" schema
PROMPT ================================

CONN /@szd_bbs_v2;

CREATE OR REPLACE PROCEDURE rgy_refresh_mview_uts
IS
BEGIN
  DBMS_MVIEW.refresh('u_tables', 'c');
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
