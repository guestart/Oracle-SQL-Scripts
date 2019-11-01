REM
REM     Script:        tablespace_per_used_size_and_rollup.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Oct 30, 2019
REM     Updated:       Nov 01, 2019
REM                    Replacing "SUM(bytes_cached)/1024/1024 AS used" with "SUM(bytes_used)/1024/1024 AS used"
REM                    on table "v$temp_extent_pool".
REM
REM     Purpose:  
REM       This SQL script usually uses to check the used size of per tablespace (and all) using "rollup" clause on Oracle Database.
REM

set linesize    10000
set pagesize    10000

COLUMN ts_name  FORMAT a25
COLUMN used_mb  FORMAT 999,999,999.99

WITH tu AS (SELECT tablespace_name
                   , bytes
            FROM dba_segments
            UNION ALL
            SELECT tablespace_name
--                 , bytes_cached AS bytes
                   , bytes_used AS bytes
            FROM v$temp_extent_pool
           )
SELECT tu.tablespace_name AS ts_name
       , SUM(tu.bytes)/1024/1024 AS used_mb
FROM tu
GROUP BY rollup(tu.tablespace_name)
ORDER BY 1
/

-- A demo of looking likes the following output result.

TS_NAME                           USED_MB
------------------------- ---------------
SYSAUX                          55,893.19
SYSTEM                             794.38
WWW_XXXXXXXXXXX                512,485.75
WWW_XXXXXXXXXXX_TEMP            32,766.00
WWW_YYYYYYYYYYY                     10.00
TEMP                            32,439.00
UNDOTBS1                         4,976.31
USERS                            2,625.13
                               641,989.75  <<== All of tablespaces' total used sizes

9 rows selected.
