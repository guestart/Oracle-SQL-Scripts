REM
REM     Script:        top_10_segment_on_system_tbs.sql
REM     Author:        Quanwen Zhao
REM     Dated:         May 11, 2019
REM
REM     Purpose:  
REM       This sql script shows top 10 segment objects on system tablespace.
REM

SET LINESIZE 300
COLUMN segment_name FORMAT a25
COLUMN segment_type FORMAT a10
COLUMN owner        FORMAT a8

SELECT * FROM
(SELECT segment_name
        , bytes/1024/1024 AS mb
        , segment_type
        , owner
 FROM dba_segments
 WHERE tablespace_name = 'SYSTEM'
 ORDER BY bytes DESC
)
WHERE rownum < 10
/
