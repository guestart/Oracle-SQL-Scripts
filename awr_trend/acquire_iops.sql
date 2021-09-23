REM
REM     Script:        acquire_iops.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 23, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       Typically there saves the average value of "Physical Read IO Requests Per Sec" and "Physical Write IO Requests Per Sec"
REM       in each of snap_id of the view "DBA_HIST_SYSMETRIC_SUMMARY" (in which the value of its column "metric_unit" is
REM       "Physical Read IO Requests Per Sec" and "Physical Write IO Requests Per Sec"), here we use the analytic function
REM       "LAG () OVER()" to get the prior snap_id from current snap_id for more clearly showing "IOPS" between these two snap_id.
REM
REM     References:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYSMETRIC_SUMMARY.html#GUID-E6377E5F-1FFF-4563-850F-C361B9D85048
REM

SET LINESIZE 200
SET PAGESIZE 200

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT *
FROM (
       SELECT LAG(snap_id, 1, 0) OVER(PARTITION BY dbid, instance_number ORDER BY snap_id) first_snap_id
            , snap_id second_snap_id
            , begin_time
            , end_time
            , ROUND(SUM(average), 2) iops
       FROM dba_hist_sysmetric_summary
       WHERE metric_name IN ('Physical Read IO Requests Per Sec', 'Physical Write IO Requests Per Sec')
       GROUP BY snap_id
              , instance_number
              , dbid
              , begin_time
              , end_time
       ORDER BY snap_id
     )
WHERE first_snap_id <> 0
;
