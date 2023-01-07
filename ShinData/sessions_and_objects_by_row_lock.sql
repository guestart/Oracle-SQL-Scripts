REM
REM     Script:        sessions_and_objects_by_row_lock.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 03, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Finding out sessions and objects that caused row lock in recent 1 hour on oracle database.
REM

select * from (
select to_char(h.sample_time,'yyyy-mm-dd hh24:mi:ss') sample_time,
       h.inst_id,
       h.session_id,
       h.session_serial#,
       h.machine,
       h.program,
       h.current_obj#,
       o.object_name,
       o.object_type,
       h.blocking_session,
       h.blocking_session_serial#,
       h.blocking_inst_id 
from gv$active_session_history h, dba_objects o
where h.current_obj# = o.object_id
and h.sample_time between sysdate - INTERVAL '60' minute and sysdate
and h.event = 'enq: TX - row lock contention'
order by 1 desc, 2
) where rownum <= 30;
