REM
REM     Script:        active_sessions_per_session_state.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 02, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       Visualizing the oracle active sessions per session state in the view "v$active_session_history" in the last 1 hour by the custom report of SQL Developer.
REM

-- Active Sessions (in ASH) Per Session State excluding BACKGROUND processes in Last 1 Hour.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time   FORMAT a19
COLUMN session_state FORMAT a15

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH ash AS
(
  SELECT TRUNC(sample_time, 'mi') sample_time
         -- TO_CHAR(CAST(sample_time AS DATE), 'yyyy-mm-dd hh24:mi') sample_time
       , session_state
       , ROUND(COUNT(*)/6e1, 2) active_sessions
  FROM v$active_session_history
  WHERE session_type = 'FOREGROUND'  -- excluding background processes
  GROUP BY TRUNC(sample_time, 'mi')
           -- TO_CHAR(CAST(sample_time AS DATE), 'yyyy-mm-dd hh24:mi')
         , session_state
  ORDER BY session_state
         , sample_time
)
SELECT * FROM ash
WHERE sample_time >= SYSDATE - INTERVAL '60' MINUTE
;

-- Active Sessions (in ASH) Per Session State including BACKGROUND processes in Last 1 Hour.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time   FORMAT a19
COLUMN session_state FORMAT a15

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH ash AS
(
  SELECT TRUNC(sample_time, 'mi') sample_time
         -- TO_CHAR(CAST(sample_time AS DATE), 'yyyy-mm-dd hh24:mi') sample_time
       , session_state
       , ROUND(COUNT(*)/6e1, 2) active_sessions
  FROM v$active_session_history
  WHERE session_type IN ('BACKGROUND', 'FOREGROUND')  -- including background processes
  GROUP BY TRUNC(sample_time, 'mi')
           -- TO_CHAR(CAST(sample_time AS DATE), 'yyyy-mm-dd hh24:mi')
         , session_state
  ORDER BY session_state
         , sample_time
)
SELECT * FROM ash
WHERE sample_time >= SYSDATE - INTERVAL '60' MINUTE
;

-- Active Sessions (in ASH) Per Session State excluding BACKGROUND processes in Last 24 Hours.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time   FORMAT a19
COLUMN session_state FORMAT a15

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH ash AS
(
  SELECT TRUNC(sample_time, 'hh24') sample_time
         -- TO_CHAR(CAST(sample_time AS DATE), 'yyyy-mm-dd hh24:mi') sample_time
       , session_state
       , ROUND(COUNT(*)/36e2, 4) active_sessions
  FROM v$active_session_history
  WHERE session_type = 'FOREGROUND'  -- excluding background processes
  GROUP BY TRUNC(sample_time, 'hh24')
           -- TO_CHAR(CAST(sample_time AS DATE), 'yyyy-mm-dd hh24:mi')
         , session_state
  ORDER BY session_state
         , sample_time
)
SELECT * FROM ash
WHERE sample_time >= SYSDATE - INTERVAL '24' HOUR
;

-- Active Sessions (in ASH) Per Session State including BACKGROUND processes in Last 24 Hours.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN sample_time   FORMAT a19
COLUMN session_state FORMAT a15

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH ash AS
(
  SELECT TRUNC(sample_time, 'hh24') sample_time
         -- TO_CHAR(CAST(sample_time AS DATE), 'yyyy-mm-dd hh24:mi') sample_time
       , session_state
       , ROUND(COUNT(*)/36e2, 4) active_sessions
  FROM v$active_session_history
  WHERE session_type IN ('BACKGROUND', 'FOREGROUND')  -- including background processes
  GROUP BY TRUNC(sample_time, 'hh24')
           -- TO_CHAR(CAST(sample_time AS DATE), 'yyyy-mm-dd hh24:mi')
         , session_state
  ORDER BY session_state
         , sample_time
)
SELECT * FROM ash
WHERE sample_time >= SYSDATE - INTERVAL '24' HOUR
;
