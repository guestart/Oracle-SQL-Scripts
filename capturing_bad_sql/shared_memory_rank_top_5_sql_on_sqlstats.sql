===============================================================================================
-- Script: shared_memory_rank_top_5_sql_on_sqlstats.sql
-- Author: Quanwen Zhao
-- Updated: May 17, 2019
-- Ranking Top 5 SQL for shared memory (Memory hogs) on v$sqlstats
-- Total shared memory (in bytes) currently occupied by all cursors with this SQL text and plan
-- Trying not to check v$sql, as you can see Connor's this blog post
-- https://connor-mcdonald.com/2019/03/04/less-slamming-vsql/
===============================================================================================

SET LINESIZE 32767
SET PAGESIZE 50000

COLUMN sql_id FORMAT a13
COLUMN sql_text FORMAT a60
COLUMN sharable_mem FORMAT 999,999,999,999,999

SELECT *
FROM (SELECT sql_id
             , sql_text
             , sharable_mem
             , DENSE_RANK() OVER (ORDER BY sharable_mem DESC) AS sharable_mem_rank
      FROM v$sqlstats
      WHERE sharable_mem > 10000000
     )
WHERE sharable_mem_rank <= 5
/

SET LINESIZE 80
SET PAGESIZE 14
