REM
REM     Script:        ash_event_count_topN_new.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Apr 25, 2018
REM
REM     Purpose:  
REM       This sql script usually statistics Top-N event counts,
REM       and when it runs you can only input 3 parameters - start_time you want to appoint,
REM       end_time and num that is Top ROWNUM.
REM
REM     Modified:      May 08, 2018 - adding the justify center to the column "session_state", "blocking_session" and "blocking_session_serial#" 
REM                                   for running nicely; at the same time, also adding some interactive and friendly prompts when inputing 3 
REM                                   parameters.
REM                    May 09, 2018 - replace all of keywords (whatever SQL*Plus or SQL exclusive use) with uppercase.
REM

SET LINESIZE 400
SET PAGESIZE 300

SET VERIFY OFF

COLUMN  event                     FORMAT  a40
COLUMN  wait_class                FORMAT  a15
COLUMN  session_state             HEADING  "session|state"             FORMAT  a15       JUSTIFY  center
COLUMN  blocking_session          HEADING  "blocking|session"          FORMAT  99999999  JUSTIFY  center
COLUMN  blocking_session_serial#  HEADING  "blocking|session|serial#"  FORMAT  99999999  JUSTIFY  center

PROMPT Enter begin time ([YYYY-MM-DD HH24:MI:SS]):
PROMPT Examples: 2018-03-13 11:20:00
PROMPT 
PROMPT Enter end time ([YYYY-MM-DD HH24:MI:SS]):
PROMPT Examples: 2018-03-13 11:30:00
PROMPT 
PROMPT Enter nums of Top-N ROWNUM:
PROMPT Examples: 15, 25 or 35 ...
PROMPT 

SELECT *
FROM
( SELECT event
         , wait_class
         , session_state
         , blocking_session
         , blocking_session_serial#
         , count(*)
  FROM v$active_session_history
  WHERE sample_time BETWEEN to_date('&start_time','yyyy-mm-dd hh24:mi:ss')
        AND to_date('&end_time','yyyy-mm-dd hh24:mi:ss')
  GROUP BY event
           , wait_class
           , session_state
           , blocking_session
           , blocking_session_serial#
  ORDER BY count(*) DESC
           , event
)
WHERE rownum <= &num
;
