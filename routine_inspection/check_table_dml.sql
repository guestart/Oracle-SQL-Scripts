REM
REM     Script:        check_table_dml.sql
REM     Author:        Quanwen Zhao
REM     Dated:         JAN 24, 2024
REM
REM     Last tested:
REM             11.2.0.4
REM             19.13.0.0
REM
REM     Purpose:
REM       This sql script uses to check the dml situation for the specific table of the specific production user by dba_tab_modifications.
REM

SET LINESIZE 400
SET PAGESIZE 200
COLUMN table_name FORMAT a35

SELECT table_name,
       inserts,
       updates,
       deletes,
       timestamp
FROM dba_tab_modifications
WHERE table_owner = upper('&table_owner')
AND table_name = upper('&table_name')
ORDER BY 1;
