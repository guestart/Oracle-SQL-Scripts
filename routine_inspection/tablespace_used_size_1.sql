REM
REM     Script:        tablespace_used_size_1.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Oct 30, 2019
REM
REM     Purpose:  
REM       This SQL script usually uses to check the used size of tablespace on Oracle Database.
REM

set linesize    10000
set pagesize    10000

COLUMN ts_name  FORMAT a25
COLUMN used_mb  FORMAT 999,999,999.99

WITH a AS (SELECT tablespace_name
                  , SUM(bytes)/1024/1024 AS total
           FROM dba_data_files
           GROUP BY tablespace_name
          ),
     b AS (SELECT tablespace_name
                  , SUM(bytes)/1024/1024 AS free
           FROM dba_free_space
           GROUP BY tablespace_name
          ),
  -- c AS (SELECT tablespace_name
  --              , SUM(bytes)/1024/1024 AS total
  --       FROM dba_temp_files
  --       GROUP BY tablespace_name
  --      ),
     d AS (SELECT tablespace_name
                  , SUM(bytes_cached)/1024/1024 AS used
           FROM v$temp_extent_pool
           GROUP BY tablespace_name
          )
SELECT a.tablespace_name AS ts_name
       , a.total - b.free AS "USED_MB"
FROM a, b
WHERE a.tablespace_name = b.tablespace_name
UNION ALL
SELECT d.tablespace_name AS ts_name
    -- c.tablespace_name AS ts_name
       , d.used AS "USED_MB"
-- FROM c, d
FROM d
-- WHERE c.tablespace_name = d.tablespace_name
ORDER BY 1
/
