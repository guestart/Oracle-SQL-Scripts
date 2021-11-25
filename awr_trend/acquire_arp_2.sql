REM
REM     Script:        acquire_arp_2.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 25, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       This is the 2nd version about acquire_arp.sql based on https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_arp.sql.
REM       DarkAthena (https://www.modb.pro/u/445229) gave me a pretty nice feedback when I published this blog post (https://www.modb.pro/db/172906) on modb
REM       a couple of days ago. He mentioned that it's uncessary to use the dynamically converting rows to columns and write extra codes about views and procedures.
REM       It can also generate Excel graph my expected if my Excel table heads are four metric names (just use the statically converting rows to columns for my
REM       initial SQL query).
REM
REM       Thus in this SQL script I'll just use the statically converting rows to columns (including two number of methods - classic "MAX(DECODE()) ... GROUP BY"
REM       and "SELECT * FROM table_name PIVOT (MAX(column_name_1) FOR column_name_2 IN ())") to state my business logic.
REM

PROMPT ===========================================
PROMPT  Average Runnable Processes in Last 1 Hour
PORMPT ===========================================

-- Statically Converting Rows to Columns by "MAX(DECODE(...)) GROUP BY ...".

SET LINESIZE 200
SET PAGESIZE 300

COLUMN sample_time FORMAT a11
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

WITH
ins_fg_cpu AS
(
  SELECT TO_CHAR(end_time, 'hh24:mi:ss') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(value/1e2, 2) value
  FROM v$sysmetric_history
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT TO_CHAR(end_time, 'hh24:mi:ss') sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(value/1e2, 2) value
  FROM v$sysmetric_history
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT TO_CHAR(end_time, 'hh24:mi:ss') sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(value/1e2, 2) value
  FROM v$sysmetric_history
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT TO_CHAR(end_time, 'hh24:mi:ss') sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(value, 2) value
  FROM v$sysmetric_history
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
),
arp AS
(
  SELECT * FROM ins_fg_cpu
  UNION ALL
  SELECT * FROM ins_bg_cpu
  UNION ALL
  SELECT * FROM non_db_host_cpu
  UNION ALL
  SELECT * FROM load_average
)
SELECT sample_time
     , MAX(DECODE(metric_name, 'Instance Foreground CPU', value)) "Instance Foreground CPU"
     , MAX(DECODE(metric_name, 'Instance Background CPU', value)) "Instance Background CPU"
     , MAX(DECODE(metric_name, 'Non-Database Host CPU'  , value)) "Non-Database Host CPU"
     , MAX(DECODE(metric_name, 'Load Average'           , value)) "Load Average"
FROM arp
GROUP BY sample_time
ORDER BY sample_time
;

-- Statically Converting Rows to Columns by "SELECT * FROM table_name PIVOT (MAX(column_name_1) FOR column_name_2 IN ())".

SET LINESIZE 200
SET PAGESIZE 300

COLUMN sample_time FORMAT a11
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

WITH
ins_fg_cpu AS
(
  SELECT TO_CHAR(end_time, 'hh24:mi:ss') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(value/1e2, 2) value
  FROM v$sysmetric_history
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT TO_CHAR(end_time, 'hh24:mi:ss') sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(value/1e2, 2) value
  FROM v$sysmetric_history
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT TO_CHAR(end_time, 'hh24:mi:ss') sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(value/1e2, 2) value
  FROM v$sysmetric_history
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT TO_CHAR(end_time, 'hh24:mi:ss') sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(value, 2) value
  FROM v$sysmetric_history
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
),
arp AS
(
  SELECT * FROM ins_fg_cpu
  UNION ALL
  SELECT * FROM ins_bg_cpu
  UNION ALL
  SELECT * FROM non_db_host_cpu
  UNION ALL
  SELECT * FROM load_average
)
SELECT *
FROM arp
PIVOT ( MAX(value)
        FOR metric_name IN
        (  'Instance Foreground CPU'
         , 'Instance Background CPU'
         , 'Non-Database Host CPU'
         , 'Load Average'
        )
      )
ORDER BY sample_time
;

PROMPT =============================================
PROMPT  Average Runnable Processes in Last 24 Hours
PORMPT =============================================

-- Statically Converting Rows to Columns by "MAX(DECODE(...)) GROUP BY ...".

SET LINESIZE 200
SET PAGESIZE 300

COLUMN sample_time FORMAT a16
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

