REM
REM     Script:        tablespace_utilization_rate.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Oct 30, 2019
REM     Updated:       Nov 01, 2019
REM                    Replacing "SUM(bytes_cached)/1024/1024 AS used" with "SUM(bytes_used)/1024/1024 AS used"
REM                    on table "v$temp_extent_pool".
REM
REM     Purpose:  
REM       This SQL script usually uses to check the utilization rate of all of the tablespace on Oracle Database.
REM

set linesize    10000
set pagesize    10000

COLUMN ts_name  FORMAT a25
COLUMN total_mb FORMAT 999,999,999.99
COLUMN used_mb  FORMAT 999,999,999.99
COLUMN free_mb  FORMAT 999,999,999.99
COLUMN used(%)  FORMAT 999.99

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
     c AS (SELECT tablespace_name
                  , SUM(bytes)/1024/1024 AS total
           FROM dba_temp_files
           GROUP BY tablespace_name
          ),
     d AS (SELECT tablespace_name
 --               , SUM(bytes_cached)/1024/1024 AS used
                  , SUM(bytes_used)/1024/1024 AS used
           FROM v$temp_extent_pool
           GROUP BY tablespace_name
          )
SELECT a.tablespace_name AS ts_name
       , a.total AS "TOTAL_MB"
       , a.total - b.free AS "USED_MB"
       , b.free AS "FREE_MB"
       , ROUND((1-b.free/a.total)*100, 2) AS "USED(%)"
FROM a, b
WHERE a.tablespace_name = b.tablespace_name
UNION ALL
SELECT c.tablespace_name AS ts_name
       , c.total AS "TOTAL_MB"
       , d.used AS "USED_MB"
       , c.total - d.used AS "FREE_MB"
       , ROUND((d.used/c.total*100), 2) AS "USED(%)"
FROM c, d
WHERE c.tablespace_name = d.tablespace_name
ORDER BY 5 DESC, 1
/
