REM
REM     Script:        sessions_hist_blocking_chains.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 03, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking which sessions (including all blockers and waiters) caused history blocking chains in recent 1 hour on oracle database.
REM

with ash as (
select *
  from gv$active_session_history
 where sample_time between sysdate - interval '60' minute and sysdate),
ash2 as (
select sample_time,inst_id,session_id,session_serial#,sql_id,sql_opname,
       event,blocking_inst_id,blocking_session,blocking_session_serial#,
       level lv,
       connect_by_isleaf isleaf,
   sys_connect_by_path(inst_id||'_'||session_id||','||session_serial#||':'||sql_id||':'||sql_opname,'->') lock_chain,
       sys_connect_by_path(EVENT,',') EVENT_CHAIN ,
       connect_by_root(inst_id||'_'||session_id||','||session_serial#) root_sess
  from ash
  -- start with event like 'enq: TX - row lock contention%'
 start with blocking_session is not null
 connect by nocycle 
        prior blocking_inst_id=inst_id
    and prior blocking_session=session_id
    and prior blocking_session_serial#=session_serial#
    and prior sample_id=sample_id)
select lock_chain lock_chain,
       case when blocking_session is not null then blocking_inst_id||'_'||blocking_session||','||blocking_session_serial# else inst_id||'_'||session_id||','||session_serial# end blocking_header, EVENT_CHAIN,
       count(*) cnt,
       TO_CHAR(min(sample_time),'YYYYMMDD HH24:MI:ss') first_seen,
       TO_CHAR(max(sample_time),'YYYYMMDD HH24:MI:ss') last_seen
   from ash2
  where isleaf=1
group by lock_chain,EVENT_CHAIN,case when blocking_session is not null then blocking_inst_id||'_'||blocking_session||','||blocking_session_serial# else inst_id||'_'||session_id||','||session_serial# end
having count(*)>1
order by first_seen, cnt desc;

-- ->1_791,3173:gzjxwfz7rjhhx:UPDATE	1_20,19233	,enq: TX - row lock contention	309	20221028 14:03:59	20221028 14:09:07
-- ->1_15,36283:gzjxwfz7rjhhx:UPDATE	1_20,19233	,enq: TX - row lock contention	305	20221028 14:04:02	20221028 14:09:06
