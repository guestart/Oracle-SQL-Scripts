REM
REM     Script:        buffer_cache_hit_ratio.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Jul 05, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the buffer cache hit ratio (captured interval by 1 minute) in recent 1 hour on oracle database.
REM

SELECT inst_id,
       TO_CHAR(end_time, 'hh24:mi:ss') end_time,
       ROUND(value,2) AS "hit_ratio(%)" 
FROM   gv$sysmetric_history
WHERE metric_name = 'Buffer Cache Hit Ratio'
AND ROUND(intsize_csec/100,0) = 60
ORDER BY inst_id, end_time;
