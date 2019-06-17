-- +------------------------------------------------------------------+
-- |                                                                  |
-- | File Name    : ~/rman_backup_check.sql                           |
-- |                                                                  |
-- | Author       : Quanwen Zhao                                      |
-- |                                                                  |
-- | Description  : Display backup situation for oracle database.     |
-- |                                                                  |
-- | Requirements : Access to the following 3 number of views.        |
-- |                                                                  |
-- |                (1) v$instance                                    |
-- |                                                                  |
-- |                (2) v$parameter                                   |
-- |                                                                  |
-- |                (3) v$rman_backup_job_details                     |
-- |                                                                  |
-- | Call Syntax  : @rman_backup_check                                |
-- |                                                                  |
-- | Last Modified: 24/08/2016 (dd/mm/yyyy)                           |
-- |                                                                  |
-- +------------------------------------------------------------------+

SET ECHO      OFF
SET HEADING   OFF
SET FEEDBACK  OFF
SET VERIFY    OFF

SET LINESIZE 250
SET PAGESIZE 250

-- COLUMN start_time                    FORMAT  a9
-- COLUMN end_time                      FORMAT  a9
-- COLUMN output_device_type            FORMAT  a4
-- COLUMN status                        FORMAT  a9
-- COLUMN input_type                    FORMAT  a13
-- COLUMN input_bytes_display           FORMAT  a9
-- COLUMN output_bytes_display          FORMAT  a9
-- COLUMN input_bytes_per_sec_display   FORMAT  a10
-- COLUMN output_bytes_per_sec_display  FORMAT  a11
-- COLUMN time_taken_display            FORMAT  a8

-- Use "||" to concatenate more than two columns,
-- do not use column alias, otherwise prompt ORA-00923: "FROM keyword not found where expected"

SELECT
       (SELECT host_name FROM v$instance)
       || ', ' ||
       (SELECT value FROM v$parameter WHERE name = 'db_unique_name')
       || ', ' ||
       (SELECT
               start_time || ', ' ||
               end_time || ', ' ||
               output_device_type || ', ' ||
               status || ', ' ||
               input_type || ', ' ||
               ltrim(input_bytes_display) || ', ' ||
               ltrim(output_bytes_display) || ', ' ||
               ltrim(input_bytes_per_sec_display) || ', ' ||
               ltrim(output_bytes_per_sec_display) || ', ' ||
               time_taken_display
        FROM  v$rman_backup_job_details
        WHERE output_device_type = 'DISK'
        AND To_Char(start_time,'dd-mm-yy') = To_Char(sysdate - 1,'dd-mm-yy')
       )
FROM dual
/

SET ECHO      ON
SET HEADING   ON
SET FEEDBACK  ON
SET VERIFY    ON
