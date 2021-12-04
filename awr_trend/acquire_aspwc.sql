REM
REM     Script:        acquire_aspwc.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Dec 04, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       Visualizing the oracle performance graph "Active Sessions Per Wait Class" (ASPWC) from EMCC 13.5 in last 1 hour and 1 minute
REM       by the user defined report of SQL Developer.
REM
REM     References:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/classes-of-wait-events.html#GUID-B30B0811-0FDC-40FC-92FC-F6726CE94736
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-SYSMETRIC.html#GUID-623748C3-F765-4149-8378-F5CDAD59909A
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-WAITCLASSMETRIC.html#GUID-A73F50B3-67F4-4F34-B332-402CC29A8011
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-EVENT_NAME.html#GUID-5C6F3606-5C6F-4E57-A149-DF3385092B54
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-SYSMETRIC_HISTORY.html#GUID-5560D15E-9F02-4300-B4DD-85A88A280392
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-WAITCLASSMETRIC_HISTORY.html#GUID-854BB495-19FC-4EB4-A81C-4D0EEA13B83C
REM

-- 
-- http://gongju.chinaadmin.cn/tupianquse/
-- 
-- Each Legend Color from the Graph of "Active Sessions Per Wait Class" of EMCC 13.5.
-- 
-- CPU Used      , #35C387 -> RGB (53 , 195, 135)
-- CPU Wait      , #A9F89C -> RGB (169, 248, 156)
-- Scheduler     , #CBE8CD -> RGB (203, 232, 205)
-- User I/O      , #0072CA -> RGB (0  , 114, 202)
-- System I/O    , #04DEDE -> RGB (4  , 222, 222)
-- Concurrency   , #8B60C9 -> RGB (139, 96 , 201)
-- Application   , #FF5C38 -> RGB (255, 92 , 56 )
-- Commit        , #FFB146 -> RGB (255, 177, 70 )
-- Configuration , #FAF37D -> RGB (250, 243, 125)
-- Administrative, #FFCC48 -> RGB (255, 204, 72 )
-- Network       , #00C0F0 -> RGB (0  , 192, 240)
-- Queueing      , #C5B79B -> RGB (197, 183, 155)
-- Cluster       , #CBC2AF -> RGB (203, 194, 175)
-- Other         , #F76AAE -> RGB (247, 106, 174)

-- Active Sessions Per Wait Class from EMCC 13.5 in last 1 hour.

SET LINESIZE 200
SET PAGESIZE 1000

COLUMN sample_time     FORMAT a11
COLUMN metric_name     FORMAT a15
COLUMN active_sessions FORMAT 999,999.999

WITH
all_cpu AS
(
  SELECT TO_CHAR(end_time, 'hh24:mi:ss') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'CPU') metric_name
       , ROUND(value/1e2, 3) active_sessions
  FROM v$sysmetric_history
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
),
aas_and_wait AS
(
  SELECT TO_CHAR(end_time, 'hh24:mi:ss') sample_time
         , MAX(DECODE(metric_name, 'Database Time Per Sec'   , value/1e2)) aas_value
         , MAX(DECODE(metric_name, 'Database Wait Time Ratio', value/1e2)) wait_ratio
  FROM v$sysmetric_history
  WHERE metric_name IN ('Database Time Per Sec', 'Database Wait Time Ratio')
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  GROUP BY TO_CHAR(end_time, 'hh24:mi:ss')
  ORDER BY sample_time
),
cpu_used AS
(
  SELECT sample_time
       , 'CPU Used' metric_name
       , ROUND(aas_value*(1-wait_ratio), 3) active_sessions
  FROM aas_and_wait
),
cpu_wait AS
(
  SELECT cu.sample_time
       , 'CPU Wait' metric_name
       , ac.active_sessions - cu.active_sessions active_sessions
  FROM all_cpu  ac
     , cpu_used cu
  WHERE ac.sample_time = cu.sample_time
),
en_wc AS
(
  SELECT DISTINCT wait_class_id
       , wait_class
  FROM v$event_name
),
wait_class AS
(
  SELECT TO_CHAR(wcmh.end_time, 'hh24:mi:ss') sample_time
       , ew.wait_class metric_name
       , ROUND(wcmh.time_waited_fg/wcmh.intsize_csec, 3) active_sessions
  FROM v$waitclassmetric_history wcmh
     , en_wc ew
  WHERE wcmh.wait_class_id = ew.wait_class_id
  AND   ew.wait_class <> 'Idle'
  AND   wcmh.end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY DECODE(ew.wait_class, 'Scheduler'     , 1
                               , 'User I/O'      , 2
                               , 'System I/O'    , 3
                               , 'Concurrency'   , 4
                               , 'Application'   , 5
                               , 'Commit'        , 6
                               , 'Configuration' , 7
                               , 'Administrative', 8
                               , 'Network'       , 9
                               , 'Queueing'      , 10
                               , 'Cluster'       , 11
                               , 'Other'         , 12
                 )
         , sample_time
)
SELECT * FROM cpu_used
UNION ALL
SELECT * FROM cpu_wait
UNION ALL
SELECT * FROM wait_class
;

