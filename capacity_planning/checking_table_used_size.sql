REM
REM     Script:        checking_table_used_size.sql
REM     Author:        Quanwen Zhao
REM     Dated:         May 24, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM
REM     Purpose:
REM       The SQL script focuses on checking the used size and other situations
REM       (such as, num_rows, blocks, avg_row_len and so on) of table. Typically
REM       the table's size exceeds 1024 MB we think that which will become a big
REM       table.
REM

SET LINESIZE 150
SET PAGESIZE 300

SET TIMING ON

COLUMN owner      FORMAT a30
COLUMN table_name FORMAT a30

WITH 
   ds AS (SELECT owner
               , segment_name
               , SUM(bytes)/POWER(2, 20) AS used_mb
            FROM dba_segments
           WHERE owner = UPPER('&&owner_name')
             AND segment_type = 'TABLE'     
           GROUP BY owner
                  , segment_name
          HAVING SUM(bytes)/POWER(2, 20) > 1024
           ORDER BY segment_name
         ),
   dt AS (SELECT owner
               , table_name
               , num_rows
               , blocks
            -- , empty_blocks
            -- , avg_space
               , avg_row_len
            FROM dba_tables
           WHERE owner = UPPER('&owner_name')
           ORDER BY table_name
         )
SELECT dt.owner
     , dt.table_name
     , ds.used_mb
     , dt.num_rows
     , dt.blocks
  -- , dt.empty_blocks
  -- , dt.avg_space
     , dt.avg_row_len
  FROM ds, dt
 WHERE ds.owner = dt.owner
   AND ds.segment_name = dt.table_name
 ORDER BY ds.used_mb DESC
        , dt.num_rows DESC
        , dt.table_name
;
