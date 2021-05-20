REM
REM     Script:        checking_tablespace_growth.sql
REM     Author:        Quanwen Zhao
REM     Dated:         May 20, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM
REM     Purpose:
REM       This SQL script uses to check the growth of tablespace.
REM

SET LINESIZE 300
SET PAGESIZE 300

COLUMN snap_interval FORMAT a20
COLUMN retention     FORMAT a20

SELECT * FROM dba_hist_wr_control;

COLUMN MIN(BEGIN_INTERVAL_TIME) FORMAT a30
COLUMN MAX(END_INTERVAL_TIME)   FORMAT a30

SELECT MIN(begin_interval_time), MAX(end_interval_time) FROM dba_hist_snapshot;

COLUMN ts_name   FORMAT a35
COLUMN snap_date FORMAT a25
COLUMN total_gb  FORMAT 999,999,999.9999
COLUMN used_gb   FORMAT 999,999,999.9999

ALTER SESSION SET nls_date_format = 'YYYY-mm-dd hh24:mi:ss';

SELECT dt.tablespace_name AS ts_name,
       TO_CHAR(dhs.end_interval_time, 'yyyy-mm-dd hh24:mi:ss') AS snap_date,
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
-- AND SUBSTR(to_char(end_interval_time, 'yyyy-mm-dd hh24:mi:ss'),12,5)='00:00'
 GROUP BY dt.tablespace_name, dhs.end_interval_time
 ORDER BY ts_name, snap_date DESC
;
