REM
REM     Script:        acquire_arp.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 03, 2021
REM
REM     Updated:       Nov 20, 2021
REM                    Adding the latest code snippets visualizing the oracle performance metrics about "CPU Time" and "Load Average"
REM                    in the past and real time by the Microsoft Office Excel.
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       Visualizing the oracle some performance metrics about "CPU Time" and "Load Average" in the past and real time by the custom report of SQL Developer,
REM       we can name them with "ARP" (Average Runnable Processes"), but it seems like to have a bug on SQL Developer 21.2 here is my feedback by Oracle Developer
REM       Community - https://community.oracle.com/tech/developers/discussion/4490965/being-not-able-to-generate-a-combination-chart-with-area-stack-and-line-by-user-defined-reports.
REM       
REM     References:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-SYSMETRIC_HISTORY.html#GUID-5560D15E-9F02-4300-B4DD-85A88A280392
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYSMETRIC_SUMMARY.html#GUID-E6377E5F-1FFF-4563-850F-C361B9D85048
REM

-- Oracle CPU Time
-- http://datavirtualizer.com/oracle-cpu-time/

-- Stacked Area Graph
-- http://www.tuzhidian.com/chart?id=5c56e55a4a8c5e048189c72d

-- https://blogs.oracle.com/sql/post/how-to-convert-rows-to-columns-and-back-again-with-sql-aka-pivot-and-unpivot
-- https://livesql.oracle.com/apex/livesql/file/tutorial_GNZ3LQPJ0K6RTD1NEEPNRQT0R.html

-- How to concat dynamic column alias using || on oracle PL/SQL?
-- https://www.freelists.org/post/oracle-l/How-to-concat-dynamic-column-alias-using-on-oracle-PLSQL,1
-- https://www.freelists.org/post/oracle-l/How-to-concat-dynamic-column-alias-using-on-oracle-PLSQL,2

-- Literals
-- https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/Literals.html

-- Oracle PL/SQL: AUTHID CURRENT_USER | DEFINER
-- https://renenyffenegger.ch/notes/development/databases/Oracle/PL-SQL/authid/

-- Quick SQLcl Trick: SET SQLFORMAT
-- http://www.thatjeffsmith.com/archive/2015/02/a-quick-4-1-trick-set-sqlformat/

-- How to convert (open or import) CSV file to Excel
-- https://www.ablebits.com/office-addins-blog/convert-csv-excel/

-- DESC dba_sys_privs
--  Name                                                              Null?    Type
--  ----------------------------------------------------------------- -------- --------------------------------------------
--  GRANTEE                                                           NOT NULL VARCHAR2(30)
--  PRIVILEGE                                                         NOT NULL VARCHAR2(40)
--  ADMIN_OPTION                                                               VARCHAR2(3)
-- 
-- SELECT privilege FROM dba_sys_privs WHERE grantee = 'SYSTEM' ORDER BY 1;
-- 
-- PRIVILEGE
-- --------------------------------------------------------------------------------
-- CREATE MATERIALIZED VIEW
-- CREATE TABLE
-- GLOBAL QUERY REWRITE
-- SELECT ANY TABLE
-- UNLIMITED TABLESPACE
-- 
-- GRANT select on v_$sysmetric_history TO system;
-- GRANT select on dba_hist_sysmetric_summary TO system;
-- 
-- SET LINESIZE 100
-- 
-- COLUMN table_name FORMAT a28
-- COLUMN privilege  FORMAT a10
-- 
-- SELECT table_name
--      , privilege
-- FROM dba_tab_privs
-- WHERE grantee = 'SYSTEM'
-- AND table_name IN ('V_$SYSMETRIC_HISTORY', 'DBA_HIST_SYSMETRIC_SUMMARY')
-- ORDER BY 1
-- ;
-- 
-- TABLE_NAME                   PRIVILEGE
-- ---------------------------- ----------
-- DBA_HIST_SYSMETRIC_SUMMARY   SELECT
-- V_$SYSMETRIC_HISTORY         SELECT

PROMPT ===========================================
PROMPT  Average Runnable Processes in Last 1 Hour
PORMPT ===========================================

SET LINESIZE 200
SET PAGESIZE 300

COLUMN sample_time FORMAT a12
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

-- 
-- Creating a view named "arp_in_last_1_hour" to show "sample_time" and "value" based on
-- the four metrics amongst "Instance Foreground CPU", "Instance Background CPU",
-- "Non-Database Host CPU" and "Load Average" from v$sysmetric_history in last 1 hour.
-- 

CREATE OR REPLACE VIEW arp_in_last_1_hour
AS
WITH
ins_fg_cpu AS
(
  SELECT TO_CHAR(end_time, 'hh24:mi:ss') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(value/1e2, 2) value
  FROM v$sysmetric_history
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT TO_CHAR(end_time, 'hh24:mi:ss') sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(value/1e2, 2) value
  FROM v$sysmetric_history
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT TO_CHAR(end_time, 'hh24:mi:ss') sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(value/1e2, 2) value
  FROM v$sysmetric_history
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT TO_CHAR(end_time, 'hh24:mi:ss') sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(value, 2) value
  FROM v$sysmetric_history
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
)
SELECT * FROM ins_fg_cpu
UNION ALL
SELECT * FROM ins_bg_cpu
UNION ALL
SELECT * FROM non_db_host_cpu
UNION ALL
SELECT * FROM load_average
;

-- 
-- Creating a procedure named "pro_convert_rows_to_columns" to dynamically convert "sample_time"
-- from rows to columns based on the previous view "arp_in_last_1_hour".
-- 

CREATE OR REPLACE PROCEDURE pro_convert_rows_to_columns
AUTHID CURRENT_USER
IS
  v_sql VARCHAR2(4000);
  CURSOR cur_samp_time IS
  SELECT sample_time
  FROM arp_in_last_1_hour
  WHERE metric_name = 'Instance Foreground CPU'
  ORDER BY sample_time;
BEGIN
  v_sql := Q'[SELECT metric_name]';

  FOR v_samp_time IN cur_samp_time
  LOOP
    v_sql := v_sql || Q'[, MAX(DECODE(sample_time, ']'
                   || v_samp_time.sample_time
                   || Q'[', value)) AS "]'
                   || v_samp_time.sample_time
                   || Q'["]';
  END LOOP;
  
  v_sql := v_sql || Q'[ FROM arp_in_last_1_hour GROUP BY metric_name]'
                 || Q'[ ORDER BY DECODE(metric_name,]'
                 || Q'[  'Instance Foreground CPU', 1]'
                 || Q'[, 'Instance Background CPU', 2]'
                 || Q'[, 'Non-Database Host CPU'  , 3]'
                 || Q'[, 'Load Average'           , 4]'
                 || Q'[)]';

  v_sql := 'CREATE OR REPLACE VIEW arp_in_last_1_hour_result AS ' || v_sql;

  EXECUTE IMMEDIATE v_sql;
