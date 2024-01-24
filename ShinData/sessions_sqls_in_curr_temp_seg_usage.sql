REM
REM     Script:        sessions_sqls_in_curr_temp_seg_usage.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 03, 2022
REM     Updated:       Jan 24, 2024
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the sessions and sql statements that occupied by temporary tablespace of oracle database.
REM

-- before 11g:

select * from (
select k.inst_id "INST_ID",
       s.sid,
       k.ktssosno "SERIAL#",
       s.username "USERNAME",
       ts.name,
       s.osuser "OSUSER", 
       k.ktssosqlid "SQL_ID",
       substr(ss.sql_text, 1, 1000) "SQL_TEXT",
       decode(k.ktssocnt, 0, 'PERMANENT', 1, 'TEMPORARY') "CONTENTS",
       decode(k.ktssosegt, 1, 'SORT', 2, 'HASH', 3, 'DATA', 4, 'INDEX', 5, 'LOB_DATA', 6, 'LOB_INDEX' , 'UNDEFINED') "SEGTYPE",
       round(k.ktssoblks * p.value / 1024 / 1024, 2) "SIZE_MB"
from x$ktsso k, v$session s, (select value from v$parameter where name='db_block_size') p, ts$ ts, v$sqlstats ss
where k.ktssoses = s.saddr
and k.ktssosno = s.serial#
and k.ktssotsn = ts.ts#  -- here
and k.ktssosqlid = ss.sql_id
and s.usernamem is not null
and not exists (select * from (SELECT username
                               FROM dba_users
                               WHERE created < (SELECT created FROM v$database)
                              ) u
                where s.username = u.username
               )
order by size_mb desc
) where rownum <= 30;

-- after 12c:

select * from (
select k.inst_id "INST_ID",
       s.sid,
       k.ktssosno "SERIAL#",
       s.username "USERNAME",
       ts.name,
       s.osuser "OSUSER", 
       k.ktssosqlid "SQL_ID",
       substr(ss.sql_text, 1, 1000) "SQL_TEXT",
       decode(ts.contents$, 0, 'PERMANENT', 1, 'TEMPORARY') "CONTENTS",
       decode(k.ktssosegt, 1, 'SORT', 2, 'HASH', 3, 'DATA', 4, 'INDEX', 5, 'LOB_DATA', 6, 'LOB_INDEX' , 'UNDEFINED') "SEGTYPE",
       round(k.ktssoblks * p.value / 1024 / 1024, 2) "SIZE_MB"
from x$ktsso k, v$session s, (select value from v$parameter where name='db_block_size') p, ts$ ts, v$sqlstats ss
where k.ktssoses = s.saddr
and k.ktssosno = s.serial#
and k.ktssotsnum = ts.ts#  -- here
and k.ktssosqlid = ss.sql_id
and s.username is not null
and not exists (select * from (SELECT username
                               FROM dba_users
                               WHERE created < (SELECT created FROM v$database)
                              ) u
                where s.username = u.username
               )
order by size_mb desc
) where rownum <= 30;
