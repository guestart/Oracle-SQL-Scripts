REM
REM     Script:        acquire_aspac_from_emcc_13.5.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 28, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       Visualizing the oracle performance graph "Active Sessions Per Activity Class" from EMCC 13.5 in last 1 minute and 1 hour
REM       by the user defined report of SQL Developer.
REM
REM     References:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-SYSMETRIC.html#GUID-623748C3-F765-4149-8378-F5CDAD59909A
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-WAITCLASSMETRIC.html#GUID-A73F50B3-67F4-4F34-B332-402CC29A8011
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-SYSTEM_WAIT_CLASS.html#GUID-142948EB-58E8-4FCE-9FD3-80DC179733C6
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-SYSMETRIC_HISTORY.html#GUID-5560D15E-9F02-4300-B4DD-85A88A280392
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-WAITCLASSMETRIC_HISTORY.html#GUID-854BB495-19FC-4EB4-A81C-4D0EEA13B83C
REM

-- Active Sessions Per Activity Class (CPU, User I/O and Wait) from EMCC 13.5 in Last 1 Minute.

SET LINESIZE 200
SET PAGESIZE 10

COLUMN begin_time      FORMAT a10
COLUMN end_time        FORMAT a10
COLUMN metric_name     FORMAT a11
COLUMN active_sessions FORMAT 999,999.99

WITH
cpu AS
(
  SELECT TO_CHAR(begin_time, 'hh24:mi:ss') begin_time
       , TO_CHAR(end_time, 'hh24:mi:ss') end_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'CPU') metric_name
       , ROUND(value/1e2, 2) active_sessions
  FROM v$sysmetric
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  ORDER BY begin_time
),
user_io AS
(
  SELECT TO_CHAR(begin_time, 'hh24:mi:ss') begin_time
       , TO_CHAR(end_time, 'hh24:mi:ss') end_time
       , swc.wait_class metric_name
       , ROUND(wcm.time_waited/wcm.intsize_csec, 2) active_sessions
  FROM v$waitclassmetric wcm
     , v$system_wait_class swc
  WHERE wcm.wait_class_id = swc.wait_class_id
  AND   swc.wait_class = 'User I/O'
  ORDER BY begin_time
),
wait AS
(
  SELECT TO_CHAR(begin_time, 'hh24:mi:ss') begin_time
       , TO_CHAR(end_time, 'hh24:mi:ss') end_time
       , 'Wait' metric_name
       , SUM(ROUND(wcm.time_waited/wcm.intsize_csec, 2)) active_sessions
  FROM v$waitclassmetric wcm
     , v$system_wait_class swc
  WHERE wcm.wait_class_id = swc.wait_class_id
  AND   (swc.wait_class NOT IN ('Idle', 'User I/O'))
  GROUP BY TO_CHAR(begin_time, 'hh24:mi:ss')
         , TO_CHAR(end_time, 'hh24:mi:ss')
  ORDER BY begin_time
)
SELECT * FROM cpu
UNION ALL
SELECT * FROM user_io
UNION ALL
SELECT * FROM wait
;

-- Active Sessions Per Activity Class (CPU, User I/O and Wait) from EMCC 13.5 in Last 1 Hour.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time     FORMAT a11
COLUMN metric_name     FORMAT a11
COLUMN active_sessions FORMAT 999,999.9999

WITH
cpu AS
(
  SELECT TO_CHAR(end_time, 'hh24:mi:ss') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'CPU') metric_name
       , ROUND(value/1e2, 4) active_sessions
  FROM v$sysmetric_history
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
),
user_io AS
(
  SELECT TO_CHAR(wcmh.end_time, 'hh24:mi:ss') sample_time
       , swc.wait_class metric_name
       , ROUND(wcmh.time_waited/wcmh.intsize_csec, 4) active_sessions
  FROM v$waitclassmetric_history wcmh
     , v$system_wait_class swc
  WHERE wcmh.wait_class_id = swc.wait_class_id
  AND   swc.wait_class = 'User I/O'
  AND   wcmh.end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
),
wait AS
(
  SELECT TO_CHAR(wcmh.end_time, 'hh24:mi:ss') sample_time
       , 'Wait' metric_name
       , SUM(ROUND(wcmh.time_waited/wcmh.intsize_csec, 4)) active_sessions
  FROM v$waitclassmetric_history wcmh
     , v$system_wait_class swc
  WHERE wcmh.wait_class_id = swc.wait_class_id
  AND   (swc.wait_class NOT IN ('Idle', 'User I/O'))
  AND   wcmh.end_time >= SYSDATE - INTERVAL '60' MINUTE
  GROUP BY TO_CHAR(wcmh.end_time, 'hh24:mi:ss')
  ORDER BY sample_time
)
SELECT * FROM cpu
UNION ALL
SELECT * FROM user_io
UNION ALL
SELECT * FROM wait
;
