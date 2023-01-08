REM
REM     Script:        ash_activity_pct_by_top10sessions.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 03, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking activity percent of top 10 sessions by cpu_time, user_io_time and other_wait_time
REM       from v$active_session_history in recent 1 hour on oracle database.
REM

SELECT * FROM (
SELECT ash.activity_pct,
       ash.session_id,
       u.username,
       ash.program
FROM (SELECT round(100 * ratio_to_report(sum(1)) OVER (), 2) AS activity_pct,
             sum(1) AS db_time,
             sum(decode(session_state, 'ON CPU', 1, 0)) AS cpu_time,
             sum(decode(session_state, 'WAITING', decode(wait_class, 'User I/O', 1, 0), 0)) AS user_io_time,
             sum(decode(session_state, 'WAITING', 1, 0)) - sum(decode(session_state, 'WAITING', decode(wait_class, 'User I/O', 1, 0), 0)) AS wait_time,
             session_id,
             session_serial#,
             user_id,
             program
      FROM gv$active_session_history
      WHERE sample_time >= sysdate - INTERVAL '1' HOUR
      GROUP BY session_id, session_serial#, user_id, program
      ORDER BY activity_pct DESC
) ash, dba_users u
WHERE ash.user_id = u.user_id
) WHERE rownum <= 30;