WITH
ins_fg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '24' HOUR
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '24' HOUR
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '24' HOUR
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(average, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '24' HOUR
  ORDER BY sample_time
),
arp AS
(
  SELECT * FROM ins_fg_cpu
  UNION ALL
  SELECT * FROM ins_bg_cpu
  UNION ALL
  SELECT * FROM non_db_host_cpu
  UNION ALL
  SELECT * FROM load_average
)
SELECT sample_time
     , MAX(DECODE(metric_name, 'Instance Foreground CPU', value)) "Instance Foreground CPU"
     , MAX(DECODE(metric_name, 'Instance Background CPU', value)) "Instance Background CPU"
     , MAX(DECODE(metric_name, 'Non-Database Host CPU'  , value)) "Non-Database Host CPU"
     , MAX(DECODE(metric_name, 'Load Average'           , value)) "Load Average"
FROM arp
GROUP BY sample_time
ORDER BY sample_time
;

-- Statically Converting Rows to Columns by "SELECT * FROM table_name PIVOT (MAX(column_name_1) FOR column_name_2 IN ())".

SET LINESIZE 200
SET PAGESIZE 300

COLUMN sample_time FORMAT a16
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

WITH
ins_fg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '24' HOUR
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '24' HOUR
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '24' HOUR
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(average, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '24' HOUR
  ORDER BY sample_time
),
arp AS
(
  SELECT * FROM ins_fg_cpu
  UNION ALL
  SELECT * FROM ins_bg_cpu
  UNION ALL
  SELECT * FROM non_db_host_cpu
  UNION ALL
  SELECT * FROM load_average
)
SELECT *
FROM arp
PIVOT ( MAX(value)
        FOR metric_name IN
        (  'Instance Foreground CPU'
         , 'Instance Background CPU'
         , 'Non-Database Host CPU'
         , 'Load Average'
        )
      )
ORDER BY sample_time
;

PROMPT ===================================================================
PROMPT  Average Runnable Processes in Last 7 Days (interval by each hour)
PORMPT ===================================================================

-- Statically Converting Rows to Columns by "MAX(DECODE(...)) GROUP BY ...".

SET LINESIZE 200
SET PAGESIZE 700

COLUMN sample_time FORMAT a16
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

WITH
ins_fg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '6' DAY
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '6' DAY
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '6' DAY
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(average, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '6' DAY
  ORDER BY sample_time
),
arp AS
(
  SELECT * FROM ins_fg_cpu
  UNION ALL
  SELECT * FROM ins_bg_cpu
  UNION ALL
  SELECT * FROM non_db_host_cpu
  UNION ALL
  SELECT * FROM load_average
)
SELECT sample_time
     , MAX(DECODE(metric_name, 'Instance Foreground CPU', value)) "Instance Foreground CPU"
     , MAX(DECODE(metric_name, 'Instance Background CPU', value)) "Instance Background CPU"
     , MAX(DECODE(metric_name, 'Non-Database Host CPU'  , value)) "Non-Database Host CPU"
     , MAX(DECODE(metric_name, 'Load Average'           , value)) "Load Average"
FROM arp
GROUP BY sample_time
ORDER BY sample_time
;

-- Statically Converting Rows to Columns by "SELECT * FROM table_name PIVOT (MAX(column_name_1) FOR column_name_2 IN ())".

SET LINESIZE 200
SET PAGESIZE 700

COLUMN sample_time FORMAT a16
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

WITH
ins_fg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '6' DAY
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '6' DAY
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '6' DAY
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(average, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '6' DAY
  ORDER BY sample_time
),
arp AS
(
  SELECT * FROM ins_fg_cpu
  UNION ALL
  SELECT * FROM ins_bg_cpu
  UNION ALL
  SELECT * FROM non_db_host_cpu
  UNION ALL
  SELECT * FROM load_average
)
SELECT *
FROM arp
PIVOT ( MAX(value)
        FOR metric_name IN
        (  'Instance Foreground CPU'
         , 'Instance Background CPU'
         , 'Non-Database Host CPU'
         , 'Load Average'
        )
      )
ORDER BY sample_time
;

PROMPT ==================================================================
PROMPT  Average Runnable Processes in Last 7 Days (interval by each day)
PORMPT ==================================================================

-- Statically Converting Rows to Columns by "MAX(DECODE(...)) GROUP BY ...".

SET LINESIZE 200
SET PAGESIZE 100

COLUMN sample_time FORMAT a11
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

