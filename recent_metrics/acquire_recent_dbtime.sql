REM
REM     Script:        acquire_recent_dbtime.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Oct 01, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       In general we can get metric_name "Database Time Per Sec" and metric_unit "CentiSeconds Per Second"
REM       from the oracle dynamic performance view "v$sysmetric_history" and "v$sysmetric_summary".
REM
REM       There saves the "Database Time Per Sec" with each interval one minute during the period of recent
REM       one hour in the view "v$sysmetric_history" and there saves the "Database Time Per Sec" with the
REM       interval recent one hour in the view "v$sysmetric_summary".
REM

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name   FORMAT a25
COLUMN metric_unit   FORMAT a25
COLUMN recent_dbtime FORMAT 999,999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT begin_time
     , end_time
     , metric_name
     , metric_unit
     , ROUND(value/1e2*((end_time-begin_time)*24*6e1), 2) recent_dbtime
FROM v$sysmetric_history
WHERE metric_name = 'Database Time Per Sec'
ORDER BY begin_time
;

or

SELECT begin_time
     , end_time
     , metric_name
     , metric_unit
     , ROUND(average/1e2*num_interval, 2) recent_dbtime
FROM v$sysmetric_summary
WHERE metric_name = 'Database Time Per Sec'
ORDER BY begin_time
;
