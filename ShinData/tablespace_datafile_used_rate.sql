REM
REM     Script:        tablespace_datafile_used_rate.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 11, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the datafile used rate on a specific tablespace (whose used rate >= 75%) on oracle database.
REM

SELECT f.file_id,
       f.file_name,
       round(f.bytes/1024/1024, 2) filesize_mb,
       round((f.bytes-nvl(s.bytes, 0))/1024/1024, 2) used_mb,
       CASE f.autoextensible WHEN 'NO' THEN round((f.bytes-nvl(s.bytes, 0))/f.bytes, 4)*100
       ELSE round((f.bytes-nvl(s.bytes, 0))/f.maxbytes, 4)*100
       END AS used_ratio,
       CASE f.autoextensible WHEN 'NO' THEN round(f.bytes/1024/1024, 2)
       ELSE round(f.maxbytes/1024/1024, 2)
       END AS maxsize_mb,
       f.autoextensible
FROM dba_data_files f, dba_tablespaces t, (SELECT file_id, SUM(bytes) bytes FROM dba_free_space GROUP BY file_id) s
WHERE f.tablespace_name = t.tablespace_name
AND f.file_id = s.file_id
AND t.contents = 'PERMANENT'
AND f.tablespace_name IN (SELECT a.tablespace_name  
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
                         );