END;
/

-- 
-- Running the previous procedure "pro_convert_rows_to_columns" to create view
-- "arp_in_last_1_hour_result" to save the result of converting rows to columns dynamically.
-- 
-- Firstly executing "SET SQLFORMAT csv" on Oracle SQL Developer 21.2 next running the following SQL query
-- by clicking the button of "Run Script" or pressing F5 to show the CSV format, finally save this CSV file
-- "arp_1.csv" to your local computer.
-- 

EXECUTE pro_convert_rows_to_columns;

SET SQLFORMAT csv;

SELECT * FROM arp_in_last_1_hour_result;

PROMPT =============================================
PROMPT  Average Runnable Processes in Last 24 Hours
PORMPT =============================================

SET LINESIZE 200
SET PAGESIZE 300

COLUMN sample_time FORMAT a20
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

-- 
-- Creating a view named "arp_in_last_24_hours" to show "sample_time" and "value" based on
-- the four metrics amongst "Instance Foreground CPU", "Instance Background CPU",
-- "Non-Database Host CPU" and "Load Average" from dba_hist_sysmetric_summary in last 24 hours.
-- 

CREATE OR REPLACE VIEW arp_in_last_24_hours
AS
WITH
ins_fg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '24' HOUR
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '24' HOUR
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '24' HOUR
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(average, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '24' HOUR
  ORDER BY sample_time
)
SELECT * FROM ins_fg_cpu
UNION ALL
SELECT * FROM ins_bg_cpu
UNION ALL
SELECT * FROM non_db_host_cpu
UNION ALL
SELECT * FROM load_average
;

-- 
-- Creating a procedure named "pro_convert_rows_to_columns_2" to dynamically convert "sample_time"
-- from rows to columns based on the previous view "arp_in_last_24_hours".
-- 

