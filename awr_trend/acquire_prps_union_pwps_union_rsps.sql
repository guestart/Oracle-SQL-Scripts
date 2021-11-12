REM
REM     Script:        acquire_prps_union_pwps_union_rsps.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 12, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       The code snippets visualizing the oracle performance metrics "PRPS", "PWPS" and "RSPS" in the past and real time by the custom report of SQL Developer
REM       is based on "RSPS" (https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_redo_gen_mbps.sql).
REM
REM     References:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-SYSMETRIC_HISTORY.html#GUID-5560D15E-9F02-4300-B4DD-85A88A280392
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYSMETRIC_SUMMARY.html#GUID-E6377E5F-1FFF-4563-850F-C361B9D85048
REM

-- Physical Reads (KB) & Physical Writes (KB) & Redo Size (KB) in Real Time (in Last 1 Hour).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time FORMAT a19
COLUMN metric_name FORMAT a20
COLUMN per_second  FORMAT 999,999.999

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT end_time sample_time
     , DECODE(metric_name, 'Redo Generated Per Sec'      , 'Redo Size (KB)'
                         , 'Physical Read Bytes Per Sec' , 'Physical Reads (KB)'
                         , 'Physical Write Bytes Per Sec', 'Physical Writes (KB)'
             ) metric_name
     , ROUND(value/POWER(2, 10), 3) per_second
FROM v$sysmetric_history
WHERE metric_name IN ('Physical Read Bytes Per Sec', 'Physical Write Bytes Per Sec', 'Redo Generated Per Sec')  -- The query value of this metric_name "Physical Read/Write Bytes Per Sec" is the same as EMCC 13.5 rather than the metric_name "Physical Read/Write Total Bytes Per Sec".
AND   group_id = 2  -- Just for metric_name "Redo Generated Per Sec", hence choosing the sample intervals by 60 seconds, the value ("System Metrics Long Duration" ) of column "name" in v$metricgroup.
ORDER BY metric_name
       , sample_time
;

-- Physical Reads (KB) & Physical Writes (KB) & Redo Size (KB) in Last 24 Hours.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time FORMAT a19
COLUMN metric_name FORMAT a20
COLUMN per_second  FORMAT 999,999.999

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT end_time sample_time
     , DECODE(metric_name, 'Redo Generated Per Sec'      , 'Redo Size (KB)'
                         , 'Physical Read Bytes Per Sec' , 'Physical Reads (KB)'
                         , 'Physical Write Bytes Per Sec', 'Physical Writes (KB)'
             ) metric_name
     , ROUND(average/POWER(2, 10), 3) per_second
FROM dba_hist_sysmetric_summary
WHERE metric_name IN ('Physical Read Bytes Per Sec', 'Physical Write Bytes Per Sec', 'Redo Generated Per Sec')  -- The query value of this metric_name "Physical Read/Write Bytes Per Sec" is the same as EMCC 13.5 rather than the metric_name "Physical Read/Write Total Bytes Per Sec".
AND   group_id = 2  -- Just for metric_name "Redo Generated Per Sec", hence choosing the sample intervals by 60 seconds, the value ("System Metrics Long Duration" ) of column "name" in v$metricgroup.
AND   end_time >= SYSDATE - 1
ORDER BY metric_name
       , sample_time
;

-- Physical Reads (KB) & Physical Writes (KB) & Redo Size (KB) in Last 7 Days (interval by each hour).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time FORMAT a19
COLUMN metric_name FORMAT a20
COLUMN per_second  FORMAT 999,999.999

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT end_time sample_time
     , DECODE(metric_name, 'Redo Generated Per Sec'      , 'Redo Size (KB)'
                         , 'Physical Read Bytes Per Sec' , 'Physical Reads (KB)'
                         , 'Physical Write Bytes Per Sec', 'Physical Writes (KB)'
             ) metric_name
     , ROUND(average/POWER(2, 10), 3) per_second
