REM
REM     Script:        acquire_tps.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 22, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       We can acquire "Transactions Per Second" (abbr TPS) from the AWR report that locates between 
REM       the begin snapshot and end one, if we wanna look at the "TPS" from all of the AWR reports it's 
REM       unnecessary to generate one by one. Hence it's the reason why I wrote this SQL Script.
REM
REM       You know, there saves the value of "user commits" and "user rollbacks" in each of snap_id of 
REM       the view DBA_HIST_SYSSTAT (adding them can get the value of "Transactions") but which is 
REM       from the oracle instance starts up to that snap_id, here we have to use the analytic function 
REM       "LAG () OVER()" to get the prior value of prior snap_id then current vlaue of current snap_id 
REM       subtracts the prior one we can get the real "Transactions" between these two snap_id, then 
REM       "Transactions" divides by the spending time (calculate it by seconds) between the prior snap_id 
REM       and the current snap_id. Ultimately we can get the "tps".
REM
REM       In addition to the begin_interval_time and end_interval_time are in the view DBA_HIST_SNAPSHOT 
REM       we're able to (inner) join the view DBA_HIST_SNAPSHOT and DBA_HIST_SYSSTAT in order to get 
REM       begin_time and end_time of a snap_id.
REM
REM       SET LINESIZE 80
REM       DESC acquire_awr_tps
REM        Name                                      Null?    Type
REM        ----------------------------------------- -------- ----------------------------
REM        INSTANCE_NUMBER                           NOT NULL NUMBER
REM        FIRST_SNAP_ID                             NOT NULL NUMBER
REM        SECOND_SNAP_ID                            NOT NULL NUMBER
REM        BEGIN_TIME                                NOT NULL DATE
REM        END_TIME                                  NOT NULL DATE
REM        STAT_NAME                                 NOT NULL VARCHAR2(25)
REM        AWR_TPS                                            NUMBER
REM
REM     References:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYSSTAT.html#GUID-C94C6E6D-3FB0-4A81-A350-A1F312CDFEBB
REM       https://www.modb.pro/db/63660
REM

SET LINESIZE 200
SET PAGESIZE 200

COLUMN begin_time FORMAT a19
COLUMN end_time   FORMAT a19
COLUMN stat_name  FORMAT a25
COLUMN awr_tps    FORMAT 999,999,999.99

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
dhst AS ( 
          SELECT snap_id
               , dbid
               , instance_number
               , SUM(value) value
          FROM dba_hist_sysstat
          WHERE stat_name IN ('user commits', 'user rollbacks')
          GROUP BY snap_id
                 , dbid
                 , instance_number
        ),
all_awr_tps AS (
                 SELECT dhsp.instance_number
                      , LAG(dhsp.snap_id, 1, 0) OVER (PARTITION BY dhsp.dbid, dhsp.instance_number ORDER BY dhsp.snap_id) first_snap_id
                      , dhsp.snap_id second_snap_id
                      , CAST(dhsp.begin_interval_time AS DATE) begin_time
                      , CAST(dhsp.end_interval_time AS DATE) end_time
                      , 'user commits/rollbacks' stat_name
                      , ROUND((dhst.value-LAG(dhst.value, 1, 0) OVER (PARTITION BY dhst.dbid, dhst.instance_number ORDER BY dhst.snap_id)), 2) transactions
                      , (CAST(dhsp.end_interval_time AS DATE)-CAST(dhsp.begin_interval_time AS DATE))*24*36e2 interval_secs
                 FROM dhsp
                    , dhst
                 WHERE dhsp.snap_id = dhst.snap_id
                 AND   dhsp.instance_number = dhst.instance_number
                 AND   dhsp.dbid = dhst.dbid
                 ORDER BY dhsp.instance_number
                        , first_snap_id
               )
SELECT instance_number
     , first_snap_id
     , second_snap_id
     , begin_time
     , end_time
     , stat_name
     , ROUND(transactions/interval_secs, 2) awr_tps
FROM all_awr_tps
WHERE first_snap_id <> 0
;

or

WITH 
dhsp AS (
          SELECT snap_id
               , dbid
               , instance_number
               , begin_interval_time
               , end_interval_time
          FROM dba_hist_snapshot
        ),
dhst AS ( 
          SELECT snap_id
               , dbid
               , instance_number
               , SUM(value) value
          FROM dba_hist_sysstat
          WHERE stat_name IN ('user commits', 'user rollbacks')
          GROUP BY snap_id
                 , dbid
                 , instance_number
        ),
all_awr_tps AS (
                 SELECT dhsp.instance_number
                      , LAG(dhsp.snap_id, 1, 0) OVER (PARTITION BY dhsp.dbid, dhsp.instance_number ORDER BY dhsp.snap_id) first_snap_id
                      , dhsp.snap_id second_snap_id
                      , CAST(dhsp.begin_interval_time AS DATE) begin_time
                      , CAST(dhsp.end_interval_time AS DATE) end_time
                      , 'user commits/rollbacks' stat_name
                      , ROUND((dhst.value-LAG(dhst.value, 1, 0) OVER (PARTITION BY dhst.dbid, dhst.instance_number ORDER BY dhst.snap_id)), 2) transactions
                   -- , (CAST(dhsp.end_interval_time AS DATE)-CAST(dhsp.begin_interval_time AS DATE))*24*36e2 interval_seconds
                      , EXTRACT(HOUR FROM (dhsp.end_interval_time - dhsp.begin_interval_time))*36e2 + EXTRACT(MINUTE FROM (dhsp.end_interval_time - dhsp.begin_interval_time))*6e1 + EXTRACT(SECOND FROM (dhsp.end_interval_time - dhsp.begin_interval_time)) interval_secs
                 FROM dhsp
                    , dhst
                 WHERE dhsp.snap_id = dhst.snap_id
                 AND   dhsp.instance_number = dhst.instance_number
                 AND   dhsp.dbid = dhst.dbid
                 ORDER BY dhsp.instance_number
                        , first_snap_id
               )
SELECT instance_number
     , first_snap_id
     , second_snap_id
     , begin_time
     , end_time
     , stat_name
     , ROUND(transactions/interval_secs, 2) awr_tps
FROM all_awr_tps
WHERE first_snap_id <> 0
;