CREATE OR REPLACE PROCEDURE pro_convert_rows_to_columns_2
AUTHID CURRENT_USER
IS
  v_sql VARCHAR2(4000);
  CURSOR cur_samp_time IS
  SELECT sample_time
  FROM arp_in_last_24_hours
  WHERE metric_name = 'Instance Foreground CPU'
  ORDER BY sample_time;
BEGIN
  v_sql := Q'[SELECT metric_name]';

  FOR v_samp_time IN cur_samp_time
  LOOP
    v_sql := v_sql || Q'[, MAX(DECODE(sample_time, ']'
                   || v_samp_time.sample_time
                   || Q'[', value)) AS "]'
                   || v_samp_time.sample_time
                   || Q'["]';
  END LOOP;
  
  v_sql := v_sql || Q'[ FROM arp_in_last_24_hours GROUP BY metric_name]'
                 || Q'[ ORDER BY DECODE(metric_name,]'
                 || Q'[  'Instance Foreground CPU', 1]'
                 || Q'[, 'Instance Background CPU', 2]'
                 || Q'[, 'Non-Database Host CPU'  , 3]'
                 || Q'[, 'Load Average'           , 4]'
                 || Q'[)]';

  v_sql := 'CREATE OR REPLACE VIEW arp_in_last_24_hours_result AS ' || v_sql;

  EXECUTE IMMEDIATE v_sql;
END;
/

-- 
-- Running the previous procedure "pro_convert_rows_to_columns_2" to create view
-- "arp_in_last_24_hours_result" to save the result of converting rows to columns dynamically.
-- 
-- Firstly executing "SET SQLFORMAT csv" on Oracle SQL Developer 21.2 next running the following SQL query
-- by clicking the button of "Run Script" or pressing F5 to show the CSV format, finally save this CSV file
-- "arp_2.csv" to your local computer.
-- 

EXECUTE pro_convert_rows_to_columns_2;

SET SQLFORMAT csv;

SELECT * FROM arp_in_last_24_hours_result;

PROMPT ===================================================================
PROMPT  Average Runnable Processes in Last 7 Days (interval by each hour)
PORMPT ===================================================================

SET LINESIZE 200
SET PAGESIZE 700

COLUMN sample_time FORMAT a20
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

-- 
-- Creating a view named "arp_in_last_7_days" to show "sample_time" and "value" based on
-- the four metrics amongst "Instance Foreground CPU", "Instance Background CPU",
-- "Non-Database Host CPU" and "Load Average" from dba_hist_sysmetric_summary
-- in last 7 days (interval by each hour).
-- 

CREATE OR REPLACE VIEW arp_in_last_7_days
AS
WITH
ins_fg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '6' DAY
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '6' DAY
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '6' DAY
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(average, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '6' DAY
  ORDER BY sample_time
)
SELECT * FROM ins_fg_cpu
UNION ALL
SELECT * FROM ins_bg_cpu
UNION ALL
SELECT * FROM non_db_host_cpu
UNION ALL
SELECT * FROM load_average
;

-- 
-- Creating a procedure named "pro_convert_rows_to_columns_3" to dynamically convert "sample_time"
-- from rows to columns based on the previous view "arp_in_last_7_days".
-- 

CREATE OR REPLACE PROCEDURE pro_convert_rows_to_columns_3
AUTHID CURRENT_USER
IS
  v_sql CLOB;
  CURSOR cur_samp_time IS
  SELECT sample_time
  FROM arp_in_last_7_days
  WHERE metric_name = 'Instance Foreground CPU'
  ORDER BY sample_time;
BEGIN
  v_sql := Q'[SELECT metric_name]';

  FOR v_samp_time IN cur_samp_time
  LOOP
    v_sql := v_sql || Q'[, MAX(DECODE(sample_time, ']'
                   || v_samp_time.sample_time
                   || Q'[', value)) AS "]'
                   || v_samp_time.sample_time
                   || Q'["]';
  END LOOP;
  
  v_sql := v_sql || Q'[ FROM arp_in_last_7_days GROUP BY metric_name]'
                 || Q'[ ORDER BY DECODE(metric_name,]'
                 || Q'[  'Instance Foreground CPU', 1]'
                 || Q'[, 'Instance Background CPU', 2]'
                 || Q'[, 'Non-Database Host CPU'  , 3]'
                 || Q'[, 'Load Average'           , 4]'
                 || Q'[)]';

  v_sql := 'CREATE OR REPLACE VIEW arp_in_last_7_days_result AS ' || v_sql;

  EXECUTE IMMEDIATE v_sql;
