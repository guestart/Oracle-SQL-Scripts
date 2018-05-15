REM
REM     Script:        table_stats_on_proc_user.sql
REM     Author:        Quanwen Zhao
REM     Dated:         May 14, 2018
REM
REM     Purpose:  
REM       This sql script usually views information of stats for username and tablename (or only username) 
REM       which need to input manually as the parameter of substitution variable on SQL*Plus. These stats 
REM       columns include "table_name", "num_rows", "blocks", "sample_size", "last_analyzed" and "stale_stats".
REM

SET VERIFY   OFF
SET FEEDBACK OFF

SET LINESIZE 300
SET PAGESIZE 300

COLUMN owner       FORMAT a20
COLUMN table_name  FORMAT a35
COLUMN stale_stats FORMAT a11

SELECT owner
       , table_name
       , num_rows
       , blocks
       , sample_size
       , last_analyzed
       , stale_stats
FROM dba_tab_statistics
WHERE owner = UPPER('&username')
AND ( table_name = UPPER('&tablename') 
      AND table_name NOT LIKE 'BIN$%'
    )
ORDER BY stale_stats DESC
         , last_analyzed DESC
         , table_name
;

PROMPT

SELECT owner
       , table_name
       , num_rows
       , blocks
       , sample_size
       , last_analyzed
       , stale_stats
FROM dba_tab_statistics
WHERE owner = UPPER('&username')
AND table_name NOT LIKE 'BIN$%'
ORDER BY stale_stats DESC
         , last_analyzed DESC
         , table_name
;

PROMPT

SET VERIFY   ON
SET FEEDBACK ON
