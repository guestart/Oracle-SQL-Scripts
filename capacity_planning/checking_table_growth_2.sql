REM
REM     Script:        checking_table_growth_2.sql
REM     Author:        Quanwen Zhao
REM     Dated:         May 23, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM
REM     Purpose:
REM       The 2nd version of the SQL script "checking_table_growth.sql",
REM       which adds an *AND* condition in the original *WHERE* clause in the last SQL query
REM       inputting the value of snap_time, whose format seems like this: (hour:minute).
REM

SET LINESIZE 300
SET PAGESIZE 300

ALTER SESSION SET nls_timestamp_format = 'yyyy-mm-dd hh24:mi:ss';

COLUMN snap_interval FORMAT a20
COLUMN retention     FORMAT a20

SELECT * FROM dba_hist_wr_control;

COLUMN MIN(end_interval_time) FORMAT a30
COLUMN MAX(end_interval_time) FORMAT a30

SELECT MIN(end_interval_time), MAX(end_interval_time) FROM dba_hist_snapshot;

COLUMN table_name         FORMAT a35
COLUMN snap_date_and_time FORMAT a25
COLUMN used_total_mb      FORMAT 999,999,999.9999
COLUMN used_delta_mb      FORMAT 999,999,999.9999

SELECT dhsso.object_name AS table_name,
       TO_CHAR(dhs.end_interval_time, 'yyyy-mm-dd hh24:mi:ss') AS snap_date_and_time,
       dhss.space_used_total / POWER(2, 20) AS used_total_mb,
       dhss.space_used_delta / POWER(2, 20) AS used_delta_mb
  FROM dba_hist_seg_stat dhss,
       dba_hist_seg_stat_obj dhsso,
       dba_hist_snapshot dhs
 WHERE dhss.snap_id = dhs.snap_id
   AND dhss.dbid = dhs.dbid
   AND dhss.instance_number = dhs.instance_number
   AND dhss.ts#= dhsso.ts#
   AND dhss.obj# = dhsso.obj#
   AND dhss.dataobj# = dhsso.dataobj#
   AND dhsso.owner = UPPER('&owner_name')
   AND dhsso.object_type LIKE '%TABLE%'
   AND dhsso.object_name = UPPER('&table_name')
   AND TO_CHAR(dhs.end_interval_time, 'yyyy-mm-dd hh24:mi:ss') LIKE '%&snap_time%'
 ORDER BY table_name, snap_date_and_time
;