END;
/

-- 
-- Running the previous procedure "pro_convert_rows_to_columns_3" to create view
-- "arp_in_last_7_days_result" to save the result of converting rows to columns dynamically.
-- 
-- Firstly executing "SET SQLFORMAT csv" on Oracle SQL Developer 21.2 next running the following SQL query
-- by clicking the button of "Run Script" or pressing F5 to show the CSV format, finally save this CSV file
-- "arp_3.csv" to your local computer.
-- 

EXECUTE pro_convert_rows_to_columns_3;

SET SQLFORMAT csv;

SELECT * FROM arp_in_last_7_days_result;

PROMPT ==================================================================
PROMPT  Average Runnable Processes in Last 7 Days (interval by each day)
PORMPT ==================================================================

SET LINESIZE 200
SET PAGESIZE 100

COLUMN sample_time FORMAT a12
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

-- 
-- Creating a view named "arp_in_last_7_days_2" to show "sample_time" and "value" based on
-- the four metrics amongst "Instance Foreground CPU", "Instance Background CPU",
-- "Non-Database Host CPU" and "Load Average" based on the view "arp_in_last_7_days"
-- in last 7 days (interval by each day).
-- 

CREATE OR REPLACE VIEW arp_in_last_7_days_2
AS
SELECT TO_CHAR(TO_DATE(sample_time, 'yyyy-mm-dd hh24:mi'), 'yyyy-mm-dd') sample_time
     , metric_name
     , ROUND(AVG(value), 2) value
FROM arp_in_last_7_days
GROUP BY TO_CHAR(TO_DATE(sample_time, 'yyyy-mm-dd hh24:mi'), 'yyyy-mm-dd')
       , metric_name
ORDER BY DECODE(metric_name, 'Instance Foreground CPU', 1
                           , 'Instance Background CPU', 2
                           , 'Non-Database Host CPU'  , 3
                           , 'Load Average'           , 4
               )
       , sample_time
;

-- 
-- Creating a procedure named "pro_convert_rows_to_columns_4" to dynamically convert "sample_time"
-- from rows to columns based on the previous view "arp_in_last_7_days_2".
-- 

CREATE OR REPLACE PROCEDURE pro_convert_rows_to_columns_4
AUTHID CURRENT_USER
IS
  v_sql VARCHAR2(4000);
  CURSOR cur_samp_time IS
  SELECT sample_time
  FROM arp_in_last_7_days_2
  WHERE metric_name = 'Instance Foreground CPU'
  ORDER BY sample_time;
BEGIN
  v_sql := Q'[SELECT metric_name]';

  FOR v_samp_time IN cur_samp_time
  LOOP
    v_sql := v_sql || Q'[, MAX(DECODE(sample_time, ']'
                   || v_samp_time.sample_time
                   || Q'[', value)) AS "]'
                   || v_samp_time.sample_time
                   || Q'["]';
  END LOOP;
  
  v_sql := v_sql || Q'[ FROM arp_in_last_7_days_2 GROUP BY metric_name]'
                 || Q'[ ORDER BY DECODE(metric_name,]'
                 || Q'[  'Instance Foreground CPU', 1]'
                 || Q'[, 'Instance Background CPU', 2]'
                 || Q'[, 'Non-Database Host CPU'  , 3]'
                 || Q'[, 'Load Average'           , 4]'
                 || Q'[)]';

  v_sql := 'CREATE OR REPLACE VIEW arp_in_last_7_days_2_result AS ' || v_sql;

  EXECUTE IMMEDIATE v_sql;
END;
/

-- 
-- Running the previous procedure "pro_convert_rows_to_columns_4" to create view
-- "arp_in_last_7_days_2_result" to save the result of converting rows to columns dynamically.
-- 
-- Firstly executing "SET SQLFORMAT csv" on Oracle SQL Developer 21.2 next running the following SQL query
-- by clicking the button of "Run Script" or pressing F5 to show the CSV format, finally save this CSV file
-- "arp_4.csv" to your local computer.
-- 

EXECUTE pro_convert_rows_to_columns_4;

SET SQLFORMAT csv;

SELECT * FROM arp_in_last_7_days_2_result;