WITH
ins_fg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '6' DAY
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '6' DAY
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '6' DAY
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(average, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '6' DAY
  ORDER BY sample_time
),
arp AS
(
  SELECT * FROM ins_fg_cpu
  UNION ALL
  SELECT * FROM ins_bg_cpu
  UNION ALL
  SELECT * FROM non_db_host_cpu
  UNION ALL
  SELECT * FROM load_average
),
arp_2 AS
(
  SELECT TO_CHAR(TO_DATE(sample_time, 'yyyy-mm-dd hh24:mi'), 'yyyy-mm-dd') sample_time
       , metric_name
       , ROUND(AVG(value), 2) value
  FROM arp
  GROUP BY TO_CHAR(TO_DATE(sample_time, 'yyyy-mm-dd hh24:mi'), 'yyyy-mm-dd')
         , metric_name
  ORDER BY DECODE(metric_name, 'Instance Foreground CPU', 1
                             , 'Instance Background CPU', 2
                             , 'Non-Database Host CPU'  , 3
                             , 'Load Average'           , 4
                 )
         , sample_time
)
SELECT sample_time
     , MAX(DECODE(metric_name, 'Instance Foreground CPU', value)) "Instance Foreground CPU"
     , MAX(DECODE(metric_name, 'Instance Background CPU', value)) "Instance Background CPU"
     , MAX(DECODE(metric_name, 'Non-Database Host CPU'  , value)) "Non-Database Host CPU"
     , MAX(DECODE(metric_name, 'Load Average'           , value)) "Load Average"
FROM arp_2
GROUP BY sample_time
ORDER BY sample_time
;

-- Statically Converting Rows to Columns by "SELECT * FROM table_name PIVOT (MAX(column_name_1) FOR column_name_2 IN ())".

SET LINESIZE 200
SET PAGESIZE 100

COLUMN sample_time FORMAT a11
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

WITH
ins_fg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '6' DAY
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '6' DAY
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '6' DAY
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(average, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '6' DAY
  ORDER BY sample_time
),
arp AS
(
  SELECT * FROM ins_fg_cpu
  UNION ALL
  SELECT * FROM ins_bg_cpu
  UNION ALL
  SELECT * FROM non_db_host_cpu
  UNION ALL
  SELECT * FROM load_average
),
arp_2 AS
(
  SELECT TO_CHAR(TO_DATE(sample_time, 'yyyy-mm-dd hh24:mi'), 'yyyy-mm-dd') sample_time
       , metric_name
       , ROUND(AVG(value), 2) value
  FROM arp
  GROUP BY TO_CHAR(TO_DATE(sample_time, 'yyyy-mm-dd hh24:mi'), 'yyyy-mm-dd')
         , metric_name
  ORDER BY DECODE(metric_name, 'Instance Foreground CPU', 1
                             , 'Instance Background CPU', 2
                             , 'Non-Database Host CPU'  , 3
                             , 'Load Average'           , 4
                 )
         , sample_time
)
SELECT *
FROM arp_2
PIVOT ( MAX(value)
        FOR metric_name IN
        (  'Instance Foreground CPU'
         , 'Instance Background CPU'
         , 'Non-Database Host CPU'
         , 'Load Average'
        )
      )
ORDER BY sample_time
;

PROMPT ====================================================================
PROMPT  Average Runnable Processes in Last 31 Days (interval by each hour)
PORMPT ====================================================================

-- Statically Converting Rows to Columns by "MAX(DECODE(...)) GROUP BY ...".

SET LINESIZE 200
SET PAGESIZE 3000

COLUMN sample_time FORMAT a16
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

WITH
ins_fg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '30' DAY
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '30' DAY
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '30' DAY
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(average, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '30' DAY
  ORDER BY sample_time
),
arp AS
(
  SELECT * FROM ins_fg_cpu
  UNION ALL
  SELECT * FROM ins_bg_cpu
  UNION ALL
  SELECT * FROM non_db_host_cpu
  UNION ALL
  SELECT * FROM load_average
)
SELECT sample_time
     , MAX(DECODE(metric_name, 'Instance Foreground CPU', value)) "Instance Foreground CPU"
     , MAX(DECODE(metric_name, 'Instance Background CPU', value)) "Instance Background CPU"
     , MAX(DECODE(metric_name, 'Non-Database Host CPU'  , value)) "Non-Database Host CPU"
     , MAX(DECODE(metric_name, 'Load Average'           , value)) "Load Average"
FROM arp
GROUP BY sample_time
ORDER BY sample_time
;

-- Statically Converting Rows to Columns by "SELECT * FROM table_name PIVOT (MAX(column_name_1) FOR column_name_2 IN ())".

