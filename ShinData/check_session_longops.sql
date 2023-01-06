REM
REM     Script:        check_session_longops.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Dec 03, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the oracle task running for a long time and the percentage of progress completed.
REM

set linesize 300
set pagesize 100
set trimspool on

col message for a40 word_wrap
col perc for 990.00
col mins for 9,990.00

alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS';

select sid,
       serial#,
       start_time,
       time_remaining,
       round(time_remaining/60) as mins,
       round(sofar/totalwork, 2) * 100 as perc,
       message
from v$session_longops
where time_remaining > 0
order by 1, 2, 3;
