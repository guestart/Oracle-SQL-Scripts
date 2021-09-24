REM
REM     Script:        acquire_iops.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 23, 2021
REM
REM     Updated:       Sep 24, 2021
REM       Searched out the MoS article "How to Calculate the Number of IOPS and Throughput of a Database (Doc ID 2206831.1)" from Google,
REM       it told us IOPS can be found in different places of the AWR report:
REM         (1) Instance Activity Stats
REM         (2) IO Profile (Starting with 11gR2)
REM         (3) Load Profile
REM
REM       Instance Activity Stats:
REM       IOPS - (Input/Output Operations Per Second) - This is the sum of "Physical Read Total IO Requests" and "Physical Write Total IO Requests".
REM
REM       IO Profile:
REM       IOPS - Total Requests (This value is the sum of the metrics "Physical Read Total IO Requests Per Sec" and "Physical Write Total IO Requests Per Sec"
REM       from the Instance Activity Stats area).
REM
REM       Load Profile:
REM       Please note that the information displayed here is a subset of the one in the IO Profile area:
REM
REM       Load profile      -> Instance Activity Stats
REM       Read IO requests  -> physical read IO requests
REM       Write IO requests -> physical write IO requests
REM
REM       physical read IO requests:
REM       Number of read requests for application activity (mainly buffer cache and direct load operation) which read one or more database blocks per request.
REM       This is a subset of "physical read total IO requests" statistic.
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       Typically there saves the average value of "Physical Read Total IO Requests Per Sec" and "Physical Write Total IO Requests Per Sec"
REM       in each of snap_id of the view "DBA_HIST_SYSMETRIC_SUMMARY" (in which the value of its column "metric_unit" is
REM       "Physical Read Total IO Requests Per Sec" and "Physical Write Total IO Requests Per Sec"), here we use the analytic function
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
    -- WHERE metric_name IN ('Physical Read IO Requests Per Sec', 'Physical Write IO Requests Per Sec')
       WHERE metric_name IN ('Physical Read Total IO Requests Per Sec', 'Physical Write Total IO Requests Per Sec')
       GROUP BY snap_id
              , instance_number
              , dbid
              , begin_time
              , end_time
       ORDER BY snap_id
     )
WHERE first_snap_id <> 0
;