FROM dba_hist_sysmetric_summary
WHERE metric_name IN ('Physical Read Bytes Per Sec', 'Physical Write Bytes Per Sec', 'Redo Generated Per Sec')  -- The query value of this metric_name "Physical Read/Write Bytes Per Sec" is the same as EMCC 13.5 rather than the metric_name "Physical Read/Write Total Bytes Per Sec".
AND   group_id = 2  -- Just for metric_name "Redo Generated Per Sec", hence choosing the sample intervals by 60 seconds, the value ("System Metrics Long Duration" ) of column "name" in v$metricgroup.
AND   end_time >= SYSDATE - 6
ORDER BY metric_name
       , sample_time
;

-- Physical Reads (KB) & Physical Writes (KB) & Redo Size (KB) in Last 7 Days (interval by each day).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time FORMAT a19
COLUMN metric_name FORMAT a20
COLUMN per_second  FORMAT 999,999.999

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH pr_pw_rs_per_hour AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd') sample_time
       , DECODE(metric_name, 'Redo Generated Per Sec'      , 'Redo Size (KB)'
                           , 'Physical Read Bytes Per Sec' , 'Physical Reads (KB)'
                           , 'Physical Write Bytes Per Sec', 'Physical Writes (KB)'
               ) metric_name
       , average
  FROM dba_hist_sysmetric_summary
  WHERE metric_name IN ('Physical Read Bytes Per Sec', 'Physical Write Bytes Per Sec', 'Redo Generated Per Sec')  -- The query value of this metric_name "Physical Read/Write Bytes Per Sec" is the same as EMCC 13.5 rather than the metric_name "Physical Read/Write Total Bytes Per Sec".
  AND   group_id = 2  -- Just for metric_name "Redo Generated Per Sec", hence choosing the sample intervals by 60 seconds, the value ("System Metrics Long Duration" ) of column "name" in v$metricgroup.
  AND   end_time >= SYSDATE - 6
)
SELECT sample_time
     , metric_name
     , ROUND(AVG(average)/POWER(2, 10), 3) per_second
FROM pr_pw_rs_per_hour
GROUP BY metric_name
       , sample_time
ORDER BY metric_name
       , sample_time
;

-- Physical Reads (KB) & Physical Writes (KB) & Redo Size (KB) in Last 31 Days (interval by each hour).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time FORMAT a19
COLUMN metric_name FORMAT a20
COLUMN per_second  FORMAT 999,999.999

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT end_time sample_time
     , DECODE(metric_name, 'Redo Generated Per Sec'      , 'Redo Size (KB)'
                         , 'Physical Read Bytes Per Sec' , 'Physical Reads (KB)'
                         , 'Physical Write Bytes Per Sec', 'Physical Writes (KB)'
             ) metric_name
     , ROUND(average/POWER(2, 10), 3) per_second
FROM dba_hist_sysmetric_summary
WHERE metric_name IN ('Physical Read Bytes Per Sec', 'Physical Write Bytes Per Sec', 'Redo Generated Per Sec')  -- The query value of this metric_name "Physical Read/Write Bytes Per Sec" is the same as EMCC 13.5 rather than the metric_name "Physical Read/Write Total Bytes Per Sec".
AND   group_id = 2  -- Just for metric_name "Redo Generated Per Sec", hence choosing the sample intervals by 60 seconds, the value ("System Metrics Long Duration" ) of column "name" in v$metricgroup.
AND   end_time >= SYSDATE - 30
ORDER BY metric_name
       , sample_time
;

