REM
REM     Script:        acquire_arp.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 03, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       Visualizing the oracle some performance metrics about "CPU Time" in the past and real time by the custom report of SQL Developer,
REM       we can name them with "ARP" (Average Runnable Processes").
REM       
REM     References:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-SYSMETRIC_HISTORY.html#GUID-5560D15E-9F02-4300-B4DD-85A88A280392
REM

-- http://datavirtualizer.com/oracle-cpu-time/
-- 
-- Hello kyle,
-- could you please elaborate (again!) a little bit further on CPU_OS.
-- While it’s clear to me that
-- CPU_ORA is the average number of oracle sessions running on cpu
-- CPU_ORA_WAIT is the average number of oracle sessions waiting for cpu
-- and so on for all other columns,
-- I hardly understand what CPU_OS relates to in terms of average number of sessions. To me CPU_ORA contains all the cpu consumed by oracle sessions, so how could it be we have sessions using non oracle cpu ?
-- Thanks !
-- Olivier
-- 
-- Everything is measured in AAS, which is similar to OS runqueue
-- 
-- CPU_TOTAL: CPU used on the host
-- CPU_OS: CPU used on the host processes but not by Oracle processes, ie CPU_TOTAL – CPU_ORA
-- CPU_ORA: CPU used by Oracle processes
-- CPU_ORA_WAIT: CPU wanted by Oracle processes but not obtained, ie CPU_from_ASH – CPU_ORA
-- 
-- Non-Database Host CPU Usage Per Sec = Host CPU Usage Per Sec - CPU Usage Per Sec - Background CPU Usage Per Sec
-- In other words Non-Database Host CPU = Host CPU - Foreground CPU - Background CPU

-- Average Runnable Processes in Last 1 Hour.

SET LINESIZE 200
SET PAGESIZE 300

COLUMN metric_name FORMAT a25

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH ins_fg_cpu AS
(
  SELECT end_time sample_time
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
  SELECT end_time sample_time
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
  SELECT end_time sample_time
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
  SELECT end_time sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(value, 2) value
  FROM v$sysmetric_history
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
)
SELECT * FROM ins_fg_cpu
UNION ALL
SELECT * FROM ins_bg_cpu
UNION ALL
SELECT * FROM non_db_host_cpu
UNION ALL
SELECT * FROM load_average
;
