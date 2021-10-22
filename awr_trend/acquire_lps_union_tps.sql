REM
REM     Script:        acquire_lps_union_tps.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Oct 22, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       The code snippets visualizing the oracle performance metrics "LPS" and "TPS" in the past and real time by the custom report of SQL Developer
REM       is based on "TPS" (https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_tps_2.sql)
REM       and "LPS" (https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_lps.sql).
REM
REM     References:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYSMETRIC_HISTORY.html#GUID-4A9988AE-B1B5-4E71-9C38-C95448B3F758
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYSMETRIC_SUMMARY.html#GUID-E6377E5F-1FFF-4563-850F-C361B9D85048
REM

-- Logons Per Sec & User Transaction Per Sec in Last 31 Days (interval by each day).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name FORMAT a12
COLUMN snap_date   FORMAT a12
COLUMN psn         FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT * FROM
(
  WITH lps_per_hour AS (
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd') snap_date
       , metric_name
       , average
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Logons Per Sec'
  AND   end_time >= SYSDATE - 30
  )
  SELECT snap_date                                                    -- the group column
       , DECODE(metric_name, 'Logons Per Sec', 'Logons') metric_name  -- the series column
       , ROUND(SUM(average)/COUNT(snap_date), 2) psn                  -- the value column
  FROM lps_per_hour
  GROUP BY snap_date
         , metric_name
  ORDER BY snap_date
)
UNION ALL
SELECT * FROM 
(
  WITH tps_per_hour AS (
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd') snap_date
       , metric_name
       , average
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'User Transaction Per Sec'
  AND   end_time >= SYSDATE - 30
  )
  SELECT snap_date                                                                    -- the group column
       , DECODE(metric_name, 'User Transaction Per Sec', 'Transactions') metric_name  -- the series column
       , ROUND(SUM(average)/COUNT(snap_date), 2) psn                                  -- the value column
  FROM tps_per_hour
  GROUP BY snap_date
         , metric_name
  ORDER BY snap_date
);

or

WITH psn_per_hour AS (
SELECT TO_CHAR(end_time, 'yyyy-mm-dd') snap_date
     , metric_name
     , average
FROM dba_hist_sysmetric_summary
WHERE metric_name IN ('User Transaction Per Sec', 'Logons Per Sec')
AND   end_time >= SYSDATE - 30
)
SELECT snap_date                                                                    -- the group column
     , DECODE(metric_name, 'User Transaction Per Sec', 'Transactions') metric_name  -- the series column
     , ROUND(SUM(average)/COUNT(snap_date), 2) psn                                  -- the value column
FROM psn_per_hour
WHERE metric_name = 'User Transaction Per Sec'
GROUP BY snap_date
       , metric_name
-- ORDER BY snap_date
UNION ALL
SELECT snap_date                                                    -- the group column
     , DECODE(metric_name, 'Logons Per Sec', 'Logons') metric_name  -- the series column
     , ROUND(SUM(average)/COUNT(snap_date), 2) psn                  -- the value column
FROM psn_per_hour
WHERE metric_name = 'Logons Per Sec'
GROUP BY snap_date
       , metric_name
ORDER BY snap_date
       , metric_name
;

-- Logons Per Sec & User Transaction Per Sec in Last 31 Days (interval by each hour).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name    FORMAT a12
COLUMN snap_date_time FORMAT a20
COLUMN psn            FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time                                                -- the group column
     , DECODE(metric_name, 'User Transaction Per Sec', 'Transactions', 'Logons Per Sec', 'Logons') metric_name  -- the series column
     , ROUND(average, 2) psn                                                                                    -- the value column
FROM dba_hist_sysmetric_summary
WHERE metric_name IN ('User Transaction Per Sec', 'Logons Per Sec')
AND   end_time >= SYSDATE - 30
ORDER BY snap_date_time
       , metric_name
;