PROMPT ====================================================================
PROMPT  Average Runnable Processes in Last 31 Days (interval by each hour)
PORMPT ====================================================================

SET LINESIZE 200
SET PAGESIZE 3000

COLUMN sample_time FORMAT a20
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

-- 
-- Creating a view named "arp_in_last_31_days" to show "sample_time" and "value" based on
-- the four metrics amongst "Instance Foreground CPU", "Instance Background CPU",
-- "Non-Database Host CPU" and "Load Average" from dba_hist_sysmetric_summary
-- in last 31 days (interval by each hour).
-- 

CREATE OR REPLACE VIEW arp_in_last_31_days
AS
WITH
ins_fg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '30' DAY
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '30' DAY
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '30' DAY
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(average, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '30' DAY
  ORDER BY sample_time
)
SELECT * FROM ins_fg_cpu
UNION ALL
SELECT * FROM ins_bg_cpu
UNION ALL
SELECT * FROM non_db_host_cpu
UNION ALL
SELECT * FROM load_average
;

-- 
-- Creating a procedure named "pro_convert_rows_to_columns_5" to dynamically convert "sample_time"
-- from rows to columns based on the previous view "arp_in_last_31_days".
-- 

CREATE OR REPLACE PROCEDURE pro_convert_rows_to_columns_5
AUTHID CURRENT_USER
IS
  v_sql CLOB;
  CURSOR cur_samp_time IS
  SELECT sample_time
  FROM arp_in_last_31_days
  WHERE metric_name = 'Instance Foreground CPU'
  ORDER BY sample_time;
BEGIN
  v_sql := Q'[SELECT metric_name]';

  FOR v_samp_time IN cur_samp_time
  LOOP
    v_sql := v_sql || Q'[, MAX(DECODE(sample_time, ']'
                   || v_samp_time.sample_time
                   || Q'[', value)) AS "]'
                   || v_samp_time.sample_time
                   || Q'["]';
  END LOOP;
  
  v_sql := v_sql || Q'[ FROM arp_in_last_31_days GROUP BY metric_name]'
                 || Q'[ ORDER BY DECODE(metric_name,]'
                 || Q'[  'Instance Foreground CPU', 1]'
                 || Q'[, 'Instance Background CPU', 2]'
                 || Q'[, 'Non-Database Host CPU'  , 3]'
                 || Q'[, 'Load Average'           , 4]'
                 || Q'[)]';

  v_sql := 'CREATE OR REPLACE VIEW arp_in_last_31_days_result AS ' || v_sql;

  EXECUTE IMMEDIATE v_sql;
END;
/

-- 
-- Running the previous procedure "pro_convert_rows_to_columns_5" to create view
-- "arp_in_last_31_days_result" to save the result of converting rows to columns dynamically.
-- 
-- Firstly executing "SET SQLFORMAT csv" on Oracle SQL Developer 21.2 next running the following SQL query
-- by clicking the button of "Run Script" or pressing F5 to show the CSV format, finally save this CSV file
-- "arp_5.csv" to your local computer.
-- 

EXECUTE pro_convert_rows_to_columns_5;

SET SQLFORMAT csv;

SELECT * FROM arp_in_last_31_days_result;

PROMPT ===================================================================
PROMPT  Average Runnable Processes in Last 31 Days (interval by each day)
PORMPT ===================================================================

SET LINESIZE 200
SET PAGESIZE 100

COLUMN sample_time FORMAT a12
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

-- 
-- Creating a view named "arp_in_last_31_days_2" to show "sample_time" and "value" based on
-- the four metrics amongst "Instance Foreground CPU", "Instance Background CPU",
-- "Non-Database Host CPU" and "Load Average" based on the view "arp_in_last_31_days"
-- in last 31 days (interval by each day).
-- 

CREATE OR REPLACE VIEW arp_in_last_31_days_2
AS
SELECT TO_CHAR(TO_DATE(sample_time, 'yyyy-mm-dd hh24:mi'), 'yyyy-mm-dd') sample_time
     , metric_name
     , ROUND(AVG(value), 2) value
FROM arp_in_last_31_days
GROUP BY TO_CHAR(TO_DATE(sample_time, 'yyyy-mm-dd hh24:mi'), 'yyyy-mm-dd')
       , metric_name
ORDER BY DECODE(metric_name, 'Instance Foreground CPU', 1
                           , 'Instance Background CPU', 2
                           , 'Non-Database Host CPU'  , 3
                           , 'Load Average'           , 4
               )
       , sample_time
