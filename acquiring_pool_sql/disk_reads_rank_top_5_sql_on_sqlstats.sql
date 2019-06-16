====================================================================
-- Script: disk_reads_rank_top_5_sql_on_sqlstats.sql
-- Author: Quanwen Zhao
-- Updated: May 17, 2019
-- Ranking Top 5 SQL for disk_reads (High I/O) on v$sqlstats
-- Number of disk reads for all cursors with this SQL text and plan
-- Trying not to check v$sql, as you can see Connor's this blog post
-- https://connor-mcdonald.com/2019/03/04/less-slamming-vsql/
====================================================================

SET LINESIZE 32767
SET PAGESIZE 50000

COLUMN sql_id FORMAT a13
COLUMN sql_text FORMAT a70
COLUMN disk_reads FORMAT 999,999,999,999,999

SELECT *
FROM (SELECT sql_id
             , sql_text
             , disk_reads
             , DENSE_RANK() OVER (ORDER BY disk_reads DESC) AS disk_reads_rank
      FROM v$sql
      WHERE disk_reads > 100000
     )
WHERE disk_reads_rank <= 5
/

SET LINESIZE 80
SET PAGESIZE 14
