rem
rem     Script:        ash_event_count_topN.sql
rem     Author:        Quanwen Zhao
rem     Dated:         Apr 25,2018
rem
rem     Purpose:  
rem     This sql script usually statistics Top-N event counts,
rem     and when it runs you can only input 3 parameters - start_time you want to appoint,
rem     end_time and num that is Top ROWNUM.
rem

set linesize 400
set pagesize 300

column  sql_id                    format  a13
column  event                     format  a40
column  wait_class                format  a15
column  session_state             format  a10     heading "session|  state"
column  blocking_session          format  999999  heading "blocking|session"
column  blocking_session_serial#  format  9999999 heading "blocking|session|serial#"

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


-- The following is an example when you execute it on your oracle db server.

SQL> set linesize 400
SQL> set pagesize 300
SQL> 
SQL> column  sql_id                    format  a13
SQL> column  event                     format  a40
SQL> column  wait_class                format  a15
SQL> column  session_state             format  a10   heading "session|  state"
SQL> column  blocking_session          format  999999  heading "blocking|session"
SQL> column  blocking_session_serial#  format  9999999 heading "blocking|session|serial#"
SQL> 
SQL> select *
  2  from
  3  ( select event
  4           , wait_class
  5           , session_state
  6           , blocking_session
  7           , blocking_session_serial#
  8           , count(*)
  9    from v$active_session_history
 10    where sample_time between to_date('&start_time','yyyy-mm-dd hh24:mi:ss')
 11          and to_date('&end_time','yyyy-mm-dd hh24:mi:ss')
 12    group by event
 13             , wait_class
 14             , session_state
 15             , blocking_session
 16             , blocking_session_serial#
 17    order by count(*) desc, event
 18  )
 19  where rownum <= &num;
Enter value for start_time: 2018-04-24 12:00:00
old  10:   where sample_time between to_date('&start_time','yyyy-mm-dd hh24:mi:ss')
new  10:   where sample_time between to_date('2018-04-24 12:00:00','yyyy-mm-dd hh24:mi:ss')
Enter value for end_time: 2018-04-24 13:00:00
old  11:         and to_date('&end_time','yyyy-mm-dd hh24:mi:ss')
new  11:         and to_date('2018-04-24 13:00:00','yyyy-mm-dd hh24:mi:ss')
Enter value for num: 20
old  19: where rownum <= &num
new  19: where rownum <= 20

                                                                             blocking
                                                         session    blocking  session
EVENT                                    WAIT_CLASS        state     session  serial#   COUNT(*)
---------------------------------------- --------------- ---------- -------- -------- ----------
                                                         ON CPU                            13296
log file sync                            Commit          WAITING        2687        1      12856
log file switch (checkpoint incomplete)  Configuration   WAITING        2687        1       2663
log file parallel write                  System I/O      WAITING                            1504
db file async I/O submit                 System I/O      WAITING                            1319
library cache: mutex X                   Concurrency     WAITING                             546
latch: shared pool                       Concurrency     WAITING                             128
SQL*Net message from dblink              Network         WAITING                             120
LNS wait on SENDREQ                      Network         WAITING                              77
control file parallel write              System I/O      WAITING                              52
null event                               Other           WAITING                              43
db file sequential read                  User I/O        WAITING                              33
flashback log file write                 System I/O      WAITING                              29
library cache: mutex X                   Concurrency     WAITING        8934     1385         25
library cache: mutex X                   Concurrency     WAITING       11071    11291         25
Log archive I/O                          System I/O      WAITING                              19
library cache: mutex X                   Concurrency     WAITING       10673    43577         19
SQL*Net more data from client            Network         WAITING                              17
library cache: mutex X                   Concurrency     WAITING       10829    34173         16
db file parallel write                   System I/O      WAITING                              15

20 rows selected.