-- Active Sessions Per Wait Class from EMCC 13.5 in last 1 minute.

SET LINESIZE 200
SET PAGESIZE 20

COLUMN sample_time     FORMAT a11
COLUMN metric_name     FORMAT a15
COLUMN active_sessions FORMAT 999,999.999

WITH
all_cpu AS
(
  SELECT TO_CHAR(end_time, 'hh24:mi:ss') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'CPU') metric_name
       , ROUND(value/1e2, 3) active_sessions
  FROM v$sysmetric
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
-- AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
),
aas_and_wait AS
(
  SELECT TO_CHAR(end_time, 'hh24:mi:ss') sample_time
         , MAX(DECODE(metric_name, 'Database Time Per Sec'   , value/1e2)) aas_value
         , MAX(DECODE(metric_name, 'Database Wait Time Ratio', value/1e2)) wait_ratio
  FROM v$sysmetric
  WHERE metric_name IN ('Database Time Per Sec', 'Database Wait Time Ratio')
  AND   group_id = 2
-- AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  GROUP BY TO_CHAR(end_time, 'hh24:mi:ss')
  ORDER BY sample_time
),
cpu_used AS
(
  SELECT sample_time
       , 'CPU Used' metric_name
       , ROUND(aas_value*(1-wait_ratio), 3) active_sessions
  FROM aas_and_wait
),
cpu_wait AS
(
  SELECT cu.sample_time
       , 'CPU Wait' metric_name
       , ac.active_sessions - cu.active_sessions active_sessions
  FROM all_cpu  ac
     , cpu_used cu
  WHERE ac.sample_time = cu.sample_time
),
en_wc AS
(
  SELECT DISTINCT wait_class_id
       , wait_class
  FROM v$event_name
),
wait_class AS
(
  SELECT TO_CHAR(wcm.end_time, 'hh24:mi:ss') sample_time
       , ew.wait_class metric_name
       , ROUND(wcm.time_waited_fg/wcm.intsize_csec, 3) active_sessions
  FROM v$waitclassmetric wcm
     , en_wc ew
  WHERE wcm.wait_class_id = ew.wait_class_id
  AND   ew.wait_class <> 'Idle'
-- AND   wcm.end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY DECODE(ew.wait_class, 'Scheduler'     , 1
                               , 'User I/O'      , 2
                               , 'System I/O'    , 3
                               , 'Concurrency'   , 4
                               , 'Application'   , 5
                               , 'Commit'        , 6
                               , 'Configuration' , 7
                               , 'Administrative', 8
                               , 'Network'       , 9
                               , 'Queueing'      , 10
                               , 'Cluster'       , 11
                               , 'Other'         , 12
                 )
         , sample_time
)
SELECT * FROM cpu_used
UNION ALL
SELECT * FROM cpu_wait
UNION ALL
SELECT * FROM wait_class
;
