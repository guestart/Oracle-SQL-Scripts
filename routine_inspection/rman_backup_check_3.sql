-- +------------------------------------------------------------------+
-- |                                                                  |
-- | File Name    : ~/rman_backup_check_3.sql                         |
-- |                                                                  |
-- | Author       : Quanwen Zhao                                      |
-- |                                                                  |
-- | Description  : Display backup situation for oracle database.     |
-- |                                                                  |
-- | Requirements : Access to the v$rman_backup_job_details view.     |
-- |                                                                  |
-- | Call Syntax  : @rman_backup_check_3                              |
-- |                                                                  |
-- | Last Modified: 24/08/2016 (dd/mm/yyyy)                           |
-- |                                                                  |
-- +------------------------------------------------------------------+

SET ECHO      OFF
SET FEEDBACK  OFF
SET VERIFY    OFF

SET LINESIZE 300
SET PAGESIZE 250

COLUMN start_time  FORMAT  a19
COLUMN end_time    FORMAT  a19
COLUMN odt         FORMAT  a4
COLUMN status      FORMAT  a9
COLUMN input_type  FORMAT  a12
COLUMN ibd         FORMAT  a9
COLUMN obd         FORMAT  a9
COLUMN ibpsd       FORMAT  a10
COLUMN obpsd       FORMAT  a10
COLUMN ttd         FORMAT  a8

SELECT
      start_time
      , end_time
      , output_device_type AS odt
      , status
      , input_type
      , LTRIM(input_bytes_display) AS ibd
      , LTRIM(output_bytes_display) AS obd
      , LTRIM(input_bytes_per_sec_display) AS ibpsd
      , LTRIM(output_bytes_per_sec_display) AS obpsd
      , time_taken_display AS ttd
FROM  v$rman_backup_job_details
WHERE output_device_type = 'DISK'
AND TO_CHAR(start_time, 'dd-mm-yy') = TO_CHAR(SYSDATE - 1, 'dd-mm-yy')
/
