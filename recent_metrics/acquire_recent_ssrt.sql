REM
REM     Script:        acquire_recent_ssrt.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Oct 11, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       In general we can get metric_name "SQL Service Response Time" and metric_unit "CentiSeconds Per Call"
REM       from the oracle dynamic performance view "v$sysmetric_history" and "v$sysmetric_summary".
REM
REM       There saves the "SQL Service Response Time" with each interval one minute during the period of recent
REM       one hour in the view "v$sysmetric_history" and there saves the "SQL Service Response Time" with the
REM       interval recent one hour in the view "v$sysmetric_summary".
REM

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name FORMAT a30
COLUMN metric_unit FORMAT a25
COLUMN ssrt_ms     FORMAT a20

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT begin_time
     , end_time
     , metric_name
     , metric_unit
     , ROUND(value*1e1, 2) || ' ms' ssrt_ms
FROM v$sysmetric_history
WHERE metric_name = 'SQL Service Response Time'
ORDER BY begin_time
;

or

SELECT begin_time
     , end_time
     , metric_name
     , metric_unit
     , ROUND(average*1e1, 2) || ' ms' ssrt_ms
FROM v$sysmetric_summary
WHERE metric_name = 'SQL Service Response Time'
ORDER BY begin_time
;
