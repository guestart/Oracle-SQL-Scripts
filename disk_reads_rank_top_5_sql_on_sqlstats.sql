====================================================================
-- Ranking Top 5 SQL for disk_reads (High I/O) on v$sqlstats
-- Number of disk reads for all cursors with this SQL text and plan
-- Trying not to check v$sql, as you can see Connor's this blog post
-- https://connor-mcdonald.com/2019/03/04/less-slamming-vsql/
====================================================================
set linesize 32767
set pagesize 50000
col sql_id for a13
col sql_text for a70
col disk_reads for 999,999,999,999,999
select *
from (select sql_id, sql_text, disk_reads,
      dense_rank() over (order by disk_reads desc) disk_reads_rank
      from v$sql
      where disk_reads > 100000
     )
where disk_reads_rank <= 5;
set linesize 80
set pagesize 14
