====================================================================
-- Ranking Top 5 SQL for buffer_gets (High CPU) on v$sqlstats
-- Number of buffer gets for all cursors with this SQL text and plan
-- Trying not to check v$sql, as you can see Connor's this blog post
-- https://connor-mcdonald.com/2019/03/04/less-slamming-vsql/
====================================================================
set linesize 32767
set pagesize 50000
col sql_id for a13
col sql_text for a60
col buffer_gets for 999,999,999,999,999
select *
from (select sql_id, sql_text, buffer_gets,
             dense_rank() over (order by buffer_gets desc) buffer_gets_rank
      from v$sqlstats
      where buffer_gets > 1000000
     )
where buffer_gets_rank <= 5
set linesize 80
set pagesize 14
/
