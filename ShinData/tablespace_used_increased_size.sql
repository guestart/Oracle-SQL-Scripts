REM
REM     Script:        tablespace_used_increased_size.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 11, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking tablespace (whose used rate >= 75%) used size (mb) and increased size (mb) in recent 7 days on oracle database.
REM

SELECT * FROM (
SELECT DISTINCT a.name tablespace_name,
       b.datetime,
       b.used_size_mb,
       ROUND((b.used_size_mb - LAG(b.used_size_mb, 1, 0) OVER (PARTITION BY a.name ORDER BY a.name)), 2) increased_size_mb
FROM v$tablespace a,
(SELECT tablespace_id,
        to_date(substr(rtime, 1, 10), 'mm/dd/yyyy') datetime,
        MAX(tablespace_usedsize*8192/1024/1024) used_size_mb
 FROM dba_hist_tbspc_space_usage u, v$tablespace t
 WHERE to_date(substr(rtime, 1, 10), 'mm/dd/yyyy') >= sysdate - 7
 GROUP BY tablespace_id, to_date(substr(rtime, 1, 10), 'mm/dd/yyyy')
 ORDER BY tablespace_id, to_date(substr(rtime, 1, 10), 'mm/dd/yyyy')
) b
WHERE a.ts# = b.tablespace_id
AND a.name IN (SELECT a.tablespace_name  
               FROM dba_tablespaces a
               LEFT JOIN (SELECT tablespace_name, SUM(bytes) used_size
                          FROM DBA_SEGMENTS
                          WHERE segment_name NOT LIKE 'BIN$%'
                          GROUP BY tablespace_name
                         ) b ON a.tablespace_name = b.tablespace_name
               LEFT JOIN (SELECT tablespace_name,
                                 sum(case autoextensible when 'YES' then maxbytes else bytes end) AS sum_maxspace
                          FROM dba_data_files
                          GROUP BY tablespace_name
                         ) c ON a.tablespace_name = c.tablespace_name
               WHERE a.contents = 'PERMANENT'
               AND round(nvl(b.used_size, 0)/c.sum_maxspace*100, 2) >= 75
              )
ORDER BY a.name, b.datetime
) WHERE increased_size_mb <> 0;

-- TABLESPACE_NAME                DATETIME            USED_SIZE_MB   INCREASED_SIZE_MB
-- ------------------------------ ------------------- ------------   -----------------
-- SYSAUX	                        01-11月-22	        2667.6875	     2667.69
-- SYSAUX	                        02-11月-22	        2673.375	       5.69
-- SYSAUX	                        03-11月-22	        2630.5	         -42.88
-- SYSAUX	                        04-11月-22	        2622.6875	     -7.81
-- SYSAUX	                        05-11月-22	        2628.375	       5.69
-- SYSAUX	                        06-11月-22	        2641.4375	     13.06
-- SYSAUX	                        07-11月-22	        2649.6875	     8.25
