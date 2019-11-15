REM
REM     Script:        temporary_tablespace_used_size.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 15, 2019
REM
REM     Purpose:
REM       This SQL script usually uses to check the used size of all of TEMPORARY tablespaces on Oracle Database.
REM
REM     Last tested:
REM             11.2.0.4
REM

SET LINESIZE 200
SET PAGESIZE 200

COLUMN tablespace FORMAT a25
COLUMN used_mb    FORMAT 999,999,999,999

WITH tbk AS ( SELECT tablespace
                     , SUM(blocks) AS bn
              FROM v$tempseg_usage
              GROUP BY tablespace
              ORDER BY 1
            ),
     tbs AS ( SELECT t.ts#
                     , t.blocksize
                     , tf.block_size
              FROM ts$ t, v$tempfile tf
              WHERE t.ts# = tf.ts#
              ORDER BY 1
            ),
     tn  AS ( SELECT ts#
                     , name
              FROM v$tablespace
              ORDER BY 1
            )
SELECT tbk.tablespace
       , tbs.block_size
       , SUM(tbk.bn) AS blocks
       , (SUM(tbk.bn) * tbs.block_size)/POWER(2,20) AS used_mb
FROM tbk, tn, tbs
WHERE tbk.tablespace = tn.name
AND tn.ts# = tbs.ts#
GROUP BY tbk.tablespace
         , tbs.block_size
ORDER BY 1
/

-- TABLESPACE                BLOCK_SIZE      BLOCKS          USED_MB
-- ------------------------- ---------- ----------- ----------------
-- WWW_XXXXXXXXXXX_TEMP            8192        2304               18
-- TEMP                            8192         128                1
-- 
-- 2 rows selected.
