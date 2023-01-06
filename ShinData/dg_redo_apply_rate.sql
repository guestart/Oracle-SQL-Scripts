REM
REM     Script:        dg_redo_apply_rate.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Dec 10, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       The SQL script uses to check redo apply rate on oracle data guard physical standby database.
REM

set linesize 200
col start_time format a20
col type       format a16
col item       format a20
col sofar      format 99999
col units      format a7

SELECT start_time,
       type,
       item,
       sofar,
       units
FROM v$recovery_progress
WHERE LOWER(item) LIKE '%apply%'
AND units = 'KB/sec'
ORDER BY start_time desc, item;