SET LINESIZE 200
SET PAGESIZE 3000

COLUMN sample_time FORMAT a16
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

WITH
ins_fg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '30' DAY
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '30' DAY
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '30' DAY
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(average, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '30' DAY
  ORDER BY sample_time
),
arp AS
(
  SELECT * FROM ins_fg_cpu
  UNION ALL
  SELECT * FROM ins_bg_cpu
  UNION ALL
  SELECT * FROM non_db_host_cpu
  UNION ALL
  SELECT * FROM load_average
)
SELECT *
FROM arp
PIVOT ( MAX(value)
        FOR metric_name IN
        (  'Instance Foreground CPU'
         , 'Instance Background CPU'
         , 'Non-Database Host CPU'
         , 'Load Average'
        )
      )
ORDER BY sample_time
;

PROMPT ===================================================================
PROMPT  Average Runnable Processes in Last 31 Days (interval by each day)
PORMPT ===================================================================

-- Statically Converting Rows to Columns by "MAX(DECODE(...)) GROUP BY ...".

SET LINESIZE 200
SET PAGESIZE 100

COLUMN sample_time FORMAT a11
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

WITH
ins_fg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '30' DAY
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '30' DAY
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '30' DAY
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(average, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '30' DAY
  ORDER BY sample_time
),
arp AS
(
  SELECT * FROM ins_fg_cpu
  UNION ALL
  SELECT * FROM ins_bg_cpu
  UNION ALL
  SELECT * FROM non_db_host_cpu
  UNION ALL
  SELECT * FROM load_average
),
arp_2 AS
(
  SELECT TO_CHAR(TO_DATE(sample_time, 'yyyy-mm-dd hh24:mi'), 'yyyy-mm-dd') sample_time
       , metric_name
       , ROUND(AVG(value), 2) value
  FROM arp
  GROUP BY TO_CHAR(TO_DATE(sample_time, 'yyyy-mm-dd hh24:mi'), 'yyyy-mm-dd')
         , metric_name
  ORDER BY DECODE(metric_name, 'Instance Foreground CPU', 1
                             , 'Instance Background CPU', 2
                             , 'Non-Database Host CPU'  , 3
                             , 'Load Average'           , 4
                 )
         , sample_time
)
SELECT sample_time
     , MAX(DECODE(metric_name, 'Instance Foreground CPU', value)) "Instance Foreground CPU"
     , MAX(DECODE(metric_name, 'Instance Background CPU', value)) "Instance Background CPU"
     , MAX(DECODE(metric_name, 'Non-Database Host CPU'  , value)) "Non-Database Host CPU"
     , MAX(DECODE(metric_name, 'Load Average'           , value)) "Load Average"
FROM arp_2
GROUP BY sample_time
ORDER BY sample_time
;

-- Statically Converting Rows to Columns by "SELECT * FROM table_name PIVOT (MAX(column_name_1) FOR column_name_2 IN ())".

SET LINESIZE 200
SET PAGESIZE 100

COLUMN sample_time FORMAT a11
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

WITH
ins_fg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '30' DAY
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '30' DAY
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '30' DAY
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(average, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '30' DAY
  ORDER BY sample_time
),
arp AS
(
  SELECT * FROM ins_fg_cpu
  UNION ALL
  SELECT * FROM ins_bg_cpu
  UNION ALL
  SELECT * FROM non_db_host_cpu
  UNION ALL
  SELECT * FROM load_average
),
arp_2 AS
(
  SELECT TO_CHAR(TO_DATE(sample_time, 'yyyy-mm-dd hh24:mi'), 'yyyy-mm-dd') sample_time
       , metric_name
       , ROUND(AVG(value), 2) value
  FROM arp
  GROUP BY TO_CHAR(TO_DATE(sample_time, 'yyyy-mm-dd hh24:mi'), 'yyyy-mm-dd')
         , metric_name
  ORDER BY DECODE(metric_name, 'Instance Foreground CPU', 1
                             , 'Instance Background CPU', 2
                             , 'Non-Database Host CPU'  , 3
                             , 'Load Average'           , 4
                 )
         , sample_time
)
SELECT *
FROM arp_2
PIVOT ( MAX(value)
        FOR metric_name IN
        (  'Instance Foreground CPU'
         , 'Instance Background CPU'
         , 'Non-Database Host CPU'
         , 'Load Average'
        )
      )
ORDER BY sample_time
;

PROMPT =======================================================================
PROMPT  Average Runnable Processes Custom Time Period (interval by each hour)
PORMPT =======================================================================

