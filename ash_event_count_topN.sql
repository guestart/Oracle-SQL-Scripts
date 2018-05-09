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

SET LINESIZE 400
SET PAGESIZE 300

COLUMN  event                     FORMAT  a40
COLUMN  wait_class                FORMAT  a15
COLUMN  session_state             FORMAT  a10     HEADING "session|  state"
COLUMN  blocking_session          FORMAT  999999  HEADING "blocking|session"
COLUMN  blocking_session_serial#  FORMAT  9999999 HEADING "blocking|session|serial#"

SELECT *
FROM
( SELECT event
         , wait_class
         , session_state
         , blocking_session
         , blocking_session_serial#
         , count(*)
  FROM v$active_session_history
  WHERE sample_time BETWEEN to_date('&start_time','yyyy-mm-dd hh24:mi:ss')
        AND to_date('&end_time','yyyy-mm-dd hh24:mi:ss')
  GROUP BY event
           , wait_class
           , session_state
           , blocking_session
           , blocking_session_serial#
  ORDER BY count(*) DESC, event
)
WHERE rownum <= &num;


-- The following is an example when you execute it on your oracle db server.

Enter value for start_time: 2018-04-24 12:00:00
old  10:   WHERE sample_time BETWEEN to_date('&start_time','yyyy-mm-dd hh24:mi:ss')
new  10:   WHERE sample_time BETWEEN to_date('2018-04-24 12:00:00','yyyy-mm-dd hh24:mi:ss')
Enter value for end_time: 2018-04-24 13:00:00
old  11:         AND to_date('&end_time','yyyy-mm-dd hh24:mi:ss')
new  11:         AND to_date('2018-04-24 13:00:00','yyyy-mm-dd hh24:mi:ss')
Enter value for num: 20
old  19: WHERE rownum <= &num
new  19: WHERE rownum <= 20

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
