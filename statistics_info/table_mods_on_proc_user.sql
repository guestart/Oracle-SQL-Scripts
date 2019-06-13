REM
REM     Script:        table_mods_on_proc_user.sql
REM     Author:        Quanwen Zhao
REM     Dated:         May 14, 2018
REM
REM     Purpose:  
REM       This sql script usually views information of modifications for username and tablename (or only username) 
REM       which need to input manually as the parameter of substitution variable on SQL*Plus. These modifications 
REM       columns include "table_name", "inserts", "updates", "deletes", "timestamp", "truncated" and "drop_segments".
REM

SET VERIFY   OFF
SET FEEDBACK OFF

SET LINESIZE 300
SET PAGESIZE 300

COLUMN table_owner FORMAT a20
COLUMN table_name  FORMAT a25
COLUMN truncated   FORMAT a5

SELECT table_owner
       , table_name
       , inserts
       , updates
       , deletes
       , timestamp
       , truncated
       , drop_segments
FROM dba_tab_modifications
WHERE table_owner = UPPER('&username')
AND ( table_name = UPPER('&tablename') 
      AND table_name NOT LIKE 'BIN$%'
    )
ORDER BY timestamp DESC
         , table_owner
         , table_name
;

PROMPT

SELECT table_owner
       , table_name
       , inserts
       , updates
       , deletes
       , timestamp
       , truncated
       , drop_segments
FROM dba_tab_modifications
WHERE table_owner = UPPER('&username')
AND table_name NOT LIKE 'BIN$%'
ORDER BY timestamp DESC
         , table_name
;

PROMPT

SET VERIFY   ON
SET FEEDBACK ON
