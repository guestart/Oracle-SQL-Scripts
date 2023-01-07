REM
REM     Script:        log_buffer_space_avg_wait_time.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Oct 29, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Finding out average wait time (ms) of wait event 'log buffer space'
REM       in recent 1 hour from view gv$active_session_history of oracle database.
REM

set linesize 200
set pagesize 100

column sample_time format a19
column event       format a30

select to_char(sample_time,'yyyy-mm-dd hh24:mi:ss') sample_time,
       inst_id,
       event,
       sum(time_waited)/1000 TOTAL_WAIT_TIME,
       count(*) WAITS,
       avg(time_waited)/1000 AVG_TIME_WAITED
from gv$active_session_history
where sample_time >= SYSDATE - INTERVAL '60' minute
and event = 'log buffer space'
group by to_char(sample_time,'yyyy-mm-dd hh24:mi:ss'),
         inst_id,
         event
order by 1,2;