;

-- 
-- Creating a procedure named "pro_convert_rows_to_columns_6" to dynamically convert "sample_time"
-- from rows to columns based on the previous view "arp_in_last_31_days_2".
-- 

CREATE OR REPLACE PROCEDURE pro_convert_rows_to_columns_6
AUTHID CURRENT_USER
IS
  v_sql VARCHAR2(4000);
  CURSOR cur_samp_time IS
  SELECT sample_time
  FROM arp_in_last_31_days_2
  WHERE metric_name = 'Instance Foreground CPU'
  ORDER BY sample_time;
BEGIN
  v_sql := Q'[SELECT metric_name]';

  FOR v_samp_time IN cur_samp_time
  LOOP
    v_sql := v_sql || Q'[, MAX(DECODE(sample_time, ']'
                   || v_samp_time.sample_time
                   || Q'[', value)) AS "]'
                   || v_samp_time.sample_time
                   || Q'["]';
  END LOOP;
  
  v_sql := v_sql || Q'[ FROM arp_in_last_31_days_2 GROUP BY metric_name]'
                 || Q'[ ORDER BY DECODE(metric_name,]'
                 || Q'[  'Instance Foreground CPU', 1]'
                 || Q'[, 'Instance Background CPU', 2]'
                 || Q'[, 'Non-Database Host CPU'  , 3]'
                 || Q'[, 'Load Average'           , 4]'
                 || Q'[)]';

  v_sql := 'CREATE OR REPLACE VIEW arp_in_last_31_days_2_result AS ' || v_sql;

  EXECUTE IMMEDIATE v_sql;
END;
/

-- 
-- Running the previous procedure "pro_convert_rows_to_columns_6" to create view
-- "arp_in_last_31_days_2_result" to save the result of converting rows to columns dynamically.
--  
-- Firstly executing "SET SQLFORMAT csv" on Oracle SQL Developer 21.2 next running the following SQL query
-- by clicking the button of "Run Script" or pressing F5 to show the CSV format, finally save this CSV file
-- "arp_6.csv" to your local computer.
-- 

EXECUTE pro_convert_rows_to_columns_6;

SET SQLFORMAT csv;

SELECT * FROM arp_in_last_31_days_2_result;

PROMPT =======================================================================
PROMPT  Average Runnable Processes Custom Time Period (interval by each hour)
PORMPT =======================================================================

SET VERIFY OFF

SET LINESIZE 200
SET PAGESIZE 3000

COLUMN sample_time FORMAT a20
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

-- 
-- Creating a view named "arp_custom_time_period" to show "sample_time" and "value" based on
-- the four metrics amongst "Instance Foreground CPU", "Instance Background CPU",
-- "Non-Database Host CPU" and "Load Average" from dba_hist_sysmetric_summary
-- custom time period (interval by each hour).
-- 

CREATE OR REPLACE VIEW arp_custom_time_period
AS
WITH
ins_fg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   (end_time BETWEEN TO_DATE('&&start_date', 'yyyy-mm-dd hh24:mi')
                  AND     TO_DATE('&&end_date', 'yyyy-mm-dd hh24:mi')
        )
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   (end_time BETWEEN TO_DATE('&&start_date', 'yyyy-mm-dd hh24:mi')
                  AND     TO_DATE('&&end_date', 'yyyy-mm-dd hh24:mi')
        )
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(average/1e2, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   (end_time BETWEEN TO_DATE('&&start_date', 'yyyy-mm-dd hh24:mi')
                  AND     TO_DATE('&&end_date', 'yyyy-mm-dd hh24:mi')
        )
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi') sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(average, 2) value
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   (end_time BETWEEN TO_DATE('&&start_date', 'yyyy-mm-dd hh24:mi')
                  AND     TO_DATE('&&end_date', 'yyyy-mm-dd hh24:mi')
        )
  ORDER BY sample_time
)
SELECT * FROM ins_fg_cpu
UNION ALL
SELECT * FROM ins_bg_cpu
UNION ALL
SELECT * FROM non_db_host_cpu
UNION ALL
SELECT * FROM load_average
;

-- 
-- Creating a procedure named "pro_convert_rows_to_columns_7" to dynamically convert "sample_time"
-- from rows to columns based on the previous view "arp_custom_time_period".
-- 

