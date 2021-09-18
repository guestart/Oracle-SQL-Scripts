REM
REM     Script:        acquire_dbtime.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 18, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM     Reference:
REM             https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-SYS_TIME_MODEL.html#GUID-DC16AB84-4978-497B-8AFB-C3C23D83FC3C
REM             http://blog.itpub.net/28602568/viewspace-1467897/
REM

SET LINESIZE 200
SET PAGESIZE 300

COLUMN begin_time FORMAT a19
COLUMN end_time   FORMAT a19
COLUMN stat_name  FORMAT a10

SELECT * FROM
(
 SELECT dhsp.instance_number
      , LAG(dhsp.snap_id, 1, 0) OVER (ORDER BY dhsp.snap_id) first_snap_id
      , dhsp.snap_id second_snap_id
      , TO_CHAR(dhsp.begin_interval_time, 'yyyy-mm-dd hh24:mi:ss') begin_time
      , TO_CHAR(dhsp.end_interval_time, 'yyyy-mm-dd hh24:mi:ss') end_time
      , dhstm.stat_name
      , ROUND((dhstm.value - LAG(dhstm.value, 1, 0) OVER (ORDER BY dhsp.snap_id))/1e6/6e1, 2) dbtime_mins
 FROM dba_hist_snapshot dhsp
    , dba_hist_sys_time_model dhstm
 WHERE dhsp.snap_id = dhstm.snap_id
 AND   dhsp.dbid = dhstm.dbid
 AND   dhsp.instance_number = dhstm.instance_number
 AND   dhstm.stat_name = 'DB time'
 -- AND   LAG(dhsp.snap_id, 1, 0) OVER (ORDER BY dhsp.snap_id) <> 0
 ORDER BY dhsp.snap_id
)
WHERE first_snap_id <> 0
;
