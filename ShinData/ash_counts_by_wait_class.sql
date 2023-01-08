REM
REM     Script:        ash_counts_by_wait_class.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 01, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking active session history counts by wait class in recent 1 hour on oracle database.
REM

SELECT trunc(sample_time, 'mi') sample_time,
       sum(decode(session_state, 'ON CPU', 1, 0)) AS "ON CPU",
       sum(decode(session_state, 'WAITING', decode(wait_class, 'Scheduler', 1, 0), 0)) AS "Scheduler",
       sum(decode(session_state, 'WAITING', decode(wait_class, 'User I/O', 1, 0), 0)) AS "User I/O",
       sum(decode(session_state, 'WAITING', decode(wait_class, 'System I/O', 1, 0), 0)) AS "System I/O",
       sum(decode(session_state, 'WAITING', decode(wait_class, 'Concurrency', 1, 0), 0)) AS "Concurrency",
       sum(decode(session_state, 'WAITING', decode(wait_class, 'Application', 1, 0), 0)) AS "Application",
       sum(decode(session_state, 'WAITING', decode(wait_class, 'Commit', 1, 0), 0)) AS "Commit",
       sum(decode(session_state, 'WAITING', decode(wait_class, 'Configuration', 1, 0), 0)) AS "Configuration",
       sum(decode(session_state, 'WAITING', decode(wait_class, 'Administrative', 1, 0), 0)) AS "Administrative",
       sum(decode(session_state, 'WAITING', decode(wait_class, 'Network', 1, 0), 0)) AS "Network",
       sum(decode(session_state, 'WAITING', decode(wait_class, 'Queueing', 1, 0), 0)) AS "Queueing",
       sum(decode(session_state, 'WAITING', decode(wait_class, 'Cluster', 1, 0), 0)) AS "Cluster",
       sum(decode(session_state, 'WAITING', decode(wait_class, 'Other', 1, 0), 0)) AS "Other"
FROM gv$active_session_history
WHERE sample_time >= sysdate - INTERVAL '1' HOUR
GROUP BY trunc(sample_time, 'mi')
ORDER BY trunc(sample_time, 'mi');