CREATE OR REPLACE PROCEDURE pro_convert_rows_to_columns_7
AUTHID CURRENT_USER
IS
  v_sql CLOB;
  CURSOR cur_samp_time IS
  SELECT sample_time
  FROM arp_custom_time_period
  WHERE metric_name = 'Instance Foreground CPU'
  ORDER BY sample_time;
BEGIN
  v_sql := Q'[SELECT metric_name]';

  FOR v_samp_time IN cur_samp_time
  LOOP
    v_sql := v_sql || Q'[, MAX(DECODE(sample_time, ']'
                   || v_samp_time.sample_time
                   || Q'[', value)) AS "]'
                   || v_samp_time.sample_time
                   || Q'["]';
  END LOOP;
  
  v_sql := v_sql || Q'[ FROM arp_custom_time_period GROUP BY metric_name]'
                 || Q'[ ORDER BY DECODE(metric_name,]'
                 || Q'[  'Instance Foreground CPU', 1]'
                 || Q'[, 'Instance Background CPU', 2]'
                 || Q'[, 'Non-Database Host CPU'  , 3]'
                 || Q'[, 'Load Average'           , 4]'
                 || Q'[)]';

  v_sql := 'CREATE OR REPLACE VIEW arp_custom_time_period_result AS ' || v_sql;

  EXECUTE IMMEDIATE v_sql;
END;
/

-- 
-- Running the previous procedure "pro_convert_rows_to_columns_7" to create view
-- "arp_custom_time_period_result" to save the result of converting rows to columns dynamically.
-- 
-- Firstly executing "SET SQLFORMAT csv" on Oracle SQL Developer 21.2 next running the following SQL query
-- by clicking the button of "Run Script" or pressing F5 to show the CSV format, finally save this CSV file
-- "arp_7.csv" to your local computer.
-- 

EXECUTE pro_convert_rows_to_columns_7;

SET SQLFORMAT csv;

SELECT * FROM arp_custom_time_period_result;

PROMPT ======================================================================
PROMPT  Average Runnable Processes Custom Time Period (interval by each day)
PORMPT ======================================================================

SET VERIFY OFF

SET LINESIZE 200
SET PAGESIZE 100

COLUMN sample_time FORMAT a12
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.99

-- 
-- Creating a view named "arp_custom_time_period_2" to show "sample_time" and "value" based on
-- the four metrics amongst "Instance Foreground CPU", "Instance Background CPU",
-- "Non-Database Host CPU" and "Load Average" based on the view "arp_custom_time_period"
-- custom time period (interval by each day).
-- 

CREATE OR REPLACE VIEW arp_custom_time_period_2
AS
SELECT TO_CHAR(TO_DATE(sample_time, 'yyyy-mm-dd hh24:mi'), 'yyyy-mm-dd') sample_time
     , metric_name
     , ROUND(AVG(value), 2) value
FROM arp_custom_time_period
GROUP BY TO_CHAR(TO_DATE(sample_time, 'yyyy-mm-dd hh24:mi'), 'yyyy-mm-dd')
       , metric_name
ORDER BY DECODE(metric_name, 'Instance Foreground CPU', 1
                           , 'Instance Background CPU', 2
                           , 'Non-Database Host CPU'  , 3
                           , 'Load Average'           , 4
               )
       , sample_time
;

-- 
-- Creating a procedure named "pro_convert_rows_to_columns_8" to dynamically convert "sample_time"
-- from rows to columns based on the previous view "arp_custom_time_period_2".
-- 

CREATE OR REPLACE PROCEDURE pro_convert_rows_to_columns_8
AUTHID CURRENT_USER
IS
  v_sql VARCHAR2(4000);
  CURSOR cur_samp_time IS
  SELECT sample_time
  FROM arp_custom_time_period_2
  WHERE metric_name = 'Instance Foreground CPU'
  ORDER BY sample_time;
BEGIN
  v_sql := Q'[SELECT metric_name]';

  FOR v_samp_time IN cur_samp_time
  LOOP
    v_sql := v_sql || Q'[, MAX(DECODE(sample_time, ']'
                   || v_samp_time.sample_time
                   || Q'[', value)) AS "]'
                   || v_samp_time.sample_time
                   || Q'["]';
  END LOOP;
  
  v_sql := v_sql || Q'[ FROM arp_custom_time_period_2 GROUP BY metric_name]'
                 || Q'[ ORDER BY DECODE(metric_name,]'
                 || Q'[  'Instance Foreground CPU', 1]'
                 || Q'[, 'Instance Background CPU', 2]'
                 || Q'[, 'Non-Database Host CPU'  , 3]'
                 || Q'[, 'Load Average'           , 4]'
                 || Q'[)]';

  v_sql := 'CREATE OR REPLACE VIEW arp_custom_time_period_2_res AS ' || v_sql;

  EXECUTE IMMEDIATE v_sql;