-- Logons Per Sec & User Transaction Per Sec in Last 7 Days (interval by each day).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name FORMAT a12
COLUMN snap_date   FORMAT a12
COLUMN psn         FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT * FROM
(
  WITH lps_per_hour AS (
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd') snap_date
       , metric_name
       , average
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Logons Per Sec'
  AND   end_time >= SYSDATE - 6
  )
  SELECT snap_date                                                    -- the group column
       , DECODE(metric_name, 'Logons Per Sec', 'Logons') metric_name  -- the series column
       , ROUND(SUM(average)/COUNT(snap_date), 2) psn                  -- the value column
  FROM lps_per_hour
  GROUP BY snap_date
         , metric_name
  ORDER BY snap_date
)
UNION ALL
SELECT * FROM 
(
  WITH tps_per_hour AS (
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd') snap_date
       , metric_name
       , average
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'User Transaction Per Sec'
  AND   end_time >= SYSDATE - 6
  )
  SELECT snap_date                                                                    -- the group column
       , DECODE(metric_name, 'User Transaction Per Sec', 'Transactions') metric_name  -- the series column
       , ROUND(SUM(average)/COUNT(snap_date), 2) psn                                  -- the value column
  FROM tps_per_hour
  GROUP BY snap_date
         , metric_name
  ORDER BY snap_date
);

or

WITH psn_per_hour AS (
SELECT TO_CHAR(end_time, 'yyyy-mm-dd') snap_date
     , metric_name
     , average
FROM dba_hist_sysmetric_summary
WHERE metric_name IN ('User Transaction Per Sec', 'Logons Per Sec')
AND   end_time >= SYSDATE - 6
)
SELECT snap_date                                                                    -- the group column
     , DECODE(metric_name, 'User Transaction Per Sec', 'Transactions') metric_name  -- the series column
     , ROUND(SUM(average)/COUNT(snap_date), 2) psn                                  -- the value column
FROM psn_per_hour
WHERE metric_name = 'User Transaction Per Sec'
GROUP BY snap_date
       , metric_name
-- ORDER BY snap_date
UNION ALL
SELECT snap_date                                                    -- the group column
     , DECODE(metric_name, 'Logons Per Sec', 'Logons') metric_name  -- the series column
     , ROUND(SUM(average)/COUNT(snap_date), 2) psn                  -- the value column
FROM psn_per_hour
WHERE metric_name = 'Logons Per Sec'
GROUP BY snap_date
       , metric_name
ORDER BY snap_date
       , metric_name
;

-- Logons Per Sec & User Transaction Per Sec in Last 7 Days (interval by each hour).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name    FORMAT a12
COLUMN snap_date_time FORMAT a20
COLUMN psn            FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time                                                -- the group column
     , DECODE(metric_name, 'User Transaction Per Sec', 'Transactions', 'Logons Per Sec', 'Logons') metric_name  -- the series column
     , ROUND(average, 2) psn                                                                                    -- the value column
FROM dba_hist_sysmetric_summary
WHERE metric_name IN ('User Transaction Per Sec', 'Logons Per Sec')
AND   end_time >= SYSDATE - 6
ORDER BY snap_date_time
       , metric_name
;

-- Logons Per Sec & User Transaction Per Sec in Last 24 Hours.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name    FORMAT a12
COLUMN snap_date_time FORMAT a20
COLUMN psn            FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time                                                -- the group column
     , DECODE(metric_name, 'User Transaction Per Sec', 'Transactions', 'Logons Per Sec', 'Logons') metric_name  -- the series column
     , ROUND(average, 2) psn                                                                                    -- the value column
FROM dba_hist_sysmetric_summary
WHERE metric_name IN ('User Transaction Per Sec', 'Logons Per Sec')
AND   end_time >= SYSDATE - 1
ORDER BY snap_date_time
       , metric_name
;

-- Logons Per Sec & User Transaction Per Sec in Real Time.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name    FORMAT a12
COLUMN snap_date_time FORMAT a20
COLUMN psn            FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time                                                -- the group column
     , DECODE(metric_name, 'User Transaction Per Sec', 'Transactions', 'Logons Per Sec', 'Logons') metric_name  -- the series column
     , ROUND(value, 2) psn                                                                                      -- the value column
FROM v$sysmetric_history
WHERE metric_name IN ('User Transaction Per Sec', 'Logons Per Sec')
AND   group_id = 2                                                                                              -- just retrieve the name with "System Metrics Long Duration" in v$metricgroup
ORDER BY snap_date_time
       , metric_name
;
