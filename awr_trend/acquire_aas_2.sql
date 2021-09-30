REM
REM     Script:        acquire_aas_2.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 25, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       It's the 2nd version (which is more simple and easy to understand than the 1st) of acquire_aas.sql,
REM       you can see "https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_aas.sql".
REM
REM       You can find out metric_name "DB Time Per Second" and metric_unit "CentiSeconds" in the view "v$metric",
REM       but oracle adjusts the corresponding metric_name to become "Database Time Per Sec" in the view
REM       "DBA_HIST_SYSMETRIC_SUMMARY".
REM
REM       Typically there saves the average value of "Database Time Per Sec" in each of snap_id of the SDDV
REM       (Static Data Dictionary View), "DBA_HIST_SYSMETRIC_SUMMARY", (in which the value of its column
REM       "metric_name" is "Database Time Per Sec" and "metric_unit" is "CentiSeconds Per Second"), here we use
REM       the analytic function "LAG () OVER()" to get the prior snap_id from current snap_id for more clearly
REM       showing "AAS" between these two snap_id.
REM
REM       SET LINESIZE 80
REM       DESC acquire_awr_aas_2
REM        Name                                      Null?    Type
REM        ----------------------------------------- -------- ----------------------------
REM        INSTANCE_NUMBER                           NOT NULL NUMBER
REM        FIRST_SNAP_ID                             NOT NULL NUMBER
REM        SECOND_SNAP_ID                            NOT NULL NUMBER
REM        BEGIN_TIME                                NOT NULL DATE
REM        END_TIME                                  NOT NULL DATE
REM        METRIC_NAME                               NOT NULL VARCHAR2(25)
REM        METRIC_UNIT                               NOT NULL VARCHAR2(25)
REM        AWR_AAS                                            NUMBER
REM
REM     References:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYSMETRIC_SUMMARY.html#GUID-E6377E5F-1FFF-4563-850F-C361B9D85048
REM

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name FORMAT a25
COLUMN metric_unit FORMAT a25
COLUMN awr_aas     FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT *
FROM (
       SELECT instance_number
            , LAG(snap_id, 1, 0) OVER(PARTITION BY dbid, instance_number ORDER BY snap_id) first_snap_id
            , snap_id second_snap_id
            , begin_time
            , end_time
            , metric_name
            , metric_unit 
            , ROUND(average/1e2, 2) awr_aas -- metric_unit is "CentiSeconds Per Second" so average should divide by 1e2.
       FROM dba_hist_sysmetric_summary
    -- WHERE metric_name = 'DB Time Per Second' -- not "DB Time Per Second", should the following metric_name "Database Time Per Sec".
       WHERE metric_name = 'Database Time Per Sec'
       ORDER BY instance_number
              , first_snap_id
     )
WHERE first_snap_id <> 0
;
