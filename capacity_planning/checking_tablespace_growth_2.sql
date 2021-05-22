REM
REM     Script:        checking_tablespace_growth_2.sql
REM     Author:        Quanwen Zhao
REM     Dated:         May 22, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM
REM     Purpose:
REM       The 2nd version of the previous SQL script with "checking_tablespace_growth.sql",
REM       which does some enhancement according to the 1st version:
REM       (1) adding the functionality with checking the internval and retention of AWR setting of Oracle Database;
REM       (2) adding the functionality with checking the *MIN* and *MAX* end_interval_time in history snapshot of Oracle Database;
REM       (3) adding the functionality with listing all of the tablespace names existing in Oracle Database;
REM       (4) adding the interactive prompt message that makes you pause notably after running one SQL query,
REM           you need to press Enter key to run the next SQL query.
REM

SET LINESIZE 300
SET PAGESIZE 300

-- 
-- Changing the value of TIMESTAMP to the given format in this session like this, 'yyyy-mm-dd hh24:mi:ss'.
-- 

ALTER SESSION SET nls_timestamp_format = 'yyyy-mm-dd hh24:mi:ss';

-- Press Enter to contiune.

PAUSE

-- 
-- Checking the internval and retention of AWR setting of Oracle Database.
-- 

COLUMN snap_interval FORMAT a20
COLUMN retention     FORMAT a20

SELECT * FROM dba_hist_wr_control;

-- Press Enter to continue.

PAUSE

-- 
-- Checking the *MIN* interval time and *MAX* interval time in history snapshot of Oracle Database.
-- They'll show based on my previous setting for TIMESTAMP value.
-- 

COLUMN MIN(end_interval_time) FORMAT a30
COLUMN MAX(end_interval_time) FORMAT a30

SELECT MIN(end_interval_time), MAX(end_interval_time) FROM dba_hist_snapshot;

-- Press Enter to continue.

PAUSE

-- 
-- Listing all of the tablespace names existing in Oracle Database.
-- 

COLUMN tablespace_name FORMAT a115

SELECT LOWER(LISTAGG(tablespace_name, ', ') WITHIN GROUP (ORDER BY tablespace_name)) AS tablespace_name
  FROM dba_tablespaces;

-- Press Enter to continue.

PAUSE

-- 
-- Checking the total and used size of tablespace (what you input according to the preceding lists)
-- existing in the AWR repository base on snap time, at this moment you should input the time with
-- "hour:minute" (you're able to retrieve something from the prior 2 number of SQL query about
-- Oracle Static Performance View "dba_hist_snapshot" and "dba_hist_wr_control"), of course, not
-- including double quotation marks after running subsequent SQL statement.
-- 

COLUMN tablespace_name    FORMAT a35
COLUMN snap_date_and_time FORMAT a25
COLUMN total_gb           FORMAT 999,999,999.999999
COLUMN used_gb            FORMAT 999,999,999.999999

SELECT dt.tablespace_name,
       TO_CHAR(dhs.end_interval_time, 'yyyy-mm-dd hh24:mi:ss') AS snap_date_and_time,
       SUM(dhtsu.tablespace_size * dt.block_size) / POWER(2, 30) AS total_gb,
       SUM(dhtsu.tablespace_usedsize * dt.block_size) / POWER(2, 30) AS used_gb
  FROM dba_hist_tbspc_space_usage dhtsu,
       dba_hist_snapshot          dhs,
       v$tablespace               vts,
       dba_tablespaces            dt
 WHERE dhtsu.snap_id = dhs.snap_id
   AND dhtsu.dbid = dhs.dbid
-- AND dhs.instance_number = 1
   AND dhtsu.tablespace_id = vts.ts#
   AND vts.name = dt.tablespace_name
   AND dt.tablespace_name = UPPER('&tablespace_name')
   AND TO_CHAR(dhs.end_interval_time, 'yyyy-mm-dd hh24:mi:SS') LIKE '%&snap_time%'
 GROUP BY dt.tablespace_name, dhs.end_interval_time
 ORDER BY tablespace_name, snap_date_and_time
;
