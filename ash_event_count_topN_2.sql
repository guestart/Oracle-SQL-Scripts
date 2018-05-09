rem
rem     Script:        ash_event_count_topN_2.sql
rem     Author:        Quanwen Zhao
rem     Dated:         Apr 28, 2018
rem
rem     Purpose:   
rem       This sql script usually statistics wait events' Top-N counts 
rem       during a period of time when you have found performance problem,
rem       If you runs it and can only input 3 parameters, they're as follows
rem       in order:
rem        (1) BEGIN_TIME you want to begin,
rem        (2) END_TIME you want to end,
rem        (3) NUMS that comes from Top ROWNUM.
rem

set linesize 400
set pagesize 300

-- whether displaying the statement which substitute variables have been replaced before and after 
set verify off

-- First, show the oldest and the latest ASH samples available
define   ash_time_format = 'yyyy-mm-dd hh24:mi:ss';
variable oldest_sample   varchar2(30);
variable latest_sample   varchar2(30);

whenever sqlerror exit;
declare
  oldest_mem     date := NULL;
  latest_mem     date := NULL;

begin

  select min(sample_time), max(sample_time)
  into   oldest_mem, latest_mem
  from v$active_session_history;

  if (oldest_mem is null OR latest_mem is null) then
    raise_application_error(-20200,
      'No ASH sample exist for Oracle Database');
  end if;
  
  :oldest_sample := to_char(oldest_mem, '&&ash_time_format');
  :latest_sample := to_char(latest_mem, '&&ash_time_format');
  
end;
/
whenever sqlerror continue;

prompt
prompt
prompt Statistics wait events' Top-N counts from ASH Samples
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set heading off
select 'Oldest ASH sample available: ' 
       || :oldest_sample 
       || ' [' 
       || (to_char((sysdate - to_date(:oldest_sample, '&&ash_time_format'))*1440,'99999')) 
       || ' mins in the past ]' 
       || chr(10) 
       || chr(13),
       'Latest ASH sample available: ' 
       || :latest_sample 
       || ' [' 
       || (to_char((sysdate - to_date(:latest_sample, '&&ash_time_format'))*1440,'99999')) 
       || ' mins in the past ]'
from   dual;
set heading on

prompt
prompt Specify the periods of time for statisticing wait events' Top-N counts
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Set up the binds for b_time, e_time and num
-- variable b_time varchar2(30);
-- variable e_time varchar2(30); 
-- variable num number;

rem
rem Get begin_time
rem ==============
prompt Enter begin time for ASH sample:
prompt
prompt --    Valid input formats:
prompt --      To specify absolute begin time:
prompt --        [YYYY-MM-DD HH24:MI:SS]
prompt --        Examples: 2018-03-13 11:20:00
prompt
prompt Report begin time specified: &&begin_time
prompt

rem
rem Get end_time
rem ============
prompt Enter end time for ASH sample:
prompt
prompt --    Valid input formats:
prompt --      To specify absolute end time:
prompt --        [YYYY-MM-DD HH24:MI:SS]
prompt --        Examples: 2018-03-13 11:30:00
prompt
prompt Report end time specified: &&end_time
prompt

rem
rem Get nums of Top-N ROWNUM
rem ========================
prompt Enter nums of Top-N ROWNUM for ASH query:
prompt
prompt --    Valid input formats:
prompt --        Examples: 25
prompt --    Recommendation: 
prompt --      You only need input two digit and its range is from [00] to [99],
prompt --      please trying to input less than 50 that is ok.
prompt
prompt Report Top-Number specified: &nums
prompt

-- exec :b_time := &begin_time;
-- exec :e_time := &end_time;
-- exec :num := &&nums

-- setting the separators of the title column
-- set colsep   '|'

column  event                     format  a40
column  wait_class                format  a15
column  session_state             heading "session|state"             format  a15       justify  center
column  blocking_session          heading "blocking|session"          format  99999999  justify  center
column  blocking_session_serial#  heading "blocking|session|serial#"  format  99999999  justify  center

select *
from
( select event
         , wait_class
         , session_state
         , blocking_session
         , blocking_session_serial#
         , count(*)
  from v$active_session_history
  where sample_time between to_date('&&begin_time','yyyy-mm-dd hh24:mi:ss')
        and to_date('&&end_time','yyyy-mm-dd hh24:mi:ss')
  group by event
           , wait_class
           , session_state
           , blocking_session
           , blocking_session_serial#
  order by count(*) desc, event
)
where rownum <= &&nums;


-- Execution Results output as follows:


Statistics wait events' Top-N counts from ASH Samples
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Oldest ASH sample available: 2018-04-23 21:03:26 [  6876 mins in the past ]

Latest ASH sample available: 2018-04-28 15:39:18 [     0 mins in the past ]



Specify the periods of time for statisticing wait events' Top-N counts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Enter begin time for ASH sample:

--    Valid input formats:
--      To specify absolute begin time:
--        [YYYY-MM-DD HH24:MI:SS]
--        Examples: 2018-03-13 11:20:00

Enter value for begin_time: 2018-04-26 12:00:00  <<== input manually
Report begin time specified: 2018-04-26 12:00:00

Enter end time for ASH sample:

--    Valid input formats:
--      To specify absolute end time:
--        [YYYY-MM-DD HH24:MI:SS]
--        Examples: 2018-03-13 11:30:00


Enter value for end_time: 2018-04-26 12:40:00  <<== input manually
Report end time specified: 2018-04-26 12:40:00

Enter nums of Top-N ROWNUM for ASH query:

--    Valid input formats:
--        Examples: 25
--    Recommendation:
--      You only need input two digit and its range is from [00] to [99],
--      please trying to input less than 50 that is ok.


Enter value for nums: 15 <<== input manually
Report Top-Number specified: 15


                                                                                   blocking
                                                             session     blocking   session
EVENT                                    WAIT_CLASS           state       session   serial#    COUNT(*)
---------------------------------------- --------------- --------------- --------- --------- ----------
                                                         ON CPU                                    8055
log file sync                            Commit          WAITING              2687         1       5973
log file parallel write                  System I/O      WAITING                                   1075
db file async I/O submit                 System I/O      WAITING                                    307
SQL*Net message from dblink              Network         WAITING                                    112
library cache: mutex X                   Concurrency     WAITING                                     88
LNS wait on SENDREQ                      Network         WAITING                                     54
null event                               Other           WAITING                                     50
latch: shared pool                       Concurrency     WAITING                                     48
control file parallel write              System I/O      WAITING                                     25
flashback log file write                 System I/O      WAITING                                     22
db file sequential read                  User I/O        WAITING                                     19
SQL*Net more data from client            Network         WAITING                                     13
library cache: mutex X                   Concurrency     WAITING              1351      3651         10
db file parallel write                   System I/O      WAITING                                      8

15 rows selected.
