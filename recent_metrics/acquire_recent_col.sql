REM
REM     Script:        acquire_recent_col.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Oct 11, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       In general we can get metric_name "Current OS Loadn" and metric_unit "Number Of Processes"
REM       from the oracle dynamic performance view "v$sysmetric_history" and "v$sysmetric_summary".
REM
REM       There saves the "Current OS Load" with each interval one minute during the period of recent
REM       one hour in the view "v$sysmetric_history" and there saves the "Current OS Load" with the
REM       interval recent one hour in the view "v$sysmetric_summary".
REM

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name     FORMAT a15
COLUMN metric_unit     FORMAT a20
COLUMN current_os_load FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT begin_time
     , end_time
     , metric_name
     , metric_unit
     , ROUND(value, 2) current_os_load
FROM v$sysmetric_history
WHERE metric_name = 'Current OS Load'
ORDER BY begin_time
;

or

SELECT begin_time
     , end_time
     , metric_name
     , metric_unit
     , ROUND(average, 2) current_os_load
FROM v$sysmetric_summary
WHERE metric_name = 'Current OS Load'
ORDER BY begin_time
;
