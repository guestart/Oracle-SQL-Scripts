REM
REM     Script:        acquire_cpu_load.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 27, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       The formula calculating "CPU Load" is "DB Time/(Elapsed Time*CPU_NUMS)*100%" (these metrics are from AWR report),
REM       We can get "DB Time" and "Elapsed Time" from the SQL script (https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_dbtime.sql),
REM       and we can also get the number of cpus from the view "DBA_HIST_OSSTAT" by querying the column "stat_name"
REM       who equals to "num_cpus".
REM
REM       Utimately we can get all of the values with "CPU Load" from the historical AWR reports of oracle database.
REM
REM     Reference:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SNAPSHOT.html#GUID-542B6CA6-793B-4D15-AAFD-4D3E6550C0B6
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYS_TIME_MODEL.html#GUID-263D0396-7C98-4C26-9993-DCC42EA9E87E
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_OSSTAT.html#GUID-C94C3F25-ADE2-4E4C-B942-C0D14D9441D8
REM

SET LINESIZE 200
SET PAGESIZE 300

COLUMN begin_time FORMAT a19
COLUMN end_time   FORMAT a19
COLUMN stat_name  FORMAT a10

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH
dhsp AS (
          SELECT snap_id
               , dbid
               , instance_number
               , begin_interval_time
               , end_interval_time
          FROM dba_hist_snapshot
        ),
dhstm AS (
           SELECT snap_id
                , dbid
                , instance_number
                , stat_name
                , value
           FROM dba_hist_sys_time_model
           WHERE stat_name = 'DB time'
         ),
dhos AS (
          SELECT snap_id
               , dbid
               , instance_number
               , stat_name
               , value
          FROM dba_hist_osstat
          WHERE stat_name = 'NUM_CPUS'
        ),
all_awr_dbtime_and_cpus AS (
                             SELECT dhsp.instance_number
                                  , LAG(dhsp.snap_id, 1, 0) OVER (PARTITION BY dhsp.dbid, dhsp.instance_number ORDER BY dhsp.snap_id) first_snap_id
                                  , dhsp.snap_id second_snap_id
                                  , CAST(dhsp.begin_interval_time AS DATE) begin_time
                                  , CAST(dhsp.end_interval_time AS DATE) end_time
                                  , ROUND((dhstm.value - LAG(dhstm.value, 1, 0) OVER (PARTITION BY dhstm.dbid, dhstm.instance_number ORDER BY dhstm.snap_id))/1e6/6e1, 2) dbtime_mins
                                  , (CAST(dhsp.end_interval_time AS DATE) - CAST(begin_interval_time AS DATE))*24*6e1 elapsed_mins
                                  , dhos.value num_cpus
                             FROM dhsp
                                , dhstm
                                , dhos
                             WHERE dhsp.snap_id = dhstm.snap_id
                             AND   dhsp.instance_number = dhstm.instance_number
                             AND   dhsp.dbid = dhstm.dbid
                             AND   dhstm.snap_id = dhos.snap_id
                             AND   dhstm.instance_number = dhos.instance_number
                             AND   dhstm.dbid = dhos.dbid
                             ORDER BY dhsp.snap_id
                           )
SELECT first_snap_id
     , second_snap_id
     , begin_time
     , end_time
     , ROUND(dbtime_mins/(elapsed_mins*num_cpus)*100, 2) || '%' cpu_load
FROM all_awr_dbtime_and_cpus
WHERE first_snap_id <> 0
;
