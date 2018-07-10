REM
REM     Script:        table_column_statistics.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Jul 10, 2018
REM
REM     Last tested
REM             11.2.0.4
REM     Purpose:  
REM       This sql script usually checks the statistics of column of table.
REM

SET LINESIZE 200
SET PAGESIZE 100

SET VERIFY OFF

COLUMN column_name FORMAT a15

SELECT column_name
       , num_distinct
       , density
       , num_nulls
       , num_buckets
       , last_analyzed
       , sample_size
       , global_stats
       , histogram
FROM dba_tab_col_statistics
WHERE owner = UPPER('&OWNER')
AND table_name = UPPER('&TABLE_NAME')
AND column_name = UPPER('&COLUMN_NAME')
ORDER BY 2 DESC
/

SET VERIFY ON

SET LINESIZE 80
SET PAGESIZE 14
