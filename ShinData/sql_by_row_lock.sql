REM
REM     Script:        sql_by_row_lock.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 03, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking which sql statements (including all blockers and waiters) caused row lock on oracle database.
REM

-- Row Lock by Waiters:

SELECT distinct s.SQL_ID,
       substr(t.SQL_TEXT,0,1000) as sql_text
FROM gv$session s, gv$lock l, gv$LOCKED_OBJECT lo, dba_objects do, v$sqlstats t
WHERE s.blocking_session IS NOT NULL
AND s.BLOCKING_INSTANCE = l.inst_id
AND s.blocking_session = l.sid
AND t.SQL_ID = s.SQL_ID
AND l.block > 0
AND s.sid = lo.session_id
AND lo.object_id = do.object_id;

-- Row Lock by Blockers:

SELECT distinct s.SQL_ID,
       substr(t.SQL_TEXT,0,1000) as sql_text
FROM gv$session s, gv$lock l, gv$LOCKED_OBJECT lo, dba_objects do, v$sqlstats t
WHERE s.blocking_session IS NULL
AND s.BLOCKING_INSTANCE = l.inst_id
AND s.blocking_session = l.sid
AND t.SQL_ID = s.SQL_ID
AND l.block > 0
AND s.sid = lo.session_id
AND lo.object_id = do.object_id;
