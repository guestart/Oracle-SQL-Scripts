REM
REM     Script:        acquire_col.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Oct 09, 2021
REM
REM     Updated:       Oct 20, 2021
REM                    Adding the code snippets visualizing the oracle performance metric "COL" in the past and real time by the custom report of SQL Developer.
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       You can find out metric_name "Current OS Load" and metric_unit "Number Of Processes" in the view "v$metric".
REM       Typically there saves the average value of "Current OS Load" in each of snap_id of the SDDV (Static Data
REM       Dictionary View), "DBA_HIST_SYSMETRIC_SUMMARY", (in which the value of its column "metric_name" is
REM       "Current OS Load" and "metric_unit" is "Number Of Processes"), here we use the analytic function "LAG () OVER()"
REM       to get the prior snap_id from current snap_id for more clearly showing "Current OS Load" between these two snap_id.
REM
REM       SET LINESIZE 80
REM       DESC acquire_current_os_load
REM        Name                                      Null?    Type
REM        ----------------------------------------- -------- ----------------------------
REM        INSTANCE_NUMBER                           NOT NULL NUMBER
REM        FIRST_SNAP_ID                             NOT NULL NUMBER
REM        SECOND_SNAP_ID                            NOT NULL NUMBER
REM        BEGIN_TIME                                NOT NULL DATE
REM        END_TIME                                  NOT NULL DATE
REM        METRIC_NAME                               NOT NULL VARCHAR2(15)
REM        METRIC_UNIT                               NOT NULL VARCHAR2(20)
REM        SESSION_COUNT                                      NUMBER
REM
REM     References:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYSMETRIC_SUMMARY.html#GUID-E6377E5F-1FFF-4563-850F-C361B9D85048
REM

-- Current OS Load in Last 31 Days (interval by each day).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name FORMAT a15
COLUMN snap_date   FORMAT a12
COLUMN col         FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH col_per_hour AS (
SELECT TO_CHAR(end_time, 'yyyy-mm-dd') snap_date
     , metric_name
     , average
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Current OS Load'
AND   end_time >= SYSDATE - 30
)
SELECT snap_date                                    -- the group column
     , metric_name                                  -- the series column
     , ROUND(SUM(average)/COUNT(snap_date), 2) col  -- the value column
FROM col_per_hour
GROUP BY snap_date
       , metric_name
ORDER BY snap_date
;

-- Current OS Load in Last 31 Days (interval by each hour).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name    FORMAT a15
COLUMN snap_date_time FORMAT a20
COLUMN col            FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time  -- the group column
     , metric_name                                                -- the series column
     , ROUND(average, 2) col                                      -- the value column
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Current OS Load'
AND   end_time >= SYSDATE - 30
ORDER BY snap_date_time
;

-- Current OS Load in Last 7 Days (interval by each day).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name FORMAT a15
COLUMN snap_date   FORMAT a12
COLUMN col         FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH col_per_hour AS (
SELECT TO_CHAR(end_time, 'yyyy-mm-dd') snap_date
     , metric_name
     , average
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Current OS Load'
AND   end_time >= SYSDATE - 6
)
SELECT snap_date                                    -- the group column
     , metric_name                                  -- the series column
     , ROUND(SUM(average)/COUNT(snap_date), 2) col  -- the value column
FROM col_per_hour
GROUP BY snap_date
       , metric_name
ORDER BY snap_date
;

-- Current OS Load in Last 7 Days (interval by each hour).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name    FORMAT a15
COLUMN snap_date_time FORMAT a20
COLUMN col            FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time  -- the group column
     , metric_name                                                -- the series column
     , ROUND(average, 2) col                                      -- the value column
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Current OS Load'
AND   end_time >= SYSDATE - 6
ORDER BY snap_date_time
;

-- Current OS Load in Last 24 Hours.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name    FORMAT a15
COLUMN snap_date_time FORMAT a20
COLUMN col            FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time  -- the group column
     , metric_name                                                -- the series column
     , ROUND(average, 2) col                                      -- the value column
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Current OS Load'
AND   end_time >= SYSDATE - 1
ORDER BY snap_date_time
;

-- Current OS Load in Real Time.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name    FORMAT a15
COLUMN snap_date_time FORMAT a20
COLUMN col            FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time  -- the group column
     , metric_name                                                -- the series column
     , ROUND(value, 2) col                                        -- the value column
FROM v$sysmetric_history
WHERE metric_name = 'Current OS Load'
AND   group_id = 2                                                -- just retrieve the name with "System Metrics Long Duration" in v$metricgroup
ORDER BY snap_date_time
;

-- The original code.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name     FORMAT a15
COLUMN metric_unit     FORMAT a20
COLUMN current_os_load FORMAT 999,999.99

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
            , ROUND(average, 2) current_os_load
       FROM dba_hist_sysmetric_summary
       WHERE metric_name = 'Current OS Load'
       ORDER BY instance_number
              , first_snap_id
     )
WHERE first_snap_id <> 0
;
