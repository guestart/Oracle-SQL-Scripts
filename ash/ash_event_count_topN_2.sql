REM
REM     Script:        ash_event_count_topN_2.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Apr 28, 2018
REM
REM     Purpose:   
REM       This sql script usually statistics wait events' Top-N counts 
REM       during a period of time when you have found performance problem,
REM       If you runs it and can only input 3 parameters, they're as follows
REM       in order:
REM        (1) BEGIN_TIME you want to begin,
REM        (2) END_TIME you want to end,
REM        (3) NUMS that comes from Top ROWNUM.
REM
REM     Modified:      May 09, 2018 - replace all of keywords (whatever SQL*Plus or SQL exclusive use) with uppercase.
REM                    May 11, 2018 - adding "set feedback off" for no displaying "PL/SQL procedure successfully completed." when script is running.
REM

SET LINESIZE 400
SET PAGESIZE 300

-- don't displaying the statement which substitute variables have been replaced before and after 
SET VERIFY OFF

-- don't displaying "PL/SQL procedure successfully completed." when script is running
SET FEEDBACK OFF

-- First, show the oldest and the latest ASH samples available
DEFINE   ash_time_format = 'yyyy-mm-dd hh24:mi:ss';
VARIABLE oldest_sample   varchar2(30);
VARIABLE latest_sample   varchar2(30);

WHENEVER sqlerror EXIT;
DECLARE
  oldest_mem     date := NULL;
  latest_mem     date := NULL;

BEGIN

  SELECT min(sample_time), max(sample_time)
  INTO   oldest_mem, latest_mem
  FROM v$active_session_history;

  IF (oldest_mem is null OR latest_mem is null) THEN
    raise_application_error(-20200,
      'No ASH sample exist for Oracle Database');
  END IF;
  
  :oldest_sample := to_char(oldest_mem, '&&ash_time_format');
  :latest_sample := to_char(latest_mem, '&&ash_time_format');
  
END;
/
WHENEVER sqlerror continue;

PROMPT
PROMPT
PROMPT Statistics wait events' Top-N counts from ASH Samples
PROMPT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SET heading OFF
SELECT 'Oldest ASH sample available: ' 
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
FROM   dual;
SET heading ON

PROMPT
PROMPT Specify the periods of time for statisticing wait events' Top-N counts
PROMPT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Set up the binds for b_time, e_time and num
-- variable b_time varchar2(30);
-- variable e_time varchar2(30); 
-- variable num number;

REM
REM Get begin_time
REM ==============
PROMPT Enter begin time for ASH sample:
PROMPT
PROMPT --    Valid input formats:
PROMPT --      To specify absolute begin time:
PROMPT --        [YYYY-MM-DD HH24:MI:SS]
PROMPT --        Examples: 2018-03-13 11:20:00
PROMPT
PROMPT Report begin time specified: &&begin_time
PROMPT

REM
REM Get end_time
REM ============
PROMPT Enter end time for ASH sample:
PROMPT
PROMPT --    Valid input formats:
PROMPT --      To specify absolute end time:
PROMPT --        [YYYY-MM-DD HH24:MI:SS]
PROMPT --        Examples: 2018-03-13 11:30:00
PROMPT
PROMPT Report end time specified: &&end_time
PROMPT

REM
REM Get nums of Top-N ROWNUM
REM ========================
PROMPT Enter nums of Top-N ROWNUM for ASH query:
PROMPT
PROMPT --    Valid input formats:
PROMPT --        Examples: 25
PROMPT --    Recommendation: 
PROMPT --      You only need input two digit and its range is from [00] to [99],
PROMPT --      please trying to input less than 50 that is ok.
PROMPT
PROMPT Report Top-Number specified: &&nums
PROMPT

-- exec :b_time := &begin_time;
-- exec :e_time := &end_time;
-- exec :num := &&nums

-- setting the separators of the title column
-- set colsep   '|'

COLUMN  event                     FORMAT  a40
COLUMN  wait_class                FORMAT  a15
COLUMN  session_state             HEADING  "session|state"             FORMAT  a15       JUSTIFY  center
COLUMN  blocking_session          HEADING  "blocking|session"          FORMAT  99999999  JUSTIFY  center
COLUMN  blocking_session_serial#  HEADING  "blocking|session|serial#"  FORMAT  99999999  JUSTIFY  center

SELECT *
FROM
( SELECT event
         , wait_class
         , session_state
         , blocking_session
         , blocking_session_serial#
         , count(*)
  FROM v$active_session_history
  WHERE sample_time BETWEEN to_date('&&begin_time','yyyy-mm-dd hh24:mi:ss')
        AND to_date('&&end_time','yyyy-mm-dd hh24:mi:ss')
  GROUP BY event
           , wait_class
           , session_state
           , blocking_session
           , blocking_session_serial#
  ORDER BY count(*) DESC
           , event
)
WHERE rownum <= &&nums
;

SET FEEDBACK ON
SET VERIFY ON

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
