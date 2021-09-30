REM
REM     Script:        acquire_aas.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 24, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       We can get "DB time" based on the acquire_dbtime.sql 
REM       (https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_dbtime.sql),
REM       we can also get "interval seconds" between the current snap_id and the prior snap_id,
REM       so aas (average active sessions) equals "DB time" divided by "interval seconds".
REM
REM       SET LINESIZE 80
REM       DESC acquire_awr_aas
REM        Name                                      Null?    Type
REM        ----------------------------------------- -------- ----------------------------
REM        INSTANCE_NUMBER                           NOT NULL NUMBER
REM        FIRST_SNAP_ID                             NOT NULL NUMBER
REM        SECOND_SNAP_ID                            NOT NULL NUMBER
REM        BEGIN_TIME                                NOT NULL DATE
REM        END_TIME                                  NOT NULL DATE
REM        AWR_AAS                                            NUMBER
REM

SET LINESIZE 200
SET PAGESIZE 200

COLUMN begin_time FORMAT a19
COLUMN end_time   FORMAT a19
COLUMN awr_aas    FORMAT 999,999.99

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
all_awr_aas AS (
                 SELECT dhsp.instance_number
                      , LAG(dhsp.snap_id, 1, 0) OVER (PARTITION BY dhsp.dbid, dhsp.instance_number ORDER BY dhsp.snap_id) first_snap_id
                      , dhsp.snap_id second_snap_id
                      , CAST(dhsp.begin_interval_time AS DATE) begin_time
                      , CAST(dhsp.end_interval_time AS DATE) end_time
                      , dhstm.stat_name
                      , (dhstm.value - LAG(dhstm.value, 1, 0) OVER (PARTITION BY dhstm.dbid, dhstm.instance_number ORDER BY dhstm.snap_id))/1e6 dbtime_secs
                      , (CAST(dhsp.end_interval_time AS DATE) - CAST(dhsp.begin_interval_time AS DATE))*24*36e2 interval_secs
                 FROM dhsp
                    , dhstm
                 WHERE dhsp.snap_id = dhstm.snap_id
                 AND   dhsp.instance_number = dhstm.instance_number
                 AND   dhsp.dbid = dhstm.dbid
                 ORDER BY dhsp.instance_number
                        , first_snap_id
               )
SELECT instance_number
     , first_snap_id
     , second_snap_id
     , begin_time
     , end_time
     , ROUND(dbtime_secs/interval_secs, 2) awr_aas
FROM all_awr_aas
WHERE first_snap_id <> 0
;
