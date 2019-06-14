-- +----------------------------------------------------------------+
-- |                                                                |
-- | File Name    : ~/db_buffer_cache_hit_ratio.sql                 |
-- |                                                                |
-- | Author       : Quanwen Zhao                                    |
-- |                                                                |
-- | Description  : Display cache hit ratio for the oracle database |
-- |                                                                |
-- | Comments     : The minimum figure of 89% is often quoted, but  |
-- |                                                                |
-- |                depending on the type of system this may not    |
-- |                                                                |
-- |                be possible.                                    |
-- |                                                                |
-- | Requirements : Access to the v$sysstat views.                  |
-- |                                                                |
-- | Call Synatix : @db_buffer_cache_hit_ratio                      |
-- |                                                                |
-- | Last Modified: 03/08/2016 (dd/mm/yyyy)                         |
-- |                                                                |
-- +----------------------------------------------------------------+

PROMPT
PROMPT Hit ratio should exceed 89%
  
COLUMN hit_ratio FORMAT a10

SELECT Round((1 - Sum(Decode(name,'physical reads',value,0)) / 
       (Sum(Decode(name,'db block gets',value,0)) + 
        Sum(Decode(name,'consistent gets',value,0))) ),4) *100 
       || '%' hit_ratio
FROM v$sysstat
/
