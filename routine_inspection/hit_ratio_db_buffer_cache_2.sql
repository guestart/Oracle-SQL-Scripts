-- +-----------------------------------------------------------------------+
-- |                                                                       |
-- | File Name    : ~/hit_ratio_db_buffer_cache_2.sql                      |
-- |                                                                       |
-- | Author       : Quanwen Zhao                                           |
-- |                                                                       |
-- | Description  : Display db buffer cache hit ratio for all of Oracle    |
-- |                                                                       |
-- |                database.                                              |
-- |                                                                       |
-- | Comments     : The minimum figure of 89% is often quoted, but         |
-- |                                                                       |
-- |                depending on the type of system this may not be        |
-- |                                                                       |
-- |                possible.                                              |
-- |                                                                       |
-- | Requirements : Access to the v$instance|v$parameter|v$sysstat views.  |
-- |                                                                       |
-- | Call Synatix : @hit_ratio_db_buffer_cache_2                           |
-- |                                                                       |
-- | Last Modified: 16/08/2016 (dd/mm/yyyy)                                |
-- |                                                                       |
-- +-----------------------------------------------------------------------+

SET  HEADING   OFF
SET  FEEDBACK  OFF
SET  VERIFY    OFF
SET  ECHO      OFF

SET  LINESIZE  200
SET  PAGESIZE  200

COLUMN  hit_ratio  FORMAT  a10
COLUMN  host_name  FORMAT  a10
COLUMN  ipaddr     FORMAT  a14
COLUMN  value      FORMAT  a8

SELECT
      (SELECT Dbms_Random.String('A',20) FROM dual)
      || ', ' ||
--    (SELECT To_Char(sysdate,'yyyy-mm-dd hh24:mi:ss') FROM dual)
--    || ', ' ||
      (SELECT Utl_Inaddr.Get_Host_Address() ipaddr FROM dual)
      || ', ' ||
      (SELECT host_name FROM v$instance)
      || ', ' ||
      (SELECT value FROM v$parameter WHERE name = 'db_name')
      || ', ' ||
      (SELECT Round((1 - SUM(DECODE(name, 'physical reads', value, 0))
       / 
       (SUM(DECODE(name, 'db block gets', value, 0)) 
       + 
       SUM(DECODE(name, 'consistent gets', value, 0))) ), 4) * 100 
       || '%' AS hit_ratio 
       FROM v$sysstat
      )
FROM dual
/

SET  HEADING   ON
SET  FEEDBACK  ON
SET  VERIFY    ON
SET  ECHO      ON
