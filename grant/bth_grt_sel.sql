REM
REM     Script:    bth_grt_sel.sql
REM     Author:    Quanwen Zhao
REM     Dated:     Jun 30, 2019
REM
REM     Purpose:
REM         This SQL script uses to batch generate "grant (only) select privilege on specific user (prod)'s all 
REM         of tables to  a new user (qwz)", and then execute SPOOL sql file 'gen_bth_grt_sel.sql' to achieve the
REM         function of 'batch grant select'.
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
 
SPOOL gen_bth_grt_sel.sql
SELECT 'GRANT SELECT ON '
       || owner
       || '.'
       || table_name
       || ' TO qwz;'
FROM dba_tables
WHERE owner = 'PROD'
ORDER BY table_name
/
SPOOL off

-- Inserting new line on Jul 05, 2019.
-- Next directly running the previous batch generated SQL statement of "grant select".
@gen_bth_grt_sel.sql;
