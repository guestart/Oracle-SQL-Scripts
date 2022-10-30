==============================================================================================================
-- Script: poor_parsing_applications_rank_top_5_sql_on_sqlstats.sql
-- Author: Quanwen Zhao
-- Updated: May 17, 2019
-- Modified: Oct 30, 2022 (modified v$sql to v$sqlstats)
-- Ranking Top 5 SQL for poor parsing applications (parse_calls/executions) on v$sqlstats
-- parse_calls, Number of parse calls for all cursors with this SQL text and plan
-- executions, Number of executions that took place on this object since it was brought into the library cache
-- Trying not to check v$sql, as you can see Connor's this blog post
-- https://connor-mcdonald.com/2019/03/04/less-slamming-vsql/
==============================================================================================================

SET LINESIZE 32767
SET PAGESIZE 50000

COLUMN sql_id FORMAT a13
COLUMN sql_text FORMAT a70
COLUMN parse_calls/executions FORMAT 999,999,999,999,999 HEADING 'parse_calls|executions'
COLUMN parse_app_rank FORMAT 999 HEADING 'parse_app|rank'

SELECT *
FROM (SELECT sql_id
             , sql_text
             , parse_calls/executions
             , DENSE_RANK() OVER (ORDER BY DECODE(executions, 0, 0, parse_calls / executions) DESC) AS parse_app_rank
      FROM v$sqlstats
      WHERE DECODE(executions, 0, 0, parse_calls / executions) > 1
     )
WHERE parse_app_rank <= 5
/

SET LINESIZE 80
SET PAGESIZE 14
