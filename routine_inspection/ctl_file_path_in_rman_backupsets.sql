-- +----------------------------------------------------------------------------+
-- |                                 Quanwen Zhao                               |
-- |                               guestart@163.com                             |
-- |                          quanwenzhao.wordpress.com                         |
-- |----------------------------------------------------------------------------|
-- |         Copyright (c) 2016-2017 Quanwen Zhao. All rights reserved.         |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : ctl_file_path_in_rman_backupsets.sql                            |
-- | CLASS    : Administration                                                  |
-- | PURPOSE  : Query all of control file's locaiton in rman backupsets.        |
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

COLUMN handle FORMAT a80 HEADING "Control File's Path In Rman Backupsets" 

SELECT 
       distinct p.handle
FROM v$backup_piece_details p
     , v$backup_set_details s
WHERE p.bs_key = s.bs_key
AND s.device_type = 'DISK'
AND s.controlfile_included = 'YES'
ORDER BY 1 DESC
/