-- Statically Converting Rows to Columns by "MAX(DECODE(...)) GROUP BY ...".

SET VERIFY OFF

SET LINESIZE 200
SET PAGESIZE 3000

COLUMN sample_time FORMAT a16
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

WITH
ins_fg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   (end_time BETWEEN TO_DATE('&&start_date', 'yyyy-mm-dd hh24:mi')
                  AND     TO_DATE('&&end_date', 'yyyy-mm-dd hh24:mi')
        )
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   (end_time BETWEEN TO_DATE('&&start_date', 'yyyy-mm-dd hh24:mi')
                  AND     TO_DATE('&&end_date', 'yyyy-mm-dd hh24:mi')
        )
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   (end_time BETWEEN TO_DATE('&&start_date', 'yyyy-mm-dd hh24:mi')
                  AND     TO_DATE('&&end_date', 'yyyy-mm-dd hh24:mi')
        )
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(average, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   (end_time BETWEEN TO_DATE('&&start_date', 'yyyy-mm-dd hh24:mi')
                  AND     TO_DATE('&&end_date', 'yyyy-mm-dd hh24:mi')
        )
  ORDER BY sample_time
),
arp AS
(
  SELECT * FROM ins_fg_cpu
  UNION ALL
  SELECT * FROM ins_bg_cpu
  UNION ALL
  SELECT * FROM non_db_host_cpu
  UNION ALL
  SELECT * FROM load_average
)
SELECT sample_time
     , MAX(DECODE(metric_name, 'Instance Foreground CPU', value)) "Instance Foreground CPU"
     , MAX(DECODE(metric_name, 'Instance Background CPU', value)) "Instance Background CPU"
     , MAX(DECODE(metric_name, 'Non-Database Host CPU'  , value)) "Non-Database Host CPU"
     , MAX(DECODE(metric_name, 'Load Average'           , value)) "Load Average"
FROM arp
GROUP BY sample_time
ORDER BY sample_time
;

-- Statically Converting Rows to Columns by "SELECT * FROM table_name PIVOT (MAX(column_name_1) FOR column_name_2 IN ())".

SET VERIFY OFF

SET LINESIZE 200
SET PAGESIZE 3000

COLUMN sample_time FORMAT a16
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

WITH
ins_fg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   (end_time BETWEEN TO_DATE('&&start_date', 'yyyy-mm-dd hh24:mi')
                  AND     TO_DATE('&&end_date', 'yyyy-mm-dd hh24:mi')
        )
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   (end_time BETWEEN TO_DATE('&&start_date', 'yyyy-mm-dd hh24:mi')
                  AND     TO_DATE('&&end_date', 'yyyy-mm-dd hh24:mi')
        )
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   (end_time BETWEEN TO_DATE('&&start_date', 'yyyy-mm-dd hh24:mi')
                  AND     TO_DATE('&&end_date', 'yyyy-mm-dd hh24:mi')
        )
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(average, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   (end_time BETWEEN TO_DATE('&&start_date', 'yyyy-mm-dd hh24:mi')
                  AND     TO_DATE('&&end_date', 'yyyy-mm-dd hh24:mi')
        )
  ORDER BY sample_time
),
arp AS
(
  SELECT * FROM ins_fg_cpu
  UNION ALL
  SELECT * FROM ins_bg_cpu
  UNION ALL
  SELECT * FROM non_db_host_cpu
  UNION ALL
  SELECT * FROM load_average
)
SELECT *
FROM arp
PIVOT ( MAX(value)
        FOR metric_name IN
        (  'Instance Foreground CPU'
         , 'Instance Background CPU'
         , 'Non-Database Host CPU'
         , 'Load Average'
        )
      )
ORDER BY sample_time
;

PROMPT ======================================================================
PROMPT  Average Runnable Processes Custom Time Period (interval by each day)
PORMPT ======================================================================

-- Statically Converting Rows to Columns by "MAX(DECODE(...)) GROUP BY ...".

SET VERIFY OFF

SET LINESIZE 200
SET PAGESIZE 100

COLUMN sample_time FORMAT a11
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

