REM
REM     Script:        check_data_dictionary_tables_and_views.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Jul 19, 2018
REM
REM     Last tested
REM             11.2.0.4
REM     Purpose:  
REM             This sql script usually checks the Oracle data dictionary tables and views.
REM

SET LINESIZE 200
SET PAGESIZE 200

COLUMN table_name FORMAT a30
COLUMN comments   FORMAT a65

SELECT * FROM dict WHERE table_name LIKE 'DBA_HIST_SQL%'
/

SELECT * FROM dict WHERE table_name LIKE 'V%SQL%'
/

SET LINESIZE 80
SET PAGESIZE 14
