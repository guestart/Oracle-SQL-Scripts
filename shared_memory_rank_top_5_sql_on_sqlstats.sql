===============================================================================================
-- Ranking Top 5 SQL for shared memory (Memory hogs) on v$sqlstats
-- Total shared memory (in bytes) currently occupied by all cursors with this SQL text and plan
-- Trying not to check v$sql, as you can see Connor's this blog post
-- https://connor-mcdonald.com/2019/03/04/less-slamming-vsql/
===============================================================================================
set linesize 32767
set pagesize 50000
col sql_id for a13
col sql_text for a60
col sharable_mem for 999,999,999,999,999
select *
from (select sql_id, sql_text, sharable_mem,
             dense_rank() over (order by sharable_mem desc) sharable_mem_rank
      from v$sqlstats
      where sharable_mem > 10000000
     )
where sharable_mem_rank <= 5;
set linesize 80
set pagesize 14