WITH
ins_fg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   (end_time BETWEEN TO_DATE('&&start_date', 'yyyy-mm-dd hh24:mi')
                  AND     TO_DATE('&&end_date', 'yyyy-mm-dd hh24:mi')
        )
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   (end_time BETWEEN TO_DATE('&&start_date', 'yyyy-mm-dd hh24:mi')
                  AND     TO_DATE('&&end_date', 'yyyy-mm-dd hh24:mi')
        )
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   (end_time BETWEEN TO_DATE('&&start_date', 'yyyy-mm-dd hh24:mi')
                  AND     TO_DATE('&&end_date', 'yyyy-mm-dd hh24:mi')
        )
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(average, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   (end_time BETWEEN TO_DATE('&&start_date', 'yyyy-mm-dd hh24:mi')
                  AND     TO_DATE('&&end_date', 'yyyy-mm-dd hh24:mi')
        )
  ORDER BY sample_time
),
arp AS
(
  SELECT * FROM ins_fg_cpu
  UNION ALL
  SELECT * FROM ins_bg_cpu
  UNION ALL
  SELECT * FROM non_db_host_cpu
  UNION ALL
  SELECT * FROM load_average
),
arp_2 AS
(
  SELECT TO_CHAR(TO_DATE(sample_time, 'yyyy-mm-dd hh24:mi'), 'yyyy-mm-dd') sample_time
       , metric_name
       , ROUND(AVG(value), 2) value
  FROM arp
  GROUP BY TO_CHAR(TO_DATE(sample_time, 'yyyy-mm-dd hh24:mi'), 'yyyy-mm-dd')
         , metric_name
  ORDER BY DECODE(metric_name, 'Instance Foreground CPU', 1
                             , 'Instance Background CPU', 2
                             , 'Non-Database Host CPU'  , 3
                             , 'Load Average'           , 4
                 )
         , sample_time
)
SELECT sample_time
     , MAX(DECODE(metric_name, 'Instance Foreground CPU', value)) "Instance Foreground CPU"
     , MAX(DECODE(metric_name, 'Instance Background CPU', value)) "Instance Background CPU"
     , MAX(DECODE(metric_name, 'Non-Database Host CPU'  , value)) "Non-Database Host CPU"
     , MAX(DECODE(metric_name, 'Load Average'           , value)) "Load Average"
FROM arp_2
GROUP BY sample_time
ORDER BY sample_time
;

-- Statically Converting Rows to Columns by "SELECT * FROM table_name PIVOT (MAX(column_name_1) FOR column_name_2 IN ())".

SET VERIFY OFF

SET LINESIZE 200
SET PAGESIZE 100

COLUMN sample_time FORMAT a11
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

WITH
ins_fg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   (end_time BETWEEN TO_DATE('&&start_date', 'yyyy-mm-dd hh24:mi')
                  AND     TO_DATE('&&end_date', 'yyyy-mm-dd hh24:mi')
        )
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   (end_time BETWEEN TO_DATE('&&start_date', 'yyyy-mm-dd hh24:mi')
                  AND     TO_DATE('&&end_date', 'yyyy-mm-dd hh24:mi')
        )
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   (end_time BETWEEN TO_DATE('&&start_date', 'yyyy-mm-dd hh24:mi')
                  AND     TO_DATE('&&end_date', 'yyyy-mm-dd hh24:mi')
        )
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(average, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   (end_time BETWEEN TO_DATE('&&start_date', 'yyyy-mm-dd hh24:mi')
                  AND     TO_DATE('&&end_date', 'yyyy-mm-dd hh24:mi')
        )
  ORDER BY sample_time
),
arp AS
(
  SELECT * FROM ins_fg_cpu
  UNION ALL
  SELECT * FROM ins_bg_cpu
  UNION ALL
  SELECT * FROM non_db_host_cpu
  UNION ALL
  SELECT * FROM load_average
),
arp_2 AS
(
  SELECT TO_CHAR(TO_DATE(sample_time, 'yyyy-mm-dd hh24:mi'), 'yyyy-mm-dd') sample_time
       , metric_name
       , ROUND(AVG(value), 2) value
  FROM arp
  GROUP BY TO_CHAR(TO_DATE(sample_time, 'yyyy-mm-dd hh24:mi'), 'yyyy-mm-dd')
         , metric_name
  ORDER BY DECODE(metric_name, 'Instance Foreground CPU', 1
                             , 'Instance Background CPU', 2
                             , 'Non-Database Host CPU'  , 3
                             , 'Load Average'           , 4
                 )
         , sample_time
)
SELECT *
FROM arp_2
PIVOT ( MAX(value)
        FOR metric_name IN
        (  'Instance Foreground CPU'
         , 'Instance Background CPU'
         , 'Non-Database Host CPU'
         , 'Load Average'
        )
      )
ORDER BY sample_time
;