-- Physical Reads (KB) & Physical Writes (KB) & Redo Size (KB) in Last 31 Days (interval by each day).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time FORMAT a19
COLUMN metric_name FORMAT a20
COLUMN per_second  FORMAT 999,999.999

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH pr_pw_rs_per_hour AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd') sample_time
       , DECODE(metric_name, 'Redo Generated Per Sec'      , 'Redo Size (KB)'
                           , 'Physical Read Bytes Per Sec' , 'Physical Reads (KB)'
                           , 'Physical Write Bytes Per Sec', 'Physical Writes (KB)'
               ) metric_name
       , average
  FROM dba_hist_sysmetric_summary
  WHERE metric_name IN ('Physical Read Bytes Per Sec', 'Physical Write Bytes Per Sec', 'Redo Generated Per Sec')  -- The query value of this metric_name "Physical Read/Write Bytes Per Sec" is the same as EMCC 13.5 rather than the metric_name "Physical Read/Write Total Bytes Per Sec".
  AND   group_id = 2  -- Just for metric_name "Redo Generated Per Sec", hence choosing the sample intervals by 60 seconds, the value ("System Metrics Long Duration" ) of column "name" in v$metricgroup.
  AND   end_time >= SYSDATE - 30
)
SELECT sample_time
     , metric_name
     , ROUND(AVG(average)/POWER(2, 10), 3) per_second
FROM pr_pw_rs_per_hour
GROUP BY metric_name
       , sample_time
ORDER BY metric_name
       , sample_time
;

-- Physical Reads (KB) & Physical Writes (KB) & Redo Size (KB) Custom Time Period (interval by each hour).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time FORMAT a19
COLUMN metric_name FORMAT a20
COLUMN per_second  FORMAT 999,999.999

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT end_time sample_time
     , DECODE(metric_name, 'Redo Generated Per Sec'      , 'Redo Size (KB)'
                         , 'Physical Read Bytes Per Sec' , 'Physical Reads (KB)'
                         , 'Physical Write Bytes Per Sec', 'Physical Writes (KB)'
             ) metric_name
     , ROUND(average/POWER(2, 10), 3) per_second
FROM dba_hist_sysmetric_summary
WHERE metric_name IN ('Physical Read Bytes Per Sec', 'Physical Write Bytes Per Sec', 'Redo Generated Per Sec')  -- The query value of this metric_name "Physical Read/Write Bytes Per Sec" is the same as EMCC 13.5 rather than the metric_name "Physical Read/Write Total Bytes Per Sec".
AND   group_id = 2  -- Just for metric_name "Redo Generated Per Sec", hence choosing the sample intervals by 60 seconds, the value ("System Metrics Long Duration" ) of column "name" in v$metricgroup.
AND   (end_time BETWEEN TO_DATE(:start_date, 'yyyy-mm-dd hh24:mi:ss')
                AND     TO_DATE(:end_date, 'yyyy-mm-dd hh24:mi:ss')
      )
ORDER BY metric_name
       , sample_time
;

-- Physical Reads (KB) & Physical Writes (KB) & Redo Size (KB) Custom Time Period (interval by each day).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time FORMAT a19
COLUMN metric_name FORMAT a20
COLUMN per_second  FORMAT 999,999.999

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH pr_pw_rs_per_hour AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd') sample_time
       , DECODE(metric_name, 'Redo Generated Per Sec'      , 'Redo Size (KB)'
                           , 'Physical Read Bytes Per Sec' , 'Physical Reads (KB)'
                           , 'Physical Write Bytes Per Sec', 'Physical Writes (KB)'
               ) metric_name
       , average
  FROM dba_hist_sysmetric_summary
  WHERE metric_name IN ('Physical Read Bytes Per Sec', 'Physical Write Bytes Per Sec', 'Redo Generated Per Sec')  -- The query value of this metric_name "Physical Read/Write Bytes Per Sec" is the same as EMCC 13.5 rather than the metric_name "Physical Read/Write Total Bytes Per Sec".
  AND   group_id = 2  -- Just for metric_name "Redo Generated Per Sec", hence choosing the sample intervals by 60 seconds, the value ("System Metrics Long Duration" ) of column "name" in v$metricgroup.
  AND   (end_time BETWEEN TO_DATE(:start_date, 'yyyy-mm-dd')
                  AND     TO_DATE(:end_date, 'yyyy-mm-dd')
        )
)
SELECT sample_time
     , metric_name
     , ROUND(AVG(average)/POWER(2, 10), 3) per_second
FROM pr_pw_rs_per_hour
GROUP BY metric_name
       , sample_time
ORDER BY metric_name
       , sample_time
;
