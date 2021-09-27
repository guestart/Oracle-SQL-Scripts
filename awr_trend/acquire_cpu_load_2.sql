REM
REM     Script:        acquire_cpu_load_2.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 27, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       The 2nd version of acquire_cpu_load.sql (https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_cpu_load.sql),
REM       which is more simple and easy to understand. The another formula calculating "CPU Load" is "Average Active Sessions (AAS)/CPU_NUMS*100%"
REM       (these metrics are from AWR report). We can get "AAS" from the SQL script (https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_aas_2.sql),
REM       and we can also get the number of cpus from the view "DBA_HIST_OSSTAT" by querying the column "stat_name" who equals to "num_cpus".    
REM
REM       Utimately we can get all of the values with "CPU Load" from the historical AWR reports of oracle database.
REM
REM     Reference:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYSMETRIC_SUMMARY.html#GUID-E6377E5F-1FFF-4563-850F-C361B9D85048
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_OSSTAT.html#GUID-C94C3F25-ADE2-4E4C-B942-C0D14D9441D8
REM

SET LINESIZE 200
SET PAGESIZE 300

COLUMN begin_time FORMAT a19
COLUMN end_time   FORMAT a19
COLUMN stat_name  FORMAT a10

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH aas
AS (
     SELECT snap_id
          , dbid
          , instance_number
          , begin_time
          , end_time
          , ROUND(average/1e2, 2) average_active_sessions -- metric_unit is "CentiSeconds Per Second" so average should divide by 1e2.
     FROM dba_hist_sysmetric_summary
  -- WHERE metric_name = 'DB Time Per Second' -- not "DB Time Per Second", should the following metric_name "Database Time Per Sec".
     WHERE metric_name = 'Database Time Per Sec'
     ORDER BY snap_id
   ),
dhos AS (
          SELECT snap_id
               , dbid
               , instance_number
               , stat_name
               , value
          FROM dba_hist_osstat
          WHERE stat_name = 'NUM_CPUS'
        )
SELECT *
FROM (
       SELECT LAG(aas.snap_id, 1, 0) OVER(PARTITION BY aas.dbid, aas.instance_number ORDER BY aas.snap_id) first_snap_id
            , aas.snap_id second_snap_id
            , aas.begin_time
            , aas.end_time
            , ROUND(aas.average_active_sessions/dhos.value*100, 2) || '%' cpu_load
       FROM aas
          , dhos
       WHERE aas.snap_id = dhos.snap_id
       AND   aas.instance_number = dhos.instance_number
       AND   aas.dbid = dhos.dbid
     )
WHERE first_snap_id <> 0
;
