REM
REM     Script:        acquire_tps_2.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 23, 2021
REM
REM     Updated:       Sep 26, 2021
REM                    Replacing the old WHERE clause "metric_unit = 'Transactions Per Second'" with
REM                    the new one, such as, "metric_name = 'User Transaction Per Sec'".
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       It's the 2nd version (which is more simple and easy to understand than the 1st) of acquire_tps.sql,
REM       you can see "https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_tps.sql".
REM
REM       Typically there saves the average value of "Transactions Per Second" in each of snap_id of the SDDV
REM       (Static Data Dictionary View), "DBA_HIST_SYSMETRIC_SUMMARY", (in which the value of its column
REM       "metric_unit" is "Transactions Per Second"), here we use the analytic function "LAG () OVER()" to
REM       get the prior snap_id from current snap_id for more clearly showing "TPS" between these two snap_id.
REM
REM     References:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYSMETRIC_SUMMARY.html#GUID-E6377E5F-1FFF-4563-850F-C361B9D85048
REM

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_unit FORMAT a25
COLUMN metric_name FORMAT a25

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT *
FROM (
       SELECT LAG(snap_id, 1, 0) OVER(PARTITION BY dbid, instance_number ORDER BY snap_id) first_snap_id
            , snap_id second_snap_id
            , begin_time
            , end_time
         -- , metric_unit
         -- , num_interval
            , ROUND(average, 2) tps
       FROM dba_hist_sysmetric_summary
    -- WHERE metric_unit = 'Transactions Per Second'
       WHERE metric_name = 'User Transaction Per Sec'
       ORDER BY snap_id
     )
WHERE first_snap_id <> 0
;
