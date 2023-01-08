REM
REM     Script:        total_parse_count_per_sec.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Aug 10, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the total parse count per second (captured by interval 1 minute) in recent 1 hour on oracle database.
REM

SET LINESIZE 200
SET PAGESIZE 300

COLUMN sample_time FORMAT a11
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

SELECT inst_id
     , TO_CHAR(end_time, 'hh24:mi:ss') sample_time
     , DECODE(metric_name, 'Total Parse Count Per Sec', 'SQL Parses') metric_name
     , ROUND(value, 2) value
FROM gv$sysmetric_history
WHERE metric_name = 'Total Parse Count Per Sec'
AND   group_id = 2
AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
ORDER BY inst_id, sample_time;
