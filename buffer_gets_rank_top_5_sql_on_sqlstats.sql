====================================================================
-- Script: buffer_gets_rank_top_5_sql_on_sqlstats.sql
-- Author: Quanwen Zhao
-- Updated: May 17, 2019
-- Ranking Top 5 SQL for buffer_gets (High CPU) on v$sqlstats
-- Number of buffer gets for all cursors with this SQL text and plan
-- Trying not to check v$sql, as you can see Connor's this blog post
-- https://connor-mcdonald.com/2019/03/04/less-slamming-vsql/
====================================================================

SET LINESIZE 32767
SET PAGESIZE 50000

COLUMN sql_id FORMAT a13
COLUMN sql_text FORMAT a60
COLUMN buffer_gets FORMAT 999,999,999,999,999

SELECT *
FROM (SELECT sql_id
             , sql_text
             , buffer_gets
             , DENSE_RANK() OVER (ORDER BY buffer_gets DESC) AS buffer_gets_rank
      FROM v$sqlstats
      WHERE buffer_gets > 1000000
     )
WHERE buffer_gets_rank <= 5
/

SET LINESIZE 80
SET PAGESIZE 14
