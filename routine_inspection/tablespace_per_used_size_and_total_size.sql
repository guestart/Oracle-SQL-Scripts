REM
REM     Script:        tablespace_per_used_size_and_total_size.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Oct 30, 2019
REM     Updated:       Nov 01, 2019
REM                    Replacing "SUM(bytes_cached)/1024/1024 AS used" with "SUM(bytes_used)/1024/1024 AS used"
REM                    on table "v$temp_extent_pool".
REM
REM     Purpose:  
REM       This SQL script usually uses to check the used size of per tablespace (and all) on Oracle Database.
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
  --              , SUM(bytes_cached)/1024/1024 AS used
                  , SUM(bytes_used)/1024/1024 AS used
           FROM v$temp_extent_pool
           GROUP BY tablespace_name
          ),
     e AS (SELECT a.tablespace_name AS ts_name
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
          )
SELECT ts_name
       , used_mb
FROM e
UNION ALL
SELECT NULL
       , SUM(used_mb)
FROM e
/

-- A demo of looking likes the following output result.

TS_NAME                           USED_MB
------------------------- ---------------
SYSAUX                          55,896.81
SYSTEM                             799.38
WWW_XXXXXXXXXXX                506,406.69
WWW_XXXXXXXXXXX_TEMP            32,766.00
WWW_YYYYYYYYYYY                      1.00
TEMP                            32,439.00
UNDOTBS1                         4,788.31
USERS                            2,626.13
                               635,723.31  <<== All of tablespaces' total used sizes

9 rows selected.
