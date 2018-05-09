rem
rem     Script:        ash_event_count_topN_new.sql
rem     Author:        Quanwen Zhao
rem     Dated:         Apr 25, 2018
rem
rem     Purpose:  
rem     This sql script usually statistics Top-N event counts,
rem     and when it runs you can only input 3 parameters - start_time you want to appoint,
rem     end_time and num that is Top ROWNUM.
rem
rem     Modified:      May 08, 2018 - adding the justify center to the column "session_state", "blocking_session" and "blocking_session_serial#" 
rem                                   for running nicely; at the same time, also adding some interactive and friendly prompts when inputing 3 
rem                                   parameters.

SET LINESIZE 400
SET PAGESIZE 300

SET verify OFF

COLUMN  event                     FORMAT  a40
COLUMN  wait_class                FORMAT  a15
COLUMN  session_state             HEADING  "session|state"             FORMAT  a15       JUSTIFY  center
COLUMN  blocking_session          HEADING  "blocking|session"          FORMAT  99999999  JUSTIFY  center
COLUMN  blocking_session_serial#  HEADING  "blocking|session|serial#"  FORMAT  99999999  JUSTIFY  center

prompt Enter begin time ([YYYY-MM-DD HH24:MI:SS]):
prompt Examples: 2018-03-13 11:20:00
prompt 
prompt Enter end time ([YYYY-MM-DD HH24:MI:SS]):
prompt Examples: 2018-03-13 11:30:00
prompt 
prompt Enter nums of Top-N ROWNUM:
prompt Examples: 15, 25 or 35 ...
prompt 

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
