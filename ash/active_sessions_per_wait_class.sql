REM
REM     Script:        active_sessions_per_wait_class.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Oct 29, 2021
REM
REM     Updated:       Nov 02, 2021
REM                    (1) Replacing "NVL(wait_class, 'CPU') wait_class" with this, such as,
REM                        "DECODE(wait_class, 'Administrative', 'Administrative'
REM                                          , 'Application'   , 'Application'
REM                                          , 'Cluster'       , 'Cluster'
REM                                          , 'Commit'        , 'Commit'
REM                                          , 'Concurrency'   , 'Concurrency'
REM                                          , 'Configuration' , 'Configuration'
REM                                          , 'Network'       , 'Network'
REM                                          , 'Other'         , 'Other'
REM                                          , 'Scheduler'     , 'Scheduler'
REM                                          , 'System I/O'    , 'System I/O'
REM                                          , 'User I/O'      , 'User I/O'
REM                                          , NULL            , 'CPU'
REM                               ) wait_class";
REM                    (2) Adding extra 2 number of SQL snippets about "excluding/including BACKGROUND processes in Last 24 Hours";
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       Visualizing the oracle active sessions per wait class in the view "v$active_session_history" in the last 1 hour by the custom report of SQL Developer.
REM

-- Active Sessions (in ASH) Per Wait Class excluding BACKGROUND processes in Last 1 Hour.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time FORMAT a19
COLUMN wait_class  FORMAT a15

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH ash AS
(
  SELECT TRUNC(sample_time, 'mi') sample_time
         -- TO_CHAR(CAST(sample_time AS DATE), 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(wait_class, 'Administrative', 'Administrative'
                          , 'Application'   , 'Application'
                          , 'Cluster'       , 'Cluster'
                          , 'Commit'        , 'Commit'
                          , 'Concurrency'   , 'Concurrency'
                          , 'Configuration' , 'Configuration'
                          , 'Network'       , 'Network'
                          , 'Other'         , 'Other'
                          , 'Scheduler'     , 'Scheduler'
                          , 'System I/O'    , 'System I/O'
                          , 'User I/O'      , 'User I/O'
                          , NULL            , 'CPU'
               ) wait_class
       , ROUND(COUNT(*)/6e1, 2) active_sessions
  FROM v$active_session_history
  WHERE session_type = 'FOREGROUND'  -- excluding background processes
  AND   (wait_class <> 'Idle' OR wait_class IS NULL)
  GROUP BY TRUNC(sample_time, 'mi')
           -- TO_CHAR(CAST(sample_time AS DATE), 'yyyy-mm-dd hh24:mi')
         , wait_class
  ORDER BY wait_class
         , sample_time
)
SELECT * FROM ash
WHERE sample_time >= SYSDATE - INTERVAL '60' MINUTE
;

-- Active Sessions (in ASH) Per Wait Class including BACKGROUND processes in Last 1 Hour.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time FORMAT a19
COLUMN wait_class  FORMAT a15

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH ash AS
(
  SELECT TRUNC(sample_time, 'mi') sample_time
         -- TO_CHAR(CAST(sample_time AS DATE), 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(wait_class, 'Administrative', 'Administrative'
                          , 'Application'   , 'Application'
                          , 'Cluster'       , 'Cluster'
                          , 'Commit'        , 'Commit'
                          , 'Concurrency'   , 'Concurrency'
                          , 'Configuration' , 'Configuration'
                          , 'Network'       , 'Network'
                          , 'Other'         , 'Other'
                          , 'Scheduler'     , 'Scheduler'
                          , 'System I/O'    , 'System I/O'
                          , 'User I/O'      , 'User I/O'
                          , NULL            , 'CPU'
               ) wait_class
       , ROUND(COUNT(*)/6e1, 2) active_sessions
  FROM v$active_session_history
  WHERE session_type IN ('BACKGROUND', 'FOREGROUND')  -- including background processes
  AND   (wait_class <> 'Idle' OR wait_class IS NULL)
  GROUP BY TRUNC(sample_time, 'mi')
           -- TO_CHAR(CAST(sample_time AS DATE), 'yyyy-mm-dd hh24:mi')
         , wait_class
  ORDER BY wait_class
         , sample_time
)
SELECT * FROM ash
WHERE sample_time >= SYSDATE - INTERVAL '60' MINUTE
;

-- Active Sessions (in ASH) Per Wait Class excluding BACKGROUND processes in Last 24 Hours.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time FORMAT a19
COLUMN wait_class  FORMAT a15

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH ash AS
(
  SELECT TRUNC(sample_time, 'hh24') sample_time
         -- TO_CHAR(CAST(sample_time AS DATE), 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(wait_class, 'Administrative', 'Administrative'
                          , 'Application'   , 'Application'
                          , 'Cluster'       , 'Cluster'
                          , 'Commit'        , 'Commit'
                          , 'Concurrency'   , 'Concurrency'
                          , 'Configuration' , 'Configuration'
                          , 'Network'       , 'Network'
                          , 'Other'         , 'Other'
                          , 'Scheduler'     , 'Scheduler'
                          , 'System I/O'    , 'System I/O'
                          , 'User I/O'      , 'User I/O'
                          , NULL            , 'CPU'
               ) wait_class
       , ROUND(COUNT(*)/36e2, 4) active_sessions
  FROM v$active_session_history
  WHERE session_type = 'FOREGROUND'  -- excluding background processes
  AND   (wait_class <> 'Idle' OR wait_class IS NULL)
  GROUP BY TRUNC(sample_time, 'hh24')
           -- TO_CHAR(CAST(sample_time AS DATE), 'yyyy-mm-dd hh24:mi')
         , wait_class
  ORDER BY wait_class
         , sample_time
)
SELECT * FROM ash
WHERE sample_time >= SYSDATE - INTERVAL '24' HOUR
;

-- Active Sessions (in ASH) Per Wait Class including BACKGROUND processes in Last 24 Hours.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time FORMAT a19
COLUMN wait_class  FORMAT a15

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH ash AS
(
  SELECT TRUNC(sample_time, 'hh24') sample_time
         -- TO_CHAR(CAST(sample_time AS DATE), 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(wait_class, 'Administrative', 'Administrative'
                          , 'Application'   , 'Application'
                          , 'Cluster'       , 'Cluster'
                          , 'Commit'        , 'Commit'
                          , 'Concurrency'   , 'Concurrency'
                          , 'Configuration' , 'Configuration'
                          , 'Network'       , 'Network'
                          , 'Other'         , 'Other'
                          , 'Scheduler'     , 'Scheduler'
                          , 'System I/O'    , 'System I/O'
                          , 'User I/O'      , 'User I/O'
                          , NULL            , 'CPU'
               ) wait_class
       , ROUND(COUNT(*)/36e2, 4) active_sessions
  FROM v$active_session_history
  WHERE session_type IN ('BACKGROUND', 'FOREGROUND')  -- including background processes
  AND   (wait_class <> 'Idle' OR wait_class IS NULL)
  GROUP BY TRUNC(sample_time, 'hh24')
           -- TO_CHAR(CAST(sample_time AS DATE), 'yyyy-mm-dd hh24:mi')
         , wait_class
  ORDER BY wait_class
         , sample_time
)
SELECT * FROM ash
WHERE sample_time >= SYSDATE - INTERVAL '24' HOUR
;

-- https://docs.oracle.com/cd/B19306_01/server.102/b14211/autostat.htm#CHDBCADD

-- To enable easier high-level analysis of the wait events, the events are grouped into classes.
-- The wait event classes include:
-- 
-- Administrative
-- Application
-- Cluster
-- Commit
-- Concurrency
-- Configuration
-- Idle
-- Network
-- Other
-- Scheduler
-- System I/O
-- User I/O

-- https://docs.oracle.com/cd/E11882_01/server.112/e41573/autostat.htm#PFGRF94163

-- To enable easier high-level analysis of the wait events, events are grouped into classes.
-- The classes include:
-- 
-- Administrative
-- Application
-- Cluster
-- Commit
-- Concurrency
-- Configuration
-- Idle
-- Network
-- Other
-- Scheduler
-- System I/O
-- User I/O
-- 
-- -- https://docs.oracle.com/en/database/oracle/oracle-database/19/tgdba/measuring-database-performance.html#GUID-FC0E9098-1B1D-4532-A6C0-91E5A2FF8FB9
-- 
-- To enable easier high-level analysis of wait events, Oracle Database groups events into the following classes:
-- 
-- Administrative
-- Application
-- Cluster
-- Commit
-- Concurrency
-- Configuration
-- Idle
-- Network
-- Other
-- Scheduler
-- System I/O
-- User I/O

-- select distinct wait_class from dba_hist_system_event order by 1;
-- 
-- WAIT_CLASS
-- -------------------
-- Administrative
-- Application
-- Commit
-- Concurrency
-- Configuration
-- Idle
-- Network
-- Other
-- Scheduler
-- System I/O
-- User I/O
-- 
-- 11 rows selected.
