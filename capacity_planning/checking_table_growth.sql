REM
REM     Script:        checking_table_growth.sql
REM     Author:        Quanwen Zhao
REM     Dated:         May 20, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM
REM     Purpose:
REM       This SQL script uses to check the growth of table.
REM

SET LINESIZE 300
SET PAGESIZE 300

COLUMN snap_interval FORMAT a20
COLUMN retention     FORMAT a20

SELECT * FROM dba_hist_wr_control;

COLUMN MIN(BEGIN_INTERVAL_TIME) FORMAT a30
COLUMN MAX(END_INTERVAL_TIME)   FORMAT a30

SELECT MIN(begin_interval_time), MAX(end_interval_time) FROM dba_hist_snapshot;

COLUMN table_name          FORMAT a35
COLUMN snap_date           FORMAT a25
COLUMN allocated_total_mb  FORMAT 999,999,999.9999
COLUMN used_total_mb       FORMAT 999,999,999.9999

ALTER SESSION SET nls_date_format = 'YYYY-mm-dd hh24:mi:ss';

SELECT TO_CHAR(dhs.end_interval_time, 'yyyy-mm-dd hh24:mi:ss') AS snap_date,
       dhsso.object_name AS table_name,
       dhss.space_allocated_total / POWER(2, 20) AS allocated_total_mb,
       dhss.space_used_total / POWER(2, 20) AS used_total_mb
  FROM DBA_HIST_SEG_STAT dhss,
       DBA_HIST_SEG_STAT_OBJ dhsso,
       DBA_HIST_SNAPSHOT dhs
 WHERE dhss.snap_id = dhs.snap_id
   AND dhss.dbid= dhs.dbid
   AND dhss.ts#= dhsso.ts#
   AND dhss.obj#=dhsso.obj#
   AND dhsso.owner = UPPER('&owner_name')
   AND dhsso.object_type = 'TABLE'
   AND dhsso.object_name = UPPER('&table_name')
;
