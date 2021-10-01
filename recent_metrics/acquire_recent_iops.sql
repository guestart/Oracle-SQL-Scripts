REM
REM     Script:        acquire_recent_iops.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Oct 01, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       In general we can get metric_name "Physical Read/Write Total IO Requests Per Sec" and metric_unit "Requests Per Second"
REM       from the oracle dynamic performance view "v$sysmetric_history" and "v$sysmetric_summary".
REM
REM       There saves the "Physical Read/Write Total IO Requests Per Sec" with each interval one minute during the period of recent
REM       one hour in the view "v$sysmetric_history" and there saves the "Physical Read/Write Total IO Requests Per Sec" with the
REM       interval recent one hour in the view "v$sysmetric_summary".
REM

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name FORMAT a45
COLUMN metric_unit FORMAT a20
COLUMN recent_iops FORMAT 999,999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT begin_time
     , end_time
     , 'Physical Read/Write Total IO Requests Per Sec' metric_name
     , metric_unit
     , ROUND(SUM(value), 2) recent_iops
FROM v$sysmetric_history
WHERE metric_name IN ('Physical Read Total IO Requests Per Sec', 'Physical Write Total IO Requests Per Sec')
GROUP BY begin_time
       , end_time
       , metric_unit
ORDER BY begin_time
;

or

SELECT begin_time
     , end_time
     , 'Physical Read/Write Total IO Requests Per Sec' metric_name
     , metric_unit
     , ROUND(SUM(average), 2) recent_iops
FROM v$sysmetric_summary
WHERE metric_name IN ('Physical Read Total IO Requests Per Sec', 'Physical Write Total IO Requests Per Sec')
GROUP BY begin_time
       , end_time
       , metric_unit
ORDER BY begin_time
;
