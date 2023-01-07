REM
REM     Script:        check_sql_commits.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Oct 30, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking which sql statements of oracle database has the frequent commits.
REM

set linesize 1000

column sid             for 99999
column program         for a20
column machine         for a20
column logon_time      for date
column wait_class      for a10
column event           for a32
column sql_id          for 9999
column prev_sql_id     for 9999
column WAIT_TIME       for 9999
column SECONDS_IN_WAIT for 9999

with ucs as
(select t1.sid,
        t1.value,
        t2.name
 from v$sesstat t1, v$statname t2
 where t2.name like '%user commits%'
 and t1.statistic# = t2.statistic#
 and t1.value >= 10000
 order by t1.value desc
),
sqlid as
(select s.sid,
        s.program,
        s.event,
        s.logon_time,
        s.wait_time,
        s.seconds_in_wait,
        s.sql_id,
        s.prev_sql_id
 from v$session s, ucs u 
 where s.sid = u.sid
)
select sa.sql_id,
       sa.sql_text,
       sa.executions,
       sa.first_load_time,
       sa.last_load_time
from v$sqlarea sa, sqlid si
where sa.sql_id = si.sql_id;
