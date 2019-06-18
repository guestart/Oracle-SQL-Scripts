-- +------------------------------------------------------------------+
-- |                                                                  |
-- | File Name    : ~/rman_backup_check_2.sql                         |
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
-- | Call Syntax  : @rman_backup_check_2                              |
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
       (SELECT host_name FROM v$instance) || ', ' ||
       (SELECT value FROM v$parameter WHERE name = 'db_unique_name') || ', ' ||
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
        -- AND To_Char(start_time,'dd-mm-yy') = To_Char(sysdate - 1,'dd-mm-yy')
       )
FROM dual
/

ERROR at line 4:
ORA-01427: single-row subquery returns more than one row

-- SET ECHO      ON
-- SET HEADING   ON
-- SET FEEDBACK  ON
-- SET VERIFY    ON

SELECT i.host_name || ', ' || 
       p.value || ', ' || 
       rbjd.start_time || ', ' || 
       rbjd.end_time || ', ' || 
       rbjd.output_device_type || ', ' || 
       rbjd.status || ', ' || 
       rbjd.input_type || ', ' || 
       ltrim(rbjd.input_bytes_display) || ', ' || 
       ltrim(rbjd.output_bytes_display) || ', ' || 
       ltrim(rbjd.input_bytes_per_sec_display) || ', ' || 
       ltrim(rbjd.output_bytes_per_sec_display) || ', ' || 
       rbjd.time_taken_display 
FROM v$instance i
JOIN v$parameter p ON p.name = 'db_unique_name'
LEFT JOIN v$rman_backup_job_details rbjd ON rbjd.output_device_type = 'DISK';

-- Normally output:

test, test, 2019-05-31 22:00:03, 2019-05-31 23:38:28, DISK, COMPLETED, DB INCR, 920.94G, 916.86G, 159.70M, 158.99M, 01:38:25
test, test, 2019-06-01 22:00:05, 2019-06-01 22:45:13, DISK, COMPLETED, DB INCR, 1.24T, 298.87M, 480.48M, 113.01K, 00:45:08
test, test, 2019-06-02 22:00:04, 2019-06-02 22:46:31, DISK, COMPLETED, DB INCR, 1.24T, 378.55M, 466.86M, 139.09K, 00:46:27
test, test, 2019-06-03 22:00:04, 2019-06-03 22:45:11, DISK, COMPLETED, DB INCR, 1.24T, 209.50M, 480.65M, 79.25K, 00:45:07
test, test, 2019-06-04 22:00:03, 2019-06-04 22:45:49, DISK, COMPLETED, DB INCR, 1.24T, 264.00M, 473.82M, 98.45K, 00:45:46
test, test, 2019-06-05 22:00:03, 2019-06-05 22:55:32, DISK, COMPLETED, DB INCR, 1.26T, 23.53G, 395.74M, 7.24M, 00:55:29
test, test, 2019-06-06 22:00:05, 2019-06-06 22:52:41, DISK, COMPLETED, DB INCR, 1.24T, 9.80G, 412.26M, 3.18M, 00:52:36
test, test, 2019-06-07 22:00:04, 2019-06-07 23:46:25, DISK, COMPLETED, DB INCR, 921.05G, 916.91G, 147.81M, 147.14M, 01:46:21
test, test, 2019-06-08 22:00:04, 2019-06-08 22:44:01, DISK, COMPLETED, DB INCR, 1.24T, 229.62M, 493.40M, 89.17K, 00:43:57
test, test, 2019-06-09 22:00:04, 2019-06-09 22:47:30, DISK, COMPLETED, DB INCR, 1.24T, 257.46M, 457.18M, 92.63K, 00:47:26
test, test, 2019-06-10 22:00:04, 2019-06-10 22:46:40, DISK, COMPLETED, DB INCR, 1.24T, 202.77M, 465.35M, 74.26K, 00:46:36
test, test, 2019-06-11 22:00:04, 2019-06-11 22:50:50, DISK, COMPLETED, DB INCR, 1.24T, 2.78G, 427.17M, 956.58K, 00:50:46
test, test, 2019-06-12 22:00:04, 2019-06-12 22:48:10, DISK, COMPLETED, DB INCR, 1.24T, 2.74G, 450.84M, 996.11K, 00:48:06
test, test, 2019-06-13 22:00:04, 2019-06-13 22:45:10, DISK, COMPLETED, DB INCR, 1.24T, 244.26M, 480.82M, 92.43K, 00:45:06
test, test, 2019-06-14 22:00:03, 2019-06-14 23:42:10, DISK, COMPLETED, DB INCR, 921.19G, 916.98G, 153.96M, 153.25M, 01:42:07
test, test, 2019-06-15 22:00:03, 2019-06-15 22:45:10, DISK, COMPLETED, DB INCR, 1.24T, 240.09M, 480.65M, 90.82K, 00:45:07
test, test, 2019-06-16 22:00:04, 2019-06-16 22:45:40, DISK, COMPLETED, DB INCR, 1.24T, 243.21M, 475.56M, 91.03K, 00:45:36
test, test, 2019-06-17 22:00:04, 2019-06-17 22:46:30, DISK, COMPLETED, DB INCR, 1.24T, 206.82M, 467.02M, 76.02K, 00:46:26

18 rows selected.
