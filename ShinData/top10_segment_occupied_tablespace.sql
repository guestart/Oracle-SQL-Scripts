REM
REM     Script:        top10_segment_occupied_tablespace.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 11, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking top 10 segment names that occupied by a specific tablespace (whose used rate >= 75%) on oracle database.
REM

SELECT * FROM
(SELECT owner,
        segment_name,
        segment_type,
        bytes/1024/1024 AS used_mb
 FROM dba_segments
 WHERE tablespace_name IN (SELECT a.tablespace_name  
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
 ORDER BY used_mb DESC
)
WHERE rownum <= 10;