END;
/

-- 
-- Running the previous procedure "pro_convert_rows_to_columns_8" to create view
-- "arp_custom_time_period_2_res" to save the result of converting rows to columns dynamically.
-- 
-- Firstly executing "SET SQLFORMAT csv" on Oracle SQL Developer 21.2 next running the following SQL query
-- by clicking the button of "Run Script" or pressing F5 to show the CSV format, finally save this CSV file
-- "arp_8.csv" to your local computer.
-- 

EXECUTE pro_convert_rows_to_columns_8;

SET SQLFORMAT csv;

SELECT * FROM arp_custom_time_period_2_res;

########################################################################################################################

-- The original code.
                         
-- http://datavirtualizer.com/oracle-cpu-time/
-- 
-- Hello kyle,
-- could you please elaborate (again!) a little bit further on CPU_OS.
-- While it’s clear to me that
-- CPU_ORA is the average number of oracle sessions running on cpu
-- CPU_ORA_WAIT is the average number of oracle sessions waiting for cpu
-- and so on for all other columns,
-- I hardly understand what CPU_OS relates to in terms of average number of sessions. To me CPU_ORA contains all the cpu consumed by oracle sessions, so how could it be we have sessions using non oracle cpu ?
-- Thanks !
-- Olivier
-- 
-- Everything is measured in AAS, which is similar to OS runqueue
-- 
-- CPU_TOTAL: CPU used on the host
-- CPU_OS: CPU used on the host processes but not by Oracle processes, ie CPU_TOTAL – CPU_ORA
-- CPU_ORA: CPU used by Oracle processes
-- CPU_ORA_WAIT: CPU wanted by Oracle processes but not obtained, ie CPU_from_ASH – CPU_ORA
-- 
-- Non-Database Host CPU Usage Per Sec = Host CPU Usage Per Sec - CPU Usage Per Sec - Background CPU Usage Per Sec
-- In other words Non-Database Host CPU = Host CPU - Foreground CPU - Background CPU

-- Average Runnable Processes in Last 1 Hour.

SET LINESIZE 200
SET PAGESIZE 300

COLUMN metric_name FORMAT a25

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH ins_fg_cpu AS
(
  SELECT end_time sample_time
       , DECODE(metric_name, 'CPU Usage Per Sec', 'Instance Foreground CPU') metric_name
       , ROUND(value/1e2, 2) value
  FROM v$sysmetric_history
  WHERE metric_name = 'CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
),
ins_bg_cpu AS
(
  SELECT end_time sample_time
       , DECODE(metric_name, 'Background CPU Usage Per Sec', 'Instance Background CPU') metric_name
       , ROUND(value/1e2, 2) value
  FROM v$sysmetric_history
  WHERE metric_name = 'Background CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
),
host_cpu AS
(
  SELECT end_time sample_time
       , DECODE(metric_name, 'Host CPU Usage Per Sec', 'Host CPU') metric_name
       , ROUND(value/1e2, 2) value
  FROM v$sysmetric_history
  WHERE metric_name = 'Host CPU Usage Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
),
non_db_host_cpu AS
(
  SELECT hc.sample_time
       , 'Non-Database Host CPU' metric_name
       , hc.value - fc.value - bc.value value
  FROM host_cpu hc
     , ins_fg_cpu fc
     , ins_bg_cpu bc
  WHERE hc.sample_time = fc.sample_time
  AND   fc.sample_time = bc.sample_time
  ORDER BY hc.sample_time
),
load_average AS
(
  SELECT end_time sample_time
       , DECODE(metric_name, 'Current OS Load', 'Load Average') metric_name
       , ROUND(value, 2) value
  FROM v$sysmetric_history
  WHERE metric_name = 'Current OS Load'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY sample_time
)
SELECT * FROM ins_fg_cpu
UNION ALL
SELECT * FROM ins_bg_cpu
UNION ALL
SELECT * FROM non_db_host_cpu
UNION ALL
SELECT * FROM load_average
;
