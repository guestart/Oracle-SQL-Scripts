rem
rem     Script:        ash_event_count_topN_new.sql
rem     Author:        Quanwen Zhao
rem     Dated:         Apr 25, 2018
rem
rem     Purpose:  
rem     This sql script usually statistics Top-N event counts,
rem     and when it runs you can only input 3 parameters - start_time you want to appoint,
rem     end_time and num that is Top ROWNUM.
rem
rem     Modified:      May 08, 2018 - adding the justify center to the column "session_state", "blocking_session" and "blocking_session_serial#" 
rem                                   for running nicely; at the same time, also adding some interactive and friendly prompts when inputing 3 
rem                                   parameters.

set linesize 400
set pagesize 300

set verify off

column  event                     format  a40
column  wait_class                format  a15
column  session_state             heading "session|state"             format  a15       justify  center
column  blocking_session          heading "blocking|session"          format  99999999  justify  center
column  blocking_session_serial#  heading "blocking|session|serial#"  format  99999999  justify  center

prompt Enter begin time ([YYYY-MM-DD HH24:MI:SS]):
prompt Examples: 2018-03-13 11:20:00
prompt 
prompt Enter end time ([YYYY-MM-DD HH24:MI:SS]):
prompt Examples: 2018-03-13 11:30:00
prompt 
prompt Enter nums of Top-N ROWNUM:
prompt Examples: 15, 25 or 35 ...
prompt 

select *
from
( select event
         , wait_class
         , session_state
         , blocking_session
         , blocking_session_serial#
         , count(*)
  from v$active_session_history
  where sample_time between to_date('&start_time','yyyy-mm-dd hh24:mi:ss')
        and to_date('&end_time','yyyy-mm-dd hh24:mi:ss')
  group by event
           , wait_class
           , session_state
           , blocking_session
           , blocking_session_serial#
  order by count(*) desc, event
)
where rownum <= &num;
