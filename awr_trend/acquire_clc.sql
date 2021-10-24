REM
REM     Script:        acquire_clc.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 28, 2021
REM
REM     Updated:       Oct 19, 2021
REM                    Adding the code snippets visualizing the oracle performance metric "CLC" in the past and real time by the custom report of SQL Developer.
REM                    Oct 24, 2021
REM                    Adding the code snippets about "Current Logons Count Custom Time Period (interval by each hour)"
REM                    and "Current Logons Count Custom Time Period (interval by each day)" for visualizing the oracle performance metric "CLC" in the past
REM                    and real time by the custom report of SQL Developer.
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       We can get "CLC" from the metric_name "Current Logons Count" of the view "DBA_HIST_SYSMETRIC_SUMMARY".
REM
REM       Next we use the analytic function "LAG () OVER()" to get the prior snap_id from current snap_id for more
REM       clearly showing "Current Logons Count" between these two snap_id.
REM
REM       SET LINESIZE 80
REM       DESC acquire_awr_clc
REM        Name                                      Null?    Type
REM        ----------------------------------------- -------- ----------------------------
REM        INSTANCE_NUMBER                           NOT NULL NUMBER
REM        FIRST_SNAP_ID                             NOT NULL NUMBER
REM        SECOND_SNAP_ID                            NOT NULL NUMBER
REM        BEGIN_TIME                                NOT NULL DATE
REM        END_TIME                                  NOT NULL DATE
REM        METRIC_NAME                               NOT NULL VARCHAR2(20)
REM        METRIC_UNIT                               NOT NULL VARCHAR2(12)
REM        AWR_CLC                                            NUMBER
REM
REM     References:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYSMETRIC_SUMMARY.html#GUID-E6377E5F-1FFF-4563-850F-C361B9D85048
REM

-- Current Logons Count in Last 31 Days (interval by each day).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name FORMAT a25
COLUMN snap_date   FORMAT a12
COLUMN clc         FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH clc_per_hour AS (
SELECT TO_CHAR(end_time, 'yyyy-mm-dd') snap_date
     , metric_name
     , average
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Current Logons Count'
AND   end_time >= SYSDATE - 30
)
SELECT snap_date                                    -- the group column
     , metric_name                                  -- the series column
     , ROUND(SUM(average)/COUNT(snap_date), 2) clc  -- the value column
FROM clc_per_hour
GROUP BY snap_date
       , metric_name
ORDER BY snap_date
;

-- Current Logons Count in Last 31 Days (interval by each hour).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name    FORMAT a25
COLUMN snap_date_time FORMAT a20
COLUMN clc            FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time  -- the group column
     , metric_name                                                -- the series column
     , ROUND(average, 2) clc                                      -- the value column
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Current Logons Count'
AND   end_time >= SYSDATE - 30
ORDER BY snap_date_time
;

-- Current Logons Count in Last 7 Days (interval by each day).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name FORMAT a25
COLUMN snap_date   FORMAT a12
COLUMN clc         FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH clc_per_hour AS (
SELECT TO_CHAR(end_time, 'yyyy-mm-dd') snap_date
     , metric_name
     , average
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Current Logons Count'
AND   end_time >= SYSDATE - 6
)
SELECT snap_date                                    -- the group column
     , metric_name                                  -- the series column
     , ROUND(SUM(average)/COUNT(snap_date), 2) clc  -- the value column
FROM clc_per_hour
GROUP BY snap_date
       , metric_name
ORDER BY snap_date
;

-- Current Logons Count in Last 7 Days (interval by each hour).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name    FORMAT a25
COLUMN snap_date_time FORMAT a20
COLUMN clc            FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time  -- the group column
     , metric_name                                                -- the series column
     , ROUND(average, 2) clc                                      -- the value column
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Current Logons Count'
AND   end_time >= SYSDATE - 6
ORDER BY snap_date_time
;

-- Current Logons Count in Last 24 Hours.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name    FORMAT a25
COLUMN snap_date_time FORMAT a20
COLUMN clc            FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time  -- the group column
     , metric_name                                                -- the series column
     , ROUND(average, 2) clc                                      -- the value column
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Current Logons Count'
AND   end_time >= SYSDATE - 1
ORDER BY snap_date_time
;

-- Current Logons Count in Real Time.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name    FORMAT a25
COLUMN snap_date_time FORMAT a20
COLUMN clc            FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time  -- the group column
     , metric_name                                                -- the series column
     , ROUND(value, 2) clc                                        -- the value column
FROM v$sysmetric_history
WHERE metric_name = 'Current Logons Count'
AND   group_id = 2                                                -- just retrieve the name with "System Metrics Long Duration" in v$metricgroup
ORDER BY snap_date_time
;

-- Current Logons Count Custom Time Period (interval by each hour).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name    FORMAT a25
COLUMN snap_date_time FORMAT a20
COLUMN clc            FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time  -- the group column
     , metric_name                                                -- the series column
     , ROUND(average, 2) clc                                      -- the value column
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Current Logons Count'
AND   (end_time BETWEEN TO_DATE(:start_date, 'yyyy-mm-dd hh24:mi:ss')
                AND     TO_DATE(:end_date, 'yyyy-mm-dd hh24:mi:ss')
      )
ORDER BY snap_date_time
;

-- Current Logons Count Custom Time Period (interval by each day).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name FORMAT a25
COLUMN snap_date   FORMAT a12
COLUMN clc         FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH clc_per_hour AS (
SELECT TO_CHAR(end_time, 'yyyy-mm-dd') snap_date
     , metric_name
     , average
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Current Logons Count'
AND   (end_time BETWEEN TO_DATE(:start_date, 'yyyy-mm-dd')
                AND     TO_DATE(:end_date, 'yyyy-mm-dd')
      )
)
SELECT snap_date                                    -- the group column
     , metric_name                                  -- the series column
     , ROUND(SUM(average)/COUNT(snap_date), 2) clc  -- the value column
FROM clc_per_hour
GROUP BY snap_date
       , metric_name
ORDER BY snap_date
;

-- The original code.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name FORMAT a20
COLUMN metric_unit FORMAT a12
COLUMN awr_clc     FORMAT 999,999.99

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
            , ROUND(average, 2) awr_clc
       FROM dba_hist_sysmetric_summary
       WHERE metric_name = 'Current Logons Count'
       ORDER BY instance_number
              , first_snap_id
     )
WHERE first_snap_id <> 0
;
