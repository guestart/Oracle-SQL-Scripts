==============================================================================================================
-- Ranking Top 5 SQL for poor parsing applications (parse_calls/executions) on v$sqlstats
-- parse_calls, Number of parse calls for all cursors with this SQL text and plan
-- executions, Number of executions that took place on this object since it was brought into the library cache
-- Trying not to check v$sql, as you can see Connor's this blog post
-- https://connor-mcdonald.com/2019/03/04/less-slamming-vsql/
==============================================================================================================
set linesize 32767
set pagesize 50000
col sql_id for a13
col sql_text for a70
col parse_calls/executions for 999,999,999,999,999 heading 'parse_calls|executions'
col parse_app_rank for 999 heading 'parse_app|rank'
select *
from (select sql_id, sql_text, parse_calls/executions,
      dense_rank() over (order by decode(executions,0,0,parse_calls/executions) desc) parse_app_rank
      from v$sql
      where decode(executions,0,0,parse_calls/executions) > 1
     )
where parse_app_rank <= 5;
set linesize 80
set pagesize 14
