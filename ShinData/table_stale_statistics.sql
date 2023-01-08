REM
REM     Script:        table_stale_statistics.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 15, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking which tables have been stale statistics on oracle database.
REM

SELECT OWNER,
       TABLE_NAME,
       PARTITION_NAME,
       NUM_ROWS,
       BLOCKS,
       CHAIN_CNT,
       SAMPLE_SIZE,
       LAST_ANALYZED,
       STALE_STATS
FROM DBA_TAB_STATISTICS
WHERE STALE_STATS = 'YES'
AND NOT EXISTS (SELECT * FROM (SELECT username
                               FROM dba_users
                               WHERE created < (SELECT created FROM v$database)
                              ) u
                WHERE DBA_TAB_STATISTICS.OWNER = u.USERNAME
               );
