REM
REM     Script:        acquire_recent_cpu_usage.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Oct 01, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       In general we can get metric_name "Host CPU Utilization (%)" and metric_unit "% Busy/(Idle+Busy)"
REM       from the oracle dynamic performance view "v$sysmetric_history" and "v$sysmetric_summary".
REM
REM       There saves the "Host CPU Utilization (%)" with each interval one minute during the period of recent
REM       one hour in the view "v$sysmetric_history" and there saves the "Host CPU Utilization (%)" with the
REM       interval recent one hour in the view "v$sysmetric_summary".
REM

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name      FORMAT a25
COLUMN metric_unit      FORMAT a20
COLUMN recent_cpu_usage FORMAT a16

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT begin_time
     , end_time
     , metric_name
     , metric_unit
     , ROUND(value, 2) || '%' recent_cpu_usage
FROM v$sysmetric_history
WHERE metric_name = 'Host CPU Utilization (%)'
ORDER BY begin_time
;

or

SELECT begin_time
     , end_time
     , metric_name
     , metric_unit
     , ROUND(average, 2) || '%' recent_cpu_usage
FROM v$sysmetric_summary
WHERE metric_name = 'Host CPU Utilization (%)'
ORDER BY begin_time
;
