REM
REM     Script:        acquire_dbtime_2.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 26, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       It's the 2nd version (which is more simple and easy to understand than the 1st) of acquire_dbtime.sql,
REM       you can see "https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_dbtime.sql".
REM
REM       Now we get ready to change another mind to calculate "DB Time", firstly acquiring "AAS" and "interval time",
REM       then multiplying them to get "DB Time".
REM
REM       You can find out metric_name "DB Time Per Second" and metric_unit "CentiSeconds" in the view "v$metric",
REM       but oracle adjusts the corresponding metric_name to become "Database Time Per Sec" in the view
REM       "DBA_HIST_SYSMETRIC_SUMMARY". Hence we can get "Average Active Sessions" (abbr AAS) from the view
REM       "DBA_HIST_SYSMETRIC_SUMMARY", on the other hand we can also get "interval minutes" with column "num_interval"
REM       from "DBA_HIST_SYSMETRIC_SUMMARY", so "DB Time" equals "AAS" multiplies "num_interval".
REM
REM       Next we use the analytic function "LAG () OVER()" to get the prior snap_id from current snap_id for more
REM       clearly showing "AAS" between these two snap_id.
REM
REM       SET LINESIZE 80
REM       DESC acquire_awr_dbtime_2
REM        Name                                      Null?    Type
REM        ----------------------------------------- -------- ----------------------------
REM        INSTANCE_NUMBER                           NOT NULL NUMBER
REM        FIRST_SNAP_ID                             NOT NULL NUMBER
REM        SECOND_SNAP_ID                            NOT NULL NUMBER
REM        BEGIN_TIME                                NOT NULL DATE
REM        END_TIME                                  NOT NULL DATE
REM        METRIC_NAME                               NOT NULL VARCHAR2(25)
REM        METRIC_UNIT                               NOT NULL VARCHAR2(25)
REM        DBTIME_MINS                                        NUMBER
REM
REM     References:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYSMETRIC_SUMMARY.html#GUID-E6377E5F-1FFF-4563-850F-C361B9D85048
REM

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name FORMAT a25
COLUMN metric_unit FORMAT a25
COLUMN dbtime_mins FORMAT 999,999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH all_aas
AS (
     SELECT *
     FROM (
            SELECT instance_number
                 , LAG(snap_id, 1, 0) OVER(PARTITION BY dbid, instance_number ORDER BY snap_id) first_snap_id
                 , snap_id second_snap_id
                 , begin_time
                 , end_time
                 , metric_name
                 , num_interval
                 , metric_unit
                 , ROUND(average/1e2, 2) aas -- metric_unit is "CentiSeconds Per Second" so average should divide by 1e2.
            FROM dba_hist_sysmetric_summary
         -- WHERE metric_name = 'DB Time Per Second' -- not "DB Time Per Second", should the following metric_name "Database Time Per Sec".
            WHERE metric_name = 'Database Time Per Sec'
            ORDER BY instance_number
                   , first_snap_id
          )
     WHERE first_snap_id <> 0
   )
SELECT instance_number
     , first_snap_id
     , second_snap_id
     , begin_time
     , end_time
     , metric_name
     , metric_unit
     , aas * num_interval dbtime_mins
FROM all_aas
;
