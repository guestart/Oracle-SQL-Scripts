REM
REM     Script:        tablespace_utilization_rate.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Oct 30, 2019
REM     Updated:       Nov 01, 2019
REM                    Replacing "SUM(bytes_cached)/1024/1024 AS used" with "SUM(bytes_used)/1024/1024 AS used"
REM                    on table "v$temp_extent_pool".
REM     Updated:       Nov 18, 2019
REM       Modifying view "a" to "ddf", "b" to "dfs", "c" to "dtf" and adding new view "ts", "tt", "tu" and "ttt".
REM       Also modifying SQL statement checking Temporary tablespace utilization rate after "UNION ALL" clause.
REM
REM     Purpose:
REM       This SQL script usually uses to check the utilization rate of all of the tablespace on Oracle Database.
REM

-- SET LINESIZE 10000
-- SET PAGESIZE 10000

SET LINESIZE 300
SET PAGESIZE 300

COLUMN ts_name  FORMAT a25
-- COLUMN total_mb FORMAT 999,999,999.99
-- COLUMN used_mb  FORMAT 999,999,999.99
-- COLUMN free_mb  FORMAT 999,999,999.99
COLUMN total_mb FORMAT 999,999,999,999
COLUMN used_mb  FORMAT 999,999,999,999
COLUMN free_mb  FORMAT 999,999,999,999
COLUMN used(%)  FORMAT 999.99

WITH ddf AS ( SELECT tablespace_name
-- WITH a AS ( SELECT tablespace_name
--                    , SUM(bytes)/1024/1024 AS total
                     , SUM(bytes)/POWER(2,20) AS total
               FROM dba_data_files
               GROUP BY tablespace_name
             ),
    dfs AS ( SELECT tablespace_name        
--      b AS (SELECT tablespace_name
--                   , SUM(bytes)/1024/1024 AS free
                    , SUM(bytes)/POWER(2,20) AS free
             FROM dba_free_space
             GROUP BY tablespace_name
           ),
    dtf AS ( SELECT tablespace_name
--      c AS (SELECT tablespace_name
--                   , SUM(bytes)/1024/1024 AS total
                    , SUM(bytes)/POWER(2,20) AS total
             FROM dba_temp_files
             GROUP BY tablespace_name
           ),
--      d AS (SELECT tablespace_name
--                   , SUM(bytes_cached)/1024/1024 AS used
--                   , SUM(bytes_used)/1024/1024 AS used
--            FROM v$temp_extent_pool
--            GROUP BY tablespace_name
--           )
    ts  AS ( SELECT ts#
                    , name
             FROM v$tablespace
           ),
    tt  AS ( SELECT t.ts#
                    , t.blocksize
                    , tf.block_size
             FROM ts$ t, v$tempfile tf
             WHERE t.ts# = tf.ts#
           ),
    tu  AS ( SELECT tablespace
                    , blocks
             FROM v$tempseg_usage
           ), 
    ttt AS ( SELECT tu.tablespace
                    , tt.block_size
                    , (SUM(tu.blocks) * tt.block_size)/POWER(2,20) AS used
             FROM ts, tt, tu
             WHERE ts.ts# = tt.ts#
             AND tu.tablespace = ts.name
             GROUP BY tu.tablespace
                      , tt.block_size
           )
-- SELECT a.tablespace_name AS ts_name
--        , a.total AS "TOTAL_MB"
--        , a.total - b.free AS "USED_MB"
--        , b.free AS "FREE_MB"
--        , ROUND((1-b.free/a.total)*100, 2) AS "USED(%)"
-- FROM a, b
-- WHERE a.tablespace_name = b.tablespace_name
-- UNION ALL
-- SELECT c.tablespace_name AS ts_name
--        , c.total AS "TOTAL_MB"
--        , d.used AS "USED_MB"
--        , c.total - d.used AS "FREE_MB"
--        , ROUND((d.used/c.total*100), 2) AS "USED(%)"
-- FROM c, d
-- WHERE c.tablespace_name = d.tablespace_name
-- ORDER BY 5 DESC, 1
SELECT ddf.tablespace_name AS ts_name
       , ddf.total AS total_mb
       , ddf.total - dfs.free AS used_mb
       , dfs.free AS free_mb
       , ROUND((1-dfs.free/ddf.total)*100, 2) AS "USED(%)"
FROM ddf, dfs
WHERE ddf.tablespace_name = dfs.tablespace_name
UNION ALL
SELECT dtf.tablespace_name AS ts_name
       , dtf.total AS total_mb
       , ttt.used AS used_mb
       , dtf.total - ttt.used AS free_mb
       , ROUND((ttt.used/dtf.total*100), 2) AS "USED(%)"
FROM dtf, ttt
WHERE dtf.tablespace_name = ttt.tablespace
ORDER BY 5 DESC, 1
/
