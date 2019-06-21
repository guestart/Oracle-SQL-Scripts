-- +------------------------------------------------------------------+
-- |                                                                  |
-- | File Name    : ~/rman_backup_check_plsql_2.sql                   |
-- |                                                                  |
-- | Author       : Quanwen Zhao                                      |
-- |                                                                  |
-- | Description  : Display rman backup situation for oracle database |
-- |                                                                  |
-- |                by calling implicit cursor (for ... in ...) on    |
-- |                                                                  |
-- |                PL/SQL code.                                      |
-- |                                                                  |
-- | Requirements : Access to the following 3 number of views.        |
-- |                                                                  |
-- |                (1) v$instance                                    |
-- |                                                                  |
-- |                (2) v$parameter                                   |
-- |                                                                  |
-- |                (3) v$rman_backup_job_details                     |
-- |                                                                  |
-- | Call Syntax  : @rman_backup_check_plsql_2                        |
-- |                                                                  |
-- | Last Modified: 20/06/2019 (dd/mm/yyyy)                           |
-- |                                                                  |
-- +------------------------------------------------------------------+

SET SERVEROUTPUT ON FORMAT WRAPPED
SET LINESIZE 300
SET PAGESIZE 300

SET SERVEROUTPUT ON FORMAT

DECLARE
  v_name       varchar2(50);
  v_value      varchar2(50);
--  v_rbjd_table varchar2(4000);
  CURSOR c_rbjd_table IS
  SELECT start_time
	 , end_time
	 , output_device_type AS odt
	 , status
	 , input_type
	 , ltrim(input_bytes_display) AS ibd
	 , ltrim(output_bytes_display) AS obd
	 , ltrim(input_bytes_per_sec_display) AS ibpd
	 , ltrim(output_bytes_per_sec_display) AS obpd
	 , time_taken_display AS ttd
  FROM  v$rman_backup_job_details
  WHERE output_device_type = 'DISK';
  
  v_rbjd_table c_rbjd_table%ROWTYPE;
  
BEGIN
	SELECT host_name INTO v_name FROM v$instance;
	SELECT value INTO v_value FROM v$parameter WHERE name = 'db_unique_name';
	FOR v_rbjd_table IN c_rbjd_table
	LOOP
	  DBMS_OUTPUT.put_line(v_name
	                       || ', ' || v_value
	                       || ', ' || v_rbjd_table.start_time
	                       || ', ' || v_rbjd_table.end_time
	                       || ', ' || v_rbjd_table.odt
	                       || ', ' || v_rbjd_table.status
	                       || ', ' || v_rbjd_table.input_type
	                       || ', ' || v_rbjd_table.ibd
	                       || ', ' || v_rbjd_table.obd
	                       || ', ' || v_rbjd_table.ibpd
	                       || ', ' || v_rbjd_table.obpd
	                       || ', ' || v_rbjd_table.ttd
	                      );
	END LOOP;
END;
/

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
test, test, 2019-06-18 22:00:04, 2019-06-18 22:48:11, DISK, COMPLETED, DB INCR, 1.24T, 214.46M, 450.68M, 76.07K, 00:48:07
test, test, 2019-06-19 22:00:04, 2019-06-19 22:47:40, DISK, COMPLETED, DB INCR, 1.24T, 219.56M, 455.57M, 78.72K, 00:47:36

PL/SQL procedure successfully completed.
