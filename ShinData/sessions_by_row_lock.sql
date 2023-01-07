REM
REM     Script:        sessions_by_row_lock.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 03, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking which sessions (including all blockers and waiters) caused row lock on oracle database.
REM

select p.spid,
       s.sid,
       s.serial#,
       l.oracle_username,
       s.machine,
       s.program,
       o.object_name
from v$process p, v$session s, v$locked_object l, dba_objects o
where p.addr = s.paddr
and s.sid = l.session_id
and l.object_id = o.object_id;
