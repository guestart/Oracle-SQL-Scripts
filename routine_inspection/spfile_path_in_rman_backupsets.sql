-- +----------------------------------------------------------------------------+
-- |                                 Quanwen Zhao                               |
-- |                               guestart@163.com                             |
-- |                          quanwenzhao.wordpress.com                         |
-- |----------------------------------------------------------------------------|
-- |         Copyright (c) 2016-2017 Quanwen Zhao. All rights reserved.         |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : spfile_path_in_rman_backupsets.sql                              |
-- | CLASS    : Administration                                                  |
-- | PURPOSE  : Query all of spfile's locaiton in rman backupsets.              |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET ECHO      OFF
SET FEEDBACK  OFF
SET HEADING   ON
SET LINESIZE  300
SET PAGESIZE  300
SET TERMOUT   ON
SET TIMING    OFF
SET TRIMOUT   ON
SET TRIMSPOOL ON
SET VERIFY    OFF

COLUMN handle FORMAT a80 HEADING "Spfile's Path In Rman Backupsets"

SELECT
       distinct p.handle
FROM v$backup_piece_details p
     , v$backup_spfile sp
     , v$backup_spfile_details s
WHERE p.bs_key = s.bs_key
AND p.status = 'A'
AND p.device_type = 'DISK'
ORDER BY 1 DESC;
/
