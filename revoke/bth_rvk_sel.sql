REM
REM     Script:    bth_rvk_sel.sql
REM     Author:    Quanwen Zhao
REM     Dated:     Jul 02, 2019
REM
REM     Purpose:
REM         This SQL script uses to batch revoke (only) select privilege on specific user's all of tables from
REM         a new user qwz to whom if (once) being granted, and then execute SPOOL sql file 'gen_bth_rvk_sel.sql'
REM         to achieve the function of 'batch revoke select'.
REM
 
DROP USER qwz;
CREATE USER qwz IDENTIFIED BY qwz;
GRANT connect, resource TO qwz;
 
SET long     10000
SET linesize 300
SET pagesize 0
 
SET echo      OFF
SET feedback  OFF
SET heading   OFF
SET termout   OFF
SET verify    OFF
SET trimout   ON
SET trimspool ON
 
SPOOL gen_bth_rvk_sel.sql
SELECT 'REVOKE SELECT ON '
       || owner
       || '.'
       || table_name
       || ' FROM qwz;'
FROM dba_tables
WHERE owner = 'PROD'
ORDER BY table_name
/
SPOOL off
