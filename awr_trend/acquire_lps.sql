REM
REM     Script:        acquire_lps.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 28, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM
REM       We can get "LPS" from the metric_name "Logons Per Sec" of the view "DBA_HIST_SYSMETRIC_HISTORY"
REM       or "DBA_HIST_SYSMETRIC_SUMMARY".
REM
REM       Next we use the analytic function "LAG () OVER()" to get the prior snap_id from current snap_id for more
REM       clearly showing "Logons Per Sec" between these two snap_id.
REM
REM     References:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYSMETRIC_HISTORY.html#GUID-4A9988AE-B1B5-4E71-9C38-C95448B3F758
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYSMETRIC_SUMMARY.html#GUID-E6377E5F-1FFF-4563-850F-C361B9D85048
REM

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name FORMAT a15
COLUMN metric_unit FORMAT a15

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH dhsh
AS (
     SELECT *
     FROM (
            SELECT LAG(snap_id, 1, 0) OVER(PARTITION BY dbid, instance_number ORDER BY snap_id) first_snap_id
                 , snap_id second_snap_id
                 , MIN(begin_time) begin_time
                 , MAX(end_time) end_time
              -- , intsize
                 , metric_name
                 , SUM(value*(intsize/1e2)) logon_numbers
                 , (MAX(end_time)-MIN(begin_time))*24*36e2 interval_secs
            FROM dba_hist_sysmetric_history
            WHERE metric_name = 'Logons Per Sec'
            GROUP BY dbid
                   , instance_number
                   , snap_id
                   , metric_name
            ORDER BY snap_id
          )
     WHERE first_snap_id <> 0
   )
SELECT first_snap_id
     , second_snap_id
     , begin_time
     , end_time
     , metric_name
     , ROUND(logon_numbers/interval_secs, 2) lps
FROM dhsh
;

or

SELECT *
FROM (
       SELECT LAG(snap_id, 1, 0) OVER(PARTITION BY dbid, instance_number ORDER BY snap_id) first_snap_id
            , snap_id second_snap_id
            , begin_time
            , end_time
            , metric_name
         -- , metric_unit
            , ROUND(average, 2) lps
       FROM dba_hist_sysmetric_summary
       WHERE metric_name = 'Logons Per Sec'
       ORDER BY snap_id
     )
WHERE first_snap_id <> 0
;
