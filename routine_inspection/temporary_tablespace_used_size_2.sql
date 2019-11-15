REM
REM     Script:        temporary_tablespace_used_size_2.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 15, 2019
REM
REM     Purpose:
REM       The 2nd version of SQL script "temporary_tablespace_used_size.sql" on Oracle Database.
REM       By the way Jared Still's "showtemp.sql" (https://github.com/jkstill/oracle-script-lib/blob/master/sql/showtemp.sql)
REM       give me a real inspiration - a pretty concise and ingenious approach checking the value "db_block_size" via view "v$parameter".
REM
REM     Last tested:
REM             11.2.0.4
REM

SET VERIFY   OFF

SET LINESIZE 200
SET PAGESIZE 200

COLUMN username   FORMAT a25
COLUMN tablespace FORMAT a25
COLUMN contents   FORMAT a10
COLUMN segtype    FORMAT a10
COLUMN blocks     FORMAT 999,999,999,999
COLUMN used_mb    FORMAT 999,999,999,999

COLUMN blocksize NEW_VALUE blocksize NOPRINT

SELECT value blocksize
FROM v$parameter
WHERE name = 'db_block_size'
/

SELECT username
	     , tablespace
	     , contents
	     , segtype
	     , blocks
	     , blocks * &&blocksize / POWER(2,10) AS used_mb
FROM v$tempseg_usage
ORDER BY username
/

-- USERNAME                  TABLESPACE                CONTENTS   SEGTYPE              BLOCKS          USED_MB
-- ------------------------- ------------------------- ---------- ---------- ---------------- ----------------
-- DBSNMP                    TEMP                      TEMPORARY  LOB_DATA                128            1,024
-- WWW_XXXXXXXXXXX           WWW_XXXXXXXXXXX_TEMP      TEMPORARY  LOB_DATA                128            1,024
-- WWW_XXXXXXXXXXX           WWW_XXXXXXXXXXX_TEMP      TEMPORARY  LOB_DATA                128            1,024
-- WWW_XXXXXXXXXXX           WWW_XXXXXXXXXXX_TEMP      TEMPORARY  LOB_DATA                128            1,024
-- WWW_XXXXXXXXXXX           WWW_XXXXXXXXXXX_TEMP      TEMPORARY  LOB_DATA                128            1,024
-- WWW_XXXXXXXXXXX           WWW_XXXXXXXXXXX_TEMP      TEMPORARY  LOB_DATA                128            1,024
-- WWW_XXXXXXXXXXX           WWW_XXXXXXXXXXX_TEMP      TEMPORARY  LOB_DATA                128            1,024
-- 
-- 7 rows selected.

SELECT username
	     , tablespace
	     , contents
	     , segtype
	     , SUM(blocks) AS blocks
	     , SUM(blocks) * &&blocksize / POWER(2,10) AS used_mb
FROM v$tempseg_usage
GROUP BY username
         , tablespace
         , contents
         , segtype
ORDER BY username
/

-- USERNAME                  TABLESPACE                CONTENTS   SEGTYPE              BLOCKS          USED_MB
-- ------------------------- ------------------------- ---------- ---------- ---------------- ----------------
-- DBSNMP                    TEMP                      TEMPORARY  LOB_DATA                128            1,024
-- WWW_XXXXXXXXXXX           WWW_XXXXXXXXXXX_TEMP      TEMPORARY  LOB_DATA                768            6,144
