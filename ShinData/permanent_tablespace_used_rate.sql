REM
REM     Script:        permanent_tablespace_used_rate.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Dec 14, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the permanent tablespace used rate of oracle database.
REM

SELECT a.tablespace_name,
       a.block_size,
       c.auexten,
       round(nvl(b.used_size, 0) / 1024 / 1024, 2)                    AS used_space,
       c.sum_blocks                                                   AS allocated_blocks,
       round(c.sum_space / 1024 /1024, 2)                             AS allocated_space,
       round((c.sum_space - nvl(b.used_size, 0)) / 1024 / 1024, 2)    AS allocated_free_space,
       round(nvl(b.used_size, 0) / c.sum_space * 100, 2)              AS allocated_space_rate,
       c.sum_maxblocks                                                AS max_usable_blocks,
       round(c.sum_maxspace / 1024 / 1024, 2)                         AS max_usable_space,
       round((c.sum_maxspace - nvl(b.used_size, 0)) / 1024 / 1024, 2) AS max_free_usable_space,
       round(nvl(b.used_size, 0) / c.sum_maxspace * 100, 2)           AS used_rate_alert,
       a.contents,
       c.status,
       a.bigfile
FROM dba_tablespaces a
         LEFT JOIN (SELECT tablespace_name,
                           SUM(bytes) used_size
                    FROM DBA_SEGMENTS
                    WHERE segment_name NOT LIKE 'BIN$%'
                    GROUP BY tablespace_name
                   ) b ON a.tablespace_name = b.tablespace_name
         LEFT JOIN (SELECT tablespace_name,
                           min(online_status)                                                 AS status,
                           round(sum(nvl(bytes, 0)), 2)                                       AS sum_space,
                           round(sum(nvl(blocks, 0)), 2)                                      AS sum_blocks,
                           DECODE(SUM(DECODE(autoextensible, 'NO', 0, 1)), 0, 'NO', 'YES')    AS auexten,
                           sum(case autoextensible when 'YES' then maxblocks else blocks end) AS sum_maxblocks,
                           case when sum(bytes) > sum(maxbytes) then sum(bytes)
                                else sum(case autoextensible when 'YES' then maxbytes else bytes end)
                           end sum_maxspace
                    FROM dba_data_files
                    GROUP BY tablespace_name
                   ) c ON a.tablespace_name = c.tablespace_name
WHERE a.contents = 'PERMANENT'
ORDER BY 1;
