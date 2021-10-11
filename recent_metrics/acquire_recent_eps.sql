REM
REM     Script:        acquire_recent_eps.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Oct 11, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       In general we can get metric_name "Executions Per Sec" and metric_unit "Executes Per Second"
REM       from the oracle dynamic performance view "v$sysmetric_history" and "v$sysmetric_summary".
REM
REM       There saves the "Executions Per Sec" with each interval one minute during the period of recent
REM       one hour in the view "v$sysmetric_history" and there saves the "Executions Per Sec" with the
REM       interval recent one hour in the view "v$sysmetric_summary".
REM

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name FORMAT a20
COLUMN metric_unit FORMAT a20
COLUMN eps         FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT begin_time
     , end_time
     , metric_name
     , metric_unit
     , ROUND(value, 2) eps
FROM v$sysmetric_history
WHERE metric_name = 'Executions Per Sec'
ORDER BY begin_time
;

or

SELECT begin_time
     , end_time
     , metric_name
     , metric_unit
     , ROUND(average, 2) eps
FROM v$sysmetric_summary
WHERE metric_name = 'Executions Per Sec'
ORDER BY begin_time
;
