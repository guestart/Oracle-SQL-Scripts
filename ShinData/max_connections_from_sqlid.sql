REM
REM     Script:        max_connections_from_sqlid.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Oct 29, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Finding out which sql_id occupied the max connections from view v$session of oracle database.
REM

select * from (
select username,
       machine,
       sql_id,
       count(*)
from v$session
group by username,
         machine,
         sql_id
order by count(*) desc
) where rownum <= 20;
