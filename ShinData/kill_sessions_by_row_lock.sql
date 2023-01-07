REM
REM     Script:        kill_sessions_by_row_lock.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 03, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Generating kill session statements of row lock on oracle database.
REM

select 'alter system kill session ''' || s.sid ||',' || s.serial# || ''';' kill_session
from v$process p, v$session s, v$locked_object l, dba_objects o
where p.addr = s.paddr
and s.sid = l.session_id
and l.object_id = o.object_id;

-- alter system kill session '1153,45130';
-- alter system kill session '401,48708';
-- alter system kill session '1169,10379';
