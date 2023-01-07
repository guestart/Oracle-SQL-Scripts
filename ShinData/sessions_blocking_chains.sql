REM
REM     Script:        sessions_blocking_chains.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 03, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking which sessions (including all blockers and waiters) caused blocking chains on oracle database.
REM

select inst_id,
       sid,
       serial,
       event,
       status,
       tree,
       tree_level
from (select a.inst_id,
             a.sid,
             a.serial# as serial,
             a.sql_id,
             a.event,
             a.status,
             connect_by_isleaf as isleaf,
             sys_connect_by_path(a.sid||','||a.serial#||'@'||a.inst_id, ' <- ') tree,
             level as tree_level
      from gv$session a
      start with a.blocking_session is not null
      connect by (a.sid||'@'||a.inst_id) = prior (a.blocking_session||'@'||a.blocking_instance)
     ) t 
where sql_id is null
order by tree_level asc;

-- 1	1153	45130	SQL*Net message from client	INACTIVE	 <- 401,48708@1 <- 1153,45130@1	2
-- 1	1153	45130	SQL*Net message from client	INACTIVE	 <- 1169,10379@1 <- 1153,45130@1 2
