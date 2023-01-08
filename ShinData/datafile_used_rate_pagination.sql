REM
REM     Script:        datafile_used_rate_pagination.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 07, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Showing the pagination query for datafile used rate of all permanent tablespaces on oracle database.
REM

-- Firstly, caculating the total line numbers of the datafile used rate of all permanent tablespaces.

SELECT COUNT(f.file_id)
FROM dba_data_files f, dba_tablespaces t
WHERE f.tablespace_name = t.tablespace_name
AND t.contents = 'PERMANENT';

-- Secondly, considering showing line numbers of per page, such as 20,
-- Thus "(:end_page_number subtracts :start_page_number) + 1" in the following query will be 20.

SELECT * FROM
(SELECT rownum AS rnum, r.*
 FROM (
       SELECT f.file_id,
              f.file_name,
              f.tablespace_name,
              round(f.bytes/1024/1024, 2) filesize_mb,
              f.blocks,
              round((f.bytes-nvl(s.bytes, 0))/1024/1024, 2) used_mb,
              CASE f.autoextensible WHEN 'NO' THEN round((f.bytes-nvl(s.bytes, 0))/f.bytes, 4)*100
              ELSE round((f.bytes-nvl(s.bytes, 0))/f.maxbytes, 4)*100
              END AS used_ratio,
              CASE f.autoextensible WHEN 'NO' THEN round(f.bytes/1024/1024, 2)
              ELSE round(f.maxbytes/1024/1024, 2)
              END AS maxsize_mb,
              CASE f.autoextensible WHEN 'NO' THEN f.blocks
              ELSE f.maxblocks
              END AS maxblocks,
              f.autoextensible,
              f.online_status
       FROM dba_data_files f, dba_tablespaces t, (SELECT file_id, SUM(bytes) bytes FROM dba_free_space GROUP BY file_id) s
       WHERE f.tablespace_name = t.tablespace_name
       AND f.file_id = s.file_id
       AND t.contents = 'PERMANENT'
       ORDER BY f.file_id
      ) r
 WHERE rownum <= :end_page_number
) WHERE rnum >= :start_page_number;

-- Finally, we can get how many pages will show for this SQL query.
