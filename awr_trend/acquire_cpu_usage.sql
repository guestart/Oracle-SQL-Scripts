REM
REM     Script:        acquire_cpu_usage.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 28, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       We can get "CPU Usage" from the metric_name "Host CPU Utilization (%)" of the view "DBA_HIST_SYSMETRIC_SUMMARY".
REM
REM       Next we use the analytic function "LAG () OVER()" to get the prior snap_id from current snap_id for more
REM       clearly showing "Host CPU Utilization (%)" between these two snap_id.
REM
REM     References:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYSMETRIC_SUMMARY.html#GUID-E6377E5F-1FFF-4563-850F-C361B9D85048
REM

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name FORMAT a25
COLUMN metric_unit FORMAT a25

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT *
FROM (
       SELECT LAG(snap_id, 1, 0) OVER(PARTITION BY dbid, instance_number ORDER BY snap_id) first_snap_id
            , snap_id second_snap_id
            , begin_time
            , end_time
            , metric_name
         -- , metric_unit
            , ROUND(average, 2) || '%' cpu_usage
       FROM dba_hist_sysmetric_summary
       WHERE metric_name = 'Host CPU Utilization (%)'
       ORDER BY snap_id
     )
WHERE first_snap_id <> 0
;
