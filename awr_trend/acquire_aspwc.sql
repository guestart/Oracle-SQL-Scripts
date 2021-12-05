REM
REM     Script:        acquire_aspwc.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Dec 04, 2021
REM
REM     Updated:       Dec 05, 2021
REM                    Adding the extra SQL code snippet visualizing ASPWC in last 1 hour to illustrate how to finish writing it by detailed steps.
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

PROMPT ==============================================================
PROMPT  Active Sessions Per Wait Class from EMCC 13.5 in last 1 hour
PROMPT ==============================================================

-- We can acquire some metric_name from the view v$sysmetric_history, like "Database xxxxxx" and "CPU xxxxxx".

SET LINESIZE 200

COLUMN metric_name FORMAT a30
COLUMN metric_unit FORMAT a25

SELECT DISTINCT metric_name
     , metric_unit
FROM v$sysmetric_history
WHERE metric_name LIKE '%Database%'
OR    metric_name LIKE '%CPU%'
ORDER BY 1
;

METRIC_NAME                    METRIC_UNIT
------------------------------ -------------------------
Background CPU Usage Per Sec   CentiSeconds Per Second
CPU Usage Per Sec              CentiSeconds Per Second  <<==
CPU Usage Per Txn              CentiSeconds Per Txn
Database CPU Time Ratio        % Cpu/DB_Time            <<==
Database Time Per Sec          CentiSeconds Per Second  <<==
Database Wait Time Ratio       % Wait/DB_Time
Host CPU Usage Per Sec         CentiSeconds Per Second
Host CPU Utilization (%)       % Busy/(Idle+Busy)

8 rows selected.

-- We hope to get a conclusion that "CPU Usage Per Sec" compares with "Database Time Per Sec" * "Database CPU Time Ratio".

SET LINESIZE 200
SET PAGESIZE 100

COLUMN sample_time     FORMAT a11
COLUMN metric_name     FORMAT a11
COLUMN active_sessions FORMAT 999,999.999

WITH
cpu_1 AS
(
  SELECT TO_CHAR(end_time, 'hh24:mi:ss') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'CPU_1') metric_name
       , ROUND(value/1e2, 3) active_sessions
  FROM v$sysmetric_history
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
),
db_cpu AS
(
  SELECT TO_CHAR(end_time, 'hh24:mi:ss') sample_time
       , MAX(DECODE(metric_name, 'Database Time Per Sec'  , value/1e2)) aas_value
       , MAX(DECODE(metric_name, 'Database CPU Time Ratio', value/1e2)) cpu_ratio
  FROM v$sysmetric_history
  WHERE metric_name IN ('Database Time Per Sec', 'Database CPU Time Ratio')
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  GROUP BY TO_CHAR(end_time, 'hh24:mi:ss')
  ORDER BY sample_time
),
cpu_2 AS
(
  SELECT sample_time
       , 'CPU_2' metric_name
       , ROUND(aas_value*cpu_ratio, 3) active_sessions
  FROM db_cpu
)
SELECT c1.sample_time
     , c2.sample_time
     , 'CPU Diff' metric_name
     , c1.active_sessions - c2.active_sessions active_sessions
FROM cpu_1 c1
   , cpu_2 c2
WHERE c1.sample_time = c2.sample_time
;

-- Next we investigate the case of "Database CPU Time Ratio" + "Database Wait Time Ratio".

SET LINESIZE 200
SET PAGESIZE 100

COLUMN sample_time     FORMAT a11
COLUMN metric_name     FORMAT a11
COLUMN active_sessions FORMAT 999,999.999

WITH
cpu_and_wait_ratio AS
(
  SELECT TO_CHAR(end_time, 'hh24:mi:ss') sample_time
       , MAX(DECODE(metric_name, 'Database CPU Time Ratio' , value/1e2)) cpu_ratio
       , MAX(DECODE(metric_name, 'Database Wait Time Ratio', value/1e2)) wait_ratio
  FROM v$sysmetric_history
  WHERE metric_name IN ('Database CPU Time Ratio', 'Database Wait Time Ratio')
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  GROUP BY TO_CHAR(end_time, 'hh24:mi:ss')
  ORDER BY sample_time
)
SELECT sample_time
     , 'Total Ratio' metric_name
     , ROUND(cpu_ratio+wait_ratio, 3) total_ratio
FROM cpu_and_wait_ratio
ORDER BY sample_time
;

-- The SQL statement about 'CPU Used' and 'CPU Wait' is right.

SET LINESIZE 200
SET PAGESIZE 150

COLUMN sample_time     FORMAT a11
COLUMN metric_name     FORMAT a11
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
db_wait AS
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
  FROM db_wait
),
cpu_wait AS
(
  SELECT cu.sample_time
       , 'CPU Wait' metric_name
       , ac.active_sessions - cu.active_sessions active_sessions
  FROM all_cpu  ac
     , cpu_used cu
  WHERE ac.sample_time = cu.sample_time
)
SELECT * FROM cpu_used
UNION ALL
SELECT * FROM cpu_wait
;

-- Wait Class (but no found 'Queueing').

SET LINESIZE 200
SET PAGESIZE 800

COLUMN sample_time     FORMAT a11
COLUMN metric_name     FORMAT a15
COLUMN active_sessions FORMAT 999,999.999

SELECT TO_CHAR(wcmh.end_time, 'hh24:mi:ss') sample_time
     , swc.wait_class metric_name
     , ROUND(wcmh.time_waited_fg/wcmh.intsize_csec, 3) active_sessions
FROM v$waitclassmetric_history wcmh
   , v$system_wait_class swc
WHERE wcmh.wait_class_id = swc.wait_class_id
AND   swc.wait_class <> 'Idle'
AND   wcmh.end_time >= SYSDATE - INTERVAL '60' MINUTE
ORDER BY DECODE(swc.wait_class, 'Scheduler'     , 1
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
;

-- We can separately check the column "wait_class" from the view "v$system_wait_class" and "v$event_name".

SELECT DISTINCT wait_class FROM v$system_wait_class ORDER BY 1;

WAIT_CLASS
---------------
Administrative
Application
Commit
Concurrency
Configuration
Idle
Network
Other
Scheduler
System I/O
User I/O

11 rows selected.

SELECT DISTINCT wait_class FROM v$event_name ORDER BY 1;

WAIT_CLASS
---------------
Administrative
Application
Cluster
Commit
Concurrency
Configuration
Idle
Network
Other
Queueing          <<==
Scheduler
System I/O
User I/O

13 rows selected.

-- Wait Class (it has 'Queueing').

SET LINESIZE 200
SET PAGESIZE 800

COLUMN sample_time     FORMAT a11
COLUMN metric_name     FORMAT a15
COLUMN active_sessions FORMAT 999,999.999

WITH en_wc AS
(
  SELECT DISTINCT wait_class_id
       , wait_class
  FROM v$event_name
)
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
;

-- Integrating "CPU Used", "CPU Wait" and "Wait Class" by "WITH xxx AS () ...".

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
db_wait AS
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
  FROM db_wait
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

PROMPT ================================================================
PROMPT  Active Sessions Per Wait Class from EMCC 13.5 in last 1 minute
PROMPT ================================================================

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
db_wait AS
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
  FROM db_wait
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
