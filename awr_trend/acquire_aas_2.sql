REM
REM     Script:        acquire_aas_2.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 25, 2021
REM
REM     Updated:       Oct 05, 2021
REM                    Adding the another SQL query with the similar metric_name "Average Active Sessions" but the same intention.
REM                    Oct 17, 2021
REM                    Adding the code snippets visualizing the oracle performance metric "AAS" in the past and real time by the custom report of SQL Developer.
REM                    Oct 24, 2021
REM                    Adding the code snippets about "Average Active Sessions Custom Time Period (interval by each hour)"
REM                    and "Average Active Sessions Custom Time Period (interval by each day)" for visualizing the oracle performance metric "AAS" in the past
REM                    and real time by the custom report of SQL Developer.
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

-- Average Active Sessions in Last 31 Days (interval by each day).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name FORMAT a25
COLUMN snap_date   FORMAT a12
COLUMN aas         FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH aas_per_hour AS (
SELECT TO_CHAR(end_time, 'yyyy-mm-dd') snap_date
     , metric_name
     , average
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Average Active Sessions'
AND   end_time >= SYSDATE - 30
)
SELECT snap_date                                    -- the group column
     , metric_name                                  -- the series column
     , ROUND(SUM(average)/COUNT(snap_date), 2) aas  -- the value column
FROM aas_per_hour
GROUP BY snap_date
       , metric_name
ORDER BY snap_date
;

-- Average Active Sessions in Last 31 Days (interval by each hour).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name    FORMAT a25
COLUMN snap_date_time FORMAT a20
COLUMN aas            FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time  -- the group column
     , metric_name                                                -- the series column
     , ROUND(average, 2) aas                                      -- the value column
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Average Active Sessions'
AND   end_time >= SYSDATE - 30
ORDER BY snap_date_time
;

-- Average Active Sessions in Last 7 Days (interval by each day).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name FORMAT a25
COLUMN snap_date   FORMAT a12
COLUMN aas         FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH aas_per_hour AS (
SELECT TO_CHAR(end_time, 'yyyy-mm-dd') snap_date
     , metric_name
     , average
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Average Active Sessions'
AND   end_time >= SYSDATE - 6
)
SELECT snap_date                                    -- the group column
     , metric_name                                  -- the series column
     , ROUND(SUM(average)/COUNT(snap_date), 2) aas  -- the value column
FROM aas_per_hour
GROUP BY snap_date
       , metric_name
ORDER BY snap_date
;

-- Average Active Sessions in Last 7 Days (interval by each hour).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name    FORMAT a25
COLUMN snap_date_time FORMAT a20
COLUMN aas            FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time  -- the group column
     , metric_name                                                -- the series column
     , ROUND(average, 2) aas                                      -- the value column
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Average Active Sessions'
AND   end_time >= SYSDATE - 6
ORDER BY snap_date_time
;

-- Average Active Sessions in Last 24 Hours.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name    FORMAT a25
COLUMN snap_date_time FORMAT a20
COLUMN aas            FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time  -- the group column
     , metric_name                                                -- the series column
     , ROUND(average, 2) aas                                      -- the value column
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Average Active Sessions'
AND   end_time >= SYSDATE - 1
ORDER BY snap_date_time
;

-- Average Active Sessions in Real Time.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name    FORMAT a25
COLUMN snap_date_time FORMAT a20
COLUMN aas            FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time  -- the group column
     , metric_name                                                -- the series column
     , ROUND(value, 2) aas                                        -- the value column
FROM v$sysmetric_history
WHERE metric_name = 'Average Active Sessions'
AND   group_id = 2                                                -- just retrieve the name with "System Metrics Long Duration" in v$metricgroup
ORDER BY snap_date_time
;

-- Average Active Sessions Custom Time Period (interval by each hour).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name    FORMAT a25
COLUMN snap_date_time FORMAT a20
COLUMN aas            FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time  -- the group column
     , metric_name                                                -- the series column
     , ROUND(average, 2) aas                                      -- the value column
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Average Active Sessions'
AND   (end_time BETWEEN TO_DATE(:start_date, 'yyyy-mm-dd hh24:mi:ss')
                AND     TO_DATE(:end_date, 'yyyy-mm-dd hh24:mi:ss')
      )
ORDER BY snap_date_time
;

-- Average Active Sessions Custom Time Period (interval by each day).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name FORMAT a25
COLUMN snap_date   FORMAT a12
COLUMN aas         FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH aas_per_hour AS (
SELECT TO_CHAR(end_time, 'yyyy-mm-dd') snap_date
     , metric_name
     , average
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Average Active Sessions'
AND   (end_time BETWEEN TO_DATE(:start_date, 'yyyy-mm-dd')
                AND     TO_DATE(:end_date, 'yyyy-mm-dd')
      )
)
SELECT snap_date                                    -- the group column
     , metric_name                                  -- the series column
     , ROUND(SUM(average)/COUNT(snap_date), 2) aas  -- the value column
FROM aas_per_hour
GROUP BY snap_date
       , metric_name
ORDER BY snap_date
;

-- The original code.

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

or

SELECT *
FROM (
       SELECT instance_number
            , LAG(snap_id, 1, 0) OVER(PARTITION BY dbid, instance_number ORDER BY snap_id) first_snap_id
            , snap_id second_snap_id
            , begin_time
            , end_time
            , metric_name
            , metric_unit
            , ROUND(average, 2) awr_aas
       FROM dba_hist_sysmetric_summary
       WHERE metric_name = 'Average Active Sessions'
       ORDER BY instance_number
              , first_snap_id
     )
WHERE first_snap_id <> 0
;
