REM
REM     Script:        acquire_recent_aas.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 30, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       AAS (Average Active Sessions), as known as "Database Time Per Sec", in general we can get
REM       metric_name "Database Time Per Sec" and metric_unit "CentiSeconds Per Second" from the
REM       oracle dynamic performance view "v$sysmetric_history" and "v$sysmetric_summary".
REM
REM       There saves the AAS with each interval one minute during the period of recent one hour in
REM       the view "v$sysmetric_history" and there saves the AAS with the interval recent one hour
REM       in the view "v$sysmetric_summary".
REM

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name FORMAT a25
COLUMN metric_unit FORMAT a25
COLUMN recent_aas  FORMAT 999,999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT begin_time
     , end_time
     , metric_name
     , metric_unit
     , ROUND(value/1e2, 2) recent_aas
FROM v$sysmetric_history
WHERE metric_name = 'Database Time Per Sec'
ORDER BY begin_time
;

or

SELECT begin_time
     , end_time
     , metric_name
     , metric_unit
     , ROUND(average/1e2, 2) recent_aas
FROM v$sysmetric_summary
WHERE metric_name = 'Database Time Per Sec'
ORDER BY begin_time
;
