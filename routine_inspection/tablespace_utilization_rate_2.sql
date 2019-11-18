REM
REM     Script:        tablespace_utilization_rate_2.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 18, 2019
REM
REM     Purpose:
REM       The 2nd (relatively simple) version of SQL script "tablespace_utilization_rate.sql" - using view both "sys.sm$ts_avail"
REM       and "sys.sm$ts_free" to check the utilization rate of non-Temporary tablespace.
REM

SET LINESIZE 300
SET PAGESIZE 300

COLUMN ts_name  FORMAT a25
COLUMN total_mb FORMAT 999,999,999,999
COLUMN used_mb  FORMAT 999,999,999,999
COLUMN free_mb  FORMAT 999,999,999,999
COLUMN used(%)  FORMAT 999.99

WITH dtf AS ( SELECT tablespace_name
                     , SUM(bytes)/POWER(2,20) AS total
              FROM dba_temp_files
              GROUP BY tablespace_name
            ),
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
SELECT ta.tablespace_name AS ts_name
       , ta.bytes/POWER(2,20) AS total_mb
       , (ta.bytes - tf.bytes)/POWER(2,20) AS used_mb
       , tf.bytes/POWER(2,20) AS free_mb
       , ROUND((1-tf.bytes/ta.bytes)*100, 2) AS "USED(%)"
FROM sys.sm$ts_avail ta
     , sys.sm$ts_free tf
WHERE ta.tablespace_name = tf.tablespace_name
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
