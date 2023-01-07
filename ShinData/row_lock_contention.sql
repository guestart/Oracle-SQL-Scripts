REM
REM     Script:        row_lock_contention.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 03, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking oracle database has been produced row lock in recent 1 hour.
REM

SELECT event,
       wait_class,
       session_state,
       blocking_session,
       blocking_session_serial#,
       count(*)
FROM v$active_session_history
WHERE sample_time BETWEEN sysdate - interval '60' minute AND sysdate
AND event = 'enq: TX - row lock contention'
GROUP BY event,
         wait_class,
         session_state,
         blocking_session,
         blocking_session_serial#
ORDER BY count(*) DESC, event;
