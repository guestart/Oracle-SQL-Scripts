REM
REM     Script:     listagg_redo_log_group_members_2.sql
REM     Author:     Quanwen Zhao
REM     Dated:      Jun 04, 2023
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       The SQL script file describes how to listagg oracle redo log members (if it is Oracle Data Guard, also including standby redo log members) in each redo log group using ', '
REM       in order to make them locate on the same line.
REM

set linesize 200
set pagesize 100
column member format a95
with llf as (
select l.thread#,
       l.group#,
       decode(lf.type, 'ONLINE', 'Redo Log') type,
       listagg(lf.member, ', ') within group (order by lf.member) as member,
       l.bytes/1024/1024 size_mb,
       l.status
from v$log l, v$logfile lf
where l.group# = lf.group#
group by l.thread#,
         l.group#,
         decode(lf.type, 'ONLINE', 'Redo Log'),
         l.bytes,
         l.status
order by 1, 2
),
sllf as (
select sl.thread#,
       sl.group#,
       decode(lf.type, 'STANDBY', 'Standby Redo Log') type,
       listagg(lf.member, ', ') within group (order by lf.member) as member,
       sl.bytes/1024/1024 size_mb,
       sl.status
from v$standby_log sl, v$logfile lf
where sl.group# = lf.group#
group by sl.thread#,
         sl.group#,
         decode(lf.type, 'STANDBY', 'Standby Redo Log'),
         sl.bytes,
         sl.status
order by 1, 2
)
select * from llf
union all
select * from sllf;
