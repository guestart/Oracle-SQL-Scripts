REM
REM     Script:        lock_waitevent.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Aug 12, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking lock related wait event situation in recent 1 hour on oracle database.
REM

SELECT inst_id,
       TRUNC(sample_time, 'mi') sample_time,
       event,
       COUNT(*) AS wait_count
FROM gv$active_session_history
WHERE event IN ('enq: TX - row lock contention', 'row cache lock', 'library cache lock', 'enq: TM - contention', 'library cache pin')
AND session_type = 'FOREGROUND'
AND sample_time BETWEEN sysdate - INTERVAL '1' HOUR AND sysdate
GROUP BY inst_id,
         TRUNC(sample_time, 'mi'),
         event
ORDER BY inst_id,
         sample_time,
         event;
