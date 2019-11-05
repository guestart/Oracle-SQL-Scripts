REM
REM     Script:        tablespace_non-temp_compare_total_size.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 05, 2019
REM
REM     Purpose:  
REM       This SQL script usually uses to compare the difference about total size (using more than one INLINE VIEW) of
REM       all of the non-temp tablespaces on Oracle Database.
REM

SET LINESIZE 1000
SET PAGESIZE 1000

COLUMN ts_name  FORMAT a25
COLUMN total_mb FORMAT 999,999,999.99

PROMPT =====
PROMPT bytes
PROMPT =====

SELECT ddf.ts_name
       , ddf.total_mb
       , dt.total_mb
       , ddf.total_mb - dt.total_mb
FROM 
     ( SELECT tablespace_name AS ts_name
              , SUM(bytes)/1024/1024 AS total_mb
       FROM dba_data_files
       GROUP BY tablespace_name
     ) ddf,  
     (
       SELECT ds.tablespace_name AS ts_name
              , (ds.used_mb + dfs.free_mb) AS total_mb 
       FROM
            ( SELECT tablespace_name
                     , SUM(bytes)/1024/1024 AS used_mb
              FROM dba_segments
              GROUP BY tablespace_name
            ) ds,
            ( SELECT tablespace_name
                     , SUM(bytes)/1024/1024 AS free_mb
              FROM dba_free_space
              GROUP BY tablespace_name
            ) dfs
       WHERE ds.tablespace_name = dfs.tablespace_name
     ) dt
WHERE ddf.ts_name = dt.ts_name
ORDER BY 1,4
;

-- TS_NAME                          TOTAL_MB        TOTAL_MB DDF.TOTAL_MB-DT.TOTAL_MB
-- ------------------------- --------------- --------------- ------------------------
-- SYSAUX                         107,898.00      107,894.38                    3.625
-- SYSTEM                         139,196.00      139,191.00                        5
-- WWW_XXXXXXXXXXX                638,538.00      644,617.06               -6079.0625
-- WWW_YYYYYYYYYYY                  4,096.00        4,105.00                       -9
-- UNDOTBS1                        25,845.00       25,844.00                        1
-- USERS                            2,758.00        2,757.00                        1
-- 
-- 6 rows selected.

PROMPT ==========
PROMPT user_bytes
PROMPT ==========

SELECT ddf.ts_name
       , ddf.total_mb
       , dt.total_mb
       , ddf.total_mb - dt.total_mb
FROM 
     ( SELECT tablespace_name AS ts_name
              , SUM(user_bytes)/1024/1024 AS total_mb
       FROM dba_data_files
       GROUP BY tablespace_name
     ) ddf,  
     (
       SELECT ds.tablespace_name AS ts_name
              , (ds.used_mb + dfs.free_mb) AS total_mb 
       FROM
            ( SELECT tablespace_name
                     , SUM(bytes)/1024/1024 AS used_mb
              FROM dba_segments
              GROUP BY tablespace_name
            ) ds,
            ( SELECT tablespace_name
                     , SUM(bytes)/1024/1024 AS free_mb
              FROM dba_free_space
              GROUP BY tablespace_name
            ) dfs
       WHERE ds.tablespace_name = dfs.tablespace_name
     ) dt
WHERE ddf.ts_name = dt.ts_name
ORDER BY 1,4
;

-- TS_NAME                          TOTAL_MB        TOTAL_MB DDF.TOTAL_MB-DT.TOTAL_MB
-- ------------------------- --------------- --------------- ------------------------
-- SYSAUX                         107,893.00      107,894.38                   -1.375
-- SYSTEM                         139,191.00      139,191.00                        0
-- WWW_XXXXXXXXXXX                638,518.00      644,617.06               -6099.0625
-- WWW_YYYYYYYYYYY                  4,095.00        4,105.00                      -10
-- UNDOTBS1                        25,844.00       25,844.00                        0
-- USERS                            2,757.00        2,757.00                        0
-- 
-- 6 rows selected.
