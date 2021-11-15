REM
REM     Script:        acquire_assbrl.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 15, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       The code snippets are visualizing the oracle performance metrics "ASSBRL" (Average Synchronous Single-Block Read Latency)
REM       in the past and real time by the custom report of SQL Developer.
REM
REM     References:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-SYSMETRIC_HISTORY.html#GUID-5560D15E-9F02-4300-B4DD-85A88A280392
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYSMETRIC_SUMMARY.html#GUID-E6377E5F-1FFF-4563-850F-C361B9D85048
REM

-- Latency For Synchronous Single Block Reads in Real Time (in Last 1 Hour).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time FORMAT a19
COLUMN metric_name FORMAT a12
COLUMN per_second  FORMAT 999,999.9999

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT end_time sample_time
     , DECODE(metric_name, 'Average Synchronous Single-Block Read Latency', 'Latency') metric_name
     , ROUND(value, 4) milli_seconds
FROM v$sysmetric_history
WHERE metric_name = 'Average Synchronous Single-Block Read Latency'
ORDER BY sample_time
;

-- Latency For Synchronous Single Block Reads in Last 24 Hours.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time FORMAT a19
COLUMN metric_name FORMAT a12
COLUMN per_second  FORMAT 999,999.9999

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT end_time sample_time
     , DECODE(metric_name, 'Average Synchronous Single-Block Read Latency', 'Latency') metric_name
     , ROUND(average, 4) milli_seconds
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Average Synchronous Single-Block Read Latency'
AND   end_time >= SYSDATE - 1
ORDER BY sample_time
;

-- Latency For Synchronous Single Block Reads in Last 7 Days (interval by each hour).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time FORMAT a19
COLUMN metric_name FORMAT a12
COLUMN per_second  FORMAT 999,999.9999

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT end_time sample_time
     , DECODE(metric_name, 'Average Synchronous Single-Block Read Latency', 'Latency') metric_name
     , ROUND(average, 4) milli_seconds
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Average Synchronous Single-Block Read Latency'
AND   end_time >= SYSDATE - 6
ORDER BY sample_time
;

-- Latency For Synchronous Single Block Reads in Last 7 Days (interval by each day).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time FORMAT a19
COLUMN metric_name FORMAT a12
COLUMN per_second  FORMAT 999,999.9999

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH assbrl_per_hour AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd') sample_time
       , DECODE(metric_name, 'Average Synchronous Single-Block Read Latency', 'Latency') metric_name
       , average
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Average Synchronous Single-Block Read Latency'
  AND   end_time >= SYSDATE - 6
)
SELECT sample_time
     , metric_name
  -- , ROUND(AVG(average), 4) milli_seconds  -- same as the following SELECT clause, ROUND(SUM(average)/COUNT(sample_time), 4)
     , ROUND(SUM(average)/COUNT(sample_time), 4) milli_seconds 
FROM assbrl_per_hour
GROUP BY sample_time
       , metric_name
ORDER BY sample_time
;

-- Latency For Synchronous Single Block Reads in Last 31 Days (interval by each hour).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time FORMAT a19
COLUMN metric_name FORMAT a12
COLUMN per_second  FORMAT 999,999.9999

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT end_time sample_time
     , DECODE(metric_name, 'Average Synchronous Single-Block Read Latency', 'Latency') metric_name
     , ROUND(average, 4) milli_seconds
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Average Synchronous Single-Block Read Latency'
AND   end_time >= SYSDATE - 30
ORDER BY sample_time
;

-- Latency For Synchronous Single Block Reads in Last 31 Days (interval by each day).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time FORMAT a19
COLUMN metric_name FORMAT a12
COLUMN per_second  FORMAT 999,999.9999

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH assbrl_per_hour AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd') sample_time
       , DECODE(metric_name, 'Average Synchronous Single-Block Read Latency', 'Latency') metric_name
       , average
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Average Synchronous Single-Block Read Latency'
  AND   end_time >= SYSDATE - 30
)
SELECT sample_time
     , metric_name
  -- , ROUND(AVG(average), 4) milli_seconds  -- same as the following SELECT clause, ROUND(SUM(average)/COUNT(sample_time), 4)
     , ROUND(SUM(average)/COUNT(sample_time), 4) milli_seconds 
FROM assbrl_per_hour
GROUP BY sample_time
       , metric_name
ORDER BY sample_time
;

-- Latency For Synchronous Single Block Reads Custom Time Period (interval by each hour).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time FORMAT a19
COLUMN metric_name FORMAT a12
COLUMN per_second  FORMAT 999,999.9999

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT end_time sample_time
     , DECODE(metric_name, 'Average Synchronous Single-Block Read Latency', 'Latency') metric_name
     , ROUND(average, 4) milli_seconds
FROM dba_hist_sysmetric_summary
WHERE metric_name = 'Average Synchronous Single-Block Read Latency'
AND   (end_time BETWEEN TO_DATE(:start_date, 'yyyy-mm-dd hh24:mi:ss')
                AND     TO_DATE(:end_date, 'yyyy-mm-dd hh24:mi:ss')
      )
ORDER BY sample_time
;

-- Latency For Synchronous Single Block Reads Custom Time Period (interval by each day).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time FORMAT a19
COLUMN metric_name FORMAT a12
COLUMN per_second  FORMAT 999,999.9999

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH assbrl_per_hour AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd') sample_time
       , DECODE(metric_name, 'Average Synchronous Single-Block Read Latency', 'Latency') metric_name
       , average
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Average Synchronous Single-Block Read Latency'
  AND   (end_time BETWEEN TO_DATE(:start_date, 'yyyy-mm-dd')
                  AND     TO_DATE(:end_date, 'yyyy-mm-dd')
        )
)
SELECT sample_time
     , metric_name
  -- , ROUND(AVG(average), 4) milli_seconds  -- same as the following SELECT clause, ROUND(SUM(average)/COUNT(sample_time), 4)
     , ROUND(SUM(average)/COUNT(sample_time), 4) milli_seconds 
FROM assbrl_per_hour
GROUP BY sample_time
       , metric_name
ORDER BY sample_time
;
