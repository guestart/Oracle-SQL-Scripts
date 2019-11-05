REM
REM     Script:        tablespace_used_size_2.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Oct 30, 2019
REM     Updated:       Nov 01, 2019
REM                    Replacing "SUM(bytes_cached)/1024/1024 AS used" with "SUM(bytes_used)/1024/1024 AS used"
REM                    on table "v$temp_extent_pool".
REM
REM     Purpose:  
REM       This SQL script usually uses to check the used size of tablespace on Oracle Database.
REM

SET LINESIZE 10000
SET PAGESIZE 10000

COLUMN ts_name FORMAT a25
COLUMN used_mb FORMAT 999,999,999.99

SELECT tablespace_name AS ts_name
       , sum(bytes)/1024/1024 AS used_mb
FROM dba_segments
GROUP BY tablespace_name
UNION ALL
SELECT tablespace_name AS ts_name
--     , SUM(bytes_cached)/1024/1024 AS used_mb
       , SUM(bytes_used)/1024/1024 AS used
FROM v$temp_extent_pool
GROUP BY tablespace_name
ORDER BY 1
/
