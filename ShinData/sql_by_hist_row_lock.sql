REM
REM     Script:        sql_by_hist_row_lock.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 03, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking which sql statements caused history row lock in recent 1 hour on oracle database.
REM

select distinct h.inst_id,
       h.sql_id,
       substr(s.sql_text, 0, 1000) as sql_text
from gv$active_session_history h, v$sqlstats s
where h.sql_id = s.sql_id
and h.sample_time between sysdate - INTERVAL '60' minute and sysdate
and h.event = 'enq: TX - row lock contention'
order by 1, 2;
